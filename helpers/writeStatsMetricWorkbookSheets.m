function [SinkMetricSheetNames,SurgeMetricSheetNames] = writeStatsMetricWorkbookSheets(OutputXlsx,ExportReady)
%WRITESTATSMETRICWORKBOOKSHEETS Write sink and surge metric sheets.

SinkMetricSheetNames = {'OxySinkArea_um','OxySinkFilledArea_um','OxySinkDiameter_um','OxySinkPerimeter_um', ...
    'OxySinkArea_Norm','OxySinkArea_Filled_Norm','NumOxySinkEvents_Norm', ...
    'MeanOxySinkEvent_Duration','MeanOxySinkEvent_NormAmp','MeanOxySinkEvent_SizeMod'};
SurgeMetricSheetNames = {'OxySurgeArea_um','OxySurgeFilledArea_um','OxySurgeDiameter_um','OxySurgePerimeter_um', ...
    'OxySurgeArea_Norm','OxySurgeArea_Filled_Norm','NumOxySurgeEvents_Norm', ...
    'MeanOxySurgeEvent_Duration','MeanOxySurgeEvent_NormAmp','MeanOxySurgeEvent_SizeMod'};

writeStatsMetricSheets(OutputXlsx,ExportReady,SinkMetricSheetNames,1);
writeStatsMetricSheets(OutputXlsx,ExportReady,SurgeMetricSheetNames,2);

end
