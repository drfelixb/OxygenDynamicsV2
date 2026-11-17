function tests=testSurgeBranchPolicy
tests=functiontests(localfunctions);
end
function setupOnce(~)
setupOxygenDynamicsPath;
end
function testMajoritySplitKeepsBothChildren(t)
P=createOxygenMasterParams(4.75,1);F=[repmat({regions({1:1000})},1,7) repmat({regions({1:550,551:1000})},1,7)];
[R,Q,E]=compareSurgeBranchPolicy(F,P,"majority_shape");
verifyEqual(t,Q.DurationFrames,[14;7]);verifyEqual(t,Q.KeptAsEvent,[true;false]);verifyEqual(t,R{2,8},(551:1000)');
verifyEqual(t,sum(E.Contact),2);verifyEqual(t,sum(E.Linked & E.Contact),1);verifyTrue(t,all(Q.AmbiguousTracking));
[~,Q]=compareSurgeBranchPolicy(F,P,"isolated_shape");verifyEqual(t,Q.DurationFrames,[7;7;7]);
end
function testEqualSplitUnresolved(t)
P=createOxygenMasterParams(4.75,1);F={regions({1:1000}),regions({1:500,501:1000})};
for policy=["isolated_shape","majority_shape","split_only","segment_contacts"]
 [~,Q,E]=compareSurgeBranchPolicy(F,P,policy);verifyEqual(t,height(Q),3);verifyFalse(t,any(E.Linked));
end
end
function testMajorityMergeJoinsIndependentSources(t)
P=createOxygenMasterParams(4.75,1);F={regions({1:550,551:1000}),regions({1:1000})};
[R,Q,E]=compareSurgeBranchPolicy(F,P,"majority_shape");verifyEqual(t,R{1,2},(1:1000)');
verifyEqual(t,Q.DurationFrames,[2;1]);verifyEqual(t,sum(E.Linked & E.Contact),1);
for policy=["isolated_shape","split_only","segment_contacts"]
 [~,Q]=compareSurgeBranchPolicy(F,P,policy);verifyEqual(t,height(Q),3);
end
end
function testCurrentPrimaryAlsoCanSwitchIdentity(t)
P=createOxygenMasterParams(4.75,1);
% Independent source A occupies 1:700 before contact and 1:400 after;
% B occupies 701:1100 before and 401:1100 after. Contact masks cannot
% determine physiological identity: dominant overlap follows A then B.
F={regions({1:700,701:1100}),regions({1:1100}),regions({1:400,401:1100})};
for policy=["isolated_shape","majority_shape","split_only"]
 [R,~,E]=compareSurgeBranchPolicy(F,P,policy);verifyEqual(t,R{1,1},(1:700)');verifyEqual(t,R{1,3},(401:1100)');
 verifyEqual(t,sum(E.Linked & E.Contact),2);
end
[~,Q,E]=compareSurgeBranchPolicy(F,P,"segment_contacts");verifyEqual(t,height(Q),5);verifyFalse(t,any(E.Linked));
end
function testNewMajorityCanSwitchIdentity(t)
P=createOxygenMasterParams(4.75,1);F={regions({1:550,551:1000}),regions({1:1000}),regions({1:450,451:1000})};
[R,~,~]=compareSurgeBranchPolicy(F,P,"majority_shape");verifyEqual(t,R{1,1},(1:550)');verifyEqual(t,R{1,3},(451:1000)');
[~,Q]=compareSurgeBranchPolicy(F,P,"isolated_shape");verifyEqual(t,height(Q),5);
end
function testIndependentNeighborsRemainIndependent(t)
P=createOxygenMasterParams(4.75,1);F=repmat({regions({1:550,1001:1550})},1,20);
for policy=["isolated_shape","majority_shape","split_only","segment_contacts"]
 [~,Q,E]=compareSurgeBranchPolicy(F,P,policy);verifyEqual(t,Q.DurationFrames,[20;20]);verifyFalse(t,any(E.Contact));
end
end
function testGapCannotCreateQualifiedEvent(t)
P=createOxygenMasterParams(4.75,1);F=[repmat({regions({1:550})},1,6) {[]} repmat({regions({1:550})},1,6)];
for policy=["isolated_shape","majority_shape","split_only","segment_contacts"]
 [R,Q,E]=compareSurgeBranchPolicy(F,P,policy);verifyEqual(t,Q.DurationFrames,[6;6]);verifyFalse(t,any(Q.KeptAsEvent));
 verifyTrue(t,all(cellfun(@isempty,R(:,7))));verifyFalse(t,any(E.FromFrame==7|E.ToFrame==7));
end
end
function testCandidatePermutationAndProductionEquivalence(t)
P=createOxygenMasterParams(4.75,1);rng(923);
for trial=1:30
 F=cell(1,5);G=F;
 for f=1:5
  labels=randi([0 4],60,1);C={};for k=1:4,px=find(labels==k);if ~isempty(px),C{end+1}=px;end;end %#ok<AGROW>
  F{f}=regions(C);G{f}=F{f}(randperm(numel(F{f})));
 end
 [expected,I]=trackSurgeCandidates(F,P.ThresholMinddur_Surges,.6,.8,2);
 [R,Q]=compareSurgeBranchPolicy(F,P,"isolated_shape");verifyEqual(t,R,expected);verifyEqual(t,Q.AmbiguousTracking,I.AmbiguousTracking);
 for policy=["isolated_shape","majority_shape","split_only","segment_contacts"]
  [R,Q,E]=compareSurgeBranchPolicy(F,P,policy);[S,V,W]=compareSurgeBranchPolicy(G,P,policy);
  verifyEqual(t,R,S);verifyEqual(t,Q,V);verifyEqual(t,E,W);
 end
end
end
function testGeometryGuardsRemainActive(t)
P=createOxygenMasterParams(4.75,1);
F={regions({1:1000}),regions({1:490,491:1000})};
[~,~,E]=compareSurgeBranchPolicy(F,P,"majority_shape");verifyEqual(t,sum(E.Linked),1);
F={regions({1:400}),regions({1:801})};
[~,~,E]=compareSurgeBranchPolicy(F,P,"majority_shape");verifyFalse(t,any(E.Linked));
% 550/1000 overlap is a majority, but neither region is 80% contained.
F={regions({1:1000}),regions({451:1450,1:400})};[~,~,E]=compareSurgeBranchPolicy(F,P,"majority_shape");
verifyFalse(t,any(E.Linked));
end
function S=regions(C)
S=struct('PixelIdxList',{});for k=1:numel(C),S(k).PixelIdxList=C{k}(:);end
end
