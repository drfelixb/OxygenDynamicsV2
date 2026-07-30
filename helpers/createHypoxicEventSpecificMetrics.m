function EventMetricsTable = createHypoxicEventSpecificMetrics(SinksDataFolder,SinksMatFile, ...
    SinkTable,IncludedPocs,RecordingMetadata)
%CREATEHYPOXICEVENTSPECIFICMETRICS Build one row per hypoxic event.

EventMetricsTable = table();
if isempty(SinkTable) || ~ismember('NumOxySinkEvents',SinkTable.Properties.VariableNames)
    return
end
if ~isnumeric(SinkTable.NumOxySinkEvents) || ~all(ismember( ...
        {'Start','Duration','NormOxySinkAmp','Size_modulation','OxySink_Pxls_all'}, ...
        SinkTable.Properties.VariableNames))
    return
end

SinkBinaryPath = findSinkBinaryTiff(SinksDataFolder);
if isempty(SinkBinaryPath)
    warning('No IM_OxySinks_BW TIFF found in %s. Event-specific morphology will be skipped.', ...
        SinksDataFolder);
    return
end

OxySinkAreaAll = loadOptionalMatVar(SinksMatFile,'OxySinkArea_all',[]);
if isempty(OxySinkAreaAll)
    warning('No OxySinkArea_all variable found in %s. Event-specific morphology will be skipped.', ...
        SinksMatFile);
    return
end
if ~isempty(IncludedPocs)
    OxySinkAreaAll = OxySinkAreaAll(IncludedPocs,:);
end

[SinkBinaryStack,~,~] = loadtiff(SinkBinaryPath);
SinkBinaryStack = logical(SinkBinaryStack);
[~,TrackedEventPixels] = reconstructHypoxicEventFootprints( ...
    SinkBinaryStack,OxySinkAreaAll,SinkTable);
EventMetricsTable = buildHypoxicEventSpecificTable(TrackedEventPixels,size(SinkBinaryStack(:,:,1)), ...
    SinkTable,RecordingMetadata);
end

function SinkBinaryPath = findSinkBinaryTiff(SinksDataFolder)

TiffFiles = dir(fullfile(SinksDataFolder,'IM_OxySinks_BW*.tif'));
if isempty(TiffFiles)
    TiffFiles = dir(fullfile(SinksDataFolder,'*OxySinks*BW*.tif'));
end
if isempty(TiffFiles)
    SinkBinaryPath = '';
    return
end

[~,NewestIdx] = max([TiffFiles.datenum]);
SinkBinaryPath = fullfile(TiffFiles(NewestIdx).folder,TiffFiles(NewestIdx).name);
end

function EventMetricsTable = buildHypoxicEventSpecificTable(TrackedEventPixels,FrameSize,SinkTable,RecordingMetadata)

TotalEvents = sum(SinkTable.NumOxySinkEvents(:));
if TotalEvents==0
    EventMetricsTable = table();
    return
end

Rows = cell(TotalEvents,1);
RowIdx = 0;
PixelSize = getRecordingPixelSize(RecordingMetadata);

for SinkIdx = 1:height(SinkTable)
    EventInfo = regionprops(~cellfun(@isempty,TrackedEventPixels(SinkIdx,:)),'Area','PixelIdxList');
    if numel(EventInfo)>SinkTable.NumOxySinkEvents(SinkIdx)
        EventInfo = EventInfo(1:SinkTable.NumOxySinkEvents(SinkIdx));
    end

    for EventIdx = 1:numel(EventInfo)
        RowIdx = RowIdx+1;
        Morphology = computeSingleEventMorphology(TrackedEventPixels(SinkIdx,:),EventInfo(EventIdx).PixelIdxList, ...
            FrameSize,PixelSize,SinkTable.RecAreaSize{SinkIdx});
        Rows{RowIdx} = createEventSpecificRow(SinkTable,SinkIdx,EventIdx,EventInfo(EventIdx), ...
            RecordingMetadata,PixelSize,Morphology);
    end
end

Rows = Rows(1:RowIdx);
if isempty(Rows)
    EventMetricsTable = table();
else
    EventMetricsTable = vertcat(Rows{:});
end
end

function PixelSize = getRecordingPixelSize(RecordingMetadata)

PixelSize = RecordingMetadata.PixelSize;
if iscell(PixelSize)
    PixelSize = PixelSize{1};
end
if isstring(PixelSize) || ischar(PixelSize)
    PixelSize = str2double(PixelSize);
end
end

function Morphology = computeSingleEventMorphology(EventPixelsByFrame,EventFrames,FrameSize,PixelSize,RecordingAreaUm)

Area = [];
FilledArea = [];
Diameter = [];
Perimeter = [];
Circularity = [];
CentroidX = [];
CentroidY = [];

for FrameIdx = EventFrames(:)'
    Pixels = EventPixelsByFrame{FrameIdx};
    if isempty(Pixels)
        continue
    end
    SingleMask = false(FrameSize);
    SingleMask(Pixels) = true;
    Props = regionprops(SingleMask,'Area','FilledArea','Centroid','Circularity','EquivDiameter','Perimeter');
    if isempty(Props)
        continue
    end
    Area(end+1,1) = sum([Props.Area]); %#ok<AGROW>
    FilledArea(end+1,1) = sum([Props.FilledArea]); %#ok<AGROW>
    Diameter(end+1,1) = mean([Props.EquivDiameter]); %#ok<AGROW>
    Perimeter(end+1,1) = sum([Props.Perimeter]); %#ok<AGROW>
    Circularity(end+1,1) = mean([Props.Circularity]); %#ok<AGROW>
    Centroids = [Props.Centroid];
    CentroidX(end+1,1) = mean(Centroids(1:2:end)); %#ok<AGROW>
    CentroidY(end+1,1) = mean(Centroids(2:2:end)); %#ok<AGROW>
end

Morphology = struct();
Morphology.AreaUm = mean(Area,'omitnan')*PixelSize^2;
Morphology.AreaNorm = Morphology.AreaUm/RecordingAreaUm;
Morphology.FilledAreaUm = mean(FilledArea,'omitnan')*PixelSize^2;
Morphology.FilledAreaNorm = Morphology.FilledAreaUm/RecordingAreaUm;
Morphology.CentroidX = mean(CentroidX,'omitnan');
Morphology.CentroidY = mean(CentroidY,'omitnan');
Morphology.Circularity = mean(Circularity,'omitnan');
Morphology.PerimeterUm = mean(Perimeter,'omitnan')*PixelSize;
Morphology.DiameterUm = mean(Diameter,'omitnan')*PixelSize;
end

function Row = createEventSpecificRow(SinkTable,SinkIdx,EventIdx,EventInfo,RecordingMetadata,PixelSize,Morphology)

Experiment = SinkTable.Experiment(SinkIdx);
Mouse = SinkTable.Mouse(SinkIdx);
Condition = SinkTable.Condition(SinkIdx);
DrugID = SinkTable.DrugID(SinkIdx);
Genotype = SinkTable.Genotype(SinkIdx);
PuffStim = SinkTable.PuffStim(SinkIdx);
Promoter = SinkTable.Promoter(SinkIdx);
Pixelsize = PixelSize;
PocketID = {[RecordingMetadata.Mouse,'_',num2str(SinkIdx)]};
EventID = {[PocketID{1},'_',num2str(EventIdx)]};
NormOxySinkAmp = SinkTable.NormOxySinkAmp{SinkIdx}(EventIdx);
Start = SinkTable.Start{SinkIdx}(EventIdx);
Duration = SinkTable.Duration{SinkIdx}(EventIdx);
Size_modulation = SinkTable.Size_modulation{SinkIdx}(EventIdx);
StartFrame = EventInfo.PixelIdxList(1);
EndFrame = EventInfo.PixelIdxList(end);
MetricBasis = {'EventBased'};

Area_um = Morphology.AreaUm;
Area_norm = Morphology.AreaNorm;
FilledArea_um = Morphology.FilledAreaUm;
FilledArea_norm = Morphology.FilledAreaNorm;
Centroid_x = Morphology.CentroidX;
Centroid_y = Morphology.CentroidY;
Circularity = Morphology.Circularity;
Perimeter_um = Morphology.PerimeterUm;
Diameter_um = Morphology.DiameterUm;

Row = table(Experiment,Mouse,Condition,DrugID,Genotype,PuffStim,Promoter,Pixelsize, ...
    PocketID,EventID,StartFrame,EndFrame,NormOxySinkAmp,Start,Duration,Size_modulation, ...
    Area_um,Area_norm,FilledArea_um,FilledArea_norm,Centroid_x,Centroid_y,Circularity, ...
    Perimeter_um,Diameter_um,MetricBasis);
end
