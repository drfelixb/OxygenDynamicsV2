function tests=testSurgeContactReview
tests=functiontests(localfunctions);
end
function setupOnce(~)
setupOxygenDynamicsPath;
end
function testSplitRetainsRejectedSiblingAndDeduplicatesContact(t)
P=createOxygenMasterParams(4.75,1);F=splitFixture(false);
[~,~,M,Q,~,E,C]=buildTrackedOxygenSurgeSites(F,P);
verifyEqual(t,Q.KeptAsEvent,[true;false]);verifyEqual(t,M.CandidateRunID,1);
verifyEqual(t,Q.ContactFrames,["6;7";"7"]);verifyEqual(t,Q.ContactFrameCount,[2;1]);
verifyEqual(t,Q.ContactEdgeCount,[2;1]);verifyEqual(t,Q.LinkedContactEdgeCount,[1;0]);
verifyEqual(t,Q.ContactNeighborCandidateRunIDs,["2";"1"]);
verifyEqual(t,Q.ContactWithRejectedCandidate,[true;false]);
verifyEqual(t,Q.ContactFrameFraction,[2/12;1]);
verifyEqual(t,Q.ContactFrameFootprintFraction,[1400/2200;1],'AbsTol',1e-12);
verifyEqual(t,[C.CandidateRunID C.Frame],[1 6;1 7;2 7]);
verifyEqual(t,C.OutgoingContactEdges,[2;0;0]);verifyEqual(t,C.IncomingContactEdges,[0;1;1]);
contact=E(E.Contact,:);verifyEqual(t,contact.PreviousCandidateRunID,[1;1]);
verifyEqual(t,contact.NextCandidateRunID,[1;2]);verifyEqual(t,contact.Linked,[true;false]);
verifyEqual(t,contact.NextKeptAsEvent,[true;false]);verifyTrue(t,isnan(contact.NextEventID(2)));
verifyTrue(t,all(E.ToFrame==E.FromFrame+1));
end
function testMergePreservesBothPredecessors(t)
P=createOxygenMasterParams(4.75,1);F=fliplr(splitFixture(false));
[~,~,~,Q,~,E,C]=buildTrackedOxygenSurgeSites(F,P);
contact=E(E.Contact,:);verifyEqual(t,height(contact),2);
verifyEqual(t,sort(contact.PreviousCandidateRunID),[1;2]);verifyEqual(t,contact.NextCandidateRunID,[1;1]);
verifyEqual(t,contact.NextPartnerCount,[2;2]);verifyEqual(t,nnz(contact.Linked),1);
verifyEqual(t,Q.ContactFrameCount,[2;1]);verifyEqual(t,height(C),3);
end
function testTwoRetainedNeighborsDoNotInflateEventCounts(t)
P=createOxygenMasterParams(4.75,1);[~,~,M,Q]=buildTrackedOxygenSurgeSites(splitFixture(true),P);
E=M(:,{'SurgeID','EventID','NativeStartFrame','NativeEndFrame'});E=attachSurgeTrackingMetadata(E,M,P);
E.RecordingID=repmat("R",height(E),1);E.BaselineStatus=repmat("valid",height(E),1);E.NormOxySurgeAmp=[.1;.2];
Stats=createOxygenMeasurementQC(table(["R";"Empty"],'VariableNames',{'RecordingID'}),table(),E);
s=Stats(Stats.EventType=="surge",:);
verifyEqual(t,s.DetectedEvents,[2;0]);verifyEqual(t,s.ContactTrackingEvents,[2;0]);
verifyEqual(t,s.ContactWithRejectedCandidateEvents,[0;0]);verifyEqual(t,s.ContactEventFrames,[3;0]);
verifyEqual(t,s.ContactEventDurationSec,[3;0]);verifyEqual(t,s.ContactTrackingNotAssessedEvents,[0;0]);
verifyEqual(t,nnz(Q.KeptAsEvent),2);
end
function testSecondsAndAreasUseCalibration(t)
for fs=[.5 1 2]
 for px=[2.35 4.75 6.75]
  P=createOxygenMasterParams(px,fs);[~,~,~,Q,~,~,C]=buildTrackedOxygenSurgeSites(splitFixture(false),P);
  verifyEqual(t,Q.ContactDurationSec,[2;1]/fs);verifyEqual(t,C.TimeSec,[5;6;6]/fs);
  verifyEqual(t,C.CandidateAreaUm2,[1400;1000;400]*px^2,'AbsTol',1e-9);
 end
end
end
function testNoContactAndEmptyRecordingAreAssessed(t)
P=createOxygenMasterParams(4.75,1);
for F={cell(1,0),cell(1,12),repmat({regions({1:1000})},1,12)}
 [~,~,~,Q,~,E,C]=buildTrackedOxygenSurgeSites(F{1},P);
 verifyEqual(t,height(C),0);verifyFalse(t,any(E.Contact));verifyFalse(t,any(Q.ContactFrameCount));
 verifyTrue(t,all(Q.ContactFrameFootprintFraction==0));
end
end
function testMissingFrameProducesNoContactLink(t)
P=createOxygenMasterParams(4.75,1);F=splitFixture(false);F{7}=[];
[~,~,~,Q,~,E,C]=buildTrackedOxygenSurgeSites(F,P);
verifyFalse(t,any(E.ToFrame==7|E.FromFrame==7));verifyEqual(t,height(C),0);verifyFalse(t,any(Q.ContactFrameCount));
end
function testUnassessedAndIncompleteMetadataAreDistinct(t)
Registry=table("R",'VariableNames',{'RecordingID'});
E=table("R","valid",.2,'VariableNames',{'RecordingID','BaselineStatus','NormOxySinkAmp'});
Q=createOxygenMeasurementQC(Registry,E,table());verifyEqual(t,Q.ContactTrackingNotAssessedEvents,[1;0]);
E.ContactFrameCount=0;
verifyError(t,@()createOxygenMeasurementQC(Registry,E,table()),'OxygenDynamics:InvalidContactQC');
end
function testIndependentPolicyGraphMatchesEveryEdge(t)
P=createOxygenMasterParams(4.75,1);
for F={splitFixture(false),splitFixture(true),fliplr(splitFixture(false))}
 [R,I,E]=trackSurgeCandidates(F{1},10,.6,.8,2);[S,Q,A]=compareSurgeBranchPolicy(F{1},P,"isolated_shape");
 verifyEqual(t,R,S);verifyEqual(t,I.AmbiguousTracking,Q.AmbiguousTracking);
 actual={'FromFrame','ToFrame','PreviousCandidateRunID','NextCandidateRunID','SharedPixels','PreviousPixels','NextPixels', ...
 'MutualCoverage','SmallerRegionCoverage','AreaRatio','PreviousPartnerCount','NextPartnerCount','PrimaryEligible','Linked','Contact'};
 verifyEqual(t,table2array(E(:,actual)),table2array(A));
end
end
function F=splitFixture(keepSibling)
% Prescribed candidates, all >=400 pixels. Tests tracking, not image filtering.
F=repmat({regions({1:1400})},1,12);F{7}=regions({1:1000,1001:1400});
% Later expansion adds new pixels without re-contacting the short sibling.
F(8:12)={regions({[1:1000 1401:2200]})};
if keepSibling,F(7:18)={regions({1:1000,1001:1400})};end
end
function S=regions(C)
S=struct('PixelIdxList',{});for k=1:numel(C),S(k).PixelIdxList=C{k}(:);end
end
