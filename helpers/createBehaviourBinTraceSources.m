function TraceSources = createBehaviourBinTraceSources(ROIsTraces,NumOngoingOxysinks, ...
    NumOngoingOxysinksPerMm2,TotalSinkAreaNorm,TotalSinkAreaUm, ...
    NumOngoingOxysurges,TotalSurgeArea,RecordingIdx,IsBLI)
%CREATEBEHAVIOURBINTRACESOURCES Collect trace vectors used for behaviour binning.

TraceSources = struct();
if IsBLI
    TraceSources.ROIMean = ROIsTraces{RecordingIdx,7};
    TraceSources.ROICovCoef = ROIsTraces{RecordingIdx,8};
    TraceSources.ROIEntropy = ROIsTraces{RecordingIdx,9};
    TraceSources.ROIDiffMean = ROIsTraces{RecordingIdx,10};
    TraceSources.ROIDiffCovCoef = ROIsTraces{RecordingIdx,11};
    TraceSources.ROIDiffEntropy = ROIsTraces{RecordingIdx,12};
end
TraceSources.NumOngoingOxysinks = NumOngoingOxysinks{RecordingIdx,6};
TraceSources.NumOngoingOxysinksPerMm2 = NumOngoingOxysinksPerMm2{RecordingIdx,6};
TraceSources.TotalSinkAreaNorm = TotalSinkAreaNorm{RecordingIdx,6};
TraceSources.TotalSinkAreaUm = TotalSinkAreaUm{RecordingIdx,6};
TraceSources.NumOngoingOxysurges = NumOngoingOxysurges{RecordingIdx,6};
TraceSources.TotalSurgeArea = TotalSurgeArea{RecordingIdx,6};

end
