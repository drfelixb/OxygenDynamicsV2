function T = refreshStatsEventMetadata(T,M)
% Refresh all descriptive fields from the same recording metadata as the sites.
n = height(T);
T.RecordingID = repmat(string(M.RecordingID),n,1);
T.Experiment = repmat({M.DatafileID},n,1);
for field = {'Mouse','Condition','DrugID','Genotype','Promoter'}
    T.(field{1}) = repmat({M.(field{1})},n,1);
end
T.PuffStim = repmat(logical(M.PuffStim),n,1);
T.StatsRecordingIndex = repmat(M.RecordingIndex,n,1);
end
