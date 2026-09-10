function tests=testSurgeOnsetModelSelection
tests=functiontests(localfunctions);
end
function R=fixture(score,onset)
R=struct('Status',"resolved",'ScoreImprovement',score,'OnsetFrame',onset,'FitStartFrame',60,'FitEndFrame',124, ...
 'ProfileStartFrame',onset-1,'ProfileEndFrame',onset+1,'BaselineStartFrame',onset-20,'BaselineEndFrame',onset-1, ...
 'BaselineMean',100,'ProvisionalAmplitude',.2,'BaselineStatus',"provisional_valid");
end
function testHigherScoreNotHigherAmplitude(t)
a=fixture(30,101);b=fixture(20,110);b.ProvisionalAmplitude=.8;R=selectSurgeOnsetModel(a,b,1);
verifyEqual(t,R.SelectedModel,"rising");verifyEqual(t,R.ProvisionalAmplitude,.2);
end
function testDisagreementMissing(t)
R=selectSurgeOnsetModel(fixture(30,100),fixture(29,110),1);
verifyEqual(t,R.Status,"model_disagreement");verifyTrue(t,isnan(R.OnsetFrame));verifyTrue(t,isnan(R.ProvisionalAmplitude));
end
function testProfileUnion(t)
a=fixture(30,100);b=fixture(29,104);a.ProfileStartFrame=95;b.ProfileEndFrame=108;
verifyEqual(t,selectSurgeOnsetModel(a,b,1).Status,"model_uncertainty");
end
function testBestUnresolvedNoRescue(t)
a=fixture(30,100);a.Status="broad_profile_unresolved";b=fixture(25,101);
verifyEqual(t,selectSurgeOnsetModel(a,b,1).Status,"best_model_unresolved");
end
function testNearUnresolvedVeto(t)
a=fixture(30,100);b=fixture(29,101);b.Status="search_boundary_unresolved";
verifyEqual(t,selectSurgeOnsetModel(a,b,1).Status,"model_uncertainty");
end
function testWeakUnresolvedNoVeto(t)
a=fixture(30,100);b=fixture(20,101);b.Status="search_boundary_unresolved";
verifyEqual(t,selectSurgeOnsetModel(a,b,1).Status,"resolved");
end
function testFamilyPenalty(t)
verifyEqual(t,selectSurgeOnsetModel(fixture(11,100),fixture(10,101),1).Status,"no_model_evidence");
end
function testMissingBaselinePreserved(t)
a=fixture(30,100);a.ProvisionalAmplitude=NaN;a.BaselineStatus="missing_native_signal";
R=selectSurgeOnsetModel(a,fixture(20,101),1);verifyEqual(t,R.Status,"resolved");verifyTrue(t,isnan(R.ProvisionalAmplitude));
end
function testFallingExcluded(t)
a=fixture(100,100);a.Status="not_a_rising_change";
verifyEqual(t,selectSurgeOnsetModel(a,fixture(20,101),1).SelectedModel,"pulse");
end
function testTieAndSampling(t)
R=selectSurgeOnsetModel(fixture(30,100),fixture(30,108),2);verifyEqual(t,R.SelectedModel,"rising");verifyEqual(t,R.ModelGapSec,4);
end
function testSharedContextFailure(t)
a=fixture(NaN,NaN);a.Status="insufficient_clean_context";
verifyEqual(t,selectSurgeOnsetModel(a,a,1).Status,"insufficient_clean_context");
end
function testContextMismatch(t)
a=fixture(30,100);b=a;b.FitStartFrame=61;
verifyError(t,@()selectSurgeOnsetModel(a,b,1),'OxygenDynamics:OnsetContextMismatch');
end
