function runSurgeContactValidation(priorRoot,outputRoot)
% Six cached candidate replays plus one complete master/statistics rerun.
setupOxygenDynamicsPath;assert(~isfolder(outputRoot));mkdir(outputRoot);
outputRoot=char(java.io.File(outputRoot).getCanonicalPath());
priorRoot=char(java.io.File(priorRoot).getCanonicalPath());
Code=createOxygenRegressionCodeManifest();writetable(Code,fullfile(outputRoot,'code-manifest.csv'));
files=dir(fullfile(priorRoot,'*','*','candidate-input.mat'));assert(numel(files)==6);
Summary=table();
for k=1:numel(files)
 D=load(fullfile(files(k).folder,files(k).name));P=D.P;M=D.M;
 assert(isequaln(P,createOxygenMasterParams(P.PixelSize,P.fs)));
 provenance=jsondecode(fileread(fullfile(files(k).folder,'provenance.json')));
 rec=provenance.InputRecording;u=dir(fullfile(rec,'OxygenSurges_Output','*.mat'));assert(isscalar(u));U=load(fullfile(u.folder,u.name));
 assert(strcmp(U.AnalysisInfo.RawSHA256,provenance.InputSHA256));
 [S,~,Map,Q,~,E,C]=buildTrackedOxygenSurgeSites(D.C,P);
 assert(isequaln(Q(:,U.SurgeCandidateRunQC.Properties.VariableNames(~strcmp(U.SurgeCandidateRunQC.Properties.VariableNames,'RecordingID'))), ...
  removevars(U.SurgeCandidateRunQC,'RecordingID')));
 assert(size(S,1)==height(U.Table_OxygenSurges_Out));
 for s=1:size(S,1),assert(isequal(S(s,:),U.Table_OxygenSurges_Out.FramePixels{s}));end
 updated=attachSurgeTrackingMetadata(U.Table_OxygenSurgeEvents_Out,Map,P);
 assert(isequaln(updated(:,U.Table_OxygenSurgeEvents_Out.Properties.VariableNames),U.Table_OxygenSurgeEvents_Out));
 R=auditSurgeContactLedger(D.C,P,Q,E,C);R.Session=string(M.SourceProfile.Session);R.Case=string(M.Case);
 R.SavedMasksAndNativeIdentitiesUnchanged=true;Summary=[Summary;struct2table(R)]; %#ok<AGROW>
 out=fullfile(outputRoot,'candidate-replays',M.SourceProfile.Session,M.Case);mkdir(out);
 Q.RecordingID=repmat(string(U.AnalysisInfo.RecordingID),height(Q),1);
 E.RecordingID=repmat(string(U.AnalysisInfo.RecordingID),height(E),1);
 C.RecordingID=repmat(string(U.AnalysisInfo.RecordingID),height(C),1);
 writetable(Q,fullfile(out,'SurgeCandidateRunQC.csv'));writetable(E,fullfile(out,'SurgeTrackingEdges.csv'));writetable(C,fullfile(out,'SurgeContactFrames.csv'));
 provenance.NewPipelineContract=oxygenPipelineContract();provenance.Scope='Cached-candidate replay only, not a new master run or converted historical analysis.';
 writeJSON(fullfile(out,'provenance.json'),provenance);
 fprintf('CONTACT REPLAY VERIFIED %s %s\n',M.SourceProfile.Session,M.Case);
end
writetable(Summary,fullfile(outputRoot,'candidate-replay-summary.csv'));
% Full master path on the ID401 stationary-pulse movie, with identical input.
v=jsondecode(fileread(fullfile(priorRoot,'M401-01-baseline-awake','smooth_pairs','provenance.json')));
old=v.InputRecording;M=jsondecode(fileread(fullfile(old,'challenge-manifest.json')));P=M.SourceProfile;
rec=fullfile(outputRoot,'master','M401-01-baseline-awake','smooth_pairs');mkdir(rec);
copyfile(fullfile(old,'challenge_original.tif'),fullfile(rec,'challenge_original.tif'));
assert(strcmp(oxygenFileSHA256(fullfile(rec,'challenge_original.tif')),v.InputSHA256));
Config=struct('SFs',P.SampleHz,'PiSz',P.PixelSize,'Mous',P.Mouse,'Cond','KnownSignal', ...
 'Drug','None','Gen',P.Genotype,'Promo',P.Promoter,'Puff',NaN,'strOW','Y');
runOxygenDynamicsMaster(rec,Config);
for kind=["sink","surge"]
 folder='OxygenSinks_Output';pattern='*Urefined*.mat';site='Table_OxygenSinks_Out';event='Table_OxygenSinkEvents_Out';
 if kind=="surge",folder='OxygenSurges_Output';pattern='*.mat';site='Table_OxygenSurges_Out';event='Table_OxygenSurgeEvents_Out';end
 a=dir(fullfile(old,folder,pattern));b=dir(fullfile(rec,folder,pattern));A=load(fullfile(a.folder,a.name));B=load(fullfile(b.folder,b.name));
 for name={site,event}
  before=A.(name{1});after=B.(name{1});fields=before.Properties.VariableNames;
  % Recording identity can depend on the output directory; compare all other
  % existing fields, including full native masks, timing and signed amplitudes.
  fields(strcmp(fields,'RecordingID'))=[];
  assert(isequaln(before(:,fields),after(:,fields)),sprintf('Existing %s outputs changed.',kind));
 end
 if kind=="surge",U=B;end
end
D=load(fullfile(priorRoot,'M401-01-baseline-awake','smooth_pairs','candidate-input.mat'));
FullGraph=auditSurgeContactLedger(D.C,D.P,U.SurgeCandidateRunQC,U.SurgeTrackingEdges,U.SurgeContactFrames);
Audits=auditOxygenEventAmplitudeSource(rec);assert(all(Audits.MeasurementMatches));
writetable(Audits,fullfile(outputRoot,'independent-amplitude-audit.csv'));
Paths={rec};PostureFile=NaN;PupilFile=NaN;PuffsFile=NaN;WhiskingFile=NaN;
Mouse={P.Mouse};Genotype={P.Genotype};Condition={'KnownSignal'};DrugID={'None'};Promoter={P.Promoter};
SampleF=P.SampleHz;Pixelsize=P.PixelSize;Puff_2use=NaN;RecordingID="CONTACT_ID401";
T=table(Paths,PostureFile,PupilFile,PuffsFile,WhiskingFile,Mouse,Genotype,Condition,DrugID,Promoter,SampleF,Pixelsize,Puff_2use,RecordingID);
csv=fullfile(outputRoot,'stats-input.csv');writetable(T,csv);
stats=runOxygenDynamicsStats(struct('inputCsv',csv,'masterFolder',outputRoot,'outputRoot',fullfile(outputRoot,'stats'),'interactive',false));
Saved=load(stats.DataOutputMat);E=Saved.Table_OxygenSurgeEvents_OutCombo;
assert(height(E)==height(U.Table_OxygenSurgeEvents_Out));
for field=surgeContactMetadataFields(),assert(isequaln(E.(field{1}),U.Table_OxygenSurgeEvents_Out.(field{1})));end
Q=Saved.EventMeasurementQC;q=Q.EventType=="surge";
assert(Q.DetectedEvents(q)==height(E)&&Q.ContactTrackingEvents(q)==nnz(E.ContactFrameCount>0));
assert(Q.ContactTrackingNotAssessedEvents(q)==0&&Q.ContactEventFrames(q)==sum(E.ContactFrameCount));
assert(Q.ContactWithRejectedCandidateEvents(q)==nnz(E.ContactWithRejectedCandidate));
definitions=readtable(stats.OutputXlsx,'Sheet','MetricDefinitions','TextType','string');
assert(all(ismember(["ContactFrameCount","ContactFrameFootprintFraction","ContactEventFrames"],definitions.MetricName)));
writetable(Q,fullfile(outputRoot,'master-statistics-qc.csv'));
Integration=runExistingAnalysisIntegration(); %#ok<NASGU>
tests=runtests('tests/analysis');assertSuccess(tests);Smoke=runOxygenPipelineSmokeTest();Repository=runRepositoryChecks();
Final=createOxygenRegressionCodeManifest();assert(isequal(Code(:,{'RelativePath','SHA256'}),Final(:,{'RelativePath','SHA256'})));
Report=struct('CachedCandidateReplays',height(Summary),'SourceRecordings',4,'NewReferenceMasterRuns',1, ...
 'PipelineContract',oxygenPipelineContract(),'FullMasterContactGraph',FullGraph,'ReferenceStatisticsExportVerified',true, ...
 'ExistingBothSignMasksTimingAndMeasurementsUnchanged',true,'IndependentEventMeasurements',height(Audits), ...
 'FocusedTests',numel(tests),'AllFocusedTestsPassed',all([tests.Passed]),'Smoke',Smoke,'Repository',Repository, ...
 'SyntheticMasterAndStatisticsIntegrationPassed',true,'CodeFreezeVerified',true, ...
 'Interpretation','Metadata/QC extension. Six candidate replays are not six master reruns; only ID401 smooth-pairs was fully rerun here. No biological accuracy estimate.');
writeJSON(fullfile(outputRoot,'completion.json'),Report);disp(Summary);
end
function writeJSON(path,value)
f=fopen(path,'w');assert(f>=0);cleanup=onCleanup(@()fclose(f));fprintf(f,'%s\n',jsonencode(value,'PrettyPrint',true));
end
