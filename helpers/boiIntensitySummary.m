function T=boiIntensitySummary(rows)
% A mixed-channel recording can appear once under each definition.
versions=["0.4.0-draft";"0.5.0-offset"]; counts=zeros(2,1);
for k=1:2
    use=string(rows.IntensityRatioDefinition)==versions(k);
    counts(k)=numel(unique(string(rows.RecordingID(use))));
end
T=table(versions,[false;true],counts,'VariableNames', ...
    {'IntensityRatioDefinition','IntensityRatiosOffsetCorrected','Recordings'});
end
