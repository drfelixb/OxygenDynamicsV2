function tests=testBOIWholeEventPreview
tests=functiontests(localfunctions);
end
function setupOnce(~),setupOxygenDynamicsPath;end
function testCompleteExcursionAndEarlierOnset(t)
[E,P]=fixture;before=E;R=previewBOIWholeEvent(E,P);
verifyEqual(t,E,before);verifyEqual(t,string({R.Candidates.Status}),repmat("complete_trace_candidate",1,2));
for k=1:numel(R.Candidates)
    C=R.Candidates(k);
    verifyEqual(t,[C.Raw.OnsetFrame C.Raw.RecoveryFrame C.Raw.RecoveryConfirmedThroughFrame],[31 51 55]);
    verifyEqual(t,[C.Corrected.OnsetFrame C.Corrected.RecoveryFrame],[31 51]);
    verifyEqual(t,C.Raw.ReferenceStartFrame,31-C.ReferenceSamples);
end
verifyFalse(t,R.ScientificAcceptance||R.BurdenCalculated||R.OriginalResultsChanged);
end
function testSingleCrossingCannotRecover(t)
[E,P]=fixture;E.Raw(40)=100;E.Corrected=E.Raw-100;R=previewBOIWholeEvent(E,P);
verifyEqual(t,R.Candidates(1).Raw.RecoveryFrame,51);
verifyEqual(t,R.Candidates(1).Raw.SustainedDipRuns,2);
end
function testUnrecoveredDipsStayOneExcursion(t)
[E,P]=fixture;E.Raw(31:60)=90;E.Raw(41:43)=100;E.Corrected=E.Raw-100;
E.NativeContact(31:60)=true;E.NativeMaskPixels(31:60)=4;E.SeedStartFrame=48;E.SeedEndFrame=55;
R=previewBOIWholeEvent(E,P);verifyEqual(t,R.Candidates(1).Raw.OnsetFrame,31);
verifyEqual(t,R.Candidates(1).Raw.RecoveryFrame,61);verifyEqual(t,R.Candidates(1).Raw.SustainedDipRuns,2);
end
function testRecoveredRecurrenceGetsOwnReference(t)
[E,P]=fixture;E.Raw(:)=100;E.Raw(31:40)=90;E.Raw(51:60)=85;E.Corrected=E.Raw-100;
E.NativeContact(:)=false;E.NativeContact([31:40 51:60])=true;
E.NativeMaskPixels(:)=0;E.NativeMaskPixels([31:40 51:60])=4;E.SeedStartFrame=55;E.SeedEndFrame=58;
R=previewBOIWholeEvent(E,P);C=R.Candidates(1);
verifyEqual(t,C.Raw.OnsetFrame,51);verifyEqual(t,C.Raw.ReferenceStartFrame,41);verifyEqual(t,C.Raw.RecoveryFrame,61);
verifyFalse(t,R.Candidates(2).Status=="complete_trace_candidate"); % no 20 clean seconds between these pockets
end
function testNoiseOnlyIsNotAnExcursion(t)
[E,P]=fixture;E.Raw=100+.2*sin((1:100)'*2);E.Corrected=E.Raw-100;
E.NativeContact(:)=false;R=previewBOIWholeEvent(E,P);
verifyEqual(t,R.Candidates(1).Status,"no_sustained_dip");
end
function testMonotonicBackgroundHasNoCompleteRecovery(t)
[E,P]=fixture;E.Raw=100-(1:100)'*.1;E.Corrected=E.Raw-100;E.NativeContact(:)=false;
R=previewBOIWholeEvent(E,P);verifyFalse(t,any(string({R.Candidates.Status})=="complete_trace_candidate"));
verifyTrue(t,all(arrayfun(@(C)isnan(C.Raw.RecoveryFrame),R.Candidates)));
end
function testBaselineDriftFlag(t)
[E,P]=fixture;E.Raw=100-(1:100)';E.Corrected=E.Raw-100;E.NativeContact(:)=false;
R=previewBOIWholeEvent(E,P);verifyEqual(t,R.Candidates(1).Raw.Status,"baseline_drift");
end
function testMissingSampleIsBarrier(t)
[E,P]=fixture;E.Raw(46)=NaN;E.Corrected(46)=NaN;R=previewBOIWholeEvent(E,P);
verifyEqual(t,R.Candidates(1).Status,"nonfinite_signal");verifyTrue(t,isnan(R.Candidates(1).Raw.RecoveryFrame));
end
function testRecordingStartNeverUsesPostReference(t)
[E,P]=fixture;E.SeedStartFrame=1;E.SeedEndFrame=8;E.Raw(1:8)=90;E.Corrected=E.Raw-100;
R=previewBOIWholeEvent(E,P);verifyEqual(t,R.Candidates(1).Status,"left_censored");
verifyTrue(t,isnan(R.Candidates(1).Raw.ReferenceMean));
end
function testRecordingEndAndContextLimitsDistinct(t)
[E,P]=fixture;E.Raw(31:end)=90;E.Corrected=E.Raw-100;R=previewBOIWholeEvent(E,P);
verifyEqual(t,R.Candidates(1).Status,"right_censored");
P.LookAheadSec=10;R=previewBOIWholeEvent(E,P);
verifyEqual(t,R.Candidates(1).Status,"recovery_outside_context_or_absent");
end
function testRawCorrectedDisagreementVisible(t)
[E,P]=fixture;E.Corrected(31:end)=-10;R=previewBOIWholeEvent(E,P);
verifyEqual(t,R.Candidates(1).Status,"raw_corrected_disagreement");
verifyEqual(t,R.Candidates(1).Raw.Status,"complete");verifyEqual(t,R.Candidates(1).Corrected.Status,"right_censored");
end
function testUnknownNativeContextIsNotClean(t)
[E,P]=fixture;E=rmfield(E,'NativeContact');R=previewBOIWholeEvent(E,P);
verifyEqual(t,R.Candidates(1).Status,"trace_candidate_reference_screening_unavailable");
verifyFalse(t,R.Candidates(1).Raw.BaselineScreened);
E=rmfield(E,'NativeMaskPixels');R=previewBOIWholeEvent(E,P);
verifyEqual(t,R.Candidates(1).SpatialStatus,"unavailable");
end
function testUnknownSpatialSupportQualifiesCandidate(t)
[E,P]=fixture;E=rmfield(E,'NativeMaskPixels');R=previewBOIWholeEvent(E,P);
verifyEqual(t,R.Candidates(1).Status,"trace_candidate_spatial_unavailable");
end
function testOvershootIsNotStableBaselineReturn(t)
[E,P]=fixture;E.Raw(51:end)=110;E.Corrected=E.Raw-100;R=previewBOIWholeEvent(E,P);
verifyEqual(t,R.Candidates(1).Status,"right_censored");
end
function testSecondsAndFramesAtTwoHz(t)
[E,P]=fixture;E.Raw=repelem(E.Raw,2);E.Corrected=repelem(E.Corrected,2);
E.NativeContact=repelem(E.NativeContact,2);E.NativeMaskPixels=repelem(E.NativeMaskPixels,2);
E.SeedStartFrame=2*E.SeedStartFrame-1;E.SeedEndFrame=2*E.SeedEndFrame;E.SampleHz=2;
R=previewBOIWholeEvent(E,P);verifyEqual(t,[R.Candidates.ReferenceSamples],[20 40]);
verifyEqual(t,R.Candidates(1).Raw.OnsetFrame,61);verifyEqual(t,R.Candidates(1).Raw.RecoveryFrame,101);
verifyEqual(t,R.Candidates(1).Raw.RecoveryConfirmedThroughFrame,110);
end
function testMalformedInputsAndExplicitSettings(t)
[E,P]=fixture;Q=P;Q.ReturnSigma=Q.DipSigma;
verifyError(t,@()previewBOIWholeEvent(E,Q),'OxygenDynamics:WholeEventPreviewInput');
Q=P;Q.LookBackSec=NaN;verifyError(t,@()previewBOIWholeEvent(E,Q),'OxygenDynamics:WholeEventPreviewInput');
E.NativeContact=double(E.NativeContact);E.NativeContact(2)=2;verifyError(t,@()previewBOIWholeEvent(E,P),'OxygenDynamics:WholeEventPreviewInput');
end
function testAdapterRetainsIdentityAndMissingSpatialEvidence(t)
[E,~]=fixture;R=reviewFixture(E);before=R;Q=buildBOIWholeEventEvidence(R,1);
verifyEqual(t,R,before);verifyEqual(t,Q.Raw,E.Raw);verifyEqual(t,Q.Corrected,E.Corrected);
verifyTrue(t,all(isnan(Q.NativeContact))&&all(isnan(Q.NativeMaskPixels)));
R.ReferenceSources=struct('AuditSHA256','saved-hash','EventCount',1,'EventFramePixels',{{repmat({[1;2]},11,1)}},'MasterSHA256',{{'sink-hash','surge-hash'}});
Q=buildBOIWholeEventEvidence(R,1);verifyEqual(t,find(Q.NativeContact),(35:45)');
verifyEqual(t,Q.NativeMaskPixels(35:45),2*ones(11,1));
end
function testPanelClearsForSelectionAndSettings(t)
[E,P]=fixture;f=uifigure('Visible','off');c=onCleanup(@()delete(f));
panel=createBOIWholeEventPanel(f,@()[],@()[]);panel.SetEvidence(E);panel.Preview();
verifyFalse(t,isempty(panel.State().Preview));Q=P;Q.RecoveryHoldSec=7;panel.SetSettings(Q);
verifyTrue(t,isempty(panel.State().Preview));panel.Preview();
R=reviewFixture(E);panel.Update(R,1);verifyTrue(t,isempty(panel.State().Preview));
R.Audit.EventType(:)="surge";panel.Update(R,1);verifyEqual(t,panel.RunButton.Enable,matlab.lang.OnOffSwitchState.off);
verifyFalse(t,isfield(panel,'Save')||isfield(panel,'Export'));
end
function testExistingReviewerHasOptInTab(t)
root=tempname;c=onCleanup(@()rmdir(root,'s'));F=makeBOIReviewedExportFixture(root);
S=load(F.AuditPath);S.Audit.StoredStatus=S.Audit.RecomputedStatus;
S.Audit.StoredBaseline=S.Audit.RecomputedBaseline;
for k=1:numel(S.Traces),S.Traces{k}.DetectionDetrended=S.Traces{k}.Raw-100;end
save(F.AuditPath,'-struct','S');
receiptPath=fullfile(root,'AuditCreationReceipt.json');receipt=jsondecode(fileread(receiptPath));
receipt.AuditSHA256=oxygenFileSHA256(F.AuditPath);writeBOIRunJSON(receiptPath,receipt);
[f,ui]=openBOIEventReview(F.AuditPath,[],true);d=onCleanup(@()delete(f));
verifyEqual(t,ui.WholeEventTab.Title,'Whole-event preview');verifyTrue(t,isempty(ui.WholeEvent.State().Preview));
ui.Select(1);verifyTrue(t,isempty(ui.WholeEvent.State().Preview));
before=ui.CurrentReview();ui.WholeEvent.Preview();verifyEqual(t,ui.CurrentReview(),before);
ui.Select(2);verifyTrue(t,isempty(ui.WholeEvent.State().Preview));
end
function [E,P]=fixture
raw=100*ones(100,1);raw(31:50)=90;contact=false(100,1);contact(31:50)=true;
counts=zeros(100,1);counts(31:50)=4;
E=struct('Raw',raw,'Corrected',raw-100,'SampleHz',1,'SeedStartFrame',35,'SeedEndFrame',45, ...
    'NativeContact',contact,'NativeMaskPixels',counts,'Identity','Synthetic pocket');P=boiWholeEventPreviewSettings;
end
function R=reviewFixture(E)
R=struct('Audit',table("recording","sink",1,1,35,45,35,45,'VariableNames', ...
    {'RecordingID','EventType','SiteID','EventID','StartFrame','EndFrame','DetectedStartFrame','DetectedEndFrame'}), ...
    'AnalysisInfo',struct('NFrames',100,'RawSHA256','raw-hash','AnalysisParams',struct('fs',1)), ...
    'Traces',{{struct('Raw',E.Raw,'DetectionDetrended',E.Corrected,'DetectedFrames',(35:45)','Footprint',[1;2])}}, ...
    'AuditPath','saved-audit.mat','AuditSHA256','saved-hash');
end
