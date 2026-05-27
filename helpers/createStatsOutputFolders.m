function OutputFolders = createStatsOutputFolders(MasterFolder,OutputRoot)
%CREATESTATSOUTPUTFOLDERS Create timestamped stats and figure output folders.

if nargin<2 || isempty(OutputRoot)
    OutputRoot = 'Stats_Runs';
end

Timestamp = char(datetime('now','Format','yyyyMMdd''T''HHmmss'));
OutputFolders = struct();
OutputFolders.Timestamp = Timestamp;
OutputFolders.Root = fullfile(MasterFolder,OutputRoot);
OutputFolders.Stats = fullfile(OutputFolders.Root,['Stats_Output_',Timestamp]);
OutputFolders.Figures = fullfile(OutputFolders.Root,['Figures_Output_',Timestamp]);

mkdirIfMissing(OutputFolders.Root);
mkdirIfMissing(OutputFolders.Stats);
mkdirIfMissing(OutputFolders.Figures);

end
