function WrapperRunInfo = OxygenDynamics_Wrapper(RunConfigOverride)
%OXYGENDYNAMICS_WRAPPER Run oxygen dynamics analysis for all CSV recordings.
%
% WrapperRunInfo = OxygenDynamics_Wrapper()
% WrapperRunInfo = OxygenDynamics_Wrapper(RunConfigOverride)
%
% RunConfigOverride is an optional struct used by the GUI and batch helpers
% to override the default/config-file wrapper settings.

if nargin<1
    RunConfigOverride = struct();
end

%% Wrapper script to run the Oxygen Dynamics analysis in all datafolders needed

% The input is a CSV file with the relative paths of the data
% folders. For example for current folder 'C:\User\Alldata\' that contains folders 'Mouse1' and 'Mouse2' etc
% the paths should be 'Mouse1\Recording1' 'Mouse1\Recording2' 'Mouse2\Recording1' etc
 
% The same CSV file can contain other metadata related to each recording,
% including, the animal genotype the type of recording (e.g awake vs aneasthetised), the sampling frequency or the type of lense (that will affect pixel size) etc.
% Check the example file 

% The wrapper script goes through the data and calls the main OxygenDynamics analysis script to analyse sinks and surges of oxygen
% If a recording comes with behavioural data, the wrapper also calls a behavioural analysis script 


% The wrapper and OxygenDynamics share a workspace, in that way the metadata can be included in the output table of
% each data session and make statistical analysis easier. 

% IMPORTANT!!
% Please use underscores instead of spaces in folder and file names of all data

% The names of the three behavioural data files should be stated without their extention. 
% It is expected that they will be csv files for pupil and movement and a abf file for the air puffs
% These files MUST be in the same folder where the imaging data file is. 

% As always, remember to add the folder with the scripts in the path.

% From Antonis Asiminas, PhD
% Last update 10 Jun 2023

setupOxygenDynamicsPath();

%% Run configuration
% Set interactive=false for reproducible batch runs without dialog prompts.
RunConfig = struct();
RunConfig.inputCsv = 'GFAP_GeNL_Ctrl.csv';
RunConfig.interactive = false;
RunConfig.reanalyseExisting = true;
RunConfig.overwritePreviousAnalysis = false;
RunConfig.analysisMode = 'All analysis'; % Also supports 'Hypoxia-amyloid only'
RunConfig.sendEmailAlerts = false;
RunConfig.emailRecipient = 'felix.beinlich@sund.ku.dk';
RunConfig.runRawDenoisedQC = true;
RunConfig.runHypoxiaAmyloidAnalysis = true;
RunConfig.hypoxiaAmyloidAmyloidThreshold = NaN;
RunConfig.hypoxiaAmyloidHypoxiaThreshold = 0.07;
RunConfig.hypoxiaAmyloidMinimumPlaqueAreaPixels = 3;
RunConfig.hypoxiaAmyloidRegionSigmaMicrometers = 9.72;
RunConfig.hypoxiaAmyloidCoarseSigmaMicrometers = 243;
RunConfig.hypoxiaAmyloidNumSpatialPermutations = 1000;
RunConfig.hypoxiaAmyloidNumCohortPermutations = 10000;
RunConfig.hypoxiaAmyloidBootstrapIterations = 5000;
RunConfig.hypoxiaAmyloidRandomSeed = 1;
RunConfig.hypoxiaAmyloidNearThresholdMicrometers = 50;
RunConfig.hypoxiaAmyloidSensitivityThresholdsMicrometers = [25 50 75 100];
RunConfig.hypoxiaAmyloidMinimumObservationsPerStratum = 3;
RunConfig.hypoxiaAmyloidDistanceVariable = 'CentroidDistance_um';
RunConfig.hypoxiaAmyloidSaveFigures = true;
RunConfig.masterFolder = pwd;
RunConfig = applyOxygenDynamicsConfig(RunConfig,'OxygenWrapper');
if ~isempty(fieldnames(RunConfigOverride))
    RunConfig = mergeStructs(RunConfig,RunConfigOverride);
end

%%
InputD=readInputTable(RunConfig.inputCsv);
RequiredInputColumns = requiredWrapperInputColumns();
validateInputTableColumns(InputD,RequiredInputColumns,RunConfig.inputCsv);

%% Resolve run choices
[answer1,strAgain,strOW] = resolveWrapperRunChoices(RunConfig);

printWrapperConfiguration('OxygenDynamics_Wrapper',RunConfig,answer1);

%% Email alerts info
% Email alerts use the shared sendolmail.m Outlook helper.
destination = getWrapperEmailDestination(RunConfig);
%% Separate the information contained in the table

[Paths,Postures,Pupils,Puffs,Mice,Genotypes,Conditions,DrugIDs,Promoters,SampleFs,Pixelsizes,AmyloidFiles] = ...
    unpackWrapperInputTable(InputD);
if strcmp(answer1,'Hypoxia-amyloid only')
    if ~ismember('AmyloidFile',InputD.Properties.VariableNames)
        error('HypoxiaAmyloid:MissingCsvColumn', ...
            'The selected CSV must contain an AmyloidFile column for Hypoxia-amyloid only mode.');
    end
    HasConfiguredAmyloid = cellfun(@isOptionalMetadataValueConfigured,AmyloidFiles);
    if ~any(HasConfiguredAmyloid)
        error('HypoxiaAmyloid:NoConfiguredFiles', ...
            'The selected CSV contains no configured AmyloidFile values.');
    end
end

%% Creating an empty table to get all the tables from each recording created in the master script.
% this is only for the oxygen surges since the oxygen sink data need to be refined 

Masterfolder=RunConfig.masterFolder;
validateRecordingPaths(Paths,Masterfolder,RunConfig.inputCsv);

% Create two structures to catch errors from the oxygen dymanics and
% behavioural metrics' analyses
OxyDynamicsfailures = struct('FileName', {}, 'ERROR', {}, 'MESSAGE', {});    
Behaviourfailures = struct('FileName', {}, 'ERROR', {}, 'MESSAGE', {});
Amyloidfailures = struct('FileName', {}, 'ERROR', {}, 'MESSAGE', {});
AmyloidResults = cell(length(Paths),1);
WrapperRunInfo = createWrapperRunInfo(RunConfig,answer1,Paths);
WrapperRunInfo.RequiredInputColumns = RequiredInputColumns;
WrapperRunInfo.ValidatedPaths = Paths;

for datai=1:length(Paths)
    RecordingFolder = makeFullRecordingPath(Paths{datai},Masterfolder);
    SFs = SampleFs{datai};
    Mous = Mice{datai};
    Cond = Conditions{datai};
    PiSz = Pixelsizes{datai};
    Gen = Genotypes{datai};
    Promo = Promoters{datai};
    Drug = DrugIDs{datai};
    Posture = Postures{datai};
    Pupil = Pupils{datai};
    Puff = Puffs{datai};
    AmyloidFile = AmyloidFiles{datai};
    RecordingContext = createLegacyRecordingContext(SFs,Mous,Cond,PiSz,Gen,Promo,Drug,Posture,Pupil,Puff,strOW);
    Metadata = createRecordingMetadata(Mous,Cond,Drug,Gen,Promo);
    OverwriteOutputs = strcmpi(strOW,'Y');
    Validation = validateOxygenRecording(RecordingFolder,SFs,PiSz,OverwriteOutputs,Metadata);
    RecordingContext = addValidationToLegacyContext(RecordingContext,Validation,SFs);
    WrapperRunInfo = updateWrapperRecordingInfo(WrapperRunInfo,datai,Paths{datai}, ...
        RecordingFolder,Mous,Cond,Drug,Validation);
    ImagingOutput = struct();

    printWrapperRecordingStatus('Oxygen',datai,length(Paths),Mous,RecordingFolder,Validation,'oxygen');

    switch answer1

        case 'Preflight only'

            WrapperRunInfo.Recordings(datai).ImagingStatus = 'Preflight only';
            WrapperRunInfo.Recordings(datai).AmyloidStatus = 'Preflight only';
            WrapperRunInfo.Recordings(datai).BehaviourStatus = 'Preflight only';
            if ~Validation.IsValid
                OxyDynamicsfailures = appendFailure(OxyDynamicsfailures,Paths{datai}, ...
                    strjoin(Validation.Errors,newline),'Preflight validation failed.');
            end

        case 'Only df/f tifs'

            WrapperRunInfo.Recordings(datai).AmyloidStatus = ...
                'Skipped: analysis mode does not detect pockets';

            if ~Validation.IsValid
                OxyDynamicsfailures = appendFailure(OxyDynamicsfailures,Paths{datai}, ...
                    strjoin(Validation.Errors,newline),'Preflight validation failed before runOxygenDynamicsTiffout.m.');
                WrapperRunInfo.Recordings(datai).ImagingStatus = 'Skipped: preflight validation failed';
            elseif shouldRunOutputStep(fullfile(RecordingFolder,'OxygenSinks_Output'),strAgain,strOW)
            
                try

                    runOxygenDynamicsTiffout(RecordingFolder,RecordingContext);
                    WrapperRunInfo.Recordings(datai).ImagingStatus = 'Completed: runOxygenDynamicsTiffout.m';

                catch ME

                    subj = ['Error alert in runOxygenDynamicsTiffout when analysing ',Paths{datai}];
                    OxyDynamicsfailures = handleWrapperFailure(OxyDynamicsfailures,Paths{datai},ME, ...
                        'runOxygenDynamicsTiffout.m',subj,RunConfig.sendEmailAlerts,destination,RunConfig.interactive);
                    WrapperRunInfo.Recordings(datai).ImagingStatus = 'Failed: runOxygenDynamicsTiffout.m';

                end
            else
                WrapperRunInfo.Recordings(datai).ImagingStatus = 'Skipped: existing output';

            end

        case 'Hypoxia-amyloid only'

            WrapperRunInfo.Recordings(datai).ImagingStatus = ...
                'Skipped: hypoxia-amyloid only mode';
            WrapperRunInfo.Recordings(datai).BehaviourStatus = ...
                'Skipped: hypoxia-amyloid only mode';

            if ~RunConfig.runHypoxiaAmyloidAnalysis
                WrapperRunInfo.Recordings(datai).AmyloidStatus = ...
                    'Skipped: disabled in configuration';
            elseif ~isOptionalMetadataValueConfigured(AmyloidFile)
                WrapperRunInfo.Recordings(datai).AmyloidStatus = ...
                    'Skipped: no AmyloidFile configured';
            else
                try
                    WrapperRunInfo.Recordings(datai).AmyloidFile = char(string(AmyloidFile));
                    AmyloidOptions = createHypoxiaAmyloidRunOptions( ...
                        RunConfig,OverwriteOutputs,datai);
                    AmyloidResult = runHypoxiaAmyloidRecordingAnalysis( ...
                        RecordingFolder,AmyloidFile,Metadata,SFs,PiSz,AmyloidOptions);
                    AmyloidResults{datai} = AmyloidResult;
                    WrapperRunInfo.Recordings(datai).AmyloidFile = AmyloidResult.AmyloidFile;
                    WrapperRunInfo.Recordings(datai).AmyloidOutputFolder = AmyloidResult.OutputFolder;
                    WrapperRunInfo.Recordings(datai).AmyloidStatus = ...
                        'Completed: hypoxia-amyloid analysis';
                    fprintf('Hypoxia-amyloid completed: %s\n',AmyloidResult.OutputFolder);
                catch ME
                    Amyloidfailures = appendFailure(Amyloidfailures,Paths{datai}, ...
                        getReport(ME),'Hypoxia-amyloid analysis failed.');
                    WrapperRunInfo.Recordings(datai).AmyloidStatus = ...
                        'Failed: hypoxia-amyloid analysis';
                    fprintf('Hypoxia-amyloid failed for %s: %s\n', ...
                        string(Mous),ME.message);
                end
            end

        case 'All analysis'
  
            if ~Validation.IsValid
                OxyDynamicsfailures = appendFailure(OxyDynamicsfailures,Paths{datai}, ...
                    strjoin(Validation.Errors,newline),'Preflight validation failed before runOxygenDynamicsMaster.m.');
                WrapperRunInfo.Recordings(datai).ImagingStatus = 'Skipped: preflight validation failed';
            elseif shouldRunOutputStep(fullfile(RecordingFolder,'OxygenSinks_Output'),strAgain,strOW)
            
                try
            
                    ImagingOutput = runOxygenDynamicsMaster(RecordingFolder,RecordingContext);
                    WrapperRunInfo.Recordings(datai).ImagingStatus = 'Completed: runOxygenDynamicsMaster.m';
                    
                catch ME %catch the error message
    
            
                    subj = ['Error alert in runOxygenDynamicsMaster when analysing ',Paths{datai}];  % subject line    
                    OxyDynamicsfailures = handleWrapperFailure(OxyDynamicsfailures,Paths{datai},ME, ...
                        'runOxygenDynamicsMaster.m',subj,RunConfig.sendEmailAlerts,destination,RunConfig.interactive);
                    WrapperRunInfo.Recordings(datai).ImagingStatus = 'Failed: runOxygenDynamicsMaster.m';

                end
            else
                WrapperRunInfo.Recordings(datai).ImagingStatus = 'Skipped: existing output';
  
            end

            if ~RunConfig.runHypoxiaAmyloidAnalysis
                WrapperRunInfo.Recordings(datai).AmyloidStatus = 'Skipped: disabled in configuration';
            elseif ~isOptionalMetadataValueConfigured(AmyloidFile)
                WrapperRunInfo.Recordings(datai).AmyloidStatus = 'Skipped: no AmyloidFile configured';
            elseif ~Validation.IsValid
                WrapperRunInfo.Recordings(datai).AmyloidStatus = ...
                    'Skipped: oxygen preflight validation failed';
            else
                try
                    WrapperRunInfo.Recordings(datai).AmyloidFile = char(string(AmyloidFile));
                    AmyloidOptions = createHypoxiaAmyloidRunOptions( ...
                        RunConfig,OverwriteOutputs,datai);
                    AmyloidResult = runHypoxiaAmyloidRecordingAnalysis( ...
                        RecordingFolder,AmyloidFile,Metadata,SFs,PiSz,AmyloidOptions);
                    AmyloidResults{datai} = AmyloidResult;
                    WrapperRunInfo.Recordings(datai).AmyloidFile = AmyloidResult.AmyloidFile;
                    WrapperRunInfo.Recordings(datai).AmyloidOutputFolder = AmyloidResult.OutputFolder;
                    WrapperRunInfo.Recordings(datai).AmyloidStatus = ...
                        'Completed: hypoxia-amyloid analysis';
                catch ME
                    Amyloidfailures = appendFailure(Amyloidfailures,Paths{datai}, ...
                        getReport(ME),'Hypoxia-amyloid analysis failed.');
                    WrapperRunInfo.Recordings(datai).AmyloidStatus = ...
                        'Failed: hypoxia-amyloid analysis';
                end
            end

    
            if shouldRunOutputStep(fullfile(RecordingFolder,'Behaviour_Output'),strAgain,false)
       
                try
                   
                    BehaviourContext = mergeStructs(RecordingContext,ImagingOutput);
                    runOxygenDynamicsBehaviour(RecordingFolder,BehaviourContext);
                    WrapperRunInfo.Recordings(datai).BehaviourStatus = 'Completed: runOxygenDynamicsBehaviour.m';
        
                catch ME %catch the error message
        
            
                    subj = 'Error alert for OxygenDynamics_Behaviour';  % subject line                       
                    Behaviourfailures = handleWrapperFailure(Behaviourfailures,Paths{datai},ME, ...
                        'runOxygenDynamicsBehaviour.m',subj,RunConfig.sendEmailAlerts,destination,RunConfig.interactive);
                    WrapperRunInfo.Recordings(datai).BehaviourStatus = 'Failed: runOxygenDynamicsBehaviour.m';
       
                end
            else
                WrapperRunInfo.Recordings(datai).BehaviourStatus = 'Skipped: existing output';

            end

    end
        
    clearvars -except datai Masterfolder Paths Mice DrugIDs Conditions Genotypes Promoters SampleFs Pixelsizes Postures Pupils Puffs AmyloidFiles strOW strAgain InputD ...
        destination answer1 OxyDynamicsfailures Behaviourfailures Amyloidfailures AmyloidResults RunConfig WrapperRunInfo
end

WrapperRunInfo.AmyloidFailures = Amyloidfailures;
CompletedAmyloidResults = AmyloidResults(~cellfun(@isempty,AmyloidResults));
if ~isempty(CompletedAmyloidResults)
    try
        CohortOptions = struct();
        CohortOptions.PropertyOptions = createHypoxiaAmyloidRunOptions( ...
            RunConfig,false,0).PropertyOptions;
        CohortOptions.NumPermutations = RunConfig.hypoxiaAmyloidNumCohortPermutations;
        CohortOptions.BootstrapIterations = ...
            RunConfig.hypoxiaAmyloidBootstrapIterations;
        CohortOptions.RandomSeed = RunConfig.hypoxiaAmyloidRandomSeed;
        CohortOptions.ConfiguredAnimals = InputD;
        WrapperRunInfo.HypoxiaAmyloidCohort = runHypoxiaAmyloidCohortSummary( ...
            CompletedAmyloidResults,Masterfolder,CohortOptions);
    catch ME
        WrapperRunInfo.HypoxiaAmyloidCohortError = getReport(ME);
    end
end
AmyloidStatuses = string({WrapperRunInfo.Recordings.AmyloidStatus});
fprintf('\nHypoxia-amyloid wrapper summary: %d completed, %d failed, %d skipped.\n', ...
    sum(startsWith(AmyloidStatuses,'Completed')), ...
    sum(startsWith(AmyloidStatuses,'Failed')), ...
    sum(startsWith(AmyloidStatuses,'Skipped')));

FinalizeOptions = createWrapperFinalizeOptions(RunConfig,answer1,Paths,Masterfolder,destination,'oxygen');
WrapperRunInfo = finalizeWrapperRun(WrapperRunInfo,OxyDynamicsfailures,Behaviourfailures,FinalizeOptions);

end
