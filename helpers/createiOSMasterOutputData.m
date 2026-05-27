function OutputData = createiOSMasterOutputData(recordingFolder,overwriteOutputs,datafileID,analysisInfo, ...
    IM_Notrend,IM_Zframetime_smoothed,IM_OxySinks_BW,IM_OxySurges_BW,Table_OxygenSinks_Out, ...
    OxySinkArea_all,Mean_OxySink_TraceZ,Mean_OxySink_Trace_Convo,OxySink_Map,Trace_PotentialNoise, ...
    Table_OxygenSurges_Out,OxySurgeArea_all,Mean_OxySurge_TraceZ,OxySurge_Map)
%CREATEIOSMASTEROUTPUTDATA Package iOS master outputs for the save helper.

OutputData = struct();
OutputData.RecordingFolder = recordingFolder;
OutputData.OverwriteOutputs = overwriteOutputs;
OutputData.DatafileID = datafileID;
OutputData.AnalysisInfo = analysisInfo;
OutputData.IM_Notrend = IM_Notrend;
OutputData.IM_Zframetime_smoothed = IM_Zframetime_smoothed;
OutputData.IM_OxySinks_BW = IM_OxySinks_BW;
OutputData.IM_OxySurges_BW = IM_OxySurges_BW;
OutputData.Table_OxygenSinks_Out = Table_OxygenSinks_Out;
OutputData.OxySinkArea_all = OxySinkArea_all;
OutputData.Mean_OxySink_TraceZ = Mean_OxySink_TraceZ;
OutputData.Mean_OxySink_Trace_Convo = Mean_OxySink_Trace_Convo;
OutputData.OxySink_Map = OxySink_Map;
OutputData.Trace_PotentialNoise = Trace_PotentialNoise;
OutputData.Table_OxygenSurges_Out = Table_OxygenSurges_Out;
OutputData.OxySurgeArea_all = OxySurgeArea_all;
OutputData.Mean_OxySurge_TraceZ = Mean_OxySurge_TraceZ;
OutputData.OxySurge_Map = OxySurge_Map;

end
