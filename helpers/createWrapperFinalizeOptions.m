function FinalizeOptions = createWrapperFinalizeOptions(RunConfig,AnalysisMode,Paths,Masterfolder,EmailDestination,WrapperType)
%CREATEWRAPPERFINALIZEOPTIONS Build options for finalizeWrapperRun.

FinalizeOptions = struct();
FinalizeOptions.RunConfig = RunConfig;
FinalizeOptions.AnalysisMode = AnalysisMode;
FinalizeOptions.Paths = Paths;
FinalizeOptions.Masterfolder = Masterfolder;
FinalizeOptions.EmailDestination = EmailDestination;
FinalizeOptions.RunLogFolder = fullfile(Masterfolder,'Run_Logs');
FinalizeOptions.QCOutputFolder = fullfile(Masterfolder,'QC_Output');

switch lower(WrapperType)
    case 'oxygen'
        FinalizeOptions.RunInfoFile = fullfile(FinalizeOptions.RunLogFolder,'OxygenDynamics_WrapperRunInfo.mat');
        FinalizeOptions.ImagingFailureField = 'OxyDynamicsfailures';
        FinalizeOptions.ImagingFailureFile = fullfile(FinalizeOptions.RunLogFolder,'OxyDynamicsfailures.mat');
        FinalizeOptions.ImagingFailureVariable = 'OxyDynamicsfailures';
        FinalizeOptions.SuccessMessage = 'OxygenDynamics_Wrapper finished running successfully';
    case 'ios'
        FinalizeOptions.RunInfoFile = fullfile(FinalizeOptions.RunLogFolder,'iOSDynamics_WrapperRunInfo.mat');
        FinalizeOptions.ImagingFailureField = 'iOSDynamicsfailures';
        FinalizeOptions.ImagingFailureFile = fullfile(FinalizeOptions.RunLogFolder,'iOSDynamicsfailures.mat');
        FinalizeOptions.ImagingFailureVariable = 'iOSDynamicsfailures';
        FinalizeOptions.SuccessMessage = 'iOSDynamics_Wrapper finished running successfully';
    otherwise
        error('Unknown wrapper type "%s". Expected "oxygen" or "ios".',WrapperType);
end

FinalizeOptions.BehaviourFailureFile = fullfile(FinalizeOptions.RunLogFolder,'Behaviourfailures.mat');
FinalizeOptions.BehaviourFailureVariable = 'Behaviourfailures';

end
