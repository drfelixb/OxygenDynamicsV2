function tests=testSurgeSpatialTracking
tests=functiontests(localfunctions);
end
function setupOnce(~)
setupOxygenDynamicsPath;
end
function testPhysicalAreaConversion(t)
for px=[2.35 4.75 6.75]
 P=createOxygenMasterParams(px,1);a=P.ThresholdMinsize_Surges;
 verifyGreaterThanOrEqual(t,a*px^2,P.surgeMinAreaUm2);
 verifyLessThan(t,(a-1)*px^2,P.surgeMinAreaUm2);
end
verifyEqual(t,createOxygenMasterParams(4.75,1).ThresholdMinsize_Surges,400);
end
function testMovingMinimumSquareDoesNotDependOnInitialSeed(t)
F=cell(30,1);
for f=1:30,M=false(20,60);M(:,f:f+19)=true;F{f}=struct('PixelIdxList',find(M));end
[R,I]=trackSurgeCandidates(F,10,.6);
verifySize(t,R,[1 30]);verifyEqual(t,[I.NativeStartFrame I.NativeEndFrame],[1 30]);
verifyFalse(t,I.AmbiguousTracking);
end
function testGapCreatesEventsAndRetainsOneSite(t)
P=createOxygenMasterParams(4.75,1);F=cell(35,1);
for f=[1:10 12:21 26:35],F{f}=struct('PixelIdxList',(1:400)');end
[S,L,M]=buildTrackedOxygenSurgeSites(F,P);
verifySize(t,S,[1 35]);verifyEqual(t,countTrackedEvents(L),3);
verifyEqual(t,M.SurgeID,ones(3,1));verifyEqual(t,M.EventID,(1:3)');
verifyEqual(t,M.NativeStartFrame,[1;12;26]);
end
function testShortRunCannotAnchorSite(t)
P=createOxygenMasterParams(4.75,1);F=cell(30,1);
for f=[1:3 11:20],F{f}=struct('PixelIdxList',(1:400)');end
[S,~,M]=buildTrackedOxygenSurgeSites(F,P);
verifySize(t,S,[1 30]);verifyEqual(t,M.NativeStartFrame,11);verifyEqual(t,M.EventID,1);
end
function testSiteAnchorsDoNotChainOrJoinAdjacentRuns(t)
R=cell(3,40);R(1,1:10)={(1:100)'};R(2,12:21)={(31:130)'};R(3,23:32)={(61:160)'};
[S,M]=groupSurgeRunsIntoSites(R,.6);verifySize(t,S,[2 40]);verifyEqual(t,M.SurgeID,[1;1;2]);
R=cell(2,20);R(1,1:10)={(1:100)'};R(2,11:20)={(1:100)'};
[S,~]=groupSurgeRunsIntoSites(R,.6);verifySize(t,S,[2 20]);
end
function testMutualOverlapRejectsTinyContainedCandidate(t)
F={struct('PixelIdxList',(1:100)');struct('PixelIdxList',(1:20)')};
[R,~]=trackSurgeCandidates(F,1,.6);verifyEqual(t,nnz(~cellfun(@isempty,R)),2);verifySize(t,R,[2 2]);
end
function testSplitMergeFlagsAndNoDuplicateOwnership(t)
F={struct('PixelIdxList',(1:100)');struct('PixelIdxList',{(1:50)',(51:100)'});struct('PixelIdxList',(1:100)')};
[R,I]=trackSurgeCandidates(F,1,.6);verifyTrue(t,all(I.AmbiguousTracking));
for f=1:3,px=vertcat(R{:,f});verifyEqual(t,sort(px),(1:100)');end
% Exact threshold ties use the same canonical candidate regardless of input order.
[A,~]=trackSurgeCandidates(F,1,.5);F{2}=F{2}([2 1]);[B,~]=trackSurgeCandidates(F,1,.5);
verifyEqual(t,A,B);
end
function testRandomizedOwnershipAndPermutation(t)
rng(29);
for trial=1:20
 F=cell(20,1);
 for f=1:20
  labels=randi([0 5],60,1);F{f}=struct('PixelIdxList',{});
  for k=1:5,px=find(labels==k);if ~isempty(px),F{f}(end+1).PixelIdxList=px;end;end
 end
 [A,I]=trackSurgeCandidates(F,1,.2);
 for f=1:20
  verifyEqual(t,sort(vertcat(A{:,f})),sort(vertcat(F{f}.PixelIdxList)));
  F{f}=F{f}(randperm(numel(F{f})));
 end
 [B,J]=trackSurgeCandidates(F,1,.2);verifyEqual(t,A,B);verifyEqual(t,I,J);
end
end
function testEmptyAndTerminalRuns(t)
[R,I]=trackSurgeCandidates(cell(5,1),3,.6);verifySize(t,R,[0 5]);verifyEqual(t,height(I),0);
P=createOxygenMasterParams(4.75,2.03);F=cell(50,1);first=51-ceil(P.ThresholMinddur_Surges);
for f=first:50,F{f}=struct('PixelIdxList',(1:400)');end
[~,~,M]=buildTrackedOxygenSurgeSites(F,P);verifyEqual(t,[M.NativeStartFrame M.NativeEndFrame],[first 50]);
end
function testTrackingMetadataMatchesIdentityAndQC(t)
P=createOxygenMasterParams(4.75,1);
M=table([2;1],[1;1],[21;1],[30;10],[false;true],[true;false], ...
 'VariableNames',{'SurgeID','EventID','NativeStartFrame','NativeEndFrame','SiteAssignmentAmbiguous','AmbiguousTracking'});
E=M([2 1],1:4);E=attachSurgeTrackingMetadata(E,M,P);
verifyEqual(t,E.AmbiguousTracking,[false;true]);verifyEqual(t,E.SiteAssignmentAmbiguous,[true;false]);
E.RecordingID=["R";"R"];E.BaselineStatus=["valid";"valid"];E.NormOxySurgeAmp=[.2;.1];
Q=createOxygenMeasurementQC(table("R",'VariableNames',{'RecordingID'}),table(),E);
verifyEqual(t,Q.AmbiguousTrackingEvents,[0;1]);verifyEqual(t,Q.TrackingNotAssessedEvents,[0;0]);
verifyEqual(t,Q.AmbiguousSiteAssignmentEvents,[0;1]);
end
