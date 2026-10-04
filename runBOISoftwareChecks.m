function Results=runBOISoftwareChecks(Mode,ReportFolder)
if nargin<1,Mode='portable';end
if nargin<2,ReportFolder='';end
assert(ismember(Mode,{'portable','desktop','all'}),'Select portable, desktop or all BOI checks.');
%RUNBOISOFTWARECHECKS Bounded BOI regression gate; no external recording data.
root=setupOxygenDynamicsPath;addpath(fullfile(root,'tests','analysis'));
names={'testPipelineContract','testBOIRecordingInputContract','testBOITissueSupport', ...
    'testBOIStrictROISupport','testBOIImportReview','testBOIEventReview', ...
    'testBOIWindowReview','testBOIConnectedReview','testBOIReviewedOptical', ...
    'testBOITemporalContext','testBOISavedMeasurementSupport','testBOISurgeWindows', ...
    'testBOIRecordingWorkflow','testBOIPortableDurationRates', ...
    'testBOIPortableSummaries','testBOIPortableAmplitude','testBOIPortableReviewedPocket'};
suites=cell(1,numel(names));
for k=1:numel(names)
    suites{k}=matlab.unittest.TestSuite.fromFile(fullfile(root,'tests','analysis',[names{k} '.m']));
end
Suite=[suites{:}];D=jsondecode(fileread(fullfile(root,'tests','analysis','BOIDesktopChecks.json')));
isDesktop=ismember(string({Suite.Name}),string(D.Tests));
if strcmp(Mode,'portable'),Suite=Suite(~isDesktop);elseif strcmp(Mode,'desktop'),Suite=Suite(isDesktop);end
Runner=matlab.unittest.TestRunner.withTextOutput;
if ~isempty(ReportFolder)
    if ~isfolder(ReportFolder),mkdir(ReportFolder);end
    Runner.addPlugin(matlab.unittest.plugins.XMLPlugin.producingJUnitFormat(fullfile(ReportFolder,'junit.xml')));
end
Results=Runner.run(Suite);
Summary=struct('Mode',Mode,'MATLABVersion',version,'MATLABRelease',version('-release'), ...
    'Computer',computer,'Passed',sum([Results.Passed]),'Failed',sum([Results.Failed]),'Incomplete',sum([Results.Incomplete]), ...
    'Total',numel(Results),'GitHubSHA',getenv('GITHUB_SHA'),'DesktopTestsSelected',sum(ismember(string({Results.Name}),string(D.Tests))), ...
    'NativeChooserEvidence',false,'Tests',struct('Name',{Results.Name},'Passed',num2cell([Results.Passed]), ...
    'Failed',num2cell([Results.Failed]),'Incomplete',num2cell([Results.Incomplete]),'Duration',num2cell([Results.Duration])));
if ~isempty(ReportFolder)
    f=fopen(fullfile(ReportFolder,'results.json'),'w');cleanup=onCleanup(@()fclose(f));fprintf(f,'%s\n',jsonencode(Summary,'PrettyPrint',true));clear cleanup;
end
fprintf('BOI %s: %d passed, %d failed, %d incomplete (%s, %s).\n',Mode,Summary.Passed,Summary.Failed,Summary.Incomplete,Summary.MATLABRelease,Summary.Computer);
assert(~isempty(Results)&&all([Results.Passed])&&~any([Results.Incomplete]), ...
    'OxygenDynamics:BOIRegressionFailed','BOI regression gate failed or was incomplete. Inspect the MATLAB test report.');
end
