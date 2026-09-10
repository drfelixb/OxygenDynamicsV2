function tests=testSurgeUnseenEnvelope
tests=functiontests(localfunctions);
end
function testFirstSampleAndRange(t)
for shape=["gamma","exponential","quadratic"]
 [e,last]=surgeUnseenEnvelope(600,101,23,shape);verifyEqual(t,find(e>0,1),101);
 verifyTrue(t,all(e>=0&e<=1+eps));verifyEqual(t,e(last+1:end),zeros(1,600-last));
end
end
function testGammaPeak(t)
e=surgeUnseenEnvelope(300,101,7,"gamma");verifyEqual(t,e(107),1,'AbsTol',1e-12);verifyLessThan(t,e(108),1);
end
function testPlateauAndAsymmetry(t)
e=surgeUnseenEnvelope(300,101,7,"quadratic");verifyEqual(t,e(107:118),ones(1,12));
verifyEqual(t,e(101),1/49,'AbsTol',1e-12);verifyEqual(t,e(132),0,'AbsTol',1e-12);
end
function testTruncation(t)
[e,last]=surgeUnseenEnvelope(120,101,23,"exponential");verifyGreaterThan(t,last,120);verifyEqual(t,numel(e),120);
end
