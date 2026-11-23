function tests=testBOICompactOversizeBurden
% Focused synthetic preview of workbook-backed oversized automatic burden.
tests=functiontests(localfunctions);
end

function testRequiresCompleteApprovedWorkbook(t)
setupOxygenDynamicsPath;
folder=tempname;
mkdir(folder);
cleanup=onCleanup(@()rmdir(folder,'s')); %#ok<NASGU>
mat=fullfile(folder,'DataOutput.mat');
book=fullfile(folder,'Detailed.xlsx');
destination=fullfile(folder,'Compact.xlsx');

RecordingRegistry=table("001","Example","M01","control","D1",false,2,2,1,1e6,"loaded", ...
    'VariableNames',{'RecordingID','Experiment','Mouse','Condition','DrugID','PuffStim', ...
    'NFrames','SampleF','RecordingDuration_sec','RecordingArea_um2','AnalysisStatus'});
NumOngoingOxysinks={'Example','M01','control','D1',false,[2 0]};
% A compressible variable exercises the reported footprint, not disk size.
HypoxicBurden=struct('SyntheticPayload',zeros(64*1024^2+1,1,'uint8'));
save(mat,'RecordingRegistry','NumOngoingOxysinks','HypoxicBurden','-v7');
clear HypoxicBurden;
info=whos('-file',mat,'HypoxicBurden');
t.assertGreaterThan(info.bytes,64*1024^2);
matHash=oxygenFileSHA256(mat);

events=table("001",1,1,-42, ...
    'VariableNames',{'RecordingID','SinkID','EventIndex','PerEventBurdenContribution'});
recordings=table("001",-42,'VariableNames',{'RecordingID','HypoxicBurden'});
timeSeries=table(["001";"001"],[1;2],[0;.5],[1;0],[-17;0], ...
    'VariableNames',{'RecordingID','Frame','TimeSec','ActiveHypoxicEvents','HypoxicBurdenPerMm2OverTime'});
selection=table("boi-signed-contributions-1",'VariableNames',{'Version'});
reference=table("synthetic-reference",'VariableNames',{'Version'});
basis=table("synthetic-basis",'VariableNames',{'Basis'});
writetable(events,book,'Sheet','HypoxicBurden_EventBased');
writetable(recordings,book,'Sheet','HypoxicBurden_ByRecording');
writetable(timeSeries,book,'Sheet','HypoxicBurden_TimeSeries');
writetable(selection,book,'Sheet','Burden_SelectionPolicy');
writetable(reference,book,'Sheet','HypoxicBurden_ReferencePolicy');

source=struct('DataOutput',mat,'Workbook',book,'UseWorkbookBurdenTables',true);
t.verifyError(@()prepareBOICompactWorkbook(source,{},destination),'OxygenDynamics:CompactSourceSize');
writetable(basis,book,'Sheet','HypoxicBurden_Basis');
bookHash=oxygenFileSHA256(book);
unapproved=rmfield(source,'UseWorkbookBurdenTables');
t.verifyError(@()prepareBOICompactWorkbook(unapproved,{},destination),'OxygenDynamics:CompactSourceSize');

[plan,prepared]=prepareBOICompactWorkbook(source,{},destination);
t.verifyEqual(plan.AutomaticSHA256,matHash);
t.verifyEqual(sort(string({plan.SourceFiles.SHA256})),sort(string({matHash,bookHash})));
t.verifyEqual(prepared.Source.Registry,RecordingRegistry);
t.verifyEqual(prepared.Source.Tables.NumOngoingOxysinks,NumOngoingOxysinks);
t.verifyEqual(prepared.Data.Events.AutomaticContribution,-42);
t.verifyEqual(prepared.Data.Recordings.AutomaticBurden(prepared.Data.Recordings.EventType=="sink"),-42);
t.verifyEqual(prepared.Data.TimeSeries.AutomaticBurdenPerMm2,[-17;0]);
t.verifyEqual(prepared.Data.TimeSeries.AutomaticActiveEvents,[2;0]);
t.verifyEqual(string(prepared.Source.Tables.HypoxicBurden_Basis.Basis),"synthetic-basis");
t.verifyFalse(isfile(destination));
t.verifyEqual(oxygenFileSHA256(mat),matHash);
t.verifyEqual(oxygenFileSHA256(book),bookHash);
end
