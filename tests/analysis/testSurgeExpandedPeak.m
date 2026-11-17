function tests=testSurgeExpandedPeak
tests=functiontests(localfunctions);
end
function [y,blocked]=fixture
y=100*ones(1,160);y(85)=130;y(100:120)=110;blocked=false(size(y));
end
function testEarlierPeak(t)
[y,b]=fixture;R=assessSurgeExpandedPeak(y,100:120,1,b,75,"resolved");
verifyEqual(t,R.ExpandedPeakFrame,85);verifyEqual(t,R.ExpandedSignedAmplitude,.3,'AbsTol',1e-12);
verifyEqual(t,R.ReferenceMean,100);verifyEqual(t,R.AddedFrameCount,25);
end
function testNeighborRefusesWholeExpansion(t)
[y,b]=fixture;b(90)=true;R=assessSurgeExpandedPeak(y,100:120,1,b,75,"resolved");
verifyEqual(t,R.ExpandedStatus,"added_interval_neighbor_overlap");verifyTrue(t,isnan(R.ExpandedSignedAmplitude));
verifyEqual(t,R.SignedRawAmplitude,.1,'AbsTol',1e-12);
end
function testNonfiniteAdded(t)
[y,b]=fixture;y(90)=NaN;R=assessSurgeExpandedPeak(y,100:120,1,b,75,"resolved");
verifyEqual(t,R.ExpandedStatus,"nonfinite_added_interval");verifyTrue(t,R.ArithmeticValid);
end
function testReferenceExclusionPreserved(t)
[y,b]=fixture;b(60)=true;R=assessSurgeExpandedPeak(y,100:120,1,b,75,"resolved");
verifyEqual(t,R.ExpandedStatus,"overlapping_reference");verifyFalse(t,R.ExpandedArithmeticValid);
end
function testSignedAndUnresolved(t)
y=100*ones(1,160);y(75:120)=90;b=false(size(y));
R=assessSurgeExpandedPeak(y,100:120,1,b,75,"resolved");verifyEqual(t,R.ExpandedStatus,"raw_direction_conflict");
verifyEqual(t,R.ExpandedSignedAmplitude,-.1,'AbsTol',1e-12);verifyTrue(t,isnan(R.ExpandedPositiveAmplitude));
R=assessSurgeExpandedPeak(y,100:120,1,b,NaN,"model_disagreement");verifyFalse(t,R.ExpandedArithmeticValid);
end
function testNoAddedFramesAndTie(t)
[y,b]=fixture;R=assessSurgeExpandedPeak(y,100:120,1,b,100,"resolved");
verifyEqual(t,R.ExpandedPeakFrame,100);verifyEqual(t,R.AddedFrameCount,0);
verifyEqual(t,R.ExpandedSignedAmplitude,R.SignedRawAmplitude);
end
function testGainAndColumnVector(t)
[y,b]=fixture;a=assessSurgeExpandedPeak(y,100:120,1,b,75,"resolved");
c=assessSurgeExpandedPeak(7*y',100:120,1,b',75,"resolved");
verifyEqual(t,a.ExpandedSignedAmplitude,c.ExpandedSignedAmplitude,'AbsTol',1e-12);
end
