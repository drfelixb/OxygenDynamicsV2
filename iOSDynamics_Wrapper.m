%% Wrapper script to run the iOS Dynamics analysis in all datafolders with iOS data. 
% This is a modified version of the Oxygen Dynamics analysis 

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
% Update 26 Sep 2023

setupOxygenDynamicsPath();

%% Run configuration
% Set interactive=false for reproducible batch runs without dialog prompts.
RunConfig = struct();
RunConfig.inputCsv = 'iOS_DataPathsExample.csv';
RunConfig.interactive = false;
RunConfig.reanalyseExisting = true;
RunConfig.overwritePreviousAnalysis = false;
RunConfig.analysisMode = 'All analysis'; % 'All analysis', 'Only df/f tifs', or 'Preflight only'
RunConfig.sendEmailAlerts = false;
RunConfig.emailRecipient = 'felix.beinlich@sund.ku.dk';
RunConfig = applyOxygenDynamicsConfig(RunConfig,'iOSWrapper');

%%
InputD=readInputTable(RunConfig.inputCsv);
RequiredInputColumns = requiredWrapperInputColumns();
validateInputTableColumns(InputD,RequiredInputColumns,RunConfig.inputCsv);

%% Resolve run choices
[answer1,strAgain,strOW] = resolveWrapperRunChoices(RunConfig);

printWrapperConfiguration('iOSDynamics_Wrapper',RunConfig,answer1);

%% Email alerts info
% Email alerts use the shared sendolmail.m Outlook helper.
destination = getWrapperEmailDestination(RunConfig);
%% Separate the information contained in the table

[Paths,Postures,Pupils,Puffs,Mice,Genotypes,Conditions,DrugIDs,Promoters,SampleFs,Pixelsizes] = ...
    unpackWrapperInputTable(InputD);

%% Creating an empty table to get all the tables from each recording created in the master script.
% this is only for the oxygen surges since the oxygen sink data need to be refined 

Masterfolder=pwd;
validateRecordingPaths(Paths,Masterfolder,RunConfig.inputCsv);

% Create two structures to catch errors from the oxygen dymanics and
% behavioural metrics' analyses
iOSDynamicsfailures = struct('FileName', {}, 'ERROR', {}, 'MESSAGE', {});    
Behaviourfailures = struct('FileName', {}, 'ERROR', {}, 'MESSAGE', {});
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
    RecordingContext = createLegacyRecordingContext(SFs,Mous,Cond,PiSz,Gen,Promo,Drug,Posture,Pupil,Puff,strOW);
    Metadata = createRecordingMetadata(Mous,Cond,Drug,Gen,Promo);
    OverwriteOutputs = strcmpi(strOW,'Y');
    Validation = validateOxygenRecording(RecordingFolder,SFs,PiSz,OverwriteOutputs,Metadata);
    RecordingContext = addValidationToLegacyContext(RecordingContext,Validation,SFs);
    WrapperRunInfo = updateWrapperRecordingInfo(WrapperRunInfo,datai,Paths{datai}, ...
        RecordingFolder,Mous,Cond,Drug,Validation);
    ImagingOutput = struct();

    printWrapperRecordingStatus('iOS',datai,length(Paths),Mous,RecordingFolder,Validation,'ios');

   
    switch answer1

        case 'Preflight only'

            WrapperRunInfo.Recordings(datai).ImagingStatus = 'Preflight only';
            WrapperRunInfo.Recordings(datai).BehaviourStatus = 'Preflight only';
            if ~Validation.IsValid
                iOSDynamicsfailures = appendFailure(iOSDynamicsfailures,Paths{datai}, ...
                    strjoin(Validation.Errors,newline),'Preflight validation failed.');
            end

                
        case 'Only df/f tifs'

            if ~Validation.IsValid
                iOSDynamicsfailures = appendFailure(iOSDynamicsfailures,Paths{datai}, ...
                    strjoin(Validation.Errors,newline),'Preflight validation failed before runiOSTiffout.m.');
                WrapperRunInfo.Recordings(datai).ImagingStatus = 'Skipped: preflight validation failed';
            elseif shouldRunOutputStep('OxygenSinks_Output',strAgain,strOW)
            
                try

                    runiOSTiffout(RecordingFolder,RecordingContext);
                    WrapperRunInfo.Recordings(datai).ImagingStatus = 'Completed: runiOSTiffout.m';

                catch ME

                    subj = ['Error alert in runiOSTiffout when analysing ',Paths{datai}];
                    iOSDynamicsfailures = handleWrapperFailure(iOSDynamicsfailures,Paths{datai},ME, ...
                        'runiOSTiffout.m',subj,RunConfig.sendEmailAlerts,destination,RunConfig.interactive);
                    WrapperRunInfo.Recordings(datai).ImagingStatus = 'Failed: runiOSTiffout.m';

                end
            else
                WrapperRunInfo.Recordings(datai).ImagingStatus = 'Skipped: existing output';

            end

            
        case 'All analysis'
    
        
            if ~Validation.IsValid
                iOSDynamicsfailures = appendFailure(iOSDynamicsfailures,Paths{datai}, ...
                    strjoin(Validation.Errors,newline),'Preflight validation failed before runiOSDynamicsMaster.m.');
                WrapperRunInfo.Recordings(datai).ImagingStatus = 'Skipped: preflight validation failed';
            elseif shouldRunOutputStep('OxygenSinks_Output',strAgain,strOW)

            
                try

                    ImagingOutput = runiOSDynamicsMaster(RecordingFolder,RecordingContext);
                    WrapperRunInfo.Recordings(datai).ImagingStatus = 'Completed: runiOSDynamicsMaster.m';

                catch ME %catch the error message
              
            
                    subj = ['Error alert in runiOSDynamicsMaster when analysing ',Paths{datai}];  % subject line    
                    iOSDynamicsfailures = handleWrapperFailure(iOSDynamicsfailures,Paths{datai},ME, ...
                        'runiOSDynamicsMaster.m',subj,RunConfig.sendEmailAlerts,destination,RunConfig.interactive);
                    WrapperRunInfo.Recordings(datai).ImagingStatus = 'Failed: runiOSDynamicsMaster.m';
            

                end
            else
                WrapperRunInfo.Recordings(datai).ImagingStatus = 'Skipped: existing output';
        
    
            end

          
    
            if shouldRunOutputStep('Behaviour_Output',strAgain,false)
                     
        
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

    clearvars -except datai Masterfolder Paths Mice DrugIDs Conditions Genotypes Promoters SampleFs Pixelsizes Postures Pupils Puffs strOW strAgain InputD ...
        destination answer1 iOSDynamicsfailures Behaviourfailures RunConfig WrapperRunInfo
end

FinalizeOptions = createWrapperFinalizeOptions(RunConfig,answer1,Paths,Masterfolder,destination,'ios');
WrapperRunInfo = finalizeWrapperRun(WrapperRunInfo,iOSDynamicsfailures,Behaviourfailures,FinalizeOptions);
