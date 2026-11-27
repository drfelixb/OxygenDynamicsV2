function T=boiIntensitySummary(rows)
% A mixed-channel recording can appear once under each definition.
if ismember('AnalysisStatus',rows.Properties.VariableNames)
    rows=rows(string(rows.AnalysisStatus)~="not_analyzed",:);
end
versions=["0.4.0-draft";"0.5.0-offset"]; counts=zeros(2,1);
for k=1:2
    use=string(rows.IntensityRatioDefinition)==versions(k);
    counts(k)=numel(unique(string(rows.RecordingID(use))));
end
T=table(versions,[false;true],counts,'VariableNames', ...
    {'IntensityRatioDefinition','IntensityRatiosOffsetCorrected','Recordings'});
local=boiEventReferencePolicy;localOffset=boiEventReferencePolicy(0);
episode=boiEpisodeReferencePolicy;episodeOffset=boiEpisodeReferencePolicy(0);
T.EventReferenceVersion=string({local.Version;localOffset.Version});
T.EpisodeReferenceVersion=string({episode.Version;episodeOffset.Version});
end
