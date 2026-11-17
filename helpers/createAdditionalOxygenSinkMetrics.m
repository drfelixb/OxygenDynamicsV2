function AdditionalOxySinkMetrics = createAdditionalOxygenSinkMetrics(SinkTable)
%CREATEADDITIONALOXYGENSINKMETRICS Calculate derived sink-level stats metrics.

OxySinkArea_Norm = SinkTable.MeanOxySinkArea_um./cell2mat(SinkTable.RecAreaSize);
OxySinkArea_Filled_Norm = SinkTable.MeanOxySinkFilledArea_um./cell2mat(SinkTable.RecAreaSize);
SinkSiteEventRate_per_min = (SinkTable.NumOxySinkEvents*60)./cell2mat(SinkTable.RecDuration);
MeanOxySinkEvent_Duration = cellfun(@safeCellMean,SinkTable.Duration);
if ismember('SampleF',SinkTable.Properties.VariableNames)
    MeanOxySinkEvent_Duration=MeanOxySinkEvent_Duration./SinkTable.SampleF;
end
MeanOxySinkEvent_NormAmp = cellfun(@safeCellMean,SinkTable.NormOxySinkAmp);
MeanOxySinkEvent_SizeModulation = cellfun(@safeCellMean,SinkTable.Size_modulation);

AdditionalOxySinkMetrics = table(OxySinkArea_Norm,OxySinkArea_Filled_Norm, ...
    SinkSiteEventRate_per_min,MeanOxySinkEvent_Duration,MeanOxySinkEvent_NormAmp, ...
    MeanOxySinkEvent_SizeModulation);

end
