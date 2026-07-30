function Analysis = analyzeHypoxiaAmyloidEventProperties(EventFootprints,SinkTable, ...
    PlaqueMask,PixelSize,SampleF,Options)
%ANALYZEHYPOXIAAMYLOIDEVENTPROPERTIES Relate amplitude-free properties to plaques.

if nargin<6 || isempty(Options)
    Options = struct();
end
if ~isfield(Options,'NearThresholdMicrometers')
    Options.NearThresholdMicrometers = 50;
end
if ~isfield(Options,'SensitivityThresholdsMicrometers')
    Options.SensitivityThresholdsMicrometers = [25 50 75 100];
end
if ~isfield(Options,'MinimumObservationsPerStratum')
    Options.MinimumObservationsPerStratum = 3;
end
if ~isfield(Options,'DistanceVariable')
    Options.DistanceVariable = 'CentroidDistance_um';
end
if ~isfield(Options,'SpatialNullShiftsPixels')
    Options.SpatialNullShiftsPixels = zeros(0,2);
end

PlaqueMask = logical(PlaqueMask);
DistancePixels = bwdist(PlaqueMask);
HasPlaques = any(PlaqueMask(:));

EventRows = cell(numel(EventFootprints),1);
for RowIdx = 1:numel(EventFootprints)
    Footprint = EventFootprints(RowIdx);
    SinkIdx = Footprint.SinkIndex;
    EventIdx = Footprint.EventIndex;
    DurationFrames = eventValue(SinkTable.Duration,SinkIdx,EventIdx, ...
        Footprint.EndFrame-Footprint.StartFrame);
    DurationSec = DurationFrames/SampleF;
    Area_um2 = Footprint.MeanAreaPixels*PixelSize^2;
    RecurrenceCount = SinkTable.NumOxySinkEvents(SinkIdx);
    [EdgeDistance,CentroidDistance] = distancesToPlaque(Footprint.PixelIdxList, ...
        Footprint.CentroidX,Footprint.CentroidY,DistancePixels,PixelSize,HasPlaques);
    PrimaryDistance = selectDistance(EdgeDistance,CentroidDistance,Options);
    NearPrimary = PrimaryDistance<=Options.NearThresholdMicrometers;
    EventRows{RowIdx} = table(SinkIdx,EventIdx,Footprint.StartFrame,Footprint.EndFrame, ...
        DurationFrames,DurationSec,Area_um2,Footprint.CentroidX,Footprint.CentroidY, ...
        RecurrenceCount,EdgeDistance,CentroidDistance,NearPrimary, ...
        'VariableNames',{'SinkID','EventID','StartFrame','EndFrame','DurationFrames', ...
        'DurationSec','Area_um2','CentroidX_px','CentroidY_px','RecurrenceCount', ...
        'EdgeDistance_um','CentroidDistance_um','NearPrimary'});
end
if isempty(EventRows)
    EventTable = emptyEventTable();
else
    EventTable = vertcat(EventRows{:});
end

PocketRows = cell(height(SinkTable),1);
for SinkIdx = 1:height(SinkTable)
    EventMask = [EventFootprints.SinkIndex]'==SinkIdx;
    PocketEvents = EventFootprints(EventMask);
    if isempty(PocketEvents)
        Pixels = SinkTable.OxySink_Pxls_all{SinkIdx};
        [Rows,Cols] = ind2sub(size(PlaqueMask),Pixels);
        CentroidX = mean(Cols,'omitnan');
        CentroidY = mean(Rows,'omitnan');
    else
        Pixels = unique(vertcat(PocketEvents.PixelIdxList));
        CentroidX = mean([PocketEvents.CentroidX],'omitnan');
        CentroidY = mean([PocketEvents.CentroidY],'omitnan');
    end
    [EdgeDistance,CentroidDistance] = distancesToPlaque(Pixels,CentroidX, ...
        CentroidY,DistancePixels,PixelSize,HasPlaques);
    RecurrenceCount = SinkTable.NumOxySinkEvents(SinkIdx);
    PrimaryDistance = selectDistance(EdgeDistance,CentroidDistance,Options);
    NearPrimary = PrimaryDistance<=Options.NearThresholdMicrometers;
    PocketRows{SinkIdx} = table(SinkIdx,RecurrenceCount,CentroidX,CentroidY, ...
        EdgeDistance,CentroidDistance,NearPrimary, ...
        'VariableNames',{'SinkID','RecurrenceCount','CentroidX_px','CentroidY_px', ...
        'EdgeDistance_um','CentroidDistance_um','NearPrimary'});
end
if isempty(PocketRows)
    PocketTable = emptyPocketTable();
else
    PocketTable = vertcat(PocketRows{:});
end

Analysis = struct();
Analysis.EventTable = EventTable;
Analysis.PocketTable = PocketTable;
Analysis.Summary = summarizeHypoxiaAmyloidProperties(EventTable,PocketTable,Options);
Analysis.SpatialNull = createSpatialNullTable(EventFootprints,EventTable,PocketTable, ...
    PlaqueMask,PixelSize,Options);
Analysis.Options = Options;
end

function NullTable = createSpatialNullTable(EventFootprints,EventTable,PocketTable, ...
    PlaqueMask,PixelSize,Options)

Shifts = Options.SpatialNullShiftsPixels;
if isempty(Shifts)
    NullTable = emptySpatialNullTable();
    return
end

EventPixels = {EventFootprints.PixelIdxList}';
PocketPixels = cell(height(PocketTable),1);
for SinkIdx = 1:height(PocketTable)
    EventMask = [EventFootprints.SinkIndex]'==PocketTable.SinkID(SinkIdx);
    if any(EventMask)
        PocketPixels{SinkIdx} = unique(vertcat(EventFootprints(EventMask).PixelIdxList));
    else
        PocketPixels{SinkIdx} = [];
    end
end
if strcmp(Options.DistanceVariable,'CentroidDistance_um')
    EventCoordinates = [EventTable.CentroidY_px,EventTable.CentroidX_px];
    PocketCoordinates = [PocketTable.CentroidY_px,PocketTable.CentroidX_px];
else
    EventCoordinates = pixelSetsToCoordinates(EventPixels,size(PlaqueMask));
    PocketCoordinates = pixelSetsToCoordinates(PocketPixels,size(PlaqueMask));
end
PeriodicDistancePixels = periodicDistanceMap(PlaqueMask);

Definitions = { ...
    "Duration","Event",EventTable.DurationSec,EventCoordinates; ...
    "SpatialSize","Event",EventTable.Area_um2,EventCoordinates; ...
    "Recurrence","Pocket",PocketTable.RecurrenceCount,PocketCoordinates};
Thresholds = Options.SensitivityThresholdsMicrometers(:)';
Rows = cell(size(Shifts,1)*size(Definitions,1)*numel(Thresholds),1);
RowIdx = 0;

for ShiftIdx = 1:size(Shifts,1)
    Shift = Shifts(ShiftIdx,:);

    for PropertyIdx = 1:size(Definitions,1)
        Property = Definitions{PropertyIdx,1};
        AnalysisUnit = Definitions{PropertyIdx,2};
        Values = Definitions{PropertyIdx,3};
        Coordinates = Definitions{PropertyIdx,4};
        Distances = shiftedPixelSetDistances(Coordinates, ...
            PeriodicDistancePixels,Shift,PixelSize);

        for Threshold = Thresholds
            RowIdx = RowIdx+1;
            Rows{RowIdx} = nullThresholdRow(ShiftIdx,Shift,Property, ...
                AnalysisUnit,Distances,Values,Threshold, ...
                Options.MinimumObservationsPerStratum);
        end
    end
end

NullTable = vertcat(Rows{1:RowIdx});
end

function Coordinates = pixelSetsToCoordinates(PixelSets,ImageSize)

Coordinates = cell(numel(PixelSets),1);
for Idx = 1:numel(PixelSets)
    Pixels = PixelSets{Idx};
    Pixels = Pixels(Pixels>=1 & Pixels<=prod(ImageSize));
    if ~isempty(Pixels)
        [Rows,Cols] = ind2sub(ImageSize,Pixels);
        Coordinates{Idx} = [Rows(:),Cols(:)];
    else
        Coordinates{Idx} = zeros(0,2);
    end
end
end

function DistancePixels = periodicDistanceMap(PlaqueMask)

ImageSize = size(PlaqueMask);
TiledMask = repmat(PlaqueMask,3,3);
TiledDistance = bwdist(TiledMask);
DistancePixels = TiledDistance(ImageSize(1)+(1:ImageSize(1)), ...
    ImageSize(2)+(1:ImageSize(2)));
end

function Distances = shiftedPixelSetDistances(Coordinates,DistancePixels, ...
    Shift,PixelSize)

ImageSize = size(DistancePixels);
if isnumeric(Coordinates)
    Rows = mod(round(Coordinates(:,1)-Shift(1))-1,ImageSize(1))+1;
    Cols = mod(round(Coordinates(:,2)-Shift(2))-1,ImageSize(2))+1;
    Valid = isfinite(Rows) & isfinite(Cols);
    Distances = nan(size(Rows));
    Distances(Valid) = DistancePixels(sub2ind(ImageSize, ...
        Rows(Valid),Cols(Valid)))*PixelSize;
    return
end
Distances = nan(numel(Coordinates),1);
for Idx = 1:numel(Coordinates)
    Points = Coordinates{Idx};
    if isempty(Points)
        continue
    end
    Rows = mod(Points(:,1)-1-Shift(1),ImageSize(1))+1;
    Cols = mod(Points(:,2)-1-Shift(2),ImageSize(2))+1;
    Indices = sub2ind(ImageSize,Rows,Cols);
    Distances(Idx) = min(DistancePixels(Indices))*PixelSize;
end
end

function Distance = selectDistance(EdgeDistance,CentroidDistance,Options)

if strcmp(Options.DistanceVariable,'CentroidDistance_um')
    Distance = CentroidDistance;
else
    Distance = EdgeDistance;
end
end

function Row = nullThresholdRow(ShiftIdx,Shift,Property,AnalysisUnit, ...
    Distances,Values,Threshold,MinimumN)

Valid = isfinite(Distances) & isfinite(Values);
Near = Valid & Distances<=Threshold;
Far = Valid & Distances>Threshold;
NNear = nnz(Near);
NFar = nnz(Far);
MedianNear = median(Values(Near),'omitnan');
MedianFar = median(Values(Far),'omitnan');
ValidComparison = NNear>=MinimumN && NFar>=MinimumN;
NearMinusFar = MedianNear-MedianFar;
if ~ValidComparison
    NearMinusFar = NaN;
end
Row = table(ShiftIdx,Shift(1),Shift(2),Property,AnalysisUnit,Threshold, ...
    NNear,NFar,MedianNear,MedianFar,NearMinusFar,ValidComparison, ...
    'VariableNames',{'ShiftIndex','ShiftY_px','ShiftX_px','Property', ...
    'AnalysisUnit','Threshold_um','NNear','NFar','MedianNear','MedianFar', ...
    'NearMinusFar','ValidComparison'});
end

function Value = eventValue(CellValues,SinkIdx,EventIdx,Fallback)

Value = Fallback;
if SinkIdx<=numel(CellValues) && ~isempty(CellValues{SinkIdx}) && ...
        EventIdx<=numel(CellValues{SinkIdx})
    Value = CellValues{SinkIdx}(EventIdx);
end
end

function [EdgeDistance,CentroidDistance] = distancesToPlaque(Pixels,CentroidX, ...
    CentroidY,DistancePixels,PixelSize,HasPlaques)

if ~HasPlaques
    EdgeDistance = NaN;
    CentroidDistance = NaN;
    return
end
Pixels = Pixels(Pixels>=1 & Pixels<=numel(DistancePixels));
if isempty(Pixels)
    EdgeDistance = NaN;
else
    EdgeDistance = min(DistancePixels(Pixels))*PixelSize;
end
if ~isfinite(CentroidX) || ~isfinite(CentroidY)
    CentroidDistance = NaN;
else
    CentroidDistance = interp2(DistancePixels,CentroidX,CentroidY,'linear',NaN)*PixelSize;
end
end

function Table = emptyEventTable()

Table = table('Size',[0 13], ...
    'VariableTypes',{'double','double','double','double','double','double', ...
    'double','double','double','double','double','double','logical'}, ...
    'VariableNames',{'SinkID','EventID','StartFrame','EndFrame','DurationFrames', ...
    'DurationSec','Area_um2','CentroidX_px','CentroidY_px','RecurrenceCount', ...
    'EdgeDistance_um','CentroidDistance_um','NearPrimary'});
end

function Table = emptyPocketTable()

Table = table('Size',[0 7], ...
    'VariableTypes',{'double','double','double','double','double','double','logical'}, ...
    'VariableNames',{'SinkID','RecurrenceCount','CentroidX_px','CentroidY_px', ...
    'EdgeDistance_um','CentroidDistance_um','NearPrimary'});
end

function Table = emptySpatialNullTable()

Table = table('Size',[0 12], ...
    'VariableTypes',{'double','double','double','string','string','double', ...
    'double','double','double','double','double','logical'}, ...
    'VariableNames',{'ShiftIndex','ShiftY_px','ShiftX_px','Property', ...
    'AnalysisUnit','Threshold_um','NNear','NFar','MedianNear','MedianFar', ...
    'NearMinusFar','ValidComparison'});
end
