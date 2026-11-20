function tests=testSurgeOnsetTracePanel
tests=functiontests(localfunctions);
end
function testContextAfterNeighbor(t)
x=100+max(0,(1:200)-100);blocked=false(size(x));blocked(75)=true;
A=estimateSurgeLocalOnset(x,120:150,1,blocked);B=estimateSurgeLocalOnset(x,120:150,1,blocked,"available");
verifyEqual(t,A.Status,"overlapping_detection_in_fit");verifyEqual(t,B.Status,"resolved");
verifyEqual(t,B.FitStartFrame,76);verifyEqual(t,B.OnsetFrame,101);verifyEqual(t,B.BaselineStartFrame,81);
end
function testNoCleanBaselineNoRescue(t)
x=100+max(0,(1:200)-100);blocked=false(size(x));blocked(110)=true;
R=estimateSurgeLocalOnset(x,120:150,1,blocked,"available");
verifyEqual(t,R.Status,"insufficient_clean_context");verifyTrue(t,isnan(R.ProvisionalAmplitude));
end
function testRecordingStartAvailable(t)
x=100+max(0,(1:100)-30);R=estimateSurgeLocalOnset(x,50:70,1,false(size(x)),"available");
verifyEqual(t,R.Status,"resolved");verifyEqual(t,R.FitStartFrame,1);verifyEqual(t,R.OnsetFrame,31);
end
function testDefaultFixedEquivalent(t)
x=100+max(0,(1:200)-100);b=false(size(x));
verifyEqual(t,estimateSurgeLocalOnset(x,120:150,1,b),estimateSurgeLocalOnset(x,120:150,1,b,"fixed"));
verifyEqual(t,estimateSurgeLocalOnset(x,120:150,1,b),estimateSurgeLocalOnset(x,120:150,1,b,"available"));
end
function testCannotFindBeforeCleanContext(t)
x=100+max(0,(1:200)-80);b=false(size(x));b(85)=true;
R=estimateSurgeLocalOnset(x,120:150,1,b,"available");verifyNotEqual(t,R.Status,"resolved");
end
function testMissingDataNotSkipped(t)
x=100+max(0,(1:200)-100);x(90)=NaN;b=false(size(x));b(75)=true;
R=estimateSurgeLocalOnset(x,120:150,1,b,"available");verifyEqual(t,R.Status,"nonfinite_fit");
end
function testLastNeighborWins(t)
x=100+max(0,(1:200)-100);b=false(size(x));b([62 75 78])=true;
R=estimateSurgeLocalOnset(x,120:150,1,b,"available");verifyEqual(t,R.FitStartFrame,79);
verifyEqual(t,R.OnsetFrame,101);
end
function testFirstAndLastFrames(t)
for shape=["linear","sine_squared"]
 e=surgeTracePanelEnvelope(150,51,15,shape);
 verifyEqual(t,find(e>0,1),51);verifyEqual(t,e(65:85),ones(1,21));
 verifyEqual(t,e(100:end),zeros(1,51));verifyTrue(t,all(e>=0&e<=1));
end
end
function testDistinctRiseShapes(t)
a=surgeTracePanelEnvelope(150,51,15,"linear");b=surgeTracePanelEnvelope(150,51,15,"sine_squared");
verifyEqual(t,a(51),1/15,'AbsTol',1e-12);verifyEqual(t,b(51),sin(pi/30)^2,'AbsTol',1e-12);
verifyEqual(t,a(58),8/15,'AbsTol',1e-12);
end
function testTerminalTruncation(t)
e=surgeTracePanelEnvelope(60,51,15,"linear");verifyEqual(t,numel(e),60);
verifyEqual(t,e(60),10/15,'AbsTol',1e-12);
end
