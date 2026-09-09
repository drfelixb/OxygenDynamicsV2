function SaveResult = saveOxygenMasterOutputs(OutputData)
%SAVEOXYGENMASTEROUTPUTS Save oxygen master TIFF and MAT outputs.

disp('Saving manipulated data matrices');

OutputFolders = createOxygenOutputFolders(OutputData.RecordingFolder,OutputData.OverwriteOutputs);
AnalysisInfo = OutputData.AnalysisInfo;
AnalysisInfo.OutputFolders = OutputFolders;

saveMasterImageStacks(OutputFolders,OutputData.DatafileID,OutputData.IM_Notrend, ...
    OutputData.IM_Zframetime_smoothed,OutputData.IM_OxySinks_BW,OutputData.IM_OxySurges_BW);

Table_OxygenSinks_Out = OutputData.Table_OxygenSinks_Out;
Table_OxygenSinkEvents_Out = OutputData.Table_OxygenSinkEvents_Out;
OxySinkArea_all = OutputData.OxySinkArea_all;
Mean_ROI_TraceZ = OutputData.Mean_ROI_TraceZ;
Mean_OxySink_TraceZ = OutputData.Mean_OxySink_TraceZ;
Mean_OxySink_Trace_Convo = OutputData.Mean_OxySink_Trace_Convo;
Mean_OxySink_Trace_Raw = OutputData.Mean_OxySink_Trace_Raw;
OxySink_Map = OutputData.OxySink_Map;
Trace_PotentialNoise = OutputData.Trace_PotentialNoise;

save(fullfile(OutputFolders.OxySinksPath,['OxygenSinks_Urefined',OutputData.DatafileID,'.mat']), ...
    'Table_OxygenSinks_Out','Table_OxygenSinkEvents_Out','OxySinkArea_all','Mean_ROI_TraceZ', ...
    'Mean_OxySink_TraceZ','Mean_OxySink_Trace_Convo','Mean_OxySink_Trace_Raw','OxySink_Map', ...
    'Trace_PotentialNoise','AnalysisInfo');

Table_OxygenSurges_Out = OutputData.Table_OxygenSurges_Out;
Table_OxygenSurgeEvents_Out = OutputData.Table_OxygenSurgeEvents_Out;
OxySurgeArea_all = OutputData.OxySurgeArea_all;
Mean_OxySurge_TraceZ = OutputData.Mean_OxySurge_TraceZ;
OxySurge_Map = OutputData.OxySurge_Map;
SurgeCandidateRunQC=OutputData.SurgeCandidateRunQC;
SurgeGapReview=OutputData.SurgeGapReview;
writetable(SurgeCandidateRunQC,fullfile(OutputFolders.OxySurgesPath,'SurgeCandidateRunQC.csv'));
writetable(SurgeGapReview,fullfile(OutputFolders.OxySurgesPath,'SurgeGapReview.csv'));

save(fullfile(OutputFolders.OxySurgesPath,['OxygenSurges',OutputData.DatafileID,'.mat']), ...
    'Table_OxygenSurges_Out','Table_OxygenSurgeEvents_Out','OxySurgeArea_all','Mean_ROI_TraceZ', ...
    'Mean_OxySurge_TraceZ','OxySurge_Map','AnalysisInfo','SurgeCandidateRunQC','SurgeGapReview');

save(fullfile(OutputFolders.ManualCurOxySinksPath,['ManualCuration',OutputData.DatafileID,'.mat']), ...
    'Table_OxygenSinks_Out','Table_OxygenSinkEvents_Out','OxySinkArea_all','Mean_OxySink_TraceZ', ...
    'Mean_OxySink_Trace_Convo','Mean_OxySink_Trace_Raw','OxySink_Map','Trace_PotentialNoise','AnalysisInfo');

SaveResult = struct();
SaveResult.OutputFolders = OutputFolders;
SaveResult.AnalysisInfo = AnalysisInfo;

end
