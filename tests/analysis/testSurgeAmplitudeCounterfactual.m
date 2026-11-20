function tests=testSurgeAmplitudeCounterfactual
tests=functiontests(localfunctions);
end
function testRisingTail(t)
X=100*ones(1,40);P=zeros(size(X));P(21:30)=20;
R=analyzeSurgeAmplitudeCounterfactual(X,X+P,P,zeros(size(X)),25:30,5:24,5:24,21:30,20);
verifyEqual(t,R.StrictMeasuredPeakFraction,16/104,'AbsTol',1e-12);
verifyEqual(t,R.UnscreenedCounterfactualPeakFraction,.2,'AbsTol',1e-12);
verifyEqual(t,R.UnscreenedBaselineImposedFraction,.04,'AbsTol',1e-12);
verifyEqual(t,R.PreFramesWithPositiveIncrement,4);
end
function testOppositeSignBaseline(t)
X=100*ones(1,40);P=zeros(size(X));P(25:30)=20;N=zeros(size(X));N(21:24)=-20;
R=analyzeSurgeAmplitudeCounterfactual(X,X+P+N,P,N,25:30,5:24,5:24,25:30,20);
verifyEqual(t,R.StrictMeasuredPeakFraction,.25,'AbsTol',1e-12);
verifyEqual(t,R.UnscreenedBaselineNegativeFraction,-.04,'AbsTol',1e-12);
end
function testInvalidBaselineStaysUnavailable(t)
X=100*ones(1,40);P=zeros(size(X));P(25:30)=20;
R=analyzeSurgeAmplitudeCounterfactual(X,X+P,P,zeros(size(X)),25:30,5:24,5:23,25:30,20);
verifyTrue(t,isnan(R.StrictMeasuredPeakFraction));verifyEqual(t,R.StrictBaselineStatus,"insufficient_clean_prebaseline");
verifyEqual(t,R.UnscreenedObservedPeakFraction,.2,'AbsTol',1e-12);
end
function testDifferentExtrema(t)
X=100*ones(1,40);X(25)=130;P=zeros(size(X));P(26)=40;
R=analyzeSurgeAmplitudeCounterfactual(X,X+P,P,zeros(size(X)),25:30,5:24,5:24,25:30,20);
verifyEqual(t,R.NativePeakFrame,26);verifyEqual(t,R.UnscreenedBackgroundAtObservedPeak,0);
verifyEqual(t,R.UnscreenedAppliedAtObservedPeak,.4,'AbsTol',1e-12);
verifyEqual(t,R.UnscreenedSourcePeakFraction,.3,'AbsTol',1e-12);
end
function testSpatialDilution(t)
X=100*ones(1,40);P=zeros(size(X));P(25:30)=5;
R=analyzeSurgeAmplitudeCounterfactual(X,X+P,P,zeros(size(X)),25:30,5:24,5:24,25:30,20);
verifyEqual(t,R.PeakPositiveAppliedVsSameFrameSource,.05,'AbsTol',1e-12);
end
function testZeroAndTruncatedReference(t)
X=zeros(1,40);R=analyzeSurgeAmplitudeCounterfactual(X,X,X,X,25:30,5:24,5:24,25:30,20);
verifyEqual(t,R.StrictBaselineStatus,"nonpositive_baseline_or_missing_event_signal");verifyTrue(t,isnan(R.StrictMeasuredPeakFraction));
X=100*ones(1,40);R=analyzeSurgeAmplitudeCounterfactual(X,X,zeros(size(X)),zeros(size(X)),5:10,1:4,1:4,25:30,20);
verifyTrue(t,isnan(R.UnscreenedObservedPeakFraction));verifyEqual(t,R.NativeIntersectionFrames,0);
verifyTrue(t,isnan(R.PeakPositiveAppliedInNativeIntersection));
end
function testOccupancyAndCeiling(t)
C={ [1;2], [1;2], [1;3] };
verifyEqual(t,surgePersistentSupport(C,1:3,0),[1;2;3]);
verifyEqual(t,surgePersistentSupport(C,1:3,.5),[1;2]);
verifyEqual(t,surgePersistentSupport(C,1:3,.75),1);
end
function testEmptyCoreNoFallback(t)
verifyEmpty(t,surgePersistentSupport({1,2,3,4},1:4,.5));
end
function testSupportIgnoresOrder(t)
C={ [3;1], [2;1], [1;3] };
verifyEqual(t,surgePersistentSupport(C,[3 1 2],.5),[1;3]);
end
