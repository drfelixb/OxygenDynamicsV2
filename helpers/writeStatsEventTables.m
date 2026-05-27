function writeStatsEventTables(OutputXlsx,TableOxygenSinkEvents,TableOxygenSurgeEvents)
%WRITESTATSEVENTTABLES Write optional sink/surge event sheets.

if ~isempty(TableOxygenSinkEvents)
    writetable(TableOxygenSinkEvents,OutputXlsx,'Sheet','OxySinkEvents');
end

if ~isempty(TableOxygenSurgeEvents)
    writetable(TableOxygenSurgeEvents,OutputXlsx,'Sheet','OxySurgeEvents');
end

end
