function saveStatsCoreTables(StatsOutputFolderPath,TableOxygenSinks,TableOxygenSinkEvents, ...
    TableOxygenSurges,TableOxygenSurgeEvents)
%SAVESTATSCORETABLES Save core stats tables with legacy variable names.

Table_OxygenSurges_OutCombo = TableOxygenSurges;
Table_OxygenSurgeEvents_OutCombo = TableOxygenSurgeEvents;
Table_OxygenSinks_OutCombo = TableOxygenSinks;
Table_OxygenSinkEvents_OutCombo = TableOxygenSinkEvents;

saveStatsMATFile(fullfile(StatsOutputFolderPath,'SurgeTable4LME.mat'),struct('Table_OxygenSurges_OutCombo',Table_OxygenSurges_OutCombo));
saveStatsMATFile(fullfile(StatsOutputFolderPath,'SurgeEventTable.mat'),struct('Table_OxygenSurgeEvents_OutCombo',Table_OxygenSurgeEvents_OutCombo));
saveStatsMATFile(fullfile(StatsOutputFolderPath,'SinkTable4LME.mat'),struct('Table_OxygenSinks_OutCombo',Table_OxygenSinks_OutCombo));
saveStatsMATFile(fullfile(StatsOutputFolderPath,'SinkEventTable.mat'),struct('Table_OxygenSinkEvents_OutCombo',Table_OxygenSinkEvents_OutCombo));

end
