function R=appendBOIEventReferenceSummary(R,E)
% Quality counts are separate from numerical completeness and review status.
if ~istable(E)||~ismember('EventReferenceVersion',E.Properties.VariableNames),return;end
P=boiEventReferencePolicy;n=height(R);
R.EventReferenceVersion=repmat(string(P.Version),n,1);
fields={'NumEventReferenceEvents','NumAvailableEventAmplitudes','NumFlaggedReferenceEvents', ...
    'NumFlaggedReferenceContributors','NumShortReferences','NumOverlappingReferences', ...
    'NumPostEventReferences','NumMissingReferenceSampleEvents','NumAboveRecordingReferenceEvents', ...
    'NumUnassessableRecordingReferences'};
for f=fields,R.(f{1})=zeros(n,1);end
R.IncludesFlaggedReferences=false(n,1);
for i=1:n
    mask=true(height(E),1);
    keys=intersect({'RecordingID','Experiment','Mouse','Condition','DrugID','Genotype','Promoter','PuffStim'}, ...
        intersect(R.Properties.VariableNames,E.Properties.VariableNames),'stable');
    for f=keys,mask=mask & string(E.(f{1}))==string(R.(f{1})(i));end
    if any(mask)
        R.EventReferenceVersion(i)=strjoin(unique(string(E.EventReferenceVersion(mask))),", ");
    elseif ismember('IntensityRatiosOffsetCorrected',R.Properties.VariableNames) && R.IntensityRatiosOffsetCorrected(i)
        policy=boiEventReferencePolicy(0);R.EventReferenceVersion(i)=string(policy.Version);
    end
    T=E(mask,:);a=getBOISinkBurdenAmplitude(T);flag=T.EventReferenceNeedsReview;
    if ismember('ReviewedBurdenValuesApplied',T.Properties.VariableNames)
        % Automatic quality fields remain evidence, not QC of reviewed references.
        flag=flag & ~T.ReviewedBurdenValuesApplied;
    end
    contributor=isfinite(a);
    if ismember('PerEventBurdenContribution',T.Properties.VariableNames),contributor=isfinite(T.PerEventBurdenContribution);end
    values=[height(T),sum(T.EventAmplitudeAvailable),sum(flag),sum(flag&contributor), ...
        sum(T.EventReferenceShort),sum(T.EventReferenceOverlapping),sum(T.EventReferencePostEvent), ...
        sum(T.EventReferenceMissingSamplesFlag),sum(T.AboveRecordingReference==1),sum(isnan(T.AboveRecordingReference))];
    for j=1:numel(fields),R.(fields{j})(i)=values(j);end
    R.IncludesFlaggedReferences(i)=any(flag&contributor);
end
end
