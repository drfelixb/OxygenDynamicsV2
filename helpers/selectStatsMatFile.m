function MatFile = selectStatsMatFile(SourceFolder,NamePattern,Description,RecordingId)
%SELECTSTATSMATFILE Select the first matching MAT file for stats loading.

Matches = dir(fullfile(SourceFolder,'*.mat'));
Matches = Matches(contains({Matches.name},NamePattern));

if isempty(Matches)
    error('No %s MAT file was found in %s for recording %s.',Description,SourceFolder,RecordingId);
elseif numel(Matches)>1
    warning('OxygenDynamics:MultipleStatsMatFiles', ...
        'Multiple %s MAT files were found in %s. Using %s.',Description,SourceFolder,Matches(1).name);
end

MatFile = fullfile(Matches(1).folder,Matches(1).name);

end
