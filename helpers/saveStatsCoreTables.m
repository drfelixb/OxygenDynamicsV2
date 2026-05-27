function saveStatsCoreTables(StatsOutputFolderPath,TableOxygenSinks,TableOxygenSinkEvents, ...
    TableOxygenSurges,TableOxygenSurgeEvents)
%SAVESTATSCORETABLES Save core stats tables with legacy variable names.

Table_OxygenSurges_OutCombo = TableOxygenSurges;
Table_OxygenSurgeEvents_OutCombo = TableOxygenSurgeEvents;
Table_OxygenSinks_OutCombo = TableOxygenSinks;
Table_OxygenSinkEvents_OutCombo = TableOxygenSinkEvents;

save(fullfile(StatsOutputFolderPath,'SurgeTable4LME.mat'),'Table_OxygenSurges_OutCombo');
save(fullfile(StatsOutputFolderPath,'SurgeEventTable.mat'),'Table_OxygenSurgeEvents_OutCombo');
save(fullfile(StatsOutputFolderPath,'SinkTable4LME.mat'),'Table_OxygenSinks_OutCombo');
save(fullfile(StatsOutputFolderPath,'SinkEventTable.mat'),'Table_OxygenSinkEvents_OutCombo');

end
