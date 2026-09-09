function AdditionalOxySurgeMetrics = createAdditionalOxygenSurgeMetrics(SurgeTable)
%CREATEADDITIONALOXYGENSURGEMETRICS Calculate derived surge-level stats metrics.

OxySurgeArea_Norm = SurgeTable.MeanOxySurgeArea_um./cell2mat(SurgeTable.RecAreaSize_Surge);
OxySurgeArea_Filled_Norm = SurgeTable.MeanOxySurgeFilledArea_um./cell2mat(SurgeTable.RecAreaSize_Surge);
SurgeSiteEventRate_per_min = (SurgeTable.NumOxySurgeEvents*60)./cell2mat(SurgeTable.RecDuration_Surge);
MeanOxySurgeEvent_Duration = cellfun(@safeCellMean,SurgeTable.Duration_Surge);
if ismember('SampleF',SurgeTable.Properties.VariableNames)
    MeanOxySurgeEvent_Duration=MeanOxySurgeEvent_Duration./SurgeTable.SampleF;
end
MeanOxySurgeEvent_NormAmp = cellfun(@safeCellMean,SurgeTable.NormOxySurgeAmp);
MeanOxySurgeEvent_SizeModulation = cellfun(@safeCellMean,SurgeTable.Size_Surge_modulation);

AdditionalOxySurgeMetrics = table(OxySurgeArea_Norm,OxySurgeArea_Filled_Norm, ...
    SurgeSiteEventRate_per_min,MeanOxySurgeEvent_Duration,MeanOxySurgeEvent_NormAmp, ...
    MeanOxySurgeEvent_SizeModulation);

end
