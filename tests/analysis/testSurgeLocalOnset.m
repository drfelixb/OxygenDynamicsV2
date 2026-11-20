function tests=testSurgeLocalOnset
tests=functiontests(localfunctions);
end
function testExactRamp(t)
x=100+max(0,(1:200)-100);R=estimateSurgeLocalOnset(x,120:150,1,false(size(x)));
verifyEqual(t,R.Status,"resolved");verifyEqual(t,R.OnsetFrame,101);
verifyEqual(t,R.BaselineStartFrame,81);verifyEqual(t,R.BaselineEndFrame,100);
verifyEqual(t,R.ProvisionalAmplitude,.5,'AbsTol',1e-12);
end
function testLinearAndConstant(t)
for x=[100*ones(200,1) (100+(1:200))']
 R=estimateSurgeLocalOnset(x,120:150,1,false(size(x)));verifyNotEqual(t,R.Status,"resolved");
end
end
function testFalling(t)
x=200-max(0,(1:200)-100);R=estimateSurgeLocalOnset(x,120:150,1,false(size(x)));
verifyEqual(t,R.Status,"not_a_rising_change");verifyTrue(t,isnan(R.ProvisionalAmplitude));
end
function testKnownNeighbor(t)
x=100+max(0,(1:200)-100);blocked=false(size(x));blocked(75)=true;
R=estimateSurgeLocalOnset(x,120:150,1,blocked);verifyEqual(t,R.Status,"overlapping_detection_in_fit");
blocked(:)=false;blocked(120:150)=true;R=estimateSurgeLocalOnset(x,120:150,1,blocked);verifyEqual(t,R.Status,"resolved");
end
function testBoundaryAndMissing(t)
x=100+max(0,(1:200)-100);R=estimateSurgeLocalOnset(x,40:60,1,false(size(x)));
verifyEqual(t,R.Status,"recording_boundary_unresolved");x(75)=NaN;
R=estimateSurgeLocalOnset(x,120:150,1,false(size(x)));verifyEqual(t,R.Status,"nonfinite_fit");
end
function testLimitNotOnset(t)
x=100+max(0,(1:200)-79);R=estimateSurgeLocalOnset(x,120:150,1,false(size(x)));
verifyEqual(t,R.Status,"search_boundary_unresolved");verifyTrue(t,isnan(R.OnsetFrame));
end
function testGainInvariant(t)
x=100+max(0,(1:200)-100);A=estimateSurgeLocalOnset(x,120:150,1,false(size(x)));
B=estimateSurgeLocalOnset(5*x,120:150,1,false(size(x)));
verifyEqual(t,A.OnsetFrame,B.OnsetFrame);verifyEqual(t,A.ProvisionalAmplitude,B.ProvisionalAmplitude,'AbsTol',1e-12);
end
function testFractionalSampling(t)
fs=2.5;x=100+max(0,((1:500)-250)/fs);R=estimateSurgeLocalOnset(x,300:375,fs,false(size(x)));
verifyEqual(t,R.OnsetFrame,251);verifyEqual(t,R.BaselineStartFrame,201);verifyEqual(t,R.BaselineEndFrame,250);
end
function testNoSearchOutsideLocalFit(t)
x=100+max(0,(1:200)-100);x(1)=NaN;x(180)=Inf;
R=estimateSurgeLocalOnset(x,120:150,1,false(size(x)));verifyEqual(t,R.Status,"resolved");
end
function testMissingPeakWindow(t)
x=100+max(0,(1:200)-100);x(140)=NaN;R=estimateSurgeLocalOnset(x,120:150,1,false(size(x)));
verifyEqual(t,R.Status,"resolved");verifyEqual(t,R.BaselineStatus,"missing_native_signal");
verifyTrue(t,isnan(R.ProvisionalAmplitude));
end
function testNonpositiveReference(t)
x=-100+max(0,(1:200)-100);R=estimateSurgeLocalOnset(x,120:150,1,false(size(x)));
verifyEqual(t,R.Status,"resolved");verifyEqual(t,R.BaselineStatus,"nonpositive_baseline");
verifyTrue(t,isnan(R.ProvisionalAmplitude));
end
function testDriftIsPreserved(t)
x=100+.1*(1:200)+max(0,(1:200)-100);R=estimateSurgeLocalOnset(x,120:150,1,false(size(x)));
verifyEqual(t,R.OnsetFrame,101);verifyEqual(t,R.BaselineMean,mean(x(81:100)),'AbsTol',1e-12);
verifyEqual(t,R.ProvisionalAmplitude,max(x(120:150))/mean(x(81:100))-1,'AbsTol',1e-12);
verifyGreaterThan(t,R.BaselineSlopePerSecOverFitMedian,0);
end
