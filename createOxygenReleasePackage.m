function ReleaseInfo = createOxygenReleasePackage(varargin)
%CREATEOXYGENRELEASEPACKAGE Create a clean source release folder and ZIP.
%
% ReleaseInfo = createOxygenReleasePackage()
% ReleaseInfo = createOxygenReleasePackage('outputRoot','Release_Packages')

ProjectRoot = setupOxygenDynamicsPath();
VersionInfo = getOxygenPipelineVersion();

Config = struct();
Config.outputRoot = fullfile(ProjectRoot,'Release_Packages');
Config.releaseName = ['OxygenDynamics_Release_',char(datetime('now','Format','yyyyMMdd''T''HHmmss'))];
Config.includeSmokeTest = true;
Config = parseReleaseOptions(Config,varargin{:});

ReleaseFolder = fullfile(Config.outputRoot,Config.releaseName);
if isfolder(ReleaseFolder)
    error('Release folder already exists: %s',ReleaseFolder);
end
mkdirIfMissing(ReleaseFolder);

ReleaseInfo = struct();
ReleaseInfo.PipelineVersion = VersionInfo;
ReleaseInfo.ProjectRoot = ProjectRoot;
ReleaseInfo.ReleaseFolder = ReleaseFolder;
ReleaseInfo.Created = char(datetime('now','Format','yyyy-MM-dd HH:mm:ss'));
ReleaseInfo.CopiedFiles = strings(0,1);
ReleaseInfo.CopiedFolders = strings(0,1);
ReleaseInfo.Skipped = strings(0,1);

[ReleaseInfo,ManifestRows] = copyReleaseContents(ProjectRoot,ReleaseFolder,Config,ReleaseInfo);
ReleaseInfo.ManifestPath = fullfile(ReleaseFolder,'RELEASE_MANIFEST.txt');
ReleaseInfo = writeReleaseManifest(ReleaseInfo,ManifestRows);
ReleaseInfo.ZipPath = [ReleaseFolder,'.zip'];
zip(ReleaseInfo.ZipPath,ReleaseFolder);

fprintf('Release package created:\n%s\n%s\n',ReleaseInfo.ReleaseFolder,ReleaseInfo.ZipPath);

end

function [ReleaseInfo,ManifestRows] = copyReleaseContents(ProjectRoot,ReleaseFolder,Config,ReleaseInfo)

ManifestRows = strings(0,1);
RootFiles = releaseRootFiles(Config.includeSmokeTest);
for FileIdx = 1:numel(RootFiles)
    Source = fullfile(ProjectRoot,RootFiles(FileIdx));
    if ~isfile(Source)
        ReleaseInfo.Skipped(end+1,1) = releaseRelativePath(ProjectRoot,Source);
        continue
    end
    Destination = fullfile(ReleaseFolder,RootFiles(FileIdx));
    copyfile(Source,Destination);
    ReleaseInfo.CopiedFiles(end+1,1) = Destination;
    ManifestRows(end+1,1) = manifestRow(ProjectRoot,Source,'file'); %#ok<AGROW>
end

Folders = ["helpers","external"];
for FolderIdx = 1:numel(Folders)
    Source = fullfile(ProjectRoot,Folders(FolderIdx));
    if ~isfolder(Source)
        ReleaseInfo.Skipped(end+1,1) = releaseRelativePath(ProjectRoot,Source);
        continue
    end
    Destination = fullfile(ReleaseFolder,Folders(FolderIdx));
    copyfile(Source,Destination);
    ReleaseInfo.CopiedFolders(end+1,1) = Destination;
    FolderFiles = dir(fullfile(Source,'**','*'));
    FolderFiles = FolderFiles(~[FolderFiles.isdir]);
    for FileIdx = 1:numel(FolderFiles)
        ManifestRows(end+1,1) = manifestRow(ProjectRoot, ...
            fullfile(FolderFiles(FileIdx).folder,FolderFiles(FileIdx).name),'file'); %#ok<AGROW>
    end
end

end

function RootFiles = releaseRootFiles(IncludeSmokeTest)

RootFiles = [ ...
    "README.md"
    "USER_MANUAL.md"
    "CITATION.cff"
    "CONTRIBUTING.md"
    "CHANGELOG.md"
    "RELEASING.md"
    "SECURITY.md"
    "THIRD_PARTY_NOTICES.md"
    "Pipeline_FlowMap.svg"
    "Detection_Processing_FlowMap.svg"
    "Amplitude_Definition_Comparison.pdf"
    "Science_vs_Current_Analysis_Differences_20260601.pdf"
    "Start_OxygenPipeline.m"
    "setupOxygenDynamicsPath.m"
    "getOxygenPipelineVersion.m"
    "OxygenDynamics_Config.m"
    "OxygenDynamics_GUI.m"
    "OxygenDynamics_Wrapper.m"
    "OxygenDynamics_Stats.m"
    "OxygenDynamics_Master.m"
    "OxygenDynamics_Tiffout.m"
    "OxygenDynamics_Behaviour.m"
    "OxygenDynamics_Sinks_Curation.mlapp"
    "OxygenDynamics_VascularAnalysis.m"
    "OxygenDynamics_VascularAnalysis_IndividualEvents.m"
    "OxygenPipeline_VerificationReport.m"
    "Run_Verification_Then_Wrapper.m"
    "Run_Verification_Then_Stats.m"
    "Run_Regression_Check.m"
    "iOSDynamics_Wrapper.m"
    "iOSDynamics_Master.m"
    "iOS_Tiffout.m"
    "runOxygenDynamicsStats.m"
    "runOxygenDynamicsVascularAnalysis.m"
    "runOxygenDynamicsVascularEventAnalysis.m"
    "runOxygenPipelineVerificationReport.m"
    "runOxygenSummaryFigures.m"
    "runOxygenRegressionCheck.m"
    "runOxygenRegressionTest.m"
    "createOxygenRegressionBaseline.m"
    "refreshAcceptedOxygenRegressionBaseline.m"
    "restoreOxygenRegressionBaseline.m"
    "listOxygenRegressionBaselines.m"
    "getOxygenRegressionStatus.m"
    "getOxygenStatsAcceptanceStatus.m"
    "reviewLatestStatsAcceptance.m"
    "checkOxygenPipelineHealth.m"
    "archiveOldOutputs.m"
    "createOxygenReleasePackage.m"
    "compareRawDenoisedOutputs.m"
    "auditOxygenSinkAmplitudeSource.m"
    "analyzeHypoxiaAmyloidPair.m"
    "testHypoxiaAmyloidAnalysis.m"
    "updateHypoxicBurdenStatsOutput.m"
    "findLatestStatsOutputFolder.m"
    "MakeRecording_3D.m"
    "OxygenDynamics_plotvideos.m"];

if IncludeSmokeTest
    RootFiles(end+1,1) = "runOxygenPipelineSmokeTest.m";
end

end

function ReleaseInfo = writeReleaseManifest(ReleaseInfo,ManifestRows)

FileId = fopen(ReleaseInfo.ManifestPath,'w');
if FileId < 0
    error('Could not write release manifest: %s',ReleaseInfo.ManifestPath);
end
Cleaner = onCleanup(@() fclose(FileId));
fprintf(FileId,'Oxygen Dynamics Pipeline Release\n');
fprintf(FileId,'Version: %s\n',ReleaseInfo.PipelineVersion.Version);
fprintf(FileId,'Build: %s\n',ReleaseInfo.PipelineVersion.BuildTimestamp);
fprintf(FileId,'Created: %s\n',ReleaseInfo.Created);
fprintf(FileId,'Paths are relative to the repository root.\n\n');
fprintf(FileId,'Included files and folders are source/documentation only.\n');
fprintf(FileId,'Excluded generated folders include Data, Stats_Runs, QC_Output, Run_Logs, Verification_Reports, Regression_Baselines, Legacy_Archive, and Release_Packages.\n\n');
fprintf(FileId,'Included file manifest:\n');
for RowIdx = 1:numel(ManifestRows)
    fprintf(FileId,'%s\n',ManifestRows(RowIdx));
end
if ~isempty(ReleaseInfo.Skipped)
    fprintf(FileId,'\nSkipped expected files:\n');
    for RowIdx = 1:numel(ReleaseInfo.Skipped)
        fprintf(FileId,'%s\n',ReleaseInfo.Skipped(RowIdx));
    end
end
delete(Cleaner);

end

function Row = manifestRow(ProjectRoot,FilePath,FileType)

Info = dir(FilePath);
RelativePath = releaseRelativePath(ProjectRoot,FilePath);
if isempty(Info)
    Row = sprintf('%s\t%s\tmissing',FileType,RelativePath);
else
    Row = sprintf('%s\t%s\t%d bytes\t%s',FileType,RelativePath,Info(1).bytes, ...
        char(datetime(Info(1).datenum,'ConvertFrom','datenum','Format','yyyy-MM-dd HH:mm:ss')));
end

end

function RelativePath = releaseRelativePath(ProjectRoot,FilePath)

RootWithSeparator = string(ProjectRoot) + filesep;
FilePath = string(FilePath);
if startsWith(FilePath,RootWithSeparator,'IgnoreCase',ispc)
    RelativePath = extractAfter(FilePath,strlength(RootWithSeparator));
else
    RelativePath = FilePath;
end
RelativePath = replace(RelativePath,filesep,'/');

end

function Config = parseReleaseOptions(Config,varargin)

if mod(numel(varargin),2)~=0
    error('Optional arguments must be name/value pairs.');
end

for ArgIdx = 1:2:numel(varargin)
    Name = char(varargin{ArgIdx});
    Value = varargin{ArgIdx+1};
    if ~isfield(Config,Name)
        error('Unknown release option "%s".',Name);
    end
    Config.(Name) = Value;
end

end
