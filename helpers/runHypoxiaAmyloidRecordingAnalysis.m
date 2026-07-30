function Result = runHypoxiaAmyloidRecordingAnalysis(RecordingFolder,AmyloidFile, ...
    Metadata,SampleF,PixelSize,Options)
%RUNHYPOXIAAMYLOIDRECORDINGANALYSIS Analyze one recording with methoxy-X04.

if nargin<6 || isempty(Options)
    Options = struct();
end
Options = applyRecordingDefaults(Options,PixelSize);
AmyloidFile = resolveOptionalRecordingFile(AmyloidFile,RecordingFolder);
if isempty(AmyloidFile)
    error('HypoxiaAmyloid:MissingAmyloidFile', ...
        'An amyloid image is required for this analysis.');
end

[SinksFolder,HasSinksFolder] = selectStatsOutputFolder(RecordingFolder, ...
    'OxygenSinks_Output','No','Recent','oxygen sink','required',false);
if ~HasSinksFolder
    error('HypoxiaAmyloid:MissingSinkOutput', ...
        'No OxygenSinks_Output folder was found in %s.',RecordingFolder);
end

SinksMatFile = selectStatsMatFile(SinksFolder,'Urefined', ...
    'Urefined oxygen sink','');
SinkTable = loadRequiredMatVar(SinksMatFile,'Table_OxygenSinks_Out');
OxySinkAreaAll = loadRequiredMatVar(SinksMatFile,'OxySinkArea_all');
SinkBinaryPath = findSinkBinaryTiff(SinksFolder);
[SinkBinaryStack,~,~] = loadtiff(SinkBinaryPath);
SinkBinaryStack = logical(SinkBinaryStack);

AmyloidRaw = double(imread(AmyloidFile));
PairOptions = Options.PairOptions;
PairOptions.PixelSizeMicrometers = PixelSize;
PairResult = analyzeHypoxiaAmyloidPair(SinkBinaryStack,AmyloidRaw,PairOptions);

[EventFootprints,~] = reconstructHypoxicEventFootprints( ...
    SinkBinaryStack,OxySinkAreaAll,SinkTable);
PropertyOptions = Options.PropertyOptions;
PropertyOptions.SpatialNullShiftsPixels = PairResult.null_shifts_pixels;
PropertyAnalysis = analyzeHypoxiaAmyloidEventProperties(EventFootprints, ...
    SinkTable,PairResult.amyloid_mask,PixelSize,SampleF,PropertyOptions);

RecordingID = recordingIdFromFolder(RecordingFolder);
Age = inferHypoxiaAmyloidAge(Metadata,RecordingFolder);
PropertyAnalysis.EventTable = addMetadata(PropertyAnalysis.EventTable, ...
    Metadata,RecordingID,Age,AmyloidFile);
PropertyAnalysis.PocketTable = addMetadata(PropertyAnalysis.PocketTable, ...
    Metadata,RecordingID,Age,AmyloidFile);
PropertyAnalysis.Summary.Correlations = addMetadata( ...
    PropertyAnalysis.Summary.Correlations,Metadata,RecordingID,Age,AmyloidFile);
PropertyAnalysis.Summary.Thresholds = addMetadata( ...
    PropertyAnalysis.Summary.Thresholds,Metadata,RecordingID,Age,AmyloidFile);
PropertyAnalysis.Summary.PrimaryThreshold = addMetadata( ...
    PropertyAnalysis.Summary.PrimaryThreshold,Metadata,RecordingID,Age,AmyloidFile);
PropertyAnalysis.SpatialNull = addMetadata(PropertyAnalysis.SpatialNull, ...
    Metadata,RecordingID,Age,AmyloidFile);
PropertyAnalysis.EventTable = addPocketIdentifiers( ...
    PropertyAnalysis.EventTable,RecordingID,true);
PropertyAnalysis.PocketTable = addPocketIdentifiers( ...
    PropertyAnalysis.PocketTable,RecordingID,false);

OutputFolder = createHypoxiaAmyloidOutputFolder(RecordingFolder,Options.OverwriteOutputs);
Result = struct();
Result.RecordingID = RecordingID;
Result.RecordingFolder = RecordingFolder;
Result.AmyloidFile = AmyloidFile;
Result.SinksFolder = SinksFolder;
Result.SinksMatFile = SinksMatFile;
Result.SinkBinaryFile = SinkBinaryPath;
Result.Metadata = Metadata;
Result.Age = Age;
Result.SampleF = SampleF;
Result.PixelSize = PixelSize;
Result.Pair = PairResult;
Result.Properties = PropertyAnalysis;
Result.OutputFolder = OutputFolder;
Result.Options = Options;
Result.RecordingSummary = createRecordingSummary(Result);

writeRecordingOutputs(Result);
if Options.SaveFigures
    writeQcFigure(Result);
end
end

function Options = applyRecordingDefaults(Options,PixelSize)

if ~isfield(Options,'OverwriteOutputs'), Options.OverwriteOutputs = false; end
if ~isfield(Options,'SaveFigures'), Options.SaveFigures = true; end
if ~isfield(Options,'PairOptions'), Options.PairOptions = struct(); end
if ~isfield(Options,'PropertyOptions'), Options.PropertyOptions = struct(); end
if ~isfield(Options.PairOptions,'PixelSizeMicrometers')
    Options.PairOptions.PixelSizeMicrometers = PixelSize;
end
end

function Path = findSinkBinaryTiff(SinksFolder)

Files = dir(fullfile(SinksFolder,'IM_OxySinks_BW*.tif'));
if isempty(Files)
    Files = dir(fullfile(SinksFolder,'*OxySinks*BW*.tif'));
end
if isempty(Files)
    error('HypoxiaAmyloid:MissingSinkBinary', ...
        'No binary oxygen-sink TIFF was found in %s.',SinksFolder);
end
[~,Idx] = max([Files.datenum]);
Path = fullfile(Files(Idx).folder,Files(Idx).name);
end

function RecordingID = recordingIdFromFolder(RecordingFolder)

[~,RecordingID] = fileparts(RecordingFolder);
end

function TableOut = addMetadata(TableIn,Metadata,RecordingID,Age,AmyloidFile)

TableOut = TableIn;
N = height(TableOut);
TableOut = addvars(TableOut,repmat(string(RecordingID),N,1), ...
    repmat(string(metadataValue(Metadata,'Mouse')),N,1), ...
    repmat(string(Age),N,1), ...
    repmat(string(metadataValue(Metadata,'Genotype')),N,1), ...
    repmat(string(metadataValue(Metadata,'Condition')),N,1), ...
    repmat(string(metadataValue(Metadata,'DrugID')),N,1), ...
    repmat(string(AmyloidFile),N,1), ...
    'Before',1,'NewVariableNames',{'RecordingID','Mouse','Age','Genotype', ...
    'Condition','DrugID','AmyloidFile'});
end

function TableOut = addPocketIdentifiers(TableIn,RecordingID,HasEvents)

TableOut = TableIn;
PocketID = repmat(string(RecordingID),height(TableOut),1) + ...
    "_P" + string(TableOut.SinkID);
NearFarLabel = repmat("Far",height(TableOut),1);
NearFarLabel(TableOut.NearPrimary) = "Near";
if HasEvents
    PocketEventID = PocketID + "_E" + string(TableOut.EventID);
    TableOut = addvars(TableOut,PocketID,PocketEventID,NearFarLabel, ...
        'After','AmyloidFile','NewVariableNames', ...
        {'PocketID','PocketEventID','NearFarLabel'});
else
    TableOut = addvars(TableOut,PocketID,NearFarLabel, ...
        'After','AmyloidFile','NewVariableNames',{'PocketID','NearFarLabel'});
end
end

function Value = metadataValue(Metadata,Name)

if isfield(Metadata,Name)
    Value = Metadata.(Name);
else
    Value = '';
end
if iscell(Value) && isscalar(Value)
    Value = Value{1};
end
end

function Summary = createRecordingSummary(Result)

Pair = Result.Pair;
Correlations = Result.Properties.Summary.Correlations;
Primary = Result.Properties.Summary.PrimaryThreshold;
Summary = table(string(Result.RecordingID), ...
    string(metadataValue(Result.Metadata,'Mouse')), ...
    string(Result.Age), ...
    string(metadataValue(Result.Metadata,'Genotype')), ...
    string(metadataValue(Result.Metadata,'Condition')), ...
    string(metadataValue(Result.Metadata,'DrugID')), ...
    string(Result.AmyloidFile),height(Result.Properties.EventTable), ...
    height(Result.Properties.PocketTable),numel(Pair.ab_props), ...
    Pair.observed_overlap_fraction,Pair.expected_overlap_fraction, ...
    Pair.overlap_enrichment,Pair.overlap_p_value,Pair.observed_correlation, ...
    Pair.correlation_p_value, ...
    'VariableNames',{'RecordingID','Mouse','Age','Genotype','Condition','DrugID', ...
    'AmyloidFile','EventCount','PocketCount','PlaqueCount', ...
    'ObservedOverlapFraction','ExpectedOverlapFraction','OverlapEnrichment', ...
    'OverlapPValue','SpatialCorrelation','SpatialCorrelationPValue'});

for Idx = 1:height(Correlations)
    Prefix = char(Correlations.Property(Idx));
    Summary.([Prefix,'SpearmanRho']) = Correlations.SpearmanRho(Idx);
    Summary.([Prefix,'SpearmanPValue']) = Correlations.SpearmanPValue(Idx);
    Summary.([Prefix,'SpearmanN']) = Correlations.N(Idx);
end
for Idx = 1:height(Primary)
    Prefix = char(Primary.Property(Idx));
    Summary.([Prefix,'MedianNear']) = Primary.MedianNear(Idx);
    Summary.([Prefix,'MedianFar']) = Primary.MedianFar(Idx);
    Summary.([Prefix,'NearMinusFar']) = Primary.NearMinusFar(Idx);
    Summary.([Prefix,'NearN']) = Primary.NNear(Idx);
    Summary.([Prefix,'FarN']) = Primary.NFar(Idx);
end
end

function writeRecordingOutputs(Result)

OutputFolder = Result.OutputFolder;
writetable(Result.Properties.EventTable, ...
    fullfile(OutputFolder,'HypoxiaAmyloid_EventMetrics.csv'));
writetable(Result.Properties.PocketTable, ...
    fullfile(OutputFolder,'HypoxiaAmyloid_PocketMetrics.csv'));
writetable(Result.Properties.Summary.Correlations, ...
    fullfile(OutputFolder,'HypoxiaAmyloid_Correlations.csv'));
writetable(Result.Properties.Summary.Thresholds, ...
    fullfile(OutputFolder,'HypoxiaAmyloid_ThresholdSensitivity.csv'));
writetable(Result.Properties.SpatialNull, ...
    fullfile(OutputFolder,'HypoxiaAmyloid_PropertySpatialNull.csv'));
writetable(Result.RecordingSummary, ...
    fullfile(OutputFolder,'HypoxiaAmyloid_RecordingSummary.csv'));
save(fullfile(OutputFolder,'HypoxiaAmyloid_Result.mat'),'Result','-v7.3');
end

function writeQcFigure(Result)

FigureHandle = figure('Color','w','Visible','off','Position',[100 100 1300 760]);
Layout = tiledlayout(FigureHandle,2,3,'TileSpacing','compact','Padding','compact');

nexttile(Layout);
imagesc(Result.Pair.hypoxia_percent);
axis image off
colorbar
title('Hypoxic-pocket frequency (%)');

nexttile(Layout);
imagesc(Result.Pair.amyloid_corrected);
axis image off
hold on
contour(Result.Pair.amyloid_mask,[0.5 0.5],'m','LineWidth',1);
title('Methoxy-X04 plaques');

nexttile(Layout);
Overlay = createMaskOverlay(Result.Pair.hypoxia_mask,Result.Pair.amyloid_mask);
imshow(Overlay);
title(sprintf('Overlap enrichment %.2fx',Result.Pair.overlap_enrichment));

Properties = {'Duration','SpatialSize','Recurrence'};
YVariables = {'DurationSec','Area_um2','RecurrenceCount'};
Tables = {Result.Properties.EventTable,Result.Properties.EventTable, ...
    Result.Properties.PocketTable};
for Idx = 1:3
    nexttile(Layout);
    Data = Tables{Idx};
    scatter(Data.EdgeDistance_um,Data.(YVariables{Idx}),28,'filled', ...
        'MarkerFaceAlpha',0.6);
    xline(Result.Properties.Options.NearThresholdMicrometers,'--k');
    xlabel('Nearest plaque edge distance (\mum)');
    ylabel(Properties{Idx});
    CorrelationRow = Result.Properties.Summary.Correlations(Idx,:);
    title(sprintf('%s: Spearman rho %.2f',Properties{Idx}, ...
        CorrelationRow.SpearmanRho));
    box off
end

exportgraphics(FigureHandle,fullfile(Result.OutputFolder, ...
    'HypoxiaAmyloid_QC.png'),'Resolution',200);
close(FigureHandle);
end

function Overlay = createMaskOverlay(HypoxiaMask,AmyloidMask)

HypoxiaMask = logical(HypoxiaMask);
AmyloidMask = logical(AmyloidMask);
OverlapMask = HypoxiaMask & AmyloidMask;
Overlay = zeros([size(HypoxiaMask),3]);
Overlay(:,:,1) = AmyloidMask;
Overlay(:,:,2) = HypoxiaMask;
Overlay(:,:,3) = HypoxiaMask | AmyloidMask;
for Channel = 1:3
    ChannelData = Overlay(:,:,Channel);
    ChannelData(OverlapMask) = 1;
    Overlay(:,:,Channel) = ChannelData;
end
end
