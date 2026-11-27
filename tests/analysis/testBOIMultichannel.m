function tests=testBOIMultichannel
tests=functiontests(localfunctions);
end
function setupOnce(~)
setupOxygenDynamicsPath;
end

function [o,d,files,root]=fixture()
root=tempname; mkdir(root); src=fullfile(root,'input'); mkdir(src);
files=fullfile(string(src),["a.tif","b.tif"]); n=12;
a=100*ones(4,4,n,'uint16'); b=200*ones(4,4,n,'uint16');
for k=1:n
    x=a(:,:,k); y=b(:,:,k);
    if k>=4 && k<=6, x(1:2)=70; end
    if k==5, x(1:2)=60; end
    if k==5, y(1:2)=180; end
    if k==6, y(1:2)=120; end
    if k==9, y(1)=140; end
    if k==8, x(5)=65; y(5)=195; end
    if k==1, imwrite(x,files(1)); imwrite(y,files(2));
    else, imwrite(x,files(1),'WriteMode','append'); imwrite(y,files(2),'WriteMode','append'); end
    a(:,:,k)=x; b(:,:,k)=y;
end
o=struct('RecordingID',"constructed",'Mode',"dual-bli",'Sensors',["GeNL","Antares"], ...
    'Promoters',["GFAP","GFAP"],'RawFiles',files,'DenoisedFiles',["",""],'SampleHz',1,'PixelSizeUm',2, ...
    'AlignedAndSynchronized',true,'OutputFolder',fullfile(root,'new'));
o=prepareBOIMultichannel(o);
d={makeEvidence(a,{[1;2];5},[4;8],[6;8],[0.4;0.35]), ...
   makeEvidence(b,{[1;2];1},[5;9],[6;9],[0.4;0.3])};
end

function d=makeEvidence(movie,px,start,last,amplitude)
n=numel(start); sign=repmat("sink",n,1); id=(1:n)'; baseline=repmat(2,n,1);
d.Audit=table(sign,id,ones(n,1),start,last,start,last,amplitude,repmat("valid",n,1),cellfun(@numel,px),baseline, ...
    'VariableNames',{'EventType','SiteID','EventID','StartFrame','EndFrame','DetectedStartFrame', ...
    'DetectedEndFrame','StoredAmplitude','StoredStatus','FootprintPixels','BaselineWindowFrames'});
d.Sinks=table(repmat("immediate_pre_event",n,1),repmat("available",n,1),false(n,1), ...
    start-2,start-1,baseline,amplitude<0,100*amplitude,'VariableNames', ...
    {'EventReferenceKind','EventReferenceStatus','EventReferenceNeedsReview','EventReferenceStartFrame', ...
    'EventReferenceEndFrame','EventReferenceFiniteSamples','EventAmplitudeNegative','Depth'});
d.Audit.StoredAmplitude(:)=NaN; % The strict sink amplitude is never the paired source.
flat=reshape(double(movie),[],size(movie,3)); d.Traces=cell(n,1); d.Native=cell(n,1);
for j=1:n
    d.Traces{j}=struct('Footprint',px{j},'Raw',mean(flat(px{j},:),1),'CleanBaselineFrames',start(j)-2:start(j)-1);
    d.Native{j}=repmat(px(j),last(j)-start(j)+1,1);
end
d.MeanArea=cellfun(@numel,px)*4;
d.AnalysisInfo=struct('SinkEligibleTissuePixels',(1:16)','SurgeEligibleTissuePixels',(1:16)');
end

function testKnownLagDelayedAndSplit(t)
[o,d,f,r]=fixture(); clean=onCleanup(@()rmdir(r,'s'));
p=buildBOIMultichannelResult(o,d,f);
verifyEqual(t,p.Summary.IndependentCount,[2;0;2;0]);
verifyEqual(t,height(p.Links),2); verifyEqual(t,p.Links.EventRowA,[1;1]);
verifyEqual(t,p.Links.OnsetLagSec_BminusA,[1;5]); verifyEqual(t,p.Links.MinimumLagSec_BminusA,[1;4]);
verifyEqual(t,p.Links.FramesWithCoincidentPixels,[2;0]); verifyEqual(t,p.Links.GapSec,[0;2]);
verifyEqual(t,p.Links.FootprintJaccard,[1;0.5]); verifyEqual(t,p.Events.DurationSec(1),3);
verifyEqual(t,p.Events.MeanNativeAreaUm2(1),8); verifyEqual(t,p.Events.OpticalDepthOrRisePct(1),40);
verifyEqual(t,p.Summary.FullyInsideRatePerMm2Min(1),2*60e6/(64*12));
verifyEqual(t,p.RawB(2,8),195); verifyFalse(t,any(p.Links.EventRowA==2));
verifyEqual(t,p.Events.ChangeAtAnchorExtremePctB(3:4),-p.Events.OpticalDepthOrRisePct(3:4),'AbsTol',1e-12);
verifyEqual(t,p.Comparisons.DeltaMeanDepthOrRisePct(1),-2.5,'AbsTol',1e-12);
verifyEqual(t,p.RawA(3,5),60); verifyEqual(t,p.RawB(3,5),180);
end

function testFluorescenceOnOxygenFootprintAndMissingReference(t)
[o,d,f,r]=fixture(); clean=onCleanup(@()rmdir(r,'s'));
o.Mode="bli-fluorescence"; o.Sensors(2)="Calcium"; d{2}=[];
d{1}.Sinks.Depth(2)=NaN;
d{1}.Sinks.EventReferenceNeedsReview(2)=true;
d{1}.Sinks.EventReferenceStatus(2)="missing_required_event_signal";
p=buildBOIMultichannelResult(o,d,f);
verifyEmpty(t,p.Links); verifyEmpty(t,p.Comparisons); verifyTrue(t,all(p.Events.Channel==1));
verifyEqual(t,p.Events.ReferenceMeanB(1),200);
verifyEqual(t,p.Events.ChangeAtAnchorExtremePctB(1),-10,'AbsTol',1e-10);
verifyEqual(t,p.Events.MeanChangePctB(1),-100/6,'AbsTol',1e-10);
verifyEqual(t,100*(p.RawB(1,6)/p.Events.ReferenceMeanB(1)-1),-40,'AbsTol',1e-10);
changes={'MeanChangePctA','MeanChangePctB','ChangeAtAnchorExtremePctA','ChangeAtAnchorExtremePctB'};
verifyTrue(t,all(isnan(p.Events{2,changes}))); verifyEqual(t,p.Summary.FlaggedSinkReferenceCount(1),1);
verifyTrue(t,isnan(p.Events.ReferenceMeanB(2))); verifyEqual(t,p.RawB(2,8),195);
end

function testCommonAreaAndReciprocalPromoters(t)
[o,d,f,r]=fixture(); clean=onCleanup(@()rmdir(r,'s'));
o.Promoters=["GFAP","hSyn"]; d{2}.AnalysisInfo.SinkEligibleTissuePixels=[1;5];
p=buildBOIMultichannelResult(o,d,f); s=p.Summary(1,:);
verifyEqual(t,[s.CommonTissueAreaUm2,s.FullyInsideCount,s.CrossesBoundaryCount],[8,1,1]);
verifyEqual(t,p.Comparisons.FirstPromoter(1),"hSyn"); verifyEqual(t,p.Comparisons.SecondPromoter(1),"GFAP");
verifyEqual(t,p.Comparisons.DeltaMedianDurationSec(1),0.5);
end

function testNoDetections(t)
[o,d,f,r]=fixture(); clean=onCleanup(@()rmdir(r,'s'));
for c=1:2
    d{c}.Sinks=d{c}.Sinks([],:); d{c}.Audit=d{c}.Audit([],:); d{c}.Traces=cell(0,1); d{c}.Native=cell(0,1); d{c}.MeanArea=zeros(0,1);
end
p=buildBOIMultichannelResult(o,d,f);
verifyEmpty(t,p.Events); verifyEmpty(t,p.Links);
verifyEqual(t,p.Summary.IndependentCount,zeros(4,1));
verifyTrue(t,all(isnan(p.Summary.MedianDepthOrRisePct)));
end

function testInputValidation(t)
[o,~,f,r]=fixture(); clean=onCleanup(@()rmdir(r,'s'));
o.AlignedAndSynchronized=false; verifyError(t,@()prepareBOIMultichannel(o),'BOIPair:Synchronization');
o.AlignedAndSynchronized=true; o.RawFiles=[f(1),f(1)]; verifyError(t,@()prepareBOIMultichannel(o),'BOIPair:Duplicate');
o.RawFiles=f; short=fullfile(r,'input','short.tif'); imwrite(ones(4,'uint16'),short);
o.DenoisedFiles(1)=short; verifyError(t,@()prepareBOIMultichannel(o),'BOIPair:Movie');
imwrite(ones(4,'uint16'),short,'WriteMode','append'); verifyError(t,@()prepareBOIMultichannel(o),'BOIPair:Grid');
end

function testImportAndSelection(t)
r=tempname; mkdir(r); clean=onCleanup(@()rmdir(r,'s')); folder=fullfile(r,'FB25047_2'); mkdir(folder);
s=["TCA_aligned_Camera1_native_GFAP-GeNL","TCA_aligned_Camera2_warped_hSyn-Antares"];
for stem=s
    for suffix=[".tif","_coupledMC.tif","_coupledMC_denoised.tif"]
        imwrite(ones(2,'uint16'),fullfile(folder,stem+suffix));
    end
end
csv=fullfile(r,'pairs.csv');
writetable(table(repmat("old/path/FB25047_49",2,1),["hSyn-Antares";"GFAP-GeNL"],[1;1],[2.35;2.35], ...
    'VariableNames',{'Paths','Sensor_Promoter','SampleF','Pixelsize'}),csv);
list=importBOIMultichannelCSV(csv); o=list{1};
verifyEqual(t,o.RecordingID,"FB25049"); verifyEqual(t,o.Promoters,["GFAP","hSyn"]);
verifyTrue(t,all(endsWith(o.RawFiles,"_coupledMC.tif"))); verifyTrue(t,all(endsWith(o.DenoisedFiles,"_coupledMC_denoised.tif")));
end

function testFollowLiveLegacyProgress(t)
root=tempname; mkdir(root); cleanup=onCleanup(@()rmdir(root,'s'));
pairFile=fullfile(root,'PairStatus.json');
childFolder=fullfile(root,'Runs','Channel2'); mkdir(childFolder);
childFile=fullfile(childFolder,'RunStatus.json');
pair=struct('Status','running','Stage','RC1 channel 2 (Antares)');
child=struct('Status','running','Stage','analysis');
writeBOIRunJSON(childFile,child); writeBOIRunJSON(pairFile,pair);
fig=openBOIMultichannelProgress(root,'Example');
closeFigure=onCleanup(@()delete(fig));
label=findobj(fig,'Tag','PairStage');
verifyTrue(t,contains(label.Text,'Channel B (Antares)') && contains(label.Text,'sinks and surges'));
child.Stage='statistics'; writeBOIRunJSON(childFile,child);
verifyTrue(t,waitForStage(label,'statistics'));
pair.Stage='paired measurements'; writeBOIRunJSON(pairFile,pair);
verifyTrue(t,waitForStage(label,'Comparing the channels'));
pair.Status='complete'; pair.Stage='complete'; writeBOIRunJSON(pairFile,pair);
verifyTrue(t,waitForStage(label,'Paired results saved'));
end

function testFollowFailedPair(t)
root=tempname; mkdir(root); cleanup=onCleanup(@()rmdir(root,'s'));
pair=struct('Status','failed','Stage','writing workbook','Error','Example error');
writeBOIRunJSON(fullfile(root,'PairStatus.json'),pair);
fig=openBOIMultichannelProgress(root,'Example'); closeFigure=onCleanup(@()delete(fig));
label=findobj(fig,'Tag','PairStage');
verifyTrue(t,contains(label.Text,'Failed') && contains(label.Text,'Example error'));
end

function yes=waitForStage(label,fragment)
clock=tic;
while ~contains(label.Text,fragment) && toc(clock)<8
    pause(0.1);
end
yes=contains(label.Text,fragment);
end

function testFolderAndFluorescenceCSV(t)
root=tempname; mkdir(root); clean=onCleanup(@()rmdir(root,'s'));
folder=fullfile(root,'pair'); mkdir(folder);
for name=["TCA_aligned_Camera1_native_hSyn-GCaMP_coupledMC.tif","TCA_aligned_Camera2_warped_hSyn-GeNL_coupledMC.tif"]
    imwrite(ones(4,'uint16'),fullfile(folder,name));
end
file=fullfile(root,'folder.csv');
list=table("pair",1,2.35,"GCaMP",'VariableNames',{'Paths','SampleF','Pixelsize','SensorB'});
writetable(list,file);
pairs=importBOIMultichannelCSV(file,'bli-fluorescence'); o=pairs{1};
verifyEqual(t,o.Sensors,["GeNL","GCaMP"]); verifyTrue(t,contains(o.RawFiles(1),"Camera2"));
verifyEqual(t,o.Promoters,["unspecified","unspecified"]); verifyEqual(t,o.Mode,"bli-fluorescence");
list=table(["pair";"pair"],["hSyn-GCaMP";"GFAP-OtherOxygen"],["B";"A"],[1;1],[2.35;2.35], ...
    ["fl.tif";"ox.tif"],'VariableNames',{'Paths','Sensor_Promoter','Channel','SampleF','Pixelsize','RawFile'});
writetable(list,file);
pairs=importBOIMultichannelCSV(file,'bli-fluorescence'); o=pairs{1};
verifyEqual(t,o.Sensors,["OtherOxygen","GCaMP"]); verifyEqual(t,o.RawFiles,fullfile(string(folder),["ox.tif","fl.tif"]));
list.Channel(1)="A"; writetable(list,file);
verifyError(t,@()importBOIMultichannelCSV(file,'bli-fluorescence'),'BOIPair:CSV');
end

function testBatchRecoveryAndSelection(t)
root=tempname; mkdir(root); clean=onCleanup(@()rmdir(root,'s'));
file=fullfile(root,'recordings.csv');
ids=["0001";"0002";"0003"];
list=table(ids,repmat("dual-bli",3,1),repmat("GeNL",3,1),repmat("Antares",3,1), ...
    repmat("hSyn",3,1),repmat("hSyn",3,1),ones(3,1),ones(3,1)*2.35, ...
    repmat("o.tif",3,1),repmat("b.tif",3,1),[true;true;false], ...
    'VariableNames',{'RecordingID','Mode','SensorA','SensorB','PromoterA','PromoterB','SampleHz','PixelSizeUm','RawA','RawB','Include'});
writetable(list,file); hash=oxygenFileSHA256(file); rows=boiPairQueueTable(importBOIMultichannelCSV(file));
verifyEqual(t,rows.RecordingID,ids); verifyEqual(t,rows.RawA(1),string(fullfile(root,'o.tif')));
out=fullfile(root,'batch');
verifyError(t,@()runBOIMultichannelBatch(rows,out,false),'BOIPair:Synchronization'); verifyFalse(t,isfolder(out));
dupes=rows; dupes.RecordingID(2)=ids(1);
verifyError(t,@()runBOIMultichannelBatch(dupes,out,true),'BOIPair:Identity'); verifyFalse(t,isfolder(out));
stop=false; [done,book]=runBOIMultichannelBatch(rows,out,true,@afterFail,@shouldStop);
verifyEqual(t,done.Status,["Failed";"Queued";""]); verifyEqual(t,book,"");
verifyEqual(t,done.Include,rows.Include); verifyEqual(t,string(oxygenFileSHA256(file)),string(hash));
again=boiPairQueueTable(importBOIMultichannelCSV(fullfile(out,'Queue.csv')));
verifyEqual(t,again,done); verifyError(t,@()runBOIMultichannelBatch(rows,out,true),'BOIPair:Destination');
    function afterFail(~,~,current)
        if any(current.Status=="Failed"), stop=true; end
    end
    function yes=shouldStop()
        yes=stop;
    end
end

function testSummaryMeansAndMissingness(t)
[o,d,f,r]=fixture(); clean=onCleanup(@()rmdir(r,'s'));
d{1}.Sinks.Depth(1)=NaN;
p=buildBOIMultichannelResult(o,d,f); s=p.Summary(1,:);
verifyEqual(t,[s.MeanDurationSec s.MeanAreaUm2 s.MeanDepthOrRisePct],[2 6 35]);
verifyEqual(t,s.AvailableDepthCount,1); verifyTrue(t,isnan(p.Summary.MeanAreaUm2(2)));
end

function testBatchModeEditClearsPreviousB(t)
root=tempname; mkdir(root); clean=onCleanup(@()rmdir(root,'s'));
csv=fullfile(root,'one.csv');
writetable(table("one",1,2.35,"GeNL","Antares","a.tif","b.tif", ...
    'VariableNames',{'Paths','SampleF','Pixelsize','SensorA','SensorB','RawA','RawB'}),csv);
fig=openBOIMultichannelBatch(csv); close=onCleanup(@()delete(fig)); sheet=findobj(fig,'Tag','PairBatchRows');
data=sheet.Data; raw=data.RawA; verifyEqual(t,data.SensorB,"Antares");
data.Mode(1)='bli-fluorescence'; sheet.Data=data;
idx=find(strcmp('Mode',data.Properties.VariableNames));
sheet.CellEditCallback(sheet,struct('Indices',[1 idx],'Error',''));
verifyEqual(t,string(sheet.Data.Mode),"bli-fluorescence"); verifyEqual(t,sheet.Data.RawA,raw);
verifyEqual(t,sheet.Data.RawB,""); verifyEqual(t,sheet.Data.SensorB,"");
verifyEqual(t,string(findobj(fig,'Text','Run included recordings…').Enable),"off");
end

function testCheckRescansIncludedBlankMovies(t)
root=tempname; mkdir(root); clean=onCleanup(@()rmdir(root,'s'));
folder=fullfile(root,'pair'); mkdir(folder); csv=fullfile(root,'pairs.csv');
list=table(["pair";"pair"],["hSyn-GeNL";"hSyn-Antares"],[1;1],[2.35;2.35], ...
    'VariableNames',{'Paths','Sensor_Promoter','SampleF','Pixelsize'});
writetable(list,csv);
fig=openBOIMultichannelBatch(csv); close=onCleanup(@()delete(fig));
sheet=findobj(fig,'Tag','PairBatchRows'); check=findobj(fig,'Text','Check included rows');
verifyEqual(t,[sheet.Data.RawA sheet.Data.RawB],["",""]);
stems=["TCA_aligned_Camera2_GeNL","TCA_aligned_Camera1_Antares"];
for stem=stems
    for suffix=[".tif","_coupledMC.tif"]
        file=fullfile(folder,stem+suffix);
        imwrite(ones(4,'uint16'),file); imwrite(ones(4,'uint16'),file,'WriteMode','append');
    end
end
sync=findobj(fig,'Type','uicheckbox'); sync.Value=true;
check.ButtonPushedFcn([],[]);
expected=fullfile(string(folder),stems+"_coupledMC.tif");
verifyEqual(t,[sheet.Data.RawA sheet.Data.RawB],expected);
verifyFalse(t,sync.Value); verifyTrue(t,startsWith(sheet.Data.Message,"Input check passed"));
% A manually selected plain aligned A constrains discovery of its missing B.
setCell('RawA',fullfile(string(folder),stems(1)+".tif")); setCell('RawB',"");
check.ButtonPushedFcn([],[]);
verifyEqual(t,[sheet.Data.RawA sheet.Data.RawB],fullfile(string(folder),stems+".tif"));
setCell('RawA',""); setCell('RawB',""); setCell('Include',false);
check.ButtonPushedFcn([],[]); verifyEqual(t,[sheet.Data.RawA sheet.Data.RawB],["",""]);
setCell('Include',true); setCell('SensorB',"GeNL");
check.ButtonPushedFcn([],[]); verifyEqual(t,[sheet.Data.RawA sheet.Data.RawB],["",""]);
    function setCell(key,v)
        d=sheet.Data; col=find(strcmp(key,d.Properties.VariableNames)); d.(key)(1)=v; sheet.Data=d;
        sheet.CellEditCallback(sheet,struct('Indices',[1 col],'Error',''));
    end
end

function testSurgeKeepsStrictReference(t)
[o,d,f,r]=fixture(); clean=onCleanup(@()rmdir(r,'s'));
d{1}.Audit.EventType(:)="surge"; d{1}.Sinks=d{1}.Sinks([],:);
d{1}.Audit.StoredAmplitude=[-0.3;NaN]; d{1}.Audit.StoredStatus(2)="insufficient_clean_prebaseline";
d{1}.Traces{2}.CleanBaselineFrames=7;
p=buildBOIMultichannelResult(o,d,f); g=p.Events(1:2,:);
verifyEqual(t,g.OpticalDepthOrRisePct,[-30;NaN]);
verifyEqual(t,g.RC1ReferenceStatus,d{1}.Audit.StoredStatus);
verifyEqual(t,g.ChangeAtAnchorExtremePctA,[-30;NaN],'AbsTol',1e-12);
verifyEqual(t,p.ReferenceFrames(1:2),{2:3;7});
end

function testEarlierPairRequiresRerun(t)
root=tempname; mkdir(root); clean=onCleanup(@()rmdir(root,'s'));
Pair=struct('Schema','boi-multichannel-1'); file=fullfile(root,'Multichannel.mat'); save(file,'Pair');
writeBOIRunJSON(fullfile(root,'PairStatus.json'),struct('Status','complete','ResultSHA256',oxygenFileSHA256(file)));
try
    loadBOIMultichannel(file);
    verifyFail(t,'Earlier paired schema was accepted.');
catch err
    verifyEqual(t,err.identifier,'BOIPair:Schema'); verifySubstring(t,err.message,'Rerun the pair');
end
end

function testSingleAndPairedSinkDepth(t)
root=tempname; mkdir(root); clean=onCleanup(@()rmdir(root,'s'));
[raw,detection,peer]=pairDepthMovies(root);
single=struct('RecordingFolder',fileparts(raw),'OutputFolder',fullfile(root,'alone'), ...
    'SampleHz',1,'PixelSizeUm',2,'SupportProfile','whole-image','Mouse','fixture','Promoter','hSyn');
run=runBOIRecordingWorkflow(prepareBOIRecordingRequest(single));
master=load(run.Paths.SinkMaster,'Table_OxygenSinkEvents_Out');
saved=sortrows(master.Table_OxygenSinkEvents_Out,{'SinkID','EventID'});
[~,compact]=prepareBOICompactWorkbook(run.Paths.DataOutput,{},fullfile(root,'compact.xlsx'));
automatic=compact.Data.Events(compact.Data.Events.EventType=="sink",:);
automatic.SiteID=str2double(automatic.SiteID); automatic.EventIndex=str2double(automatic.EventIndex);
automatic=sortrows(automatic,{'SiteID','EventIndex'});
record=compact.Data.Recordings(compact.Data.Recordings.EventType=="sink",:);
stats=load(run.Paths.DataOutput,'HypoxicBurden');

pairFolder=fullfile(root,'pair');
o=struct('RecordingID',"fixture",'Mode',"bli-fluorescence",'Sensors',["GeNL","Calcium"], ...
    'Promoters',["hSyn","hSyn"],'RawFiles',string({raw,peer}),'DenoisedFiles',[string(detection),""], ...
    'SampleHz',1,'PixelSizeUm',2,'AlignedAndSynchronized',true,'OutputFolder',pairFolder);
runBOIMultichannel(o); p=loadBOIMultichannel(pairFolder);
verifyEqual(t,p.Schema,'boi-multichannel-2');
e=sortrows(p.Events(p.Events.Sign=="sink" & p.Events.Channel==1,:),{'SiteID','EventID'});
assertEqual(t,[e.SiteID e.EventID],[saved.SinkID saved.EventID]);
assertEqual(t,[e.SiteID e.EventID],[automatic.SiteID automatic.EventIndex]);
verifyEqual(t,[e.StartFrame e.EndFrame e.DurationSec e.MeanNativeAreaUm2 e.OpticalDepthOrRisePct], ...
    [automatic.AutomaticStartFrame automatic.AutomaticEndFrame automatic.AutomaticDuration_sec ...
    automatic.AutomaticMeanArea_um2 automatic.AutomaticAmplitudePercent]);
verifyEqual(t,e.ReferenceKind,saved.EventReferenceKind);
verifyEqual(t,e.RC1ReferenceStatus,saved.EventReferenceStatus);
verifyEqual(t,e.SinkReferenceNeedsReview,saved.EventReferenceNeedsReview);
verifyEqual(t,e.ReferenceStartFrame,saved.EventReferenceStartFrame);
verifyEqual(t,e.ReferenceEndFrame,saved.EventReferenceEndFrame);
verifyEqual(t,e.ReferenceSamples,saved.EventReferenceFiniteSamples);
verifyEqual(t,e.NegativeSinkDepth,saved.EventAmplitudeNegative);
verifyTrue(t,any(saved.EventReferenceStatus=="available" & ~saved.EventAmplitudeNegative));
verifyTrue(t,any(saved.EventReferenceOverlapping & saved.EventAmplitudeAvailable));
verifyTrue(t,any(saved.NativeStartFrame==1 & saved.EventReferencePostEvent & saved.EventAmplitudeAvailable));
verifyTrue(t,any(saved.EventAmplitudeNegative));
for k=1:height(e)
    ref=saved.EventReferenceStartFrame(k):saved.EventReferenceEndFrame(k);
    verifyEqual(t,p.ReferenceFrames{e.EventRow(k)},ref);
    % The peer movie is spatially uniform with a known intensity at every frame.
    reference=mean(800+ref);
    verifyEqual(t,e.ReferenceMeanB(k),reference);
    verifyEqual(t,e.MeanChangePctB(k),100*(mean(800+(e.StartFrame(k):e.EndFrame(k)))/reference-1),'AbsTol',1e-12);
    verifyEqual(t,e.ChangeAtAnchorExtremePctB(k),100*((800+e.ExtremeFrame(k))/reference-1),'AbsTol',1e-12);
end
verifyEqual(t,e.ChangeAtAnchorExtremePctA,-e.OpticalDepthOrRisePct,'AbsTol',1e-12);
s=p.Summary(p.Summary.Sign=="sink",:);
verifyEqual(t,s.IndependentRatePerMm2Min,record.AutomaticEventRate_per_mm2_per_min,'RelTol',1e-12);
verifyEqual(t,s.MeanDepthOrRisePct,stats.HypoxicBurden.RecordingTable.MeanBurdenAmplitudePercent,'AbsTol',1e-12);
verifyEqual(t,s.MedianDepthOrRisePct,median(automatic.AutomaticAmplitudePercent,'omitnan'),'AbsTol',1e-12);
verifyEqual(t,[s.AvailableDepthCount s.FlaggedSinkReferenceCount s.NegativeSinkDepthCount], ...
    [nnz(saved.EventAmplitudeAvailable) nnz(saved.EventReferenceNeedsReview) nnz(saved.EventAmplitudeNegative)]);

combined=fullfile(root,'combined.xlsx');
exportBOIMultichannelComparison(pairFolder,combined);
for book=[string(fullfile(pairFolder,'Multichannel.xlsx')),string(combined)]
    sheet=sortrows(readtable(book,'Sheet','Sinks','TextType','string'),{'SiteID','EventID'});
    verifyEqual(t,sheet.OpticalDepthOrRisePct,e.OpticalDepthOrRisePct,'AbsTol',1e-12);
    verifyEqual(t,sheet.ReferenceKind,e.ReferenceKind);
    verifyEqual(t,logical(sheet.SinkReferenceNeedsReview),e.SinkReferenceNeedsReview);
    verifyEqual(t,logical(sheet.NegativeSinkDepth),e.NegativeSinkDepth);
end
end

function [raw,detection,peer]=pairDepthMovies(root)
source=fullfile(root,'oxygen'); mkdir(source);
raw=fullfile(source,'preserved.tif'); detection=fullfile(source,'denoised.tif');
peerFolder=fullfile(root,'fluorescence'); mkdir(peerFolder);
peer=fullfile(peerFolder,'peer.tif');
[x,y]=meshgrid(1:160);
spot=(x-80).^2+(y-80).^2<=14^2;
noise=RandStream('mt19937ar','Seed',16);
for frame=1:112
    active=frame<=9 || (frame>=39 && frame<=47) || (frame>=57 && frame<=66) || (frame>=93 && frame<=101);
    detectFrame=uint16(2000+randi(noise,41,160,160)-21-800*spot*active);
    % A rising raw background makes the last detection a negative signed depth.
    rawFrame=uint16(2000+2*frame-400*spot*(active && frame<90));
    peerFrame=repmat(uint16(800+frame),160,160);
    mode='append'; if frame==1, mode='overwrite'; end
    imwrite(rawFrame,raw,'WriteMode',mode);
    imwrite(detectFrame,detection,'WriteMode',mode);
    imwrite(peerFrame,peer,'WriteMode',mode);
end
end

function testCameraOffsetPreservesNativeOutputs(t)
root=tempname;mkdir(root);t.addTeardown(@()rmdir(root,'s'));
[raw,~,~]=pairDepthMovies(root);
context=createLegacyRecordingContext(1,'fixture','baseline',2,'unknown','hSyn','none',NaN,NaN,NaN,'N');
blank=runOxygenDynamicsMaster(fileparts(raw),context);
context.CameraOffsetCounts=1000;
calibrated=runOxygenDynamicsMaster(fileparts(raw),context);
for kind=["Sink","Surge"]
    if kind=="Sink"
        folder="OxySinksPath"; file="OxygenSinks_Urefined";
    else
        folder="OxySurgesPath"; file="OxygenSurges";
    end
    file=file+blank.DatafileID+".mat";
    a=load(fullfile(blank.OutputFolders.(folder),file));
    b=load(fullfile(calibrated.OutputFolders.(folder),file));
    site="Table_Oxygen"+kind+"s_Out"; event="Table_Oxygen"+kind+"Events_Out";
    amp="NormOxy"+kind+"Amp";
    t.verifyEqual(removevars(a.(site),amp),removevars(b.(site),amp));
    e=a.(event); v=b.(event);
    if kind=="Sink",t.assertGreaterThan(height(e),0);end
    ratios=[amp,amp+"Percent","MeanSignedChangeFraction","SignedTraceAUC_sec", ...
        "EpisodeAmplitudePercent","EventAmplitudePercent","EventReferenceVersion","EpisodeReferenceVersion", ...
        "CameraOffsetCounts","CameraOffsetSource","IntensityRatioDefinition","IntensityRatiosOffsetCorrected","ReferencesAtOrBelowOffset"];
    other=setdiff(string(e.Properties.VariableNames),ratios,'stable');
    t.verifyEqual(e(:,other),v(:,other));
    valid=isfinite(e.(amp));
    t.verifyEqual(v.(amp)(valid),e.(amp)(valid).*e.BaselineValue(valid)./(e.BaselineValue(valid)-1000),'AbsTol',1e-12);
    payload=setdiff(fieldnames(a),{char(site),char(event),'AnalysisInfo'});
    for j=1:numel(payload),t.verifyEqual(a.(payload{j}),b.(payload{j}));end
end
end

function testOffsetForEachChannel(t)
[o,d,f,r]=fixture();t.addTeardown(@()rmdir(r,'s'));
plain=buildBOIMultichannelResult(o,d,f);
o.CameraOffsetCountsA=20; o.CameraOffsetCountsB=100;
p=buildBOIMultichannelResult(o,d,f);
t.verifyEqual(p.Channels.CameraOffsetCounts,[20;100]);
t.verifyEqual(p.Events.ChangeAtAnchorExtremePctA(1),100*(60-100)/80,'AbsTol',1e-12);
t.verifyEqual(p.Events.ChangeAtAnchorExtremePctB(1),100*(180-200)/100,'AbsTol',1e-12);
t.verifyEqual(p.Links,plain.Links);t.verifyEqual(p.RawB,plain.RawB);
o.CameraOffsetCountsB=200;p=buildBOIMultichannelResult(o,d,f);
t.verifyTrue(isnan(p.Events.MeanChangePctB(1)));
t.verifyEqual(p.Events.RatioReferenceStatusB(1),"reference_at_or_below_camera_offset");
t.verifyGreaterThan(p.Channels.ReferencesAtOrBelowOffset(2),0);
end
