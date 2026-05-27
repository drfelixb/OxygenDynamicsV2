function [BinsLPaw,BinsRPaw,BinsPupil] = createStatsBehaviourPercentileBins( ...
    BehaviourDataCombo,ROIsTraces,NumOngoingOxysinks,NumOngoingOxysinksPerMm2, ...
    TotalSinkAreaNorm,TotalSinkAreaUm,NumOngoingOxysurges,TotalSurgeArea,IsBLI)
%CREATESTATSBEHAVIOURPERCENTILEBINS Build paw and pupil percentile-bin traces.

NumRecordings = size(BehaviourDataCombo,1);
BinsLPaw = cell(NumRecordings,12);
BinsRPaw = cell(NumRecordings,12);
BinsPupil = cell(NumRecordings,12);

for RecordingIdx = 1:NumRecordings
    if ~isempty(BehaviourDataCombo{RecordingIdx,1})
        TraceSources = createBehaviourBinTraceSources(ROIsTraces,NumOngoingOxysinks, ...
            NumOngoingOxysinksPerMm2,TotalSinkAreaNorm,TotalSinkAreaUm, ...
            NumOngoingOxysurges,TotalSurgeArea,RecordingIdx,IsBLI);
        BinsLPaw(RecordingIdx,:) = computeBehaviourPercentileBins( ...
            BehaviourDataCombo{RecordingIdx,1},size(ROIsTraces{RecordingIdx,6},2),TraceSources,IsBLI);
        BinsRPaw(RecordingIdx,:) = computeBehaviourPercentileBins( ...
            BehaviourDataCombo{RecordingIdx,2},size(ROIsTraces{RecordingIdx,6},2),TraceSources,IsBLI);
    else
        BinsLPaw(RecordingIdx,:) = createNanBehaviourPercentileBins(10);
        BinsRPaw(RecordingIdx,:) = createNanBehaviourPercentileBins(10);
    end

    if ~isempty(BehaviourDataCombo{RecordingIdx,7})
        TraceSources = createBehaviourBinTraceSources(ROIsTraces,NumOngoingOxysinks, ...
            NumOngoingOxysinksPerMm2,TotalSinkAreaNorm,TotalSinkAreaUm, ...
            NumOngoingOxysurges,TotalSurgeArea,RecordingIdx,IsBLI);
        BinsPupil(RecordingIdx,:) = computeBehaviourPercentileBins( ...
            BehaviourDataCombo{RecordingIdx,7},size(ROIsTraces{RecordingIdx,6},2),TraceSources,IsBLI);
    end
end

end
