function StatsResult = runOxygenDynamicsStats(varargin)
%% Function for the statistical analysis of oxygen dynamics as detected by the OxygenDynamics_Master script 
% The oxygen sinks need to be manually curated using the
% OxygenDynamics_Sinks_Curation app.

%What does the script do?
% It reads the same csv file as the OxygenDynamics Wrapper containing paths and metadata for the dataset
% IMPORTANT!!! **This analysis script should be run in the same directory where wrapper is called

setupOxygenDynamicsPath();

% The script goes through the data folders:
% Finds the latest ManualCurOxySinksData OR OxySinksfolder folder (depending on user input) and
% Table_Out_Surges folder for each recording
% Collates the oxygen sink and surges data it finds into separate tables
% Also gets the traces of the bins in the recording area (Mean_ROI_TraceZ) and populates a N-row cell vector (N = number of data folders) 

% Finds the latest Behaviour_Output folder and collect the data for
% RpawMovmm LpawMovmm, NoseMovmm, Groomlogical, PupilDiammm, and Pufflogical
% and place them in a Nx6 cell array (N = number of data folders). 
% IMPORTANT!!! Given that some recordings do NOT have behavioural data or air puffs, some cells will be empty

% STEPS

% (1) Loads all the data and metadata 
% (2) Checks the metadata and asks for input to prints the levels for each grouping variable. 

% IMPORTANT!!
% This data structure will be assumed in the next steps
% The experimental design that Felix has used is the following 
% Between subject factor: genotype (usually there is only one genotype)
% Between subject factor: type of aneasthetic 
% Within subject factor (lvl1): Aneasthesia status (awake-aneasthetised)
% Within subject factor (lvl2): Recording type (baseline-stimulation). This
% can be derived from the existance or not of puff data

% The structure of the experiment dictates 8 separate groups that form the
% 8 columns in the filters cell arrays
%              ISO                           K/X                DrugID
%              /\                            /\
%             /  \                          /  \
%       AWAKE     ANESTHE             AWAKE     ANESTHE         Condition
%        /\          /\                /\          /\  
%       /  \        /  \              /  \        /  \ 
%     (1)  (2)    (3)  (4)          (5)  (6)    (7)  (8)
%  B/LINE PUFFS  B/LINE PUFFS    B/LINE PUFFS  B/LINE PUFFS     StimCond
%
%


% (3) Calculates a series of additional logical behavioural vectors that will connect the behavioural
% readout with Oxygen dynamics
% (4) Calculate some extra metrics for each oxygen sink and surge locus
% (5) Creates data filters according to the data structure found in the metadata 
% (6) Filter data filtering and prepare tables that can be readily used for statistical analysis

% (7) Exporting results. 

% (8) NOT READY YET! Performs generalised linear mixed-effects modelling analysis 
% (This step is not finished yet. I need to feed the data to R OR take sometime to implement a LME
% model for hypothesis testing in Matlab). For now analysis can be done in
% SPSS or Graphpad



% From Antonis Asiminas, PhD
% Copenhagen, Denmark, January 2022,

%Last updated 1 October 2023
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% (1.1) Load the file with all data paths and metadata.
% The same file is used by the wrapper script and has provided all the
% metadata to the datatables produced by the master analysis script

StatsConfig = struct();
StatsConfig.inputCsv = 'GFAP_GeNL_Ctrl.csv';
StatsConfig.interactive = false;
StatsConfig.useCuratedSinks = false;
StatsConfig.imagingMode = 'BLI'; % 'BLI' or 'iOS'
StatsConfig.chooseSpecificFolders = false;
StatsConfig.sinkFolderSelection = 'Recent'; % 'Recent' or 'Oldest'
StatsConfig.surgeFolderSelection = 'Recent'; % 'Recent' or 'Oldest'
StatsConfig.behaviourFolderSelection = 'Recent'; % 'Recent' or 'Oldest'
StatsConfig.outputRoot = 'Stats_Runs';
StatsConfig.behaviourTimeWindows = {'3','3','3','3'}; % manual, movement/whisking, pupil, puff
StatsConfig.masterFolder = pwd;
StatsConfig = applyOxygenDynamicsConfig(StatsConfig,'Stats');
if nargin > 0
    if nargin ~= 1 || ~isstruct(varargin{1})
        error('runOxygenDynamicsStats accepts at most one optional config struct.');
    end
    StatsConfig = mergeStructs(StatsConfig,varargin{1});
end

Masterfolder=StatsConfig.masterFolder;
InputD=readInputTable(StatsConfig.inputCsv);
RequiredInputColumns = {'Paths','PostureFile','PupilFile','PuffsFile','WhiskingFile','Mouse','Genotype','Condition','DrugID','Promoter','SampleF','Pixelsize','Puff_2use'};
validateInputTableColumns(InputD,RequiredInputColumns,StatsConfig.inputCsv);
%%
Paths=table2cell(InputD(:,{'Paths'}));
validateRecordingPaths(Paths,Masterfolder,StatsConfig.inputCsv);
Postures=table2cell(InputD(:,{'PostureFile'}));
Pupils=table2cell(InputD(:,{'PupilFile'}));
Puffs=table2cell(InputD(:,{'PuffsFile'}));
Whiskings=table2cell(InputD(:,{'WhiskingFile'}));
Mice=table2cell(InputD(:,{'Mouse'}));
Genotypes=table2cell(InputD(:,{'Genotype'}));
Conditions=table2cell(InputD(:,{'Condition'}));
DrugIDs=table2cell(InputD(:,{'DrugID'}));
Promoters=table2cell(InputD(:,{'Promoter'}));
SampleFs=table2cell(InputD(:,{'SampleF'}));
Pixelsizes=table2cell(InputD(:,{'Pixelsize'}));
Puffs_2Use=table2cell(InputD(:,{'Puff_2use'}));

%% Some inputs for behaviour
% The sample frequency for pupil and posture data is 25Hz
BehFs=25;
% the sampling freq for puffs is 1KHz
PuffsSFs=1000;

%% Inputs from the user to check if curated oxygensink data should be used and what folders

if StatsConfig.interactive
    Currated = questdlg('Do you have curated Oxygen sinks data ready for analysis?',...
        'What data',...
        'Yes', 'No','No');

    iOS = questdlg('Is this BLI or iOS imaging?',...
        'BLI or iOS',...
        'BLI', 'iOS','BLI');

    Choosespecific = questdlg(['Do you you want to choose the specific output folders for each recording?' newline 'If not, you can still select whether the newest or oldest output will be used from all recordings'],...
        'What folders to use?',...
        'Yes', 'No','Yes');
else
    if StatsConfig.useCuratedSinks
        Currated = 'Yes';
    else
        Currated = 'No';
    end
    iOS = StatsConfig.imagingMode;
    if StatsConfig.chooseSpecificFolders
        Choosespecific = 'Yes';
    else
        Choosespecific = 'No';
    end
    SinkFold_OldORNew = StatsConfig.sinkFolderSelection;
    SurgeFold_OldORNew = StatsConfig.surgeFolderSelection;
    BehFold_OldORNew = StatsConfig.behaviourFolderSelection;
end
IsBLI = strcmp(iOS,'BLI');
if  strcmp(Choosespecific,'No')

    if StatsConfig.interactive
        SinkFold_OldORNew = questdlg('Do you want to use the oldest or the most recent data for oxygen sinks?', ...
        'Which folder to use?', ...
        'Oldest','Recent','Recent');

        SurgeFold_OldORNew = questdlg('Do you want to use the oldest or the most recent data for oxygen surges?', ...
        'Which folder to use?', ...
        'Oldest','Recent','Recent');

        BehFold_OldORNew = questdlg('Do you want to use the oldest or the most recent data for behaviour?', ...
        'Which folder to use?', ...
        'Oldest','Recent','Recent');
    end
elseif ~StatsConfig.interactive
    error('StatsConfig.chooseSpecificFolders requires StatsConfig.interactive=true because folder selection uses a GUI list dialog.');
end

StatsInfo = struct();
StatsInfo.AnalysisDate = char(datetime('now','Format','yyyy-MM-dd HH:mm:ss'));
StatsInfo.Masterfolder = Masterfolder;
StatsInfo.InputCsv = StatsConfig.inputCsv;
StatsInfo.Config = StatsConfig;
StatsInfo.RequiredInputColumns = RequiredInputColumns;
StatsInfo.ValidatedPaths = Paths;
StatsInfo.SampleFs = SampleFs;
StatsInfo.CuratedSinks = Currated;
StatsInfo.ImagingMode = iOS;
StatsInfo.ChooseSpecificFolders = Choosespecific;
if exist('SinkFold_OldORNew','var')
    StatsInfo.SinkFolderSelection = SinkFold_OldORNew;
else
    StatsInfo.SinkFolderSelection = '';
end
if exist('SurgeFold_OldORNew','var')
    StatsInfo.SurgeFolderSelection = SurgeFold_OldORNew;
else
    StatsInfo.SurgeFolderSelection = '';
end
if exist('BehFold_OldORNew','var')
    StatsInfo.BehaviourFolderSelection = BehFold_OldORNew;
else
    StatsInfo.BehaviourFolderSelection = '';
end

%% Additional input

% This should be a vector with times (in sec from start of recording) that
% specific manual events happened. 
% For example, increase in CO2

% The CRITICAL thing here is that ALL recordings in the study analysed with
% this script are assumed to have the same timings!

%% (1.2) Collecting data from all data folders and adding the metadata from the source scv 

StatsRecordingCells=initializeStatsRecordingCells(height(InputD));
ManualEvents=StatsRecordingCells.ManualEvents;
FolderSelection = struct('Mode',Choosespecific,'Sinks',SinkFold_OldORNew, ...
    'Surges',SurgeFold_OldORNew,'Behaviour',BehFold_OldORNew);
%%
StatsRunTimer = tic;
fprintf('[Stats %s] Loading recording outputs from %d CSV rows...\n', ...
    char(datetime('now','Format','HH:mm:ss')),length(Paths));
for datai=1:length(Paths)
    fprintf('[Stats %s] Loading recording %d/%d: mouse %s, condition %s, path %s\n', ...
        char(datetime('now','Format','HH:mm:ss')),datai,length(Paths), ...
        string(Mice{datai}),string(Conditions{datai}),string(Paths{datai}));
    RecordingTimer = tic;
    RecordingInput = createStatsRecordingInput(Paths{datai},Mice{datai},Conditions{datai}, ...
        Genotypes{datai},Promoters{datai},DrugIDs{datai},Postures{datai}, ...
        Pupils{datai},Puffs{datai},Whiskings{datai},Pixelsizes{datai});
    [StatsRecordingCells,StatsInfo] = loadStatsRecordingIntoCells( ...
        StatsRecordingCells,StatsInfo,datai,RecordingInput,Masterfolder,FolderSelection,Currated,iOS,BehFs);
    fprintf('[Stats %s] Finished recording %d/%d in %.1f s\n', ...
        char(datetime('now','Format','HH:mm:ss')),datai,length(Paths),toc(RecordingTimer));
end

fprintf('[Stats %s] Combining loaded recording tables...\n',char(datetime('now','Format','HH:mm:ss')));
StatsInfo.LoadSummary = warnStatsLoadedDataIssues(StatsInfo,StatsRecordingCells,IsBLI);
StatsLoadedData=createStatsLoadedRecordingData(StatsRecordingCells);
Table_OxygenSinks_OutCombo=StatsLoadedData.TableOxygenSinks;
Table_OxygenSinkEvents_OutCombo=StatsLoadedData.TableOxygenSinkEvents;
HypoxicEventSpecificMetrics=StatsLoadedData.HypoxicEventSpecificMetrics;
Table_OxygenSurges_OutCombo=StatsLoadedData.TableOxygenSurges;
Table_OxygenSurgeEvents_OutCombo=StatsLoadedData.TableOxygenSurgeEvents;
ROIs_Traces=StatsLoadedData.ROIsTraces;
Surges_Area=StatsLoadedData.SurgesArea;
Sinks_Traces=StatsLoadedData.SinksTraces;
Behaviour_data_combo=StatsLoadedData.BehaviourDataCombo;

clear RecordingInput FolderSelection StatsLoadedData

%% (2) Check metadata and define levels for grouping variables

fprintf('[Stats %s] Summarizing metadata and grouping levels...\n',char(datetime('now','Format','HH:mm:ss')));
[Table_OxygenSinks_OutCombo,StatsGroupingLevels]=summarizeStatsGroupingLevels( ...
    Table_OxygenSinks_OutCombo,length(Paths));
Conditions_unique=StatsGroupingLevels.Conditions;
Drugs_unique=StatsGroupingLevels.Drugs;
StimCond_unique=StatsGroupingLevels.StimCond;
clear StatsGroupingLevels
%% (3) Creating some additional logical vectors for the movement of left paw and pupil dilation. These will be used for the probability calculations later
% I also collect previous calculated logical vectors in the same cell
% array. I should probably include this part in the behavioural analysis
% script to declutter this script

% At this point I do not use the logical vectors except from the puffs
% There is not a real hypothesis for either movement of pupil dialation
% events that can be testing with this analysis




%% (4) Calculate additional metrics for each oxygen sink and surge locus

% These are metrics that can be calculated for each oxygen sink and surge.
fprintf('[Stats %s] Calculating additional sink/surge metrics...\n',char(datetime('now','Format','HH:mm:ss')));
[Table_OxygenSinks_OutCombo,Table_OxygenSurges_OutCombo,AdditionalOxySinkMetrics, ...
    AdditionalOxySurgeMetrics]=augmentStatsOxygenMetricTables( ...
    Table_OxygenSinks_OutCombo,Table_OxygenSurges_OutCombo);

%%
% Here I calculate a number of recording specific time series that can be
% plotted with behaviour and puffs (if present).
% These are, of course, recording specific.

%ROI mean signal for every sampling point
%ROIs entropy for every sampling point
%ROIs covariance coefficient

%ROIs mean signal differential
%ROIs signal differential entropy
%ROIs signal differential covariance coeffient
%These last three will tell me if the increase or decrease in oxygen (dynamics) exhibit spatial organisation (high entropy/cov coef) or not 

fprintf('[Stats %s] Preparing ROI trace features...\n',char(datetime('now','Format','HH:mm:ss')));
[ROIs_Traces,TraceCorrs]=prepareStatsROITraceFeatures(ROIs_Traces,IsBLI);

%Another thing I can calculate is the deferential of each ROI and then the mean differential
%Then I can calculate the cov coef and entropy of that differential
%%

% Number and area of ongoing sink/surge events at each imaging time point.
fprintf('[Stats %s] Building ongoing sink/surge time series...\n',char(datetime('now','Format','HH:mm:ss')));
[NumOngoingOxysinks,NumOngoingOxysinksPerMm2,SinkCountAreaNormalization, ...
    TotalSinkArea_Norm,TotalSinkArea_um,NumOngoingOxysurges, ...
    TotalSurgeArea,SinksRaster,SurgesRaster,TraceCorrs] = createOngoingStatsTimeSeries( ...
    Sinks_Traces,Surges_Area,ROIs_Traces,Table_OxygenSinks_OutCombo, ...
    Table_OxygenSurges_OutCombo,Pixelsizes,TraceCorrs,IsBLI);
StatsInfo.SinkCountAreaNormalization = SinkCountAreaNormalization;


%% Connecting physiology with behaviour 
% Bin the movement and the pupil size
% in 10bins and then see what the different traces values are during those
% periods. The problem here is that I need to average on seconds to make
% sense for the slow bioiluminescence data
% Behaviour_data_combo;
% Reminder
% Column 1: LpawMovmm;
% Column 2: RpawMovmm;
% Column 3: NoseMovmm;
% Column 4: Groomlogical;
% Column 5: LpawMovZ;
% Column 6: RpawMovZ;
% Column 7: PupilDiammm;
% Column 8: PupilDiamZ;
% Column 9: Puffs;

StatsBehaviourInputs = struct();
StatsBehaviourInputs.BehaviourDataCombo = Behaviour_data_combo;
StatsBehaviourInputs.ManualEvents = ManualEvents;
StatsBehaviourInputs.DefaultTimeWindows = StatsConfig.behaviourTimeWindows;
StatsBehaviourInputs.Interactive = StatsConfig.interactive;
StatsBehaviourInputs.BehFs = BehFs;
StatsBehaviourInputs.ROIsTraces = ROIs_Traces;

StatsTimeSeriesInputs = struct();
StatsTimeSeriesInputs.NumOngoingOxysinks = NumOngoingOxysinks;
StatsTimeSeriesInputs.NumOngoingOxysinksPerMm2 = NumOngoingOxysinksPerMm2;
StatsTimeSeriesInputs.TotalSinkAreaNorm = TotalSinkArea_Norm;
StatsTimeSeriesInputs.NumOngoingOxysurges = NumOngoingOxysurges;
StatsTimeSeriesInputs.TotalSurgeArea = TotalSurgeArea;
StatsTimeSeriesInputs.TotalSinkAreaUm = TotalSinkArea_um;

fprintf('[Stats %s] Preparing behaviour-linked analysis inputs...\n',char(datetime('now','Format','HH:mm:ss')));
StatsBehaviourAnalysis = prepareStatsBehaviourAnalysisData(IsBLI,StatsBehaviourInputs,StatsTimeSeriesInputs);
Twindows = StatsBehaviourAnalysis.TimeWindows;
Behaviouraldatalogical = StatsBehaviourAnalysis.BehaviourLogicals;
BinsLPaw_10percentiles = StatsBehaviourAnalysis.BinsLPaw;
BinsRPaw_10percentiles = StatsBehaviourAnalysis.BinsRPaw;
BinsPupil_10percentiles = StatsBehaviourAnalysis.BinsPupil;


%% Event-based analysis
% For now I do this only for mean ROIsignal but I can repeat for all other
% trace types I have calculated (e.g cov coef, entropy, oxygen sink area etc)

% start with the manual events 
StatsEventSnips = struct();
if IsBLI
    fprintf('[Stats %s] Extracting BLI event snippets...\n',char(datetime('now','Format','HH:mm:ss')));
    StatsEventSnips = extractStatsBLIEventSnippets(ROIs_Traces,ManualEvents, ...
        Behaviouraldatalogical,SampleFs,BehFs,PuffsSFs,Twindows);
end
%% Alligning the traces of all oxygen sink events for each recording

fprintf('[Stats %s] Aligning oxygen sink event traces...\n',char(datetime('now','Format','HH:mm:ss')));
Sinks_Traces=addAlignedSinkEventTraces(Sinks_Traces,Table_OxygenSinks_OutCombo,3,150);
%% (5)  Creating filters for the different conditions

% The structure of the experiment dictates 8 separate groups that form the
% 8 columns in the filters cell arrays
%              ISO                           K/X                DrugID
%              /\                            /\
%             /  \                          /  \
%       AWAKE     ANESTHE             AWAKE     ANESTHE         Condition
%        /\          /\                /\          /\  
%       /  \        /  \              /  \        /  \ 
%     (1)  (2)    (3)  (4)          (5)  (6)    (7)  (8)
%  B/LINE PUFFS  B/LINE PUFFS    B/LINE PUFFS  B/LINE PUFFS     StimCond
%
%

fprintf('[Stats %s] Creating condition/group filters...\n',char(datetime('now','Format','HH:mm:ss')));
[FiltersOxySinksMetrics,FiltersOxySurgesMetrics,Filters_ROIsandEvents] = ...
    createStatsAnalysisFilters(Table_OxygenSinks_OutCombo,Table_OxygenSurges_OutCombo, ...
    ROIs_Traces,Drugs_unique,Conditions_unique,StimCond_unique);

%% (6) Now using the filters generated in (5) divide the dataset and prepare the tables for export

fprintf('[Stats %s] Preparing grouped metric workbook tables...\n',char(datetime('now','Format','HH:mm:ss')));
[ExportReady,GroupHeaders] = createStatsMetricWorkbookData(Table_OxygenSinks_OutCombo, ...
    Table_OxygenSurges_OutCombo,AdditionalOxySinkMetrics,AdditionalOxySurgeMetrics, ...
    FiltersOxySinksMetrics,FiltersOxySurgesMetrics);

StatsPooledInputs = struct();
StatsPooledInputs.FiltersROIsAndEvents = Filters_ROIsandEvents;
StatsPooledInputs.BehaviourDataCombo = Behaviour_data_combo;
StatsPooledInputs.PuffsToUse = Puffs_2Use;
StatsPooledInputs.SampleFs = SampleFs;
StatsPooledInputs.Mice = Mice;
StatsPooledInputs.ROIsTraces = ROIs_Traces;
StatsPooledInputs.PuffsFs = PuffsSFs;
fprintf('[Stats %s] Preparing pooled trace exports...\n',char(datetime('now','Format','HH:mm:ss')));
[Pooled_Traces,Titles1,Titles2] = prepareStatsPooledTraceExports( ...
    IsBLI,StatsPooledInputs,StatsTimeSeriesInputs);
StatsTraceInputs = struct();
StatsTraceInputs.GroupHeaders = GroupHeaders;
StatsTraceInputs.Titles1 = Titles1;
StatsTraceInputs.Titles2 = Titles2;
StatsTraceInputs.FiltersROIsAndEvents = Filters_ROIsandEvents;
StatsTraceInputs.ROIsTraces = ROIs_Traces;
StatsTraceInputs.TraceCorrs = TraceCorrs;

StatsBinnedInputs = struct();
StatsBinnedInputs.BinsLeftPaw = BinsLPaw_10percentiles;
StatsBinnedInputs.BinsRightPaw = BinsRPaw_10percentiles;
StatsBinnedInputs.BinsPupil = BinsPupil_10percentiles;

fprintf('[Stats %s] Preparing trace export tables...\n',char(datetime('now','Format','HH:mm:ss')));
[ExportTraces,ExportTraceCorrs,ExportLPawBinnedTraces,ExportRPawBinnedTraces, ...
    ExportPupilBinnedTraces] = prepareStatsTraceExportData(IsBLI,StatsTraceInputs, ...
    StatsTimeSeriesInputs,StatsBinnedInputs);

% Given that I am using percentiles for each recording the
% different bins will not correspond to the same movement speed/pupil size
% for the different recordings. Therefore when I average data for each of
% the 10 bins this maybe wrong.
% I can do a control analysis with the mm movement to see if mice move
% wildly differently. If not, binning the zscored data makes sense (..ish)
% Another way may be to bin the data for each recording at a mm and then
% pile up all sampling points from all animals and calculate
% average....This will be a nightmare to analyse statistically


%% Prepare the event-based analysis for extraction
EventSnippetTables = {};
EventSnippetSheetNames = {};
ExportreadySinksalligned = {};
if IsBLI
    fprintf('[Stats %s] Preparing BLI workbook-specific exports...\n',char(datetime('now','Format','HH:mm:ss')));
    [EventSnippetTables,EventSnippetSheetNames,ExportreadySinksalligned] = prepareStatsBLIExportData( ...
        Filters_ROIsandEvents,Sinks_Traces,StatsEventSnips);
end
%% (7) Exporting results

disp('Creating folder for sorted data and statistical analysis matrices');
StatsInfo.OutputFolders = createStatsOutputFolders(Masterfolder,StatsConfig.outputRoot);
StatsoutputfolderPath = StatsInfo.OutputFolders.Stats;
FiguresoutputfolderPath = StatsInfo.OutputFolders.Figures;
StatsCoreInputs = struct();
StatsCoreInputs.TableOxygenSurges = Table_OxygenSurges_OutCombo;
StatsCoreInputs.TableOxygenSurgeEvents = Table_OxygenSurgeEvents_OutCombo;
StatsCoreInputs.TableOxygenSinks = Table_OxygenSinks_OutCombo;
StatsCoreInputs.TableOxygenSinkEvents = Table_OxygenSinkEvents_OutCombo;
StatsCoreInputs.FiltersOxySinksMetrics = FiltersOxySinksMetrics;
StatsCoreInputs.FiltersOxySurgesMetrics = FiltersOxySurgesMetrics;
StatsCoreInputs.FiltersROIsAndEvents = Filters_ROIsandEvents;
StatsCoreInputs.ExportTraces = ExportTraces;
StatsCoreInputs.NumOngoingOxysinks = NumOngoingOxysinks;
StatsCoreInputs.NumOngoingOxysinksPerMm2 = NumOngoingOxysinksPerMm2;
StatsCoreInputs.SinkCountAreaNormalization = SinkCountAreaNormalization;
StatsCoreInputs.TotalSinkAreaNorm = TotalSinkArea_Norm;
StatsCoreInputs.NumOngoingOxysurges = NumOngoingOxysurges;
StatsCoreInputs.TotalSurgeArea = TotalSurgeArea;
StatsCoreInputs.SinksRaster = SinksRaster;
StatsCoreInputs.SurgesRaster = SurgesRaster;
StatsCoreInputs.StatsInfo = StatsInfo;

StatsBLIInputs = struct();
StatsBLIInputs.BehaviourDataCombo = Behaviour_data_combo;
StatsBLIInputs.BehaviourLogicals = Behaviouraldatalogical;
StatsBLIInputs.ROIsTraces = ROIs_Traces;
StatsBLIInputs.ExportTraceCorrs = ExportTraceCorrs;
StatsBLIInputs.TraceCorrs = TraceCorrs;

StatsBLIWorkbookInputs = struct();
StatsBLIWorkbookInputs.AlignedSinkTraces = ExportreadySinksalligned;
StatsBLIWorkbookInputs.TraceCorrs = ExportTraceCorrs;
StatsBLIWorkbookInputs.LPawBinnedTraces = ExportLPawBinnedTraces;
StatsBLIWorkbookInputs.RPawBinnedTraces = ExportRPawBinnedTraces;
StatsBLIWorkbookInputs.PupilBinnedTraces = ExportPupilBinnedTraces;
StatsBLIWorkbookInputs.PooledTraces = Pooled_Traces;
StatsBLIWorkbookInputs.BehaviourLogicals = Behaviouraldatalogical;
StatsBLIWorkbookInputs.SampleFs = SampleFs;
StatsBLIWorkbookInputs.PuffsFs = PuffsSFs;
StatsBLIWorkbookInputs.FiguresOutputFolder = FiguresoutputfolderPath;

[StatsCoreData,StatsBLIData,StatsBLIWorkbookData] = prepareStatsExportBundles( ...
    IsBLI,StatsCoreInputs,StatsBLIInputs,StatsBLIWorkbookInputs);
StatsCoreData.HypoxicEventSpecificMetrics = HypoxicEventSpecificMetrics;
fprintf('[Stats %s] Calculating hypoxic burden metrics...\n',char(datetime('now','Format','HH:mm:ss')));
StatsCoreData.HypoxicBurden = createHypoxicBurdenMetrics( ...
    Table_OxygenSinkEvents_OutCombo,HypoxicEventSpecificMetrics,Table_OxygenSinks_OutCombo);
fprintf('[Stats %s] Exporting stats results and workbook...\n',char(datetime('now','Format','HH:mm:ss')));
StatsExportInfo = exportStatsResults(StatsoutputfolderPath,StatsConfig.inputCsv, ...
    IsBLI,StatsCoreData,StatsBLIData,StatsBLIWorkbookData,ExportReady, ...
    EventSnippetTables,EventSnippetSheetNames);
fprintf('[Stats %s] Stats completed in %.1f min.\n', ...
    char(datetime('now','Format','HH:mm:ss')),toc(StatsRunTimer)/60);

%% (8) Linear Mix effects modeling analysis 

StatsResult = struct();
StatsResult.StatsInfo = StatsInfo;
StatsResult.OutputFolders = StatsInfo.OutputFolders;
StatsResult.OutputXlsx = StatsExportInfo.OutputXlsx;
StatsResult.DataOutputMat = StatsExportInfo.DataOutputMat;
StatsResult.EventSpecificOutputXlsx = StatsExportInfo.EventSpecificOutputXlsx;
StatsResult.EventSpecificDataMat = StatsExportInfo.EventSpecificDataMat;

end
