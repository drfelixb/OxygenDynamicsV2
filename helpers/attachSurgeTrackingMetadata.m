function E=attachSurgeTrackingMetadata(E,Map,P)
% Match by site/event identity and assert native bounds before attaching QC.
assert(height(E)==height(Map));
[found,row]=ismember([E.SurgeID E.EventID],[Map.SurgeID Map.EventID],'rows');
assert(all(found)&&numel(unique(row))==height(E),'Surge run identities must be unique.');
assert(isequal(E.NativeStartFrame,Map.NativeStartFrame(row))&&isequal(E.NativeEndFrame,Map.NativeEndFrame(row)));
fields={'CandidateRunID','AmbiguousTracking','ShapeChangeLinkCount','ShapeChangeLinkFrames', ...
 'MinimumMatchedMutualCoverage','MaximumMatchedAreaRatio','PotentialGapContinuation'};
fields=[fields surgeContactMetadataFields()];
for k=1:numel(fields),E.(fields{k})=Map.(fields{k})(row,:);end
E.SiteAssignmentAmbiguous=Map.SiteAssignmentAmbiguous(row);
E.TrackingMethod=repmat("adjacent_mutual_or_isolated_containment",height(E),1);
E.SiteAssignmentMethod=repmat("first_retained_event_footprint_overlap",height(E),1);
E.TrackingOverlapFraction=repmat(P.surgeTrackingOverlapFraction,height(E),1);
E.TrackingContainmentFraction=repmat(P.surgeTrackingContainmentFraction,height(E),1);
E.TrackingMaxAreaRatio=repmat(P.surgeTrackingMaxAreaRatio,height(E),1);
E.GapReviewMaxSec=repmat(P.surgeGapReviewMaxSec,height(E),1);
E.SiteOverlapFraction=repmat(P.surgeSiteOverlapFraction,height(E),1);
end
