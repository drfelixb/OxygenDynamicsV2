function R=appendBOIEpisodeReferenceSummary(R,E)
% Companion counts distinguish unavailable derived references from valid totals.
n=height(R);R.EpisodeReferenceVersion=repmat("legacy_automatic",n,1);
names={'NumEpisodeReferenceEvents','NumValidEpisodeReferenceEvents', ...
    'NumPreEpisodeReferenceEvents','NumOldEpisodeReferenceEvents', ...
    'NumStartReferenceUnresolvedEvents','NumUnavailableEpisodeEvidenceEvents', ...
    'NumEpisodeReferenceReviewEvents'};
for f=names,R.(f{1})=zeros(n,1);end
if ~istable(E)||~ismember('EpisodeReferenceVersion',E.Properties.VariableNames),return;end
P=boiEpisodeReferencePolicy;R.EpisodeReferenceVersion(:)=string(P.Version);
for i=1:n
    mask=true(height(E),1);
    keys=intersect({'RecordingID','Experiment','Mouse','Condition','DrugID','Genotype','Promoter','PuffStim'}, ...
        intersect(R.Properties.VariableNames,E.Properties.VariableNames),'stable');
    for f=keys,mask=mask & string(E.(f{1}))==string(R.(f{1})(i));end
    if any(mask)
        R.EpisodeReferenceVersion(i)=strjoin(unique(string(E.EpisodeReferenceVersion(mask))),", ");
    elseif ismember('IntensityRatiosOffsetCorrected',R.Properties.VariableNames) && R.IntensityRatiosOffsetCorrected(i)
        policy=boiEpisodeReferencePolicy(0);R.EpisodeReferenceVersion(i)=string(policy.Version);
    end
    T=E(mask,:);status=string(T.EpisodeReferenceStatus);
    R.NumEpisodeReferenceEvents(i)=height(T);
    R.NumValidEpisodeReferenceEvents(i)=sum(status=="valid");
    R.NumPreEpisodeReferenceEvents(i)=sum(T.EpisodeReferenceKind=="pre_episode" & status=="valid");
    R.NumOldEpisodeReferenceEvents(i)=sum(status=="reference_too_old_review");
    R.NumStartReferenceUnresolvedEvents(i)=sum(status=="recording_start_recovery_unclear");
    R.NumUnavailableEpisodeEvidenceEvents(i)=sum(status=="saved_evidence_unavailable");
    R.NumEpisodeReferenceReviewEvents(i)=sum(T.EpisodeReferenceNeedsReview);
end
end
