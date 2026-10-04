function tests=testBOIPortableReviewedPocket
% Saved scalar traces and fixed pixels, no source recording or GUI required.
tests=functiontests(localfunctions);
end
function setupOnce(~),setupOxygenDynamicsPath;end
function [R,folder]=fixture(kind)
folder=tempname;mkdir(folder);values=[100 100 100 100 80 90 100 100];
Raw=repmat(reshape(values,1,1,8),2,2,1);pixels=cell(1,8);pixels(5:6)={[1;2]};
S=table("fixture",1,{pixels},'VariableNames',{'RecordingID','SiteID','FramePixels'});
amp='NormOxySinkAmp';site='SinkID';expected=.2;if strcmp(kind,'surge'),amp='NormOxySurgeAmp';site='SurgeID';expected=-.1;end
E=table("fixture",1,1,5,6,100,"valid",3,expected,'VariableNames', ...
    {'RecordingID',site,'EventID','StartFrame','EndFrame','BaselineValue','BaselineStatus','BaselineValidSamples',amp});
[Audit,Traces]=auditOxygenEventFootprints(S,E,S([],:),Raw,3,kind);
raw=values;corrected=[10 10 10 10 -15 5 10 10];
Traces{1}.RawCubicTrend=raw-corrected;Traces{1}.DetectionDetrended=corrected;
Traces{1}.Filtered=values/100;
AnalysisInfo=struct('RawFile',fullfile(folder,'not-present-recording.tif'),'RawSHA256',repmat('1',1,64), ...
    'DenoisedFile','','DenoisedSHA256','','NFrames',8,'FrameSize',[2 2],'AnalysisParams',struct('fs',1,'PixelSize',2));
Audit.SourceRawSHA256=string(AnalysisInfo.RawSHA256);
path=fullfile(folder,'event-amplitude-audit.mat');save(path,'Audit','Traces','AnalysisInfo');R=loadBOIEventReview(path);
end
function [E,J]=preview(R,state,endpoint)
J=createBOIPocketJudgment(R,1,5,6,2:4,state,endpoint,'portable test','Explicit frozen tiny trace','external_trigger_1Hz');
E=buildBOIReviewedPocketEvidence(R,1,J);
end
function testSinkPreviewSaveReopenExport(t)
[R,f]=fixture('sink');cleanup=onCleanup(@()rmdir(f,'s'));original=R.Audit;
[E,~]=preview(R,'accepted_local_state','recovery_observed');
verifyEqual(t,E.Measures.CorrectedSignedTroughPercent,-25);verifyEqual(t,E.Measures.RawSignedTroughPercent,-20);
verifyEqual(t,E.Measures.CorrectedMinimumFrames,5);verifyEqual(t,E.Correction.NewFits,0);
store=saveBOIReviewedPocketEvidence(E,fullfile(f,'saved'));opened=loadBOIReviewedPocketEvidence(store.Path);
verifyEqual(t,opened.Document,E);verifyFalse(t,opened.ReplayedOnOpen);verifyEqual(t,verifyBOIReviewedPocketArithmetic(E),E.Measures);
R=attachBOIPocketEvidence(R,1,store.Path);out=exportBOIReviewedPocketEvidence(store,fullfile(f,'portable'));verifyEqual(t,out.Document,E);
receipt=exportBOIEventReview(R,1,fullfile(f,'event-export'));
embedded=loadBOIReviewedPocketEvidence(fullfile(f,'event-export','ReviewedPocket'));verifyEqual(t,embedded.Document,E);
S=load(fullfile(f,'event-export','SelectedEventReview.mat'),'Data');verifyEqual(t,S.Data.Row,original);
verifyEqual(t,receipt.ExportProvenance.OriginalCalculation.SoftwareVersion,'unknown');verifyEqual(t,R.Audit,original);
verifyError(t,@()saveBOIReviewedPocketEvidence(E,store.Path),'OxygenDynamics:PocketOutputExists');
end
function testConditionalSurgeFootprintAndUnresolvedRecovery(t)
[R,f]=fixture('surge');cleanup=onCleanup(@()rmdir(f,'s'));
[E,~]=preview(R,'provisional_local_state','recovery_unresolved');
verifyEqual(t,E.Measures.CorrectedSignedTroughPercent,-25);verifyEqual(t,E.Measures.RawSignedTroughPercent,-20);
verifyEqual(t,E.Measures.PrimaryStatus,'conditional_exploratory');verifyTrue(t,isnan(E.ConfirmedPocketDurationSec));
verifyEqual(t,E.OriginalAutomatic.StoredAmplitude,-.1,'AbsTol',1e-15);verifyTrue(t,contains(E.FootprintQualification,'saved surge footprint'));
store=saveBOIReviewedPocketEvidence(E,fullfile(f,'saved'));verifyEqual(t,loadBOIReviewedPocketEvidence(store.Path).Document,E);
end
function testMissingCorrectionReferenceAndClock(t)
raw=[100 100 100 100 80 90 100 100];
M=computeBOIReviewedPocketMeasures(raw,[],2:4,5:6,'accepted_local_state','external_trigger_1Hz');
verifyEqual(t,M.RawSignedTroughPercent,-20);verifyTrue(t,isnan(M.CorrectedSignedTroughPercent));verifyEqual(t,M.PrimaryStatus,'unavailable_missing_saved_correction');
M=computeBOIReviewedPocketMeasures(raw,raw-90,2:4,5:6,'accepted_local_state','unknown');verifyEqual(t,M.ArithmeticStatus,'unavailable_unverified_clock');
M=computeBOIReviewedPocketMeasures(raw,raw-90,[],5:6,'accepted_local_state','external_trigger_1Hz');verifyEqual(t,M.ArithmeticStatus,'unavailable_empty_reference');
end
function testIncompleteAndUnsupportedReviewedArtifacts(t)
[R,f]=fixture('sink');cleanup=onCleanup(@()rmdir(f,'s'));[E,~]=preview(R,'accepted_local_state','recovery_observed');
store=saveBOIReviewedPocketEvidence(E,fullfile(f,'saved'));
write(fullfile(store.Path,'Incomplete.json'),struct('Reason','synthetic incomplete'));verifyError(t,@()loadBOIReviewedPocketEvidence(store.Path),'OxygenDynamics:InvalidPocketEvidence');delete(fullfile(store.Path,'Incomplete.json'));
M=jsondecode(fileread(fullfile(store.Path,'Manifest.json')));M.Schema='future-unsupported';write(fullfile(store.Path,'Manifest.json'),M);
verifyError(t,@()loadBOIReviewedPocketEvidence(store.Path),'OxygenDynamics:UnsupportedPocketSchema');
E.Schema='future-unsupported';verifyError(t,@()saveBOIReviewedPocketEvidence(E,fullfile(f,'bad')),'OxygenDynamics:UnsupportedPocketSchema');verifyFalse(t,isfolder(fullfile(f,'bad')));
end
function testHistoricalSavedDimensionsRequireMatchedMetadata(t)
[R,f]=fixture('sink');cleanup=onCleanup(@()rmdir(f,'s'));S=load(R.AuditPath);S.AnalysisInfo=rmfield(S.AnalysisInfo,'FrameSize');save(R.AuditPath,'-struct','S');
verifyError(t,@()loadBOIEventReview(R.AuditPath),'OxygenDynamics:HistoricalDimensionsRequired');
p=fullfile(f,'dimensions.json');write(p,struct('Conversion',struct('TiffSHA256',S.AnalysisInfo.RawSHA256,'MatlabInputShape',[8 2 2])));
oldHash=oxygenFileSHA256(R.AuditPath);historical=loadBOIEventReview(R.AuditPath,p);verifyEqual(t,historical.AnalysisInfo.FrameSize,[2 2]);verifyEqual(t,oxygenFileSHA256(R.AuditPath),oldHash);
write(p,struct('Conversion',struct('TiffSHA256','different-source','MatlabInputShape',[8 2 2])));
verifyError(t,@()loadBOIEventReview(R.AuditPath,p),'OxygenDynamics:HistoricalMetadataMismatch');
end
function testFailedAuditCannotReopen(t)
[R,f]=fixture('sink');cleanup=onCleanup(@()rmdir(f,'s'));write(fullfile(f,'AuditCreationFailure.json'),struct('Reason','incomplete fixture'));
verifyError(t,@()loadBOIEventReview(R.AuditPath),'OxygenDynamics:IncompleteEventAudit');
end
function write(p,v)
f=fopen(p,'w');cleanup=onCleanup(@()fclose(f));fprintf(f,'%s\n',jsonencode(v,'PrettyPrint',true));
end
