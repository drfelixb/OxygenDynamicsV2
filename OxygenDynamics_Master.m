%% Script for the detection and analysis of oxygen dynamics in the mouse barrel cortex

setupOxygenDynamicsPath();

% Provisional title: Optical investigation of oxygen dynamics in the murine cortex

% Each data folder (e.g 'Recording1') should contain ONLY one tif stack of original motion corrected data and one tif stack of denoised data.
% IMPORTANT!! We use this denoising approach 
% https://royerlab.github.io/aydin/getting_started/install.html denoising
% The denoised data should have the tag 'DENOISED' in the name of the tif stack.

% Overview of script (high level)
% Data are imported (both motion corrected and denoised)
% !Future version! Intrinsic Optical Signal Imaging data are imported along with a way to map them spatially to the oxygen dynamics data
% Preprocessing of data including detrending, z-scoring and convolution
% Identification of oxygen sinks seen as spatially confined hypoxic pockets 
% Identification of oxygen surges
% Calculation of events
% The output contains a series tables with data as well as ploted time traces of signal from identified hypoxic poxic
% The output can be curated further with the use of a MATLAB app and create ground-truth data for the training of detection algorithms

% All needed, custom fuctions are contained within the script. This is not good practice in general but it allows for the script to be portable.

% Initial script and selected functions from Ryszard Gomolka, dr. eng.

% All subsequent scripts from Antonis Asiminas, PhD
% Center for Translational Neuromedicine
% University of Copenhagen, November 2021

% Last updated 12 Sep 2018

%% Initial parameters

if exist('PiSz','var')
    PixelSize = PiSz; %this is taken from the wrapper. Change to specific number if running the script alone
else
    fprintf('Script was call individually. No info from wrapper available! Pixel size is set to 2.5um \n');
    PixelSize =2.5;
end

if exist('SFs','var')
    fs=SFs;    % your frequency of the sampling [Hz]. This is taken from the wrapper. Change to specific number if running the script alone
else
    fprintf('Script was call individually. No info from wrapper available! Sampling Freq is set to 1Hz \n');
    fs =1;
end

[AnalysisParams,ParamVars] = createOxygenMasterParams(PixelSize,fs);
smooth = ParamVars.smooth;
ThresholdMinsize = ParamVars.ThresholdMinsize;
ThresholdMaxsize = ParamVars.ThresholdMaxsize;
CircularityThres = ParamVars.CircularityThres;
ThresholdMinsize_Surges = ParamVars.ThresholdMinsize_Surges;
ThresholMinddur = ParamVars.ThresholMinddur;
ThresholMaxddur = ParamVars.ThresholMaxddur;
ThresholMinddur_Surges = ParamVars.ThresholMinddur_Surges;
Pixel_frame = ParamVars.Pixel_frame;
PercentileDetectionThres = ParamVars.PercentileDetectionThres;
RecAreaBackgroundPercentile = ParamVars.RecAreaBackgroundPercentile;
RecAreaBinHalfSizeUm = ParamVars.RecAreaBinHalfSizeUm;
RecAreaMinCoverageFraction = ParamVars.RecAreaMinCoverageFraction;
SinkTraceCorrelationThreshold = ParamVars.SinkTraceCorrelationThreshold;
SinkNoiseCorrelationPercentile = ParamVars.SinkNoiseCorrelationPercentile;
EventBaselineReturnTolerance = ParamVars.EventBaselineReturnTolerance;
SinkDetectionNoiseAmpThreshold = ParamVars.SinkDetectionNoiseAmpThreshold;
PercentileSurgeDetectionThres = ParamVars.PercentileSurgeDetectionThres;
SurgeCircularityThreshold = ParamVars.SurgeCircularityThreshold;
MaxOutsideRecordingAreaFraction = ParamVars.MaxOutsideRecordingAreaFraction;

%% STEP 1 Read files and get some basic stats of the signal
if exist('RecordingFolder','var') && ~isempty(RecordingFolder)
    MasterRecordingFolder = RecordingFolder;
else
    MasterRecordingFolder = pwd;
end
[InputData,AnalysisInfo] = loadOxygenMasterInputs(MasterRecordingFolder,AnalysisParams);
IM_Raw = InputData.IM_Raw;
IM_NoNoise = InputData.IM_NoNoise;
Miu = InputData.Miu;
Miu_NoNoise = InputData.Miu_NoNoise;
Tifffiles = InputData.Tifffiles;
DatafileID = InputData.DatafileID;
RecDur = InputData.RecDur;
clear InputData ParamVars MasterRecordingFolder

%% STEP 2 Detrending data
fprintf('Detrending... This might take some time! \n');

tic;
%detrend the raw data. That's were the analysis will retun to extract the signal. 
IM_Raw_Notrend=detrend_custom(IM_Raw,3);
%Check if the denoised data is available 
if ~isempty(IM_NoNoise) %if so
    %Detrend this and all subsequenct analyses will be based on the detrended/denoised data .
    IM_Notrend=detrend_custom(IM_NoNoise,3); 
else %if not
    
    fprintf('Cannot find denoised data... Analysis will continue with motion-corrected-only data! \n')
    IM_Notrend=IM_Raw_Notrend; 
end

toc;

%% STEP 3 Defining the area of tissue that is being recorded.
% This is not as clearcut as one might though simply because of the tissue movement. 

RecordingArea = computeRecordingArea(IM_Notrend,PixelSize,RecAreaBackgroundPercentile, ...
    'recAreaBinHalfSizeUm',RecAreaBinHalfSizeUm, ...
    'recAreaMinCoverageFraction',RecAreaMinCoverageFraction);
RecAreaFilter = RecordingArea.Filter;
RecArea = RecordingArea.AreaUm2;
RecArea_bins = RecordingArea.Bins;

clear RecordingArea

IM_Notrend = single(IM_Notrend);
IM_Raw_Notrend = single(IM_Raw_Notrend);

%% STEP 4 Normalize according to the standard deviation, to separate white and black spots
% I produced three different z-scored methods. It looks like the 'IM_Zframetime' is better but I need to investigate

%% STEP 5 Multiply the z-scored amplitude of each pixel with the mean amplitude of a 21x21 pixel window around it ('smooth' in four directions from each pixel).

%% STEP 6 Smooth the signal a bit more 
% This step maybe redundant when working for denoised data
[IM_Zframetime,IM_Zframetime_smoothed] = preprocessDetectionStack(IM_Notrend,smooth);

%% STEP 7  Detect the oxygen sink events/pockets in the filtered, smoothed data             
fprintf('Detecting putative oxygen sinks in every frame... \n'); 
tic;
%The putative hypoxic pockets are identified based on singal intensity.
%To avoid weird results at the borders (because of motion correction) I clip a 20 pixel frame around the field of view.
IMclip=IM_Zframetime_smoothed(Pixel_frame+1:end-Pixel_frame,Pixel_frame+1:end-Pixel_frame,:);
%I also clip the recording are so the linear indices to match when I refine
RecAreaFilterclip=RecAreaFilter(Pixel_frame+1:end-Pixel_frame,Pixel_frame+1:end-Pixel_frame);
SinkDetectionParams = struct();
SinkDetectionParams.percentileThreshold = PercentileDetectionThres;
SinkDetectionParams.minArea = ThresholdMinsize;
SinkDetectionParams.maxArea = ThresholdMaxsize;
SinkDetectionParams.minCircularity = CircularityThres;
SinkDetectionParams.maxOutsideFraction = MaxOutsideRecordingAreaFraction;
SinkDetectionParams.frameTransform = 'invert';
OxygenSinksInfo_all = detectFrameRegionCandidates(IMclip,RecAreaFilterclip,SinkDetectionParams);

clear IMclip RecAreaFilterclip SinkDetectionParams
toc;
%% STEP 8  Tracking oxygen sinks across time
% For the remaining oxygen sinks of each frame track them accross time by checking if they overlap with oxygen sinks from subsequent frames.
fprintf('Tracking putative oxygen sinks across imaging session... \n'); 
tic;
%this will contain putative unique pockets(rows) and the pixels belonging to events for every frame of the recording.
sink_overlap_thres=0.6; %percentage of overlap that is needed between sinks in two different frames
Overall_OxygenSinks_Pxllist = trackSinkCandidates(OxygenSinksInfo_all,ThresholMinddur,sink_overlap_thres);

clear OxygenSinksInfo_all
toc;
%% STEP 9 Refine the identified oxygen sinks based on event duration thresholds

fprintf('Refining putative oxygen sinks based on event duration thresholds... \n'); 
tic;
[Overall_OxygenSinks_Pxllist,Overall_OxySinks_logical] = filterSinkRunsByDuration( ...
    Overall_OxygenSinks_Pxllist,ThresholMinddur,ThresholMaxddur);
toc;

%% STEP 10 Extracting the mean trace for each identified pocket
fprintf('Extracting mean traces from Oxygen Sinks... \n');
[~,Mean_OxySink_Trace_Convo,~,~,~] = extractSinkTraces(...
    Overall_OxygenSinks_Pxllist,Overall_OxySinks_logical,IM_Zframetime,IM_Zframetime_smoothed,[],Pixel_frame);

%% Detrending again the individual traces
% When getting the average pocket singal I end up combining pixels with
% different trends which have not been completely removed when detrending
% pixel by pixel the data matrix

Mean_OxySink_Trace_Convo=detrend_custom(Mean_OxySink_Trace_Convo,2);

%% Here I calculate whether the trace of a oxygen sink pocket is correlated with other identified pockets.
% I first combine traces with good correlation and spatial overlap creating
% a new average trace.
% This is the first time!!
fprintf('Refining putative oxygen sinks based on the correlation of traces with other sinks... \n'); 
tic;

[Overall_OxygenSinks_Pxllist,Overall_OxySinks_logical,~] = ...
    refineSinkRegionsByTraceCorrelation(Overall_OxygenSinks_Pxllist,Overall_OxySinks_logical, ...
    Mean_OxySink_Trace_Convo,SinkTraceCorrelationThreshold,SinkNoiseCorrelationPercentile,0.7);

toc;
clear FlippedTracestemp GoodCorrTraces SeedTrace SeedTracePxls Corrs CombinedPxls IndxSort GoodCorrIndx SeedIndx OxySink_Pxls_Currated

%% Repeat the extraction of mean sink traces for the refined sink areas
[~,Mean_OxySink_Trace_Convo,~,~,~] = extractSinkTraces(...
    Overall_OxygenSinks_Pxllist,Overall_OxySinks_logical,IM_Zframetime,IM_Zframetime_smoothed,[],Pixel_frame);

%% Detrending again the individual traces
% When getting the average pocket singal I end up combining pixels with
% different trends which have not been completely removed when detrending
% pixel by pixel the data matrix

Mean_OxySink_Trace_Convo=detrend_custom(Mean_OxySink_Trace_Convo,2);

%% Here I calculate whether the trace of a oxygen sink pocket is correlated with other identified pockets.
% I first combine traces with good correlation and spatial overlap creating
% a new average trace.
% This is the sencond time!!
fprintf('Refining putative oxygen sinks based on the correlation of traces with other sinks for a second time... \n'); 
tic;

[Overall_OxygenSinks_Pxllist,Overall_OxySinks_logical,~] = ...
    refineSinkRegionsByTraceCorrelation(Overall_OxygenSinks_Pxllist,Overall_OxySinks_logical, ...
    Mean_OxySink_Trace_Convo,SinkTraceCorrelationThreshold,SinkNoiseCorrelationPercentile,0.7);

toc;
clear FlippedTracestemp GoodCorrTraces SeedTrace SeedTracePxls Corrs CombinedPxls IndxSort GoodCorrIndx SeedIndx OxySink_Pxls_Currated

%% Repeat the extraction of mean sink traces for the refined sink areas
[~,Mean_OxySink_Trace_Convo,~,~,~] = extractSinkTraces(...
    Overall_OxygenSinks_Pxllist,Overall_OxySinks_logical,IM_Zframetime,IM_Zframetime_smoothed,IM_Raw,Pixel_frame);

%% Detrending again the individual traces
% When getting the average pocket singal I end up combining pixels with
% different trends which have not been completely removed when detrending
% pixel by pixel the data matrix

Mean_OxySink_Trace_Convo=detrend_custom(Mean_OxySink_Trace_Convo,2);

%% Here I calculate whether the trace of a oxygen sink pocket is correlated with other identified pockets.
% I first combine traces with good correlation and spatial overlap creating
% a new average trace.
% This is the third time!!
fprintf('Refining putative oxygen sinks based on the correlation of traces with other sinks for a third time... \n'); 
tic;

[Overall_OxygenSinks_Pxllist,Overall_OxySinks_logical,~] = ...
    refineSinkRegionsByTraceCorrelation(Overall_OxygenSinks_Pxllist,Overall_OxySinks_logical, ...
    Mean_OxySink_Trace_Convo,SinkTraceCorrelationThreshold,SinkNoiseCorrelationPercentile,0.7);
fprintf([num2str(size(Overall_OxygenSinks_Pxllist,1)),' putative hypoxic pockets identified! \n'])
toc;
clear FlippedTracestemp GoodCorrTraces SeedTrace SeedTracePxls Corrs CombinedPxls IndxSort GoodCorrIndx SeedIndx OxySink_Pxls_Currated

%% Repeat the extraction of mean sink traces for the refined sink areas
[Mean_OxySink_TraceZ,Mean_OxySink_Trace_Convo,Mean_OxySink_Trace_Raw,OxySink_Pxls_all,OxySink_Map] = extractSinkTraces(...
    Overall_OxygenSinks_Pxllist,Overall_OxySinks_logical,IM_Zframetime,IM_Zframetime_smoothed,IM_Raw,Pixel_frame);

%% Detrending again the individual traces
% When getting the average pocket singal I end up combining pixels with
% different trends which have not been completely removed when detrending
% pixel by pixel the data matrix

Mean_OxySink_TraceZ=detrend_custom(Mean_OxySink_TraceZ,2);
Mean_OxySink_Trace_Convo=detrend_custom(Mean_OxySink_Trace_Convo,2);

%% Now I correlated the new traces to see which of them correlate with too many other traces, therefore being potential noise
Trace_PotentialNoise = computeTracePotentialNoise(Mean_OxySink_Trace_Convo, ...
    SinkTraceCorrelationThreshold,SinkNoiseCorrelationPercentile);
%% STEP 11  Get the properties of sinks and their events in equal size column cells/vectors to export them as a table
% Gathering oxygen sink pocket parameters
tic;
SinkMorphology = computeTrackedRegionMorphology(Overall_OxygenSinks_Pxllist,Overall_OxySinks_logical, ...
    size(IM_Zframetime),PixelSize,'pixelFrame',Pixel_frame,'coordinates','clipped');
OxySinkArea_all = SinkMorphology.AreaAll;
IM_OxySinks_BW = SinkMorphology.BinaryMap;
MeanOxySinkArea_um = SinkMorphology.MeanArea_um;
MeanOxySinkFilledArea_um = SinkMorphology.MeanFilledArea_um;
MeanOxySinkDiameter_um = SinkMorphology.MeanDiameter_um;
MeanOxySinkPerimeter_um = SinkMorphology.MeanPerimeter_um;
MeanCircularity = SinkMorphology.MeanCircularity;
MeanCentroid_x = SinkMorphology.MeanCentroid_x;
MeanCentroid_y = SinkMorphology.MeanCentroid_y;
MeanOxySinkBoundingBox = SinkMorphology.MeanBoundingBox;
clear SinkMorphology


%% 
%Now the Overall_Pocket_Pxllist has all the putative oxygen sinks (row)and the list of pixels for each frame an event took place
fprintf('Collating properties of oxygen sinks and events... \n')

MetadataValues = currentLegacyMetadata();
SinkMetadata = createOutputMetadataVectors(size(Overall_OxygenSinks_Pxllist,1), ...
    DatafileID,RecDur,RecArea,MetadataValues,true);
Experiment = SinkMetadata.Experiment;
Mouse = SinkMetadata.Mouse;
Condition = SinkMetadata.Condition;
DrugID = SinkMetadata.DrugID;
Genotype = SinkMetadata.Genotype;
Promoter = SinkMetadata.Promoter;
RecDuration = SinkMetadata.RecDuration;
RecAreaSize = SinkMetadata.RecAreaSize;
PuffStim_locus = SinkMetadata.PuffStim_locus;
clear SinkMetadata
%% Collecting metrics for the events

%Event parameters
SinkEventMetadata = struct('Experiment',{Experiment},'Mouse',{Mouse},'Condition',{Condition}, ...
    'DrugID',{DrugID},'Genotype',{Genotype},'Promoter',{Promoter},'PuffStim',PuffStim_locus);
SinkEventMorphology = struct('MeanArea_um',MeanOxySinkArea_um,'MeanFilledArea_um',MeanOxySinkFilledArea_um, ...
    'MeanDiameter_um',MeanOxySinkDiameter_um,'MeanPerimeter_um',MeanOxySinkPerimeter_um, ...
    'MeanCircularity',MeanCircularity,'MeanCentroid_x',MeanCentroid_x,'MeanCentroid_y',MeanCentroid_y);
[NumOxySinkEvents,Start,Duration,NormOxySinkAmp,Size_modulation,Table_OxygenSinkEvents_Out,Trace_PotentialNoise] = ...
    collateOxygenSinkEvents(Overall_OxygenSinks_Pxllist,Overall_OxySinks_logical,Mean_OxySink_Trace_Convo, ...
    Mean_OxySink_Trace_Raw,Trace_PotentialNoise,SinkEventMetadata,SinkEventMorphology,fs,AnalysisParams, ...
    EventBaselineReturnTolerance,SinkDetectionNoiseAmpThreshold);

clear SinkEventMetadata SinkEventMorphology

toc;
%% STEP 12 Detecting Oxygen surges
fprintf('Identifying oxygen surges now... \n');

% Surge candidate thresholds are distinct from sink thresholds and remain provisional.
tic;
%The putative oxygen surges are identified based on singal intensity.

SurgeDetectionParams = struct();
SurgeDetectionParams.percentileThreshold = PercentileSurgeDetectionThres;
SurgeDetectionParams.minArea = ThresholdMinsize_Surges;
SurgeDetectionParams.maxArea = Inf;
SurgeDetectionParams.minCircularity = SurgeCircularityThreshold;
SurgeDetectionParams.maxOutsideFraction = MaxOutsideRecordingAreaFraction;
SurgeDetectionParams.frameTransform = 'mat2gray';
OxygenSurgesInfo_all = detectFrameRegionCandidates(IM_Zframetime_smoothed,RecAreaFilter,SurgeDetectionParams);

clear SurgeDetectionParams
toc;

%% STEP 13 Tracking surges through frames
fprintf('Tracking putative oxygen surges across the imaging session... \n'); 
tic;
%this will contain putative oxygen surges(rows) and the pixels belonging to events for every frame of the recording.
[Overall_OxygenSurges_Pxllist,Overall_OxySurges_logical,SurgeRunMap,SurgeCandidateRunQC,SurgeGapReview] = ...
    buildTrackedOxygenSurgeSites(OxygenSurgesInfo_all,AnalysisParams);

clear OxygenSurgesInfo_all
toc;

% Native runs have already passed duration filtering before recurring-site grouping.
fprintf('%d retained oxygen surge runs across %d sites.\n',height(SurgeRunMap),size(Overall_OxygenSurges_Pxllist,1));

%% Gathering oxygen surge loci parameters

SurgeMorphology = computeTrackedRegionMorphology(Overall_OxygenSurges_Pxllist,Overall_OxySurges_logical, ...
    size(IM_Zframetime),PixelSize,'coordinates','full','boundingBoxSummaryRow','first');
OxySurgeArea_all = SurgeMorphology.AreaAll;
IM_OxySurges_BW = SurgeMorphology.BinaryMap;
MeanOxySurgeArea_um = SurgeMorphology.MeanArea_um;
MeanOxySurgeFilledArea_um = SurgeMorphology.MeanFilledArea_um;
MeanOxySurgeDiameter_um = SurgeMorphology.MeanDiameter_um;
MeanOxySurgePerimeter_um = SurgeMorphology.MeanPerimeter_um;
MeanCircularity_Surge = SurgeMorphology.MeanCircularity;
MeanCentroid_Surge_x = SurgeMorphology.MeanCentroid_x;
MeanCentroid_Surge_y = SurgeMorphology.MeanCentroid_y;
MeanOxySurgeBoundingBox = SurgeMorphology.MeanBoundingBox;
clear SurgeMorphology

SurgeMetadata = createOutputMetadataVectors(size(Overall_OxygenSurges_Pxllist,1), ...
    DatafileID,RecDur,RecArea,MetadataValues,true);
Experiment_Surge = SurgeMetadata.Experiment;
Mouse_Surge = SurgeMetadata.Mouse;
Condition_Surge = SurgeMetadata.Condition;
DrugID_Surge = SurgeMetadata.DrugID;
Genotype_Surge = SurgeMetadata.Genotype;
Promoter_Surge = SurgeMetadata.Promoter;
RecDuration_Surge = SurgeMetadata.RecDuration;
RecAreaSize_Surge = SurgeMetadata.RecAreaSize;
PuffStim_Surge_locus = SurgeMetadata.PuffStim_locus;
clear SurgeMetadata MetadataValues

%% STEP 14

%Event parameters
fprintf('Extracting mean traces from Oxygen Surges... \n');
% I have to go pocket by pocket

[Mean_OxySurge_TraceZ,OxySurge_Pxls_all,OxySurge_Map] = extractSurgeTraces( ...
    Overall_OxygenSurges_Pxllist,Overall_OxySurges_logical,IM_Zframetime,IM_Zframetime_smoothed);

%% Calculating SurgeEvent parameters
SurgeEventMetadata = struct('Experiment',{Experiment_Surge},'Mouse',{Mouse_Surge}, ...
    'Condition',{Condition_Surge},'DrugID',{DrugID_Surge},'Genotype',{Genotype_Surge}, ...
    'Promoter',{Promoter_Surge},'PuffStim',PuffStim_Surge_locus);
SurgeEventMorphology = struct('MeanArea_um',MeanOxySurgeArea_um,'MeanFilledArea_um',MeanOxySurgeFilledArea_um, ...
    'MeanDiameter_um',MeanOxySurgeDiameter_um,'MeanPerimeter_um',MeanOxySurgePerimeter_um, ...
    'MeanCircularity',MeanCircularity_Surge,'MeanCentroid_x',MeanCentroid_Surge_x, ...
    'MeanCentroid_y',MeanCentroid_Surge_y);
[NumOxySurgeEvents,Start_Surge,Duration_Surge,NormOxySurgeAmp,Size_Surge_modulation,Table_OxygenSurgeEvents_Out] = ...
    collateOxygenSurgeEvents(Overall_OxygenSurges_Pxllist,Overall_OxySurges_logical, ...
    SurgeEventMetadata,SurgeEventMorphology,fs,AnalysisParams);
Table_OxygenSurgeEvents_Out=attachSurgeTrackingMetadata(Table_OxygenSurgeEvents_Out,SurgeRunMap,AnalysisParams);

clear SurgeEventMetadata SurgeEventMorphology


%% extracting traces for spatial bins
Mean_ROI_TraceZ = extractSpatialBinTraces(IM_Zframetime,RecArea_bins,fix(RecAreaBinHalfSizeUm/PixelSize)*2);

%% The output tables 
Table_OxygenSinks_Out = createOxygenSinkSummaryTable(Experiment,Mouse,Condition,DrugID,Genotype,Promoter, ...
    RecDuration,RecAreaSize,MeanCentroid_x,MeanCentroid_y,MeanOxySinkArea_um,MeanOxySinkFilledArea_um, ...
    MeanOxySinkDiameter_um,MeanOxySinkPerimeter_um,MeanCircularity,MeanOxySinkBoundingBox, ...
    NumOxySinkEvents,Start,Duration,NormOxySinkAmp,Size_modulation,OxySink_Pxls_all);

Table_OxygenSurges_Out = createOxygenSurgeSummaryTable(Experiment_Surge,Mouse_Surge,Condition_Surge, ...
    DrugID_Surge,Genotype_Surge,Promoter_Surge,RecDuration_Surge,RecAreaSize_Surge,MeanCentroid_Surge_x, ...
    MeanCentroid_Surge_y,MeanOxySurgeArea_um,MeanOxySurgeFilledArea_um,MeanOxySurgeDiameter_um, ...
    MeanOxySurgePerimeter_um,MeanCircularity_Surge,MeanOxySurgeBoundingBox,NumOxySurgeEvents, ...
    Start_Surge,Duration_Surge,NormOxySurgeAmp,Size_Surge_modulation,OxySurge_Pxls_all);
% Analysis schema 2.1: preserve native geometry and quantify each event independently.
AnalysisInfo.PipelineContract=oxygenPipelineContract();
AnalysisInfo.AnalysisSchemaVersion=AnalysisInfo.PipelineContract.Schema;
AnalysisInfo.RecordingID = char(java.io.File(Tifffiles(1).folder).getCanonicalPath());
AnalysisInfo.NFrames = size(IM_Raw,3);
AnalysisInfo.RecordingDurationSec = size(IM_Raw,3)/fs;
AnalysisInfo.RecordingAreaUm2 = nnz(RecAreaFilter(Pixel_frame+1:end-Pixel_frame,Pixel_frame+1:end-Pixel_frame))*PixelSize^2;
AnalysisInfo.SurgeRecordingAreaUm2 = RecArea;
SinkTissueMask=false(size(RecAreaFilter));
SinkTissueMask(Pixel_frame+1:end-Pixel_frame,Pixel_frame+1:end-Pixel_frame)= ...
    RecAreaFilter(Pixel_frame+1:end-Pixel_frame,Pixel_frame+1:end-Pixel_frame);
AnalysisInfo.SinkEligibleTissuePixels=find(SinkTissueMask);
AnalysisInfo.SurgeEligibleTissuePixels=find(RecAreaFilter);
Table_OxygenSinks_Out.RecAreaSize=repmat({AnalysisInfo.RecordingAreaUm2},height(Table_OxygenSinks_Out),1);
[Table_OxygenSinks_Out,Table_OxygenSinkEvents_Out] = finalizeOxygenEventMeasurements( ...
    Table_OxygenSinks_Out,Table_OxygenSinkEvents_Out,Overall_OxygenSinks_Pxllist, ...
    IM_Raw,fs,PixelSize,Pixel_frame,AnalysisInfo.RecordingID,'sink',AnalysisParams.quantBaselineWindowSec,Overall_OxygenSurges_Pxllist,0);
[Table_OxygenSurges_Out,Table_OxygenSurgeEvents_Out] = finalizeOxygenEventMeasurements( ...
    Table_OxygenSurges_Out,Table_OxygenSurgeEvents_Out,Overall_OxygenSurges_Pxllist, ...
    IM_Raw,fs,PixelSize,0,AnalysisInfo.RecordingID,'surge',AnalysisParams.surgeBaselineWindowSec,Overall_OxygenSinks_Pxllist,Pixel_frame);
Table_OxygenSinks_Out.EligibleTissuePixels=repmat({AnalysisInfo.SinkEligibleTissuePixels},height(Table_OxygenSinks_Out),1);
Table_OxygenSurges_Out.EligibleTissuePixels=repmat({AnalysisInfo.SurgeEligibleTissuePixels},height(Table_OxygenSurges_Out),1);
%% Saving outputs
OverwriteOutputs = exist('strOW','var') && strcmpi(strOW,'Y');
OutputData = createOxygenMasterOutputData(Tifffiles(1).folder,OverwriteOutputs,DatafileID,AnalysisInfo, ...
    IM_Notrend,IM_Zframetime_smoothed,IM_OxySinks_BW,IM_OxySurges_BW,Table_OxygenSinks_Out, ...
    Table_OxygenSinkEvents_Out,OxySinkArea_all,Mean_ROI_TraceZ,Mean_OxySink_TraceZ, ...
    Mean_OxySink_Trace_Convo,Mean_OxySink_Trace_Raw,OxySink_Map,Trace_PotentialNoise, ...
    Table_OxygenSurges_Out,Table_OxygenSurgeEvents_Out,OxySurgeArea_all,Mean_OxySurge_TraceZ,OxySurge_Map);
SurgeCandidateRunQC.RecordingID=repmat(string(AnalysisInfo.RecordingID),height(SurgeCandidateRunQC),1);
SurgeGapReview.RecordingID=repmat(string(AnalysisInfo.RecordingID),height(SurgeGapReview),1);
OutputData.SurgeCandidateRunQC=SurgeCandidateRunQC;
OutputData.SurgeGapReview=SurgeGapReview;
SaveResult = saveOxygenMasterOutputs(OutputData);
OutputFolders = SaveResult.OutputFolders;
AnalysisInfo = SaveResult.AnalysisInfo;
clear OutputData SaveResult

