function Result = runOxygenDynamicsVascularEventAnalysis(varargin)
%RUNOXYGENDYNAMICSVASCULAREVENTANALYSIS Compute event-level vascular distances.

setupOxygenDynamicsPath();

Parser = inputParser;
Parser.addParameter('inputCsv','VasculatureData.csv',@(Value) ischar(Value) || isstring(Value));
Parser.addParameter('masterFolder',pwd,@(Value) ischar(Value) || isstring(Value));
Parser.addParameter('sinkFolderAge','Recent',@(Value) any(strcmp(Value,{'Oldest','Recent'})));
Parser.addParameter('interactive',false,@islogical);
Parser.parse(varargin{:});

InputCsv = char(Parser.Results.inputCsv);
Masterfolder = char(Parser.Results.masterFolder);
SinkFolderAge = char(Parser.Results.sinkFolderAge);

if Parser.Results.interactive
    SinkFolderAge = questdlg('Do you want to use the oldest or the most recent data for oxygen sinks?', ...
        'Which folder to use?','Oldest','Recent','Recent');
end

InputD = readInputTable(InputCsv);
Paths = table2cell(InputD(:,{'Paths'}));
Pixelsizes = table2cell(InputD(:,{'Pixelsize'}));

Result = struct();
Result.InputCsv = InputCsv;
Result.Masterfolder = Masterfolder;
Result.SinkFolderAge = SinkFolderAge;
Result.Recordings = repmat(struct('RecordingFolder','','SinksDataFolder','', ...
    'OutputXlsx','','NumEvents',0),numel(Paths),1);

for DataIdx = 1:numel(Paths)
    RecordingFolder = makeFullRecordingPath(Paths{DataIdx},Masterfolder);
    fprintf('Running event-level vascular analysis for %s\n',RecordingFolder);

    [Arteries,Veins] = loadVascularAnnotationMasks(RecordingFolder);
    [SinksDataFolder,HasSinksFolder] = selectStatsOutputFolder(RecordingFolder, ...
        'OxygenSinks_Output','No',SinkFolderAge,'oxygen-sink','required',false);
    if ~HasSinksFolder
        warning('No OxygenSinks_Output folder found for %s. Skipping vascular event analysis.',RecordingFolder);
        continue
    end

    SinksMatFile = selectVascularSinkMatFile(SinksDataFolder);
    SinkBinaryPath = selectVascularSinkTiff(SinksDataFolder);
    SinkData = load(SinksMatFile,'Table_OxygenSinks_Out','OxySinkArea_all');
    Table_OxygenSinks_Out = SinkData.Table_OxygenSinks_Out;
    OxySinkArea_all = SinkData.OxySinkArea_all;

    Pixelsize = cell(height(Table_OxygenSinks_Out),1);
    Pixelsize(:) = Pixelsizes(DataIdx);
    if ismember('Pixelsize',Table_OxygenSinks_Out.Properties.VariableNames)
        Table_OxygenSinks_Out.Pixelsize = Pixelsize;
    else
        Table_OxygenSinks_Out = addvars(Table_OxygenSinks_Out,Pixelsize,'Before','RecDuration');
    end

    [IM_BW,~,~] = loadtiff(SinkBinaryPath);
    IM_BW = logical(IM_BW);

    EventMetrics = createVascularEventMetrics(IM_BW,OxySinkArea_all,Table_OxygenSinks_Out);
    CentroidCoordinates = [round(EventMetrics.Centroid_y), round(EventMetrics.Centroid_x)];
    ExportTable = computeVascularDistances(EventMetrics.OxySink_Pxls_event,CentroidCoordinates, ...
        size(IM_BW(:,:,1)),Veins,Arteries);

    OutputXlsx = fullfile(SinksDataFolder,'Vascular_Analysis_Events.xlsx');
    writetable(ExportTable,OutputXlsx);

    Result.Recordings(DataIdx).RecordingFolder = RecordingFolder;
    Result.Recordings(DataIdx).SinksDataFolder = SinksDataFolder;
    Result.Recordings(DataIdx).OutputXlsx = OutputXlsx;
    Result.Recordings(DataIdx).NumEvents = height(ExportTable);
end

end

function SinksMatFile = selectVascularSinkMatFile(sinksDataFolder)

Matches = dir(fullfile(sinksDataFolder,'*Urefined*.mat'));
if isempty(Matches)
    Matches = dir(fullfile(sinksDataFolder,'*.mat'));
end
if isempty(Matches)
    error('No sink MAT file was found in %s.',sinksDataFolder);
end
[~,NewestIdx] = max([Matches.datenum]);
SinksMatFile = fullfile(Matches(NewestIdx).folder,Matches(NewestIdx).name);

end

function SinkBinaryPath = selectVascularSinkTiff(sinksDataFolder)

Matches = dir(fullfile(sinksDataFolder,'IM_OxySinks_BW*.tif'));
if isempty(Matches)
    Matches = dir(fullfile(sinksDataFolder,'*.tif'));
end
if isempty(Matches)
    error('No sink binary TIFF file was found in %s.',sinksDataFolder);
end
[~,NewestIdx] = max([Matches.datenum]);
SinkBinaryPath = fullfile(Matches(NewestIdx).folder,Matches(NewestIdx).name);

end

function EventMetrics = createVascularEventMetrics(sinkBinaryStack,oxySinkAreaAll,sinkTable)

TrackedPixels = reconstructVascularEventPixels(sinkBinaryStack,oxySinkAreaAll,sinkTable);
NumEvents = sum(sinkTable.NumOxySinkEvents(:));

Area_um = nan(NumEvents,1);
Area_norm = nan(NumEvents,1);
FilledArea_um = nan(NumEvents,1);
FilledArea_norm = nan(NumEvents,1);
Centroid_x = nan(NumEvents,1);
Centroid_y = nan(NumEvents,1);
Circularity = nan(NumEvents,1);
Perimeter_um = nan(NumEvents,1);
Diameter_um = nan(NumEvents,1);
OxySink_Pxls_event = cell(NumEvents,1);

Counter = 1;
for SinkIdx = 1:height(sinkTable)
    EventInfo = regionprops(~cellfun(@isempty,TrackedPixels(SinkIdx,:)),'Area','PixelIdxList');
    if numel(EventInfo)>sinkTable.NumOxySinkEvents(SinkIdx)
        EventInfo = EventInfo(1:sinkTable.NumOxySinkEvents(SinkIdx));
    end

    for EventIdx = 1:numel(EventInfo)
        Props = createVascularSingleEventProps(TrackedPixels(SinkIdx,:),EventInfo(EventIdx).PixelIdxList, ...
            size(sinkBinaryStack(:,:,1)));
        if isempty(Props)
            continue
        end

        Centroids = [Props.Centroid];
        PixelSize = sinkTable.Pixelsize{SinkIdx};
        Area_um(Counter) = mean([Props.Area])*PixelSize^2;
        Area_norm(Counter) = Area_um(Counter)/sinkTable.RecAreaSize{SinkIdx};
        FilledArea_um(Counter) = mean([Props.FilledArea])*PixelSize^2;
        FilledArea_norm(Counter) = FilledArea_um(Counter)/sinkTable.RecAreaSize{SinkIdx};
        Centroid_x(Counter) = mean(Centroids(1:2:end));
        Centroid_y(Counter) = mean(Centroids(2:2:end));
        Circularity(Counter) = mean([Props.Circularity]);
        Perimeter_um(Counter) = mean([Props.Perimeter])*PixelSize;
        Diameter_um(Counter) = mean([Props.EquivDiameter])*PixelSize;
        OxySink_Pxls_event{Counter} = unique(cell2mat({Props.PixelIdxList}'));
        Counter = Counter+1;
    end
end

KeepRows = 1:(Counter-1);
EventMetrics = table(Area_um(KeepRows),Area_norm(KeepRows),FilledArea_um(KeepRows), ...
    FilledArea_norm(KeepRows),Centroid_x(KeepRows),Centroid_y(KeepRows),Circularity(KeepRows), ...
    Perimeter_um(KeepRows),Diameter_um(KeepRows),OxySink_Pxls_event(KeepRows), ...
    'VariableNames',{'Area_um','Area_norm','FilledArea_um','FilledArea_norm','Centroid_x', ...
    'Centroid_y','Circularity','Perimeter_um','Diameter_um','OxySink_Pxls_event'});

end

function TrackedPixels = reconstructVascularEventPixels(sinkBinaryStack,oxySinkAreaAll,sinkTable)

FrameRegionInfo = cell(size(sinkBinaryStack,3),1);
for FrameIdx = 1:size(sinkBinaryStack,3)
    FrameRegionInfo{FrameIdx} = regionprops(sinkBinaryStack(:,:,FrameIdx),'Area','PixelIdxList');
end

TrackedPixels = cell(size(oxySinkAreaAll));
for SinkIdx = 1:size(oxySinkAreaAll,1)
    for FrameIdx = 1:size(oxySinkAreaAll,2)
        if isempty(oxySinkAreaAll{SinkIdx,FrameIdx})
            continue
        end

        [TrackedPixels{SinkIdx,FrameIdx},FrameRegionInfo{FrameIdx}] = matchVascularEventPixelsInFrame( ...
            FrameRegionInfo{FrameIdx},oxySinkAreaAll{SinkIdx,FrameIdx},sinkTable.OxySink_Pxls_all{SinkIdx}, ...
            nnz(~cellfun(@isempty,oxySinkAreaAll(:,FrameIdx))));
    end
end

end

function [Pixels,FrameRegions] = matchVascularEventPixelsInFrame(frameRegions,targetArea,sinkPixelsAll,numActiveSinks)

Pixels = [];
FrameRegions = frameRegions;
if isempty(frameRegions)
    return
end

Areas = [frameRegions.Area];
AreaMatch = find(Areas==targetArea);
if isscalar(AreaMatch)
    Pixels = frameRegions(AreaMatch).PixelIdxList;
    frameRegions(AreaMatch).Area = NaN;
    return
end

if numel(frameRegions)>numActiveSinks && numel(frameRegions)>=2
    PairIdx = nchoosek(1:numel(frameRegions),2);
    PairAreas = Areas(PairIdx(:,1))+Areas(PairIdx(:,2));
    PairMatch = find(PairAreas==targetArea);
    if isscalar(PairMatch)
        ConstituentIdx = PairIdx(PairMatch,:);
        Pixels = vertcat(frameRegions(ConstituentIdx).PixelIdxList);
        for Idx = ConstituentIdx
            frameRegions(Idx).Area = NaN;
        end
        return
    end
end

OverlapCounts = nan(numel(frameRegions),1);
for RegionIdx = 1:numel(frameRegions)
    OverlapCounts(RegionIdx) = numel(intersect(frameRegions(RegionIdx).PixelIdxList,sinkPixelsAll));
end
if any(OverlapCounts>0)
    BestIdx = find(OverlapCounts==max(OverlapCounts),1,'first');
    Pixels = frameRegions(BestIdx).PixelIdxList;
    frameRegions(BestIdx).Area = NaN;
end

end

function Props = createVascularSingleEventProps(eventPixelsByFrame,eventFrames,frameSize)

Props = struct('Area',{},'PixelIdxList',{},'Centroid',{},'Circularity',{}, ...
    'FilledArea',{},'EquivDiameter',{},'Perimeter',{});

for FrameIdx = eventFrames(:)'
    SingleMask = false(frameSize);
    SingleMask(eventPixelsByFrame{FrameIdx}) = true;
    FrameProps = regionprops(SingleMask,'Area','PixelIdxList','Centroid', ...
        'Circularity','FilledArea','EquivDiameter','Perimeter');
    Props = [Props; FrameProps(:)]; %#ok<AGROW>
end

end
