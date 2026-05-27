function WrapperRunInfo = finalizeWrapperRun(WrapperRunInfo,ImagingFailures,Behaviourfailures,Options)
%FINALIZEWRAPPERRUN Save wrapper manifest, failures, optional QC, and final email.

WrapperRunInfo.EndTime = char(datetime('now','Format','yyyy-MM-dd HH:mm:ss'));
WrapperRunInfo.(Options.ImagingFailureField) = ImagingFailures;
WrapperRunInfo.Behaviourfailures = Behaviourfailures;
WrapperRunInfo.RunInfoFile = Options.RunInfoFile;

mkdirIfMissing(fileparts(Options.RunInfoFile));
mkdirIfMissing(fileparts(Options.ImagingFailureFile));
if isfield(Options,'BehaviourFailureFile')
    mkdirIfMissing(fileparts(Options.BehaviourFailureFile));
else
    Options.BehaviourFailureFile = 'Behaviourfailures.mat';
    Options.BehaviourFailureVariable = 'Behaviourfailures';
end
if isfield(Options,'QCOutputFolder')
    mkdirIfMissing(Options.QCOutputFolder);
else
    Options.QCOutputFolder = Options.Masterfolder;
end

if isfield(Options.RunConfig,'runRawDenoisedQC') && Options.RunConfig.runRawDenoisedQC && strcmp(Options.AnalysisMode,'All analysis')
    try
        WrapperRunInfo.RawDenoisedQC = compareRawDenoisedOutputs(Options.Paths, ...
            'baseFolder',Options.Masterfolder,'outputFolder',Options.QCOutputFolder);
    catch ME
        WrapperRunInfo.RawDenoisedQCError = getReport(ME);
        warning('OxygenDynamics:RawDenoisedQCFailed','Raw/denoised QC failed: %s',ME.message);
    end
end

WrapperRunInfo.InputCsvCopy = copyRunInputCsv(Options);
save(Options.RunInfoFile,'WrapperRunInfo');

saveFailureLog(ImagingFailures,Options.ImagingFailureFile,Options.ImagingFailureVariable);
saveFailureLog(Behaviourfailures,Options.BehaviourFailureFile,Options.BehaviourFailureVariable);

if Options.RunConfig.sendEmailAlerts
    sendolmail(Options.EmailDestination,'Message from Matlab',Options.SuccessMessage);
end

function InputCsvCopy = copyRunInputCsv(Options)
InputCsvCopy = '';
if ~isfield(Options.RunConfig,'inputCsv') || isempty(Options.RunConfig.inputCsv)
    return
end

InputCsv = Options.RunConfig.inputCsv;
if ~isfile(InputCsv)
    InputCsv = fullfile(Options.Masterfolder,Options.RunConfig.inputCsv);
end
if ~isfile(InputCsv)
    warning('OxygenDynamics:InputCsvCopySkipped','Could not copy input CSV because it was not found: %s',Options.RunConfig.inputCsv);
    return
end

[~,CsvName,CsvExt] = fileparts(InputCsv);
Timestamp = char(datetime('now','Format','yyyyMMdd''T''HHmmss'));
Destination = fullfile(fileparts(Options.RunInfoFile),[CsvName,'_',Timestamp,CsvExt]);
copyfile(InputCsv,Destination);
InputCsvCopy = Destination;

end

end
