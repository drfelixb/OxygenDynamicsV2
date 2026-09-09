function [Sites,Logical,Map,RunQC,GapReview] = buildTrackedOxygenSurgeSites(Frames,P)
% Detect contiguous runs, retain rejected-run provenance, then group sites.
[Runs,Info]=trackSurgeCandidates(Frames,P.ThresholMinddur_Surges,P.surgeTrackingOverlapFraction, ...
 P.surgeTrackingContainmentFraction,P.surgeTrackingMaxAreaRatio);
[Info,GapReview]=createSurgeGapReview(Runs,Info,P.fs,P.surgeGapReviewMaxSec,P.surgeTrackingOverlapFraction);
keep=Info.KeptAsEvent;
[Sites,Map]=groupSurgeRunsIntoSites(Runs(keep,:),P.surgeSiteOverlapFraction);
fields={'CandidateRunID','AmbiguousTracking','ShapeChangeLinkCount','ShapeChangeLinkFrames', ...
 'MinimumMatchedMutualCoverage','MaximumMatchedAreaRatio','PotentialGapContinuation'};
for k=1:numel(fields),Map.(fields{k})=Info.(fields{k})(keep,:);end
Logical=~cellfun(@isempty,Sites);
assert(countTrackedEvents(Logical)==height(Map),'Site grouping changed the retained event count.');
RunQC=Info;RunQC.DurationSec=RunQC.DurationFrames/P.fs;
RunQC.MinimumDurationFrames=repmat(ceil(P.ThresholMinddur_Surges),height(RunQC),1);
RunQC.RejectionReason=repmat("below_minimum_contiguous_duration",height(RunQC),1);
RunQC.RejectionReason(keep)="retained_native_event";
RunQC.SurgeID=nan(height(RunQC),1);RunQC.EventID=nan(height(RunQC),1);
RunQC.SurgeID(keep)=Map.SurgeID;RunQC.EventID(keep)=Map.EventID;
end
