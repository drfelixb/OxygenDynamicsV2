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
verifyEqual(t,p.RawA(3,5),60); verifyEqual(t,p.RawB(3,5),180);
end

function testFluorescenceOnOxygenFootprintAndMissingReference(t)
[o,d,f,r]=fixture(); clean=onCleanup(@()rmdir(r,'s'));
o.Mode="bli-fluorescence"; o.Sensors(2)="Calcium"; d{2}=[];
d{1}.Traces{2}.CleanBaselineFrames=[];
p=buildBOIMultichannelResult(o,d,f);
verifyEmpty(t,p.Links); verifyEmpty(t,p.Comparisons); verifyTrue(t,all(p.Events.Channel==1));
verifyEqual(t,p.Events.ReferenceMeanB(1),200);
verifyEqual(t,p.Events.ChangeAtAnchorExtremePctB(1),-10,'AbsTol',1e-10);
verifyEqual(t,p.Events.MeanChangePctB(1),-100/6,'AbsTol',1e-10);
verifyEqual(t,100*(p.RawB(1,6)/p.Events.ReferenceMeanB(1)-1),-40,'AbsTol',1e-10);
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
    d{c}.Audit=d{c}.Audit([],:); d{c}.Traces=cell(0,1); d{c}.Native=cell(0,1); d{c}.MeanArea=zeros(0,1);
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
d{1}.Audit.StoredAmplitude(1)=NaN;
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
