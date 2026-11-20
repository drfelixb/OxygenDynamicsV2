function tests = testAutomaticPocketTraces
tests = functiontests(localfunctions);
end

function setupOnce(t)
setupOxygenDynamicsPath;
root = string(char(java.io.File(tempname).getCanonicalPath()));
mkdir(root);
t.addTeardown(@()rmdir(root,'s'));
[t.TestData.Folder,t.TestData.MissingFile] = fixture(root);
t.TestData.Root = root;
end

function testConflictsAndPartialExport(t)
folder=t.TestData.Folder; parent=string(tempname(t.TestData.Root)); mkdir(parent);
plan=preparePocketNearbyTissue(folder,parent);
r=plan.Rows; missing=r.SourceSHA256(end);
t.verifyEqual(r.BatchMouse(1:2),["001";"copy"]);
t.verifyEqual(r.Mouse(1:2),["";""]);
t.verifyEqual(r.SourceSHA256(1),r.SourceSHA256(2));
t.verifyEqual(r.VerifiedRawFile(end),"");
t.verifyError(@()exportAutomaticPocketTraces(plan,parent,table(),strings(0,1),false),'OxygenDynamics:PocketOmission');
t.verifyError(@()exportAutomaticPocketTraces(plan,parent,table(),missing,false),'OxygenDynamics:PocketIdentity');
decisions=table(r.SourceSHA256(1),"001",'VariableNames',{'SourceSHA256','Mouse'});
out=exportAutomaticPocketTraces(plan,parent,decisions,missing,false);
trace=readPocketTable(fullfile(out,'Trace_exports','All_pocket_traces.csv'));
t.verifyEqual(unique(trace.Condition),["A/B";"A:B"]);
t.verifyEqual(unique(trace.PocketSet),"Automatic");
t.verifyEqual(numel(unique(trace.PocketKey)),4);
t.verifyEqual(trace.FromNativeOffset_s-trace.FromOffset_s,ones(height(trace),1));
t.verifyEqual(trace.FromOnset_s-trace.FromNativeOnset_s,repmat(2,height(trace),1));
t.verifyTrue(all(trace.RecordingFrame(trace.FromOffset_s==0)==26));
t.verifyTrue(all(trace.RecordingFrame(trace.FromNativeOffset_s==0)==25));
t.verifyEqual(trace.PocketRaw(trace.FromOffset_s==1 & trace.Mouse=="001" & trace.Condition=="A/B"),110);
t.verifyEqual(trace.NearRaw(trace.FromOffset_s==1 & trace.Mouse=="001" & trace.Condition=="A/B"),100);
late=readPocketTable(fullfile(out,'condition_001','Windows_by_group.csv'));
late=late(late.Start_s==31 & late.Analysis=="Primary" & late.Group=="All",:);
t.verifyEqual([late.Pockets late.Mice late.PocketPct late.RingPct],[3 2 20 0],'AbsTol',1e-10);
other=readPocketTable(fullfile(out,'condition_002','Windows_by_group.csv'));
t.verifyEqual(other.PocketPct(other.Start_s==31 & other.Analysis=="Primary" & other.Group=="All"),50,'AbsTol',1e-10);
omitted=readPocketTable(fullfile(out,'Omitted_recordings.csv'));
t.verifyEqual(omitted.SourceSHA256,missing);
p=preparePocketNearbyTissue(folder,parent);
t.verifyEqual(p.Rows.Mouse(1:2),["001";"001"]);
t.verifyEqual(p.Rows.VerifiedRawFile(end),"");
end

function testMouseAppearingUnderTwoSensors(t)
parent=string(tempname(t.TestData.Root)); mkdir(parent);
ev=table((1:4)',["A";"A";"B";"A"],["GFAP";"ECS";"GFAP";"GFAP"],ones(4,1), ...
    'VariableNames',{'PocketKey','Mouse','Group','SampleF'});
f=table(ev.PocketKey,zeros(4,1),zeros(4,1),[1;4;12;4],zeros(4,1),zeros(4,1),zeros(4,1), ...
    false(4,1),false(4,1),false(4,1),false(4,1),'VariableNames',{'PocketKey','FromOnset_s','FromOffset_s', ...
    'PocketPct','NearPct','FarPct','TissueOnlyPocketPct','PocketBaselineFlagged','NearPotentialEventDuringBaseline','NearPotentialEvent','AfterNextSameSiteSink'});
nearbySummaries(ev,f,parent,"example");
s=readPocketTable(fullfile(parent,'Aligned_by_group.csv'));
a=s(s.Group=="All" & s.Analysis=="Primary" & s.Alignment=="Offset",:);
t.verifyEqual([a.Mice,a.Pockets,a.PocketPct],[2,4,7.5]);
end

function testLocatedTIFFRequiresDigest(t)
parent=string(tempname(t.TestData.Root)); mkdir(parent);
p=preparePocketNearbyTissue(t.TestData.Folder,parent);
r=p.Rows;
d=table(r.SourceSHA256([1 end]),["001";""],["";r.VerifiedRawFile(1)],'VariableNames',{'SourceSHA256','Mouse','RawFile'});
t.verifyError(@()exportAutomaticPocketTraces(p,parent,d,strings(0,1),false),'OxygenDynamics:PocketSource');
d.RawFile(end)=t.TestData.MissingFile;
out=exportAutomaticPocketTraces(p,parent,d,strings(0,1),false);
m=readPocketTable(fullfile(out,'Recording_sources.csv'));
t.verifyEqual(nnz(m.DistinctSource),4);
t.verifyEqual(m.VerifiedRawFile(end),t.TestData.MissingFile);
empty=readPocketTable(fullfile(out,'condition_003','Pocket_index.csv'));
t.verifyEmpty(empty);
end

function testDifferentDuplicateGeometryIsHeld(t)
parent=string(tempname(t.TestData.Root)); mkdir(parent);
p=preparePocketNearbyTissue(t.TestData.Folder,parent);
audit=p.Rows.AuditFile(2);
s=load(audit);s.Traces{1}.Footprint=s.Traces{1}.Footprint+1;
p.Rows.AuditFile(2)=fullfile(parent,'changed.mat');save(p.Rows.AuditFile(2),'-struct','s');
d=table(p.Rows.SourceSHA256(1),"001",'VariableNames',{'SourceSHA256','Mouse'});
t.verifyError(@()exportAutomaticPocketTraces(p,parent,d,p.Rows.SourceSHA256(end),false),'OxygenDynamics:PocketDuplicate');
t.verifyEmpty(dir(fullfile(parent,'Automatic_PocketTraces_*')));
end

function testEditorOpensAutomaticPreview(t)
[editor,ui]=openBOIBatchEditor();
t.addTeardown(@()delete(editor));
t.verifyEqual(string(ui.PocketTracesButton.Enable),"off");
ui.ReopenStats(t.TestData.Folder);
t.verifyEqual(string(ui.PocketTracesButton.Enable),"on");
callback=ui.PocketTracesButton.ButtonPushedFcn; callback(ui.PocketTracesButton,[]);
t.assertFalse(startsWith(ui.Status.Text,'Needs attention:'),ui.Status.Text);
fig=findall(groot,'Type','figure','Name','Pocket traces | Automatic');
t.assertNumElements(fig,1);
t.addTeardown(@()delete(fig));
grid=findall(fig,'Type','uitable');
t.verifyEqual(grid.Data.BatchMouse,["001";"copy";"002";"001";"003"]);
t.verifyEqual(grid.Data.Mouse(1:2),["";""]);
t.verifyTrue(startsWith(grid.Data.SourceStatus(end),"TIFF unavailable"));
% Locate the synthetic movie, persist the confirmed identity via the same export,
% and replay the reopened editor through its visible controls.
p=preparePocketNearbyTissue(t.TestData.Folder);
d=table(p.Rows.SourceSHA256(1),"001",'VariableNames',{'SourceSHA256','Mouse'});
exportAutomaticPocketTraces(p,t.TestData.Folder,d,p.Rows.SourceSHA256(end),false);
restored=p.Rows.SourcePath(end);
copyfile(t.TestData.MissingFile,restored);t.addTeardown(@()delete(restored));
retry=findall(fig,'Type','uibutton','Text','Retry sources');
retry.ButtonPushedFcn(retry,[]);
t.verifyEqual(grid.Data.Mouse(1:2),["001";"001"]);
t.verifyTrue(all(grid.Data.SourceStatus=="TIFF verified"));
button=findall(fig,'Type','uibutton','Text','Export pocket traces');
button.ButtonPushedFcn(button,[]);
status=findall(fig,'Type','uitextarea');
t.verifyEqual(string(button.Text),"Open results folder",strjoin(string(status.Value),newline));
list=dir(fullfile(t.TestData.Folder,'Automatic_PocketTraces_*','condition_001','Post_offset_signal_by_mouse.png'));
t.verifyNumElements(list,1);

end

function [folder,missingFile]=fixture(root)
folder=fullfile(root,'export');mkdir(folder);stats=fullfile(folder,'statistics');mkdir(stats);
movies=fullfile(root,'movies');mkdir(movies);
amounts=[10 10 30 50 70]; ids="recording-"+(1:5)';
mouse=["001";"copy";"002";"001";"003"]; condition=["A/B";"A/B";"A/B";"A:B";"Empty"];
paths=fullfile(root,ids); rowIDs="row-"+(1:5)'; original=paths;
events=cell(5,1);
for k=1:5
    rec=paths(k);mkdir(rec);mkdir(fullfile(rec,'BOIReview'));
    file=fullfile(rec,'movie.tif');
    [yy,xx]=ndgrid(1:23,1:23); fp=find(xx==12 & yy==12);
    N=88; H=23; W=23; raw=100*ones(N,1);raw(22:26)=90;raw(27:end)=100+amounts(k);
    if k==2
        copyfile(fullfile(paths(1),'movie.tif'),file);
    else
        for frame=1:N
            image=repmat(uint16(100),H,W); image(fp)=raw(frame);
            if frame==1, imwrite(image,file,'Compression','none');
            else, imwrite(image,file,'WriteMode','append','Compression','none'); end
        end
    end
    hash=string(oxygenFileSHA256(file));
    AnalysisInfo=struct('RawFile',file,'RawSHA256',hash,'RecordingID',ids(k),'NFrames',N,'FrameSize',[H W], ...
        'AnalysisParams',struct('fs',1,'PixelSize',3),'SinkEligibleTissuePixels',(1:H*W)');
    count=double(k~=5)+(k==3);
    site=(1:count)'; one=ones(count,1);
    Audit=table(repmat(ids(k),count,1),repmat("sink",count,1),site,one,22*one,26*one,24*one,25*one,one, ...
        20*one,100*one,repmat("ok",count,1),one,one,true(count,1),false(count,1),repmat(hash,count,1), ...
        'VariableNames',{'RecordingID','EventType','SiteID','EventID','StartFrame','EndFrame','DetectedStartFrame','DetectedEndFrame', ...
        'FootprintPixels','BaselineWindowFrames','RecomputedBaseline','RecomputedStatus','StoredAmplitude','RecomputedAmplitude','MeasurementMatches','WrongDirection','SourceRawSHA256'});
    Traces=repmat({struct('Raw',raw,'Footprint',fp,'CleanBaselineFrames',(2:21)','DetectedFrames',(24:25)')},count,1);
    save(fullfile(rec,'BOIReview','event-amplitude-audit.mat'),'AnalysisInfo','Traces','Audit');
    E=Audit(:,{'RecordingID','SiteID','EventID','StartFrame','EndFrame','DetectedStartFrame','DetectedEndFrame'});
    E.Properties.VariableNames([2 6 7])={'SinkID','NativeStartFrame','NativeEndFrame'};
    E.SampleF=one; E.NFrames=N*one; E.EventReferenceRequestedSamples=20*one;
    E.EventReferenceKind=repmat("immediate_pre_event",count,1); E.EventReferenceValue=100*one;
    E.EventReferenceStartFrame=2*one; E.EventReferenceEndFrame=21*one; E.EventReferenceNeedsReview=false(count,1);
    events{k}=E;
end
missingFile=fullfile(movies,'relocated.tif'); movefile(fullfile(paths(end),'movie.tif'),missingFile);
E=vertcat(events{:});
included=table(rowIDs,mouse,condition,paths,ids,fullfile(paths,'sink.mat'),fullfile(paths,'surge.mat'), ...
    'VariableNames',{'BatchRowID','Mouse','Condition','RunFolder','RecordingID','SinkMaster','SurgeMaster'});
excluded=included([],:);
sources=struct('RecordingID',cellstr(ids),'RecordingFolder',cellstr(paths),'SinkMaster',cellstr(included.SinkMaster),'SurgeMaster',cellstr(included.SurgeMaster));
records=struct('SinksMatFile',cellstr(included.SinkMaster),'SurgesMatFile',cellstr(included.SurgeMaster));
Plan=struct('Schema','boi-batch-stats-plan-1','OutputFolder',folder,'Included',included,'Excluded',excluded, ...
    'InputRows',table(ids,repmat("GFAP",5,1),'VariableNames',{'RecordingID','Promoter'}), ...
    'SourceRows',table(rowIDs,original,'VariableNames',{'BatchRowID','Paths'}),'InputCSVName','batch.csv','SavedSources',sources, ...
    'Counts',struct('Included',5,'Excluded',0));
Plan.Digest=boiBatchQueueDigest(Plan);save(fullfile(folder,'BatchStatsSelection.mat'),'Plan');
writetable(Plan.InputRows,fullfile(folder,'batch.csv'));writetable(Plan.SourceRows,fullfile(folder,'BatchSourceRows.csv'));
writetable(included,fullfile(folder,'IncludedRecordings.csv'));writetable(excluded,fullfile(folder,'ExcludedRecordings.csv'));
data=fullfile(stats,'DataOutput.mat');book=fullfile(stats,'stats.xlsx');manifest=fullfile(stats,'manifest.txt');
D=struct('RecordingRegistry',Plan.InputRows,'Table_OxygenSinks_OutCombo',table(),'Table_OxygenSinkEvents_OutCombo',E, ...
    'Table_OxygenSurges_OutCombo',table(),'Table_OxygenSurgeEvents_OutCombo',table()); save(data,'-struct','D');
saveStatsCoreTables(stats,table(),E,table(),table());writetable(Plan.InputRows,book,'Sheet','RecordingRegistry');
writelines("Synthetic receipt",manifest);
statsResult=struct('OutputXlsx',book,'DataOutputMat',data,'AnalysisManifest',manifest,'StatsInfo',struct('Recordings',records));
Result=struct('Schema','boi-batch-stats-result-1','Status','complete','Directory',char(folder),'Workbook',char(book), ...
    'DataOutput',char(data),'AnalysisManifest',char(manifest),'StatsResult',statsResult,'Included',included,'Excluded',excluded,'PlanDigest',Plan.Digest);
save(fullfile(folder,'BatchStatsResult.mat'),'Result');
writeBOIRunJSON(fullfile(folder,'BatchStatsStatus.json'),struct('Schema','boi-batch-stats-status-1','Status','complete','Stage','complete', ...
    'Workbook',char(book),'IncludedRecordings',5,'ExcludedRecordings',0));
end
