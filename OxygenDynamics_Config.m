function Config = OxygenDynamics_Config()
%OXYGENDYNAMICS_CONFIG Central editable configuration for batch scripts.
%
% Edit values here instead of changing wrapper/statistics script internals.
% The wrappers and stats script still define defaults first, then override
% matching fields from this file.

Config = struct();

Config.OxygenWrapper = struct();
Config.OxygenWrapper.inputCsv = 'GFAP_GeNL_Ctrl.csv';
Config.OxygenWrapper.interactive = false;
Config.OxygenWrapper.reanalyseExisting = true;
Config.OxygenWrapper.overwritePreviousAnalysis = false;
Config.OxygenWrapper.analysisMode = 'All analysis'; % Also supports 'Hypoxia-amyloid only'
Config.OxygenWrapper.sendEmailAlerts = false;
Config.OxygenWrapper.emailRecipient = 'felix.beinlich@sund.ku.dk';
Config.OxygenWrapper.runRawDenoisedQC = true;
Config.OxygenWrapper.runHypoxiaAmyloidAnalysis = true;
Config.OxygenWrapper.hypoxiaAmyloidAmyloidThreshold = NaN;
Config.OxygenWrapper.hypoxiaAmyloidHypoxiaThreshold = 0.07;
Config.OxygenWrapper.hypoxiaAmyloidMinimumPlaqueAreaPixels = 3;
Config.OxygenWrapper.hypoxiaAmyloidRegionSigmaMicrometers = 9.72;
Config.OxygenWrapper.hypoxiaAmyloidCoarseSigmaMicrometers = 243;
Config.OxygenWrapper.hypoxiaAmyloidNumSpatialPermutations = 1000;
Config.OxygenWrapper.hypoxiaAmyloidNumCohortPermutations = 10000;
Config.OxygenWrapper.hypoxiaAmyloidRandomSeed = 1;
Config.OxygenWrapper.hypoxiaAmyloidNearThresholdMicrometers = 50;
Config.OxygenWrapper.hypoxiaAmyloidSensitivityThresholdsMicrometers = [25 50 75 100];
Config.OxygenWrapper.hypoxiaAmyloidMinimumObservationsPerStratum = 3;
Config.OxygenWrapper.hypoxiaAmyloidDistanceVariable = 'EdgeDistance_um';
Config.OxygenWrapper.hypoxiaAmyloidSaveFigures = true;

Config.iOSWrapper = struct();
Config.iOSWrapper.inputCsv = 'iOS_DataPathsExample.csv';
Config.iOSWrapper.interactive = false;
Config.iOSWrapper.reanalyseExisting = true;
Config.iOSWrapper.overwritePreviousAnalysis = false;
Config.iOSWrapper.analysisMode = 'All analysis'; % 'All analysis', 'Only df/f tifs', or 'Preflight only'
Config.iOSWrapper.sendEmailAlerts = false;
Config.iOSWrapper.emailRecipient = 'felix.beinlich@sund.ku.dk';

Config.Stats = struct();
Config.Stats.inputCsv = 'GFAP_GeNL_Ctrl.csv';
Config.Stats.interactive = false;
Config.Stats.useCuratedSinks = false;
Config.Stats.imagingMode = 'BLI'; % 'BLI' or 'iOS'
Config.Stats.chooseSpecificFolders = false;
Config.Stats.sinkFolderSelection = 'Recent'; % 'Recent' or 'Oldest'
Config.Stats.surgeFolderSelection = 'Recent'; % 'Recent' or 'Oldest'
Config.Stats.behaviourFolderSelection = 'Recent'; % 'Recent' or 'Oldest'
Config.Stats.outputRoot = 'Stats_Runs';
Config.Stats.analysisWindowsCsv = '';
Config.Stats.windowPairsCsv = '';
Config.Stats.baselinePairsCsv = ''; % Explicit BaselineRecordingID,ComparisonRecordingID pairs
Config.Stats.behaviourTimeWindows = {'3','3','3','3'}; % manual, movement/whisking, pupil, puff

Config.Verification = struct();
Config.Verification.inputCsv = Config.Stats.inputCsv;
Config.Verification.outputRoot = 'Verification_Reports';
Config.Verification.sinkFolderSelection = Config.Stats.sinkFolderSelection;
Config.Verification.surgeFolderSelection = Config.Stats.surgeFolderSelection;
Config.Verification.behaviourFolderSelection = Config.Stats.behaviourFolderSelection;
Config.Verification.overwriteOutputs = false;
Config.Verification.requireBehaviour = false;
Config.Verification.requireVascularAnnotations = false;

Config.Regression = struct();
Config.Regression.baselinePath = fullfile('Regression_Baselines','OxygenRegressionBaseline.mat');
Config.Regression.throwOnFailure = false;
Config.Regression.createBaselineIfMissing = false;

end
