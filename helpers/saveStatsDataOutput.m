function saveStatsDataOutput(StatsOutputFolderPath,StatsDataOutput,IsBLI)
%SAVESTATSDATAOUTPUT Save the main stats DataOutput.mat with legacy fields.

OutputPath = fullfile(StatsOutputFolderPath,'DataOutput.mat');
CommonFields = {'Table_OxygenSurges_OutCombo','Table_OxygenSurgeEvents_OutCombo', ...
    'Table_OxygenSinks_OutCombo','Table_OxygenSinkEvents_OutCombo','FiltersOxySinksMetrics', ...
    'FiltersOxySurgesMetrics','Filters_ROIsandEvents','ExportTraces','NumOngoingOxysinks', ...
    'NumOngoingOxysinksPerMm2','SinkCountAreaNormalization','TotalSinkArea_Norm', ...
    'NumOngoingOxysurges','TotalSurgeArea','SinksRaster','SurgesRaster','StatsInfo','HypoxicBurden'};
BLIFields = {'Behaviour_data_combo','Behaviouraldatalogical','ROIs_Traces','ExportTraceCorrs', ...
    'TraceCorrs'};

FieldsToSave = CommonFields;
if IsBLI
    FieldsToSave = [FieldsToSave,BLIFields];
end
FieldsToSave = FieldsToSave(isfield(StatsDataOutput,FieldsToSave));

save(OutputPath,'-struct','StatsDataOutput',FieldsToSave{:});

end
