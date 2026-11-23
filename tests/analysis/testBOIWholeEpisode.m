function tests=testBOIWholeEpisode,tests=functiontests(localfunctions);end
function setupOnce(~),setupOxygenDynamicsPath;end
function testIsolatedEpisode(t)
[E,P]=fixture;R=previewBOIWholeEpisode(E,P);assertCandidate(t,R.Raw,[121 169]);
verifyFalse(t,R.ScientificAcceptance||R.BurdenCalculated||R.OriginalResultsChanged);verifyEqual(t,R.NewCorrectionFits,0);
end
function testAsymmetricEarlyTrough(t)
[E,P]=fixture(.25);R=previewBOIWholeEpisode(E,P);assertCandidate(t,R.Raw,[121 169]);
end
function testAsymmetricLateTrough(t)
[E,P]=fixture(.75);R=previewBOIWholeEpisode(E,P);assertCandidate(t,R.Raw,[121 169]);
end
function testLongEpisode(t)
[E,P]=fixture;E.Raw=signal(600,100,385,.5);E.Corrected=E.Raw-100;R=previewBOIWholeEpisode(E,P);assertCandidate(t,R.Raw,[100 385]);
end
function testShortEpisode(t)
[E,P]=fixture;E.Raw=signal(600,121,133,.5);E.Corrected=E.Raw-100;R=previewBOIWholeEpisode(E,P);assertCandidate(t,R.Raw,[121 133]);
end
function testFlatHasNoEpisode(t)
[E,P]=fixture;E.Raw(:)=100;E.Corrected(:)=0;R=previewBOIWholeEpisode(E,P);verifyEmpty(t,R.Raw.Proposals);verifyEmpty(t,R.Corrected.Proposals);
end
function testMonotonicHasNoCompleteEpisode(t)
[E,P]=fixture;E.Raw=100+(1:600)'*.04;E.Corrected=E.Raw-100;R=previewBOIWholeEpisode(E,P);verifyFalse(t,any(string({R.Raw.Proposals.Status})=="pocket_candidate"));
end
function testStepAlternative(t)
[E,P]=fixture;E.Raw(:)=100;E.Raw(300:end)=90;E.Corrected=E.Raw-100;R=previewBOIWholeEpisode(E,P);
verifyFalse(t,any(arrayfun(@(c)strcmp(c.Status,'pocket_candidate')&&c.StartFrame<=300&&c.EndFrame>=300,R.Raw.Proposals)));
end
function testCurvedBackgroundAlternative(t)
[E,P]=fixture;x=((1:600)'-300)/300;E.Raw=100+10*x.^2;E.Corrected=E.Raw-100;R=previewBOIWholeEpisode(E,P);
verifyFalse(t,any(string({R.Raw.Proposals.Status})=="pocket_candidate"));
end
function testDriftingEpisode(t)
[E,P]=fixture;E.Raw=E.Raw+(1:600)'*.03;E.Corrected=E.Raw-100;R=previewBOIWholeEpisode(E,P);assertCandidate(t,R.Raw,[121 169]);
end
function testOvershootNoPlateauRequirement(t)
[E,P]=fixture;E.Raw(170:end)=E.Raw(170:end)+3;E.Corrected=E.Raw-100;R=previewBOIWholeEpisode(E,P);assertCandidate(t,R.Raw,[121 169]);
end
function testRecoveredRecurrence(t)
[E,P]=fixture;E.Raw=signal(600,121,169,.5)+signal(600,241,289,.5)-100;E.Corrected=E.Raw-100;
R=previewBOIWholeEpisode(E,P);assertCandidate(t,R.Raw,[121 169]);assertCandidate(t,R.Raw,[241 289]);
end
function testUnrecoveredSeriesRetainsCompetingHypotheses(t)
[E,P]=fixture;E.Raw=signal(600,121,217,.5);E.Raw(160:180)=E.Raw(160:180)-5;E.Corrected=E.Raw-100;
R=previewBOIWholeEpisode(E,P);verifyGreaterThan(t,numel(R.Raw.ScreenedHypotheses),0);verifyTrue(t,all([R.Raw.Proposals.AlternativeCount]>=0));
end
function testStageDisagreement(t)
[E,P]=fixture;E.Corrected(:)=0;R=previewBOIWholeEpisode(E,P);assertCandidate(t,R.Raw,[121 169]);verifyEmpty(t,R.Corrected.Proposals);verifyTrue(t,any(string({R.StageMatches.Status})=="raw_only_context"));
end
function testBoundaryCensoring(t)
[E,P]=fixture;E.Raw=100*ones(600,1);E.Raw(1:30)=linspace(90,100,30);E.Raw(end-29:end)=linspace(100,90,30);E.Corrected=E.Raw-100;
R=previewBOIWholeEpisode(E,P);verifyEqual(t,string({R.Raw.BoundaryAssessments.Side}),["left" "right"]);verifyTrue(t,all(string({R.Raw.BoundaryAssessments.Status})=="uncertain_incomplete"));
end
function testGapNeverBridged(t)
[E,P]=fixture;E.Raw(150)=NaN;E.Corrected(150)=NaN;R=previewBOIWholeEpisode(E,P);
verifyTrue(t,all(arrayfun(@(c)~(c.ContextStartFrame<=150&&c.ContextEndFrame>=150),R.Raw.Proposals)));
verifyEqual(t,R.Raw.FiniteSegments,[1 149;151 600]);
end
function testClockScaling(t)
[E,P]=fixture;A=previewBOIWholeEpisode(E,P);E.Raw=repelem(E.Raw,2);E.Corrected=repelem(E.Corrected,2);E.SampleHz=2;
B=previewBOIWholeEpisode(E,P);a=best(A.Raw,[121 169]);b=best(B.Raw,[241 338]);verifyLessThanOrEqual(t,abs(a.DurationSec-b.DurationSec),3);
end
function testSeedIndependentAndNoMutation(t)
[E,P]=fixture;before=E;A=previewBOIWholeEpisode(E,P);verifyEqual(t,E,before);
E.SeedStartFrame=450;E.SeedEndFrame=460;B=previewBOIWholeEpisode(E,P);verifyEqual(t,A.Raw,B.Raw);verifyEqual(t,A.Corrected,B.Corrected);assertCandidate(t,B.Raw,[121 169]);
end
function testMissingStageAndUnknownSpatialEvidence(t)
[E,P]=fixture;E.Corrected(:)=NaN;R=previewBOIWholeEpisode(E,P);verifyEqual(t,R.Corrected.Status,'insufficient_finite_samples');verifyNotEmpty(t,R.Raw.Proposals);verifyNotEmpty(t,R.SpatialQualification);
end
function testInputAndSettingsGuards(t)
[E,P]=fixture;E.SampleHz=0;verifyError(t,@()previewBOIWholeEpisode(E,P),'OxygenDynamics:WholeEpisodeInput');
[E,P]=fixture;P.ExperimentalOnly=false;verifyError(t,@()previewBOIWholeEpisode(E,P),'OxygenDynamics:WholeEpisodeInput');
[E,P]=fixture;P.Profiles=[.8 .2];verifyError(t,@()previewBOIWholeEpisode(E,P),'OxygenDynamics:WholeEpisodeInput');
[E,P]=fixture;E.Raw(1)=Inf;verifyError(t,@()previewBOIWholeEpisode(E,P),'OxygenDynamics:WholeEpisodeInput');
end
function testScreeningLimitsAndRanges(t)
[E,P]=fixture;P.MaximumScreenedPerStage=1;R=previewBOIWholeEpisode(E,P);verifyTrue(t,R.Raw.ScreeningCapReached);verifyEqual(t,R.Raw.ScreenedSeeds,1);
verifyTrue(t,all(arrayfun(@(c)c.OnsetRange(1)<=c.StartFrame&&c.OnsetRange(2)>=c.StartFrame,R.Raw.Proposals)));
end
function testPanelReadOnlyReset(t)
[E,P]=fixture;f=uifigure('Visible','off');cleanup=onCleanup(@()delete(f));panel=createBOIWholeEpisodePanel(f);panel.SetEvidence(E);panel.Preview();
verifyNotEmpty(t,panel.State().Preview);verifyFalse(t,isfield(panel,'Save')||isfield(panel,'Export'));
panel.ShowFull();verifyEqual(t,panel.RawAxes.XLim,[.5 600.5]);panel.SetSettings(P);verifyEmpty(t,panel.State().Preview);
end
function testReviewerOptInAndPreservation(t)
root=tempname;cleanup=onCleanup(@()rmdir(root,'s'));F=makeBOIReviewedExportFixture(root);
S=load(F.AuditPath);S.Audit.StoredStatus=S.Audit.RecomputedStatus;S.Audit.StoredBaseline=S.Audit.RecomputedBaseline;
save(F.AuditPath,'-struct','S');receiptPath=fullfile(root,'AuditCreationReceipt.json');receipt=jsondecode(fileread(receiptPath));receipt.AuditSHA256=oxygenFileSHA256(F.AuditPath);writeBOIRunJSON(receiptPath,receipt);
[f,ui]=openBOIEventReview(F.AuditPath,[],true);closeFig=onCleanup(@()delete(f));
verifyEqual(t,ui.EpisodeTab.Title,'Episode prototype');verifyEmpty(t,ui.Episode.State().Preview);ui.Select(1);before=ui.CurrentReview();ui.Episode.Preview();verifyEqual(t,ui.CurrentReview(),before);ui.Select(2);verifyEmpty(t,ui.Episode.State().Preview);
end
function [E,P]=fixture(peak)
if nargin<1,peak=.5;end
raw=signal(600,121,169,peak);E=struct('Raw',raw,'Corrected',raw-100,'SampleHz',1,'SeedStartFrame',140,'SeedEndFrame',150,'Identity','Synthetic saved footprint');P=boiWholeEpisodeSettings;
end
function y=signal(n,a,b,peak)
x=(1:n)';p=max(0,min((x-a)/((b-a)*peak),(b-x)/((b-a)*(1-peak))));
y=100-12*p+.08*sin(x*.93)+.06*cos(x*.31);
end
function c=best(S,interval)
C=S.Proposals;if isempty(C),c=[];return;end
IoU=arrayfun(@(c)max(0,min(c.EndFrame,interval(2))-max(c.StartFrame,interval(1))+1)/(max(c.EndFrame,interval(2))-min(c.StartFrame,interval(1))+1),C);
[~,j]=max(IoU);c=C(j);
end
function assertCandidate(t,S,interval)
c=best(S,interval);assertNotEmpty(t,c);
IoU=max(0,min(c.EndFrame,interval(2))-max(c.StartFrame,interval(1))+1)/(max(c.EndFrame,interval(2))-min(c.StartFrame,interval(1))+1);
verifyGreaterThanOrEqual(t,IoU,.45);verifyEqual(t,c.Status,'pocket_candidate');
end
