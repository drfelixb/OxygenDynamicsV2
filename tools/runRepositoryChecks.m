function Summary = runRepositoryChecks()
%RUNREPOSITORYCHECKS Inspect the MATLAB source tree and run the hypoxia-amyloid check.

RepositoryRoot = setupOxygenDynamicsPath();
OriginalFolder = pwd;
Cleanup = onCleanup(@() cd(OriginalFolder));
cd(RepositoryRoot);

RequiredFiles = {
    'openBOIBatchEditor.m'
    'openBOIMultichannelBatch.m'
    fullfile('workflows','runBOIRecordingWorkflow.m')
    fullfile('workflows','runBOIMultichannel.m')
    fullfile('core','OxygenDynamics_Config.m')
    fullfile('core','OxygenDynamics_Master.m')
    fullfile('core','runOxygenDynamicsStats.m')
    fullfile('core','runOxygenSummaryFigures.m')
    fullfile('tools','runBOISoftwareChecks.m')
    fullfile('hypoxia_amyloid','testHypoxiaAmyloidAnalysis.m')
    fullfile('external','loadtiff.m')
    fullfile('external','saveastiff.m')
    };
MissingFiles = RequiredFiles(~cellfun(@isfile,RequiredFiles));
assert(isempty(MissingFiles), ...
    'OxygenDynamics:RepositoryCheck:MissingFiles', ...
    'Required repository files are missing: %s',strjoin(MissingFiles,', '));

SourceFiles = dir(fullfile(RepositoryRoot,'**','*.m'));
CheckMessages = 0;
for FileIdx = 1:numel(SourceFiles)
    FilePath = fullfile(SourceFiles(FileIdx).folder,SourceFiles(FileIdx).name);
    try
        Messages = checkcode(FilePath,'-id');
        CheckMessages = CheckMessages+numel(Messages);
    catch ErrorInfo
        NewError = MException( ...
            'OxygenDynamics:RepositoryCheck:CodeInspectionFailed', ...
            'Unable to inspect %s: %s',FilePath,ErrorInfo.message);
        throwAsCaller(NewError);
    end
end

TestResult = testHypoxiaAmyloidAnalysis();
assert(isstruct(TestResult) && isfield(TestResult,'Passed') && TestResult.Passed, ...
    'OxygenDynamics:RepositoryCheck:FocusedTestFailed', ...
    'The hypoxia-amyloid focused test did not report success.');

Summary = struct( ...
    'Passed',true, ...
    'SourceFilesInspected',numel(SourceFiles), ...
    'CodeAnalyzerMessages',CheckMessages, ...
    'FocusedTestsRun',true, ...
    'Timestamp',char(datetime('now','Format','yyyy-MM-dd HH:mm:ss')));

fprintf(['Repository checks passed: %d MATLAB files inspected, ', ...
    '%d Code Analyzer messages, focused tests run: %d.\n'], ...
    Summary.SourceFilesInspected,Summary.CodeAnalyzerMessages, ...
    Summary.FocusedTestsRun);
end
