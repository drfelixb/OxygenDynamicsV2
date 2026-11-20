function tests=testSurgeAmplitudeEligibility
tests=functiontests(localfunctions);
end
function R=assess(y,onset,status,blocked)
if nargin<2,onset=41;end
if nargin<3,status="resolved";end
if nargin<4,blocked=false(size(y));end
R=assessSurgeAmplitudeEligibility(y,51:60,1,blocked,onset,status);
end
function testPositiveAndPeakTie(t)
y=100*ones(1,80);y(51:60)=120;R=assess(y);
verifyEqual(t,R.ProvisionalPositiveAmplitude,.2,'AbsTol',1e-12);
verifyEqual(t,R.NativePeakFrame,51);verifyTrue(t,R.PositiveAcrossReferenceHalves);
end
function testNegativePreservedNotReported(t)
y=100*ones(1,80);y(51:60)=90;R=assess(y);
verifyEqual(t,R.AmplitudeStatus,"raw_direction_conflict");verifyEqual(t,R.SignedRawAmplitude,-.1,'AbsTol',1e-12);
verifyTrue(t,isnan(R.ProvisionalPositiveAmplitude));verifyTrue(t,R.ArithmeticValid);
end
function testZeroNotPositive(t)
R=assess(100*ones(1,80));verifyEqual(t,R.AmplitudeStatus,"no_positive_raw_change");verifyFalse(t,R.PositiveAmplitudeEligible);
end
function testMissingOnsetAndReference(t)
y=100*ones(1,80);verifyEqual(t,assess(y,NaN,"model_disagreement").AmplitudeStatus,"onset_unresolved");
verifyEqual(t,assess(y,20).AmplitudeStatus,"incomplete_reference");
verifyEqual(t,assess(y,52).AmplitudeStatus,"invalid_onset");
end
function testExclusionAndMissingFrames(t)
y=100*ones(1,80);blocked=false(size(y));blocked(30)=true;
verifyEqual(t,assess(y,41,"resolved",blocked).AmplitudeStatus,"overlapping_reference");
y(30)=NaN;verifyEqual(t,assess(y).AmplitudeStatus,"nonfinite_reference");
y(30)=100;y(55)=NaN;verifyEqual(t,assess(y).AmplitudeStatus,"missing_native_signal");
end
function testNonpositiveDenominator(t)
y=100*ones(1,80);y(21:40)=0;verifyEqual(t,assess(y).AmplitudeStatus,"nonpositive_reference");
end
function testReferenceSensitivityDoesNotSelectAmplitude(t)
y=100*ones(1,80);y(21:30)=90;y(31:40)=110;y(51:60)=105;R=assess(y);
verifyEqual(t,R.SignedRawAmplitude,.05,'AbsTol',1e-12);verifyTrue(t,R.PositiveAmplitudeEligible);
verifyFalse(t,R.PositiveAcrossReferenceHalves);verifyEqual(t,R.ReferenceHalfChangeFraction,.2,'AbsTol',1e-12);
verifyLessThan(t,R.SecondHalfAmplitude,0);
end
function testGainAndSampling(t)
y=100*ones(1,160);y(101:120)=125;blocked=false(size(y));
a=assessSurgeAmplitudeEligibility(y,101:120,2,blocked,81,"resolved");
b=assessSurgeAmplitudeEligibility(7*y,101:120,2,blocked,81,"resolved");
verifyEqual(t,a.ReferenceStartFrame,41);verifyEqual(t,a.SignedRawAmplitude,b.SignedRawAmplitude,'AbsTol',1e-12);
end
