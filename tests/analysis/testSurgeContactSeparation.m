function tests=testSurgeContactSeparation
tests=functiontests(localfunctions);
end
function testPersistentResolvedPair(t)
[C,F,T,P,O]=fixture();[R,D]=separateSurgeCandidateContacts(C,F,T,P,O);
verifyEqual(t,numel(R{4}),2);verifyEqual(t,D.Outcome(end),"split_applied");verifyGreaterThan(t,D.SaddleDropFraction(end),.2);
end
function testPlateau(t)
[C,F,T,P,O]=fixture();F(:,:,4)=1;[R,D]=separateSurgeCandidateContacts(C,F,T,P,O);
verifyEqual(t,numel(R{4}),1);verifyEqual(t,D.Outcome(end),"insufficient_saddle_drop");
end
function testHistory(t)
[C,F,T,P,O]=fixture();[R,D]=separateSurgeCandidateContacts(C(3:4),F(:,:,3:4),T,P,O);
verifyEqual(t,numel(R{2}),1);verifyEqual(t,D.Outcome(end),"insufficient_history");
end
function testSinglePredecessor(t)
[C,F,T,P,O]=fixture();C(1:3)=C(4);[R,~]=separateSurgeCandidateContacts(C,F,T,P,O);
verifyEqual(t,numel(R{4}),1);
end
function testMarkerSeparation(t)
[C,F,T,P,O]=fixture();O.MinimumMarkerDistanceUm=1000;[R,D]=separateSurgeCandidateContacts(C,F,T,P,O);
verifyEqual(t,numel(R{4}),1);verifyEqual(t,D.Outcome(end),"markers_too_close");
end
function testChildArea(t)
[C,F,T,P,O]=fixture();P.ThresholdMinsize_Surges=2000;[R,D]=separateSurgeCandidateContacts(C,F,T,P,O);
verifyEqual(t,numel(R{4}),1);verifyEqual(t,D.Outcome(end),"child_filter_failed");
end
function testTissue(t)
[C,F,T,P,O]=fixture();T(:,91:end)=false;[R,D]=separateSurgeCandidateContacts(C,F,T,P,O);
verifyEqual(t,numel(R{4}),1);verifyEqual(t,D.Outcome(end),"child_filter_failed");
end
function testGap(t)
[C,F,T,P,O]=fixture();C{3}=struct('Area',{},'PixelIdxList',{});[R,~]=separateSurgeCandidateContacts(C,F,T,P,O);
verifyEqual(t,numel(R{4}),1);
end
function testOrder(t)
[C,F,T,P,O]=fixture();[R,D]=separateSurgeCandidateContacts(C,F,T,P,O);
for f=1:3,C{f}=flip(C{f});end
[R2,D2]=separateSurgeCandidateContacts(C,F,T,P,O);verifyEqual(t,R2,R);verifyEqual(t,D2,D);
end
function testExactConservation(t)
[C,F,T,P,O]=fixture();[A,~]=separateSurgeCandidateContacts(C,F,T,P,O);
for f=1:4
 expected=sort(vertcat(C{f}.PixelIdxList));actual=sort(vertcat(A{f}.PixelIdxList));
 verifyEqual(t,actual,expected);verifyEqual(t,numel(unique(actual)),numel(actual));
end
end
function testRecipeWindowAndRelativeAmplitude(t)
verifyEqual(t,surgeSeparationRecipe(512,512,100,2.35,"approach_pair"),zeros(512,512,2));
W=surgeSeparationRecipe(512,512,140,2.35,"separate_pair");
verifyGreaterThan(t,max(W,[],'all'),.19);verifyLessThanOrEqual(t,max(W,[],'all'),.2);
verifyEqual(t,surgeSeparationRecipe(512,512,181,2.35,"single_expanding"),zeros(512));
end
function testCrossingExchangesSpatialPositions(t)
A=surgeSeparationRecipe(512,512,101,2.35,"crossing_pair");
B=surgeSeparationRecipe(512,512,180,2.35,"crossing_pair");
verifyEqual(t,A(:,:,1),B(:,:,2)*1.25,'AbsTol',1e-14);
verifyEqual(t,A(:,:,2)*1.25,B(:,:,1),'AbsTol',1e-14);
end
function [C,F,T,P,O]=fixture()
P=createOxygenMasterParams(4.75,1);
O=struct('MinimumHistorySec',3,'MinimumMarkerDistanceUm',2*sqrt(P.surgeMinAreaUm2/pi),'MinimumSaddleDropFraction',.2);
[y,x]=ndgrid(1:120,1:180);T=true(size(x));
two=(x-60).^2+(y-60).^2<=15^2 | (x-120).^2+(y-60).^2<=15^2;
one=false(size(x));one(45:75,45:135)=true;
C=repmat({regionprops(two,'Area','PixelIdxList')},4,1);C{4}=regionprops(one,'Area','PixelIdxList');
F=repmat(single(exp(-((x-60).^2+(y-60).^2)/(2*12^2))+exp(-((x-120).^2+(y-60).^2)/(2*12^2))),1,1,4);
end
