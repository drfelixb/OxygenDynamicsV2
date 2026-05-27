function StatsOutputFolder = findLatestStatsOutputFolder(SearchRoot)
%FINDLATESTSTATSOUTPUTFOLDER Return newest Stats_Output_* folder below SearchRoot.

if nargin<1 || isempty(SearchRoot)
    SearchRoot = pwd;
end

StatsRunsFolder = fullfile(SearchRoot,'Stats_Runs');
if isfolder(StatsRunsFolder)
    SearchRoot = StatsRunsFolder;
end

Folders = dir(fullfile(SearchRoot,'**','Stats_Output_*'));
Folders = Folders([Folders.isdir]);
if isempty(Folders)
    error('OxygenDynamics:NoStatsOutputFolder', ...
        'No Stats_Output_* folders were found below: %s',SearchRoot);
end

[~,Idx] = max([Folders.datenum]);
StatsOutputFolder = fullfile(Folders(Idx).folder,Folders(Idx).name);

end
