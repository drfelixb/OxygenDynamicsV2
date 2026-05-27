function [NumOngoingOxysinks,NumOngoingOxysinksPerMm2,AreaNormalization, ...
    TotalSinkAreaNorm,TotalSinkAreaUm,NumOngoingOxysurges, ...
    TotalSurgeArea, SinksRaster, SurgesRaster, TraceCorrs] = createOngoingStatsTimeSeries( ...
    SinksTraces,SurgesArea,ROIsTraces,TableOxygenSinks,TableOxygenSurges,Pixelsizes,TraceCorrs,IsBLI)
%CREATEONGOINGSTATSTIMESERIES Build recording-level sink/surge time series.

NumRecordings = size(SinksTraces,1);
NumOngoingOxysinks = cell(NumRecordings,6);
NumOngoingOxysinks(:,1:5) = SinksTraces(:,1:5);
NumOngoingOxysinksPerMm2 = cell(NumRecordings,6);
NumOngoingOxysinksPerMm2(:,1:5) = SinksTraces(:,1:5);
AreaNormalization = initializeAreaNormalizationTable(NumRecordings);
TotalSinkAreaNorm = cell(NumRecordings,6);
TotalSinkAreaNorm(:,1:5) = SinksTraces(:,1:5);
TotalSinkAreaUm = cell(NumRecordings,6);
TotalSinkAreaUm(:,1:5) = SinksTraces(:,1:5);
NumOngoingOxysurges = cell(NumRecordings,6);
NumOngoingOxysurges(:,1:5) = SurgesArea(:,1:5);
TotalSurgeArea = cell(NumRecordings,6);
TotalSurgeArea(:,1:5) = SurgesArea(:,1:5);
SinksRaster = cell(NumRecordings,6);
SinksRaster(:,1:5) = SinksTraces(:,1:5);
SurgesRaster = cell(NumRecordings,6);
SurgesRaster(:,1:5) = SurgesArea(:,1:5);

for RecordingIdx = 1:NumRecordings
    SinkIndex = strcmp(TableOxygenSinks.Experiment,SinksTraces{RecordingIdx,1});
    RecDuration = inferRecordingDuration(TableOxygenSinks,SinkIndex,SinksTraces,ROIsTraces,RecordingIdx);
    SinkSeries = computeOngoingSinkTimeSeries(TableOxygenSinks(SinkIndex,:),RecDuration,Pixelsizes{RecordingIdx});
    AreaNorm = computeFovAreaNormalization(TableOxygenSinks(SinkIndex,:));

    NumOngoingOxysinks{RecordingIdx,6} = SinkSeries.Count;
    NumOngoingOxysinksPerMm2{RecordingIdx,6} = SinkSeries.Count .* AreaNorm.AreaCorrectionFactor;
    AreaNormalization = setAreaNormalizationRow(AreaNormalization,RecordingIdx, ...
        SinksTraces(RecordingIdx,:),AreaNorm);
    TotalSinkAreaNorm{RecordingIdx,6} = SinkSeries.AreaNorm;
    TotalSinkAreaUm{RecordingIdx,6} = SinkSeries.AreaUm;
    SinksRaster{RecordingIdx,6} = SinkSeries.Raster;

    if IsBLI
        TraceCorrs{RecordingIdx,12} = safeCorr(SinkSeries.AreaNorm,ROIsTraces{RecordingIdx,8});
        TraceCorrs{RecordingIdx,13} = safeCorr(SinkSeries.AreaNorm,ROIsTraces{RecordingIdx,9});
    end

    SurgeIndex = strcmp(TableOxygenSurges.Experiment,ROIsTraces{RecordingIdx,1});
    SurgeSeries = computeOngoingSurgeTimeSeries(TableOxygenSurges(SurgeIndex,:),RecDuration);

    NumOngoingOxysurges{RecordingIdx,6} = SurgeSeries.Count;
    TotalSurgeArea{RecordingIdx,6} = SurgeSeries.AreaNorm;
    SurgesRaster{RecordingIdx,6} = SurgeSeries.Raster;

    if IsBLI
        TraceCorrs{RecordingIdx,14} = safeCorr(SurgeSeries.AreaNorm,ROIsTraces{RecordingIdx,8});
        TraceCorrs{RecordingIdx,15} = safeCorr(SurgeSeries.AreaNorm,ROIsTraces{RecordingIdx,9});
    end
end

end

function AreaNormalization = initializeAreaNormalizationTable(numRecordings)

RecordingIndex = (1:numRecordings)';
Experiment = strings(numRecordings,1);
Mouse = strings(numRecordings,1);
Condition = strings(numRecordings,1);
DrugID = strings(numRecordings,1);
RecordingArea_um2 = nan(numRecordings,1);
FOVEdge_um = nan(numRecordings,1);
Kappa_1000umPerFOVEdge = nan(numRecordings,1);
AreaCorrectionFactor_1mm2 = nan(numRecordings,1);
MetricBasis = repmat("RecordingAreaNormalizedCount",numRecordings,1);
NormalizationSource = repmat("TableOxygenSinks.RecAreaSize",numRecordings,1);
NormalizedTrace = repmat("NumOngoingOxysinksPerMm2",numRecordings,1);
Formula = repmat("NumOngoingOxysinksPerMm2 = NumOngoingOxysinks * (1000 / sqrt(RecordingArea_um2))^2", ...
    numRecordings,1);

AreaNormalization = table(RecordingIndex,Experiment,Mouse,Condition,DrugID,RecordingArea_um2, ...
    FOVEdge_um,Kappa_1000umPerFOVEdge,AreaCorrectionFactor_1mm2,MetricBasis, ...
    NormalizationSource,NormalizedTrace,Formula);

end

function AreaNorm = computeFovAreaNormalization(SinkRows)

AreaNorm = struct();
AreaNorm.RecordingAreaUm2 = NaN;
AreaNorm.FOVEdgeUm = NaN;
AreaNorm.Kappa = NaN;
AreaNorm.AreaCorrectionFactor = NaN;

if isempty(SinkRows) || ~ismember('RecAreaSize',SinkRows.Properties.VariableNames)
    return
end

RecordingAreaUm2 = SinkRows.RecAreaSize{1};
if iscell(RecordingAreaUm2)
    RecordingAreaUm2 = RecordingAreaUm2{1};
end
if isstring(RecordingAreaUm2) || ischar(RecordingAreaUm2)
    RecordingAreaUm2 = str2double(RecordingAreaUm2);
end
if ~isfinite(RecordingAreaUm2) || RecordingAreaUm2<=0
    return
end

AreaNorm.RecordingAreaUm2 = RecordingAreaUm2;
AreaNorm.FOVEdgeUm = sqrt(RecordingAreaUm2);
AreaNorm.Kappa = 1000 ./ AreaNorm.FOVEdgeUm;
AreaNorm.AreaCorrectionFactor = AreaNorm.Kappa.^2;

end

function AreaNormalization = setAreaNormalizationRow(AreaNormalization,RecordingIdx,MetadataRow,AreaNorm)

AreaNormalization.Experiment(RecordingIdx) = string(MetadataRow{1});
AreaNormalization.Mouse(RecordingIdx) = string(MetadataRow{2});
AreaNormalization.Condition(RecordingIdx) = string(MetadataRow{3});
AreaNormalization.DrugID(RecordingIdx) = string(MetadataRow{4});
AreaNormalization.RecordingArea_um2(RecordingIdx) = AreaNorm.RecordingAreaUm2;
AreaNormalization.FOVEdge_um(RecordingIdx) = AreaNorm.FOVEdgeUm;
AreaNormalization.Kappa_1000umPerFOVEdge(RecordingIdx) = AreaNorm.Kappa;
AreaNormalization.AreaCorrectionFactor_1mm2(RecordingIdx) = AreaNorm.AreaCorrectionFactor;

end

function RecDuration = inferRecordingDuration(TableOxygenSinks,SinkIndex,SinksTraces,ROIsTraces,RecordingIdx)

FirstSinkOfRecording = find(SinkIndex,1,'first');
if ~isempty(FirstSinkOfRecording)
    RecDuration = TableOxygenSinks.RecDuration{FirstSinkOfRecording};
elseif size(ROIsTraces,2) >= 6 && ~isempty(ROIsTraces{RecordingIdx,6})
    RecDuration = size(ROIsTraces{RecordingIdx,6},2);
elseif size(SinksTraces,2) >= 6 && ~isempty(SinksTraces{RecordingIdx,6})
    RecDuration = size(SinksTraces{RecordingIdx,6},2);
else
    RecDuration = 0;
end

end
