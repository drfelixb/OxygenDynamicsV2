function [Sites,Logical,Map] = buildTrackedOxygenSurgeSites(Frames,P)
% Detect native runs, filter duration, then assign recurring sites separately.
[Runs,Info]=trackSurgeCandidates(Frames,P.ThresholMinddur_Surges,P.surgeTrackingOverlapFraction);
keep=(Info.NativeEndFrame-Info.NativeStartFrame+1)>=ceil(P.ThresholMinddur_Surges);
Runs=Runs(keep,:);Info=Info(keep,:);
[Sites,Map]=groupSurgeRunsIntoSites(Runs,P.surgeSiteOverlapFraction);
Map.AmbiguousTracking=Info.AmbiguousTracking;
Logical=~cellfun(@isempty,Sites);
assert(countTrackedEvents(Logical)==height(Map),'Site grouping changed the retained event count.');
end
