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

% Fail on missing/excluded sources before creating any output directory.
SourcePlan = getOxygenReleaseSourceList(ProjectRoot,Config.includeSmokeTest);

ReleaseFolder = fullfile(Config.outputRoot,Config.releaseName);
if isfolder(ReleaseFolder) || isfile(ReleaseFolder) || isfile([ReleaseFolder,'.zip'])
    error('Release folder already exists: %s',ReleaseFolder);
end
SourcePlan = getOxygenReleaseSourceList(ProjectRoot,Config.includeSmokeTest,SourcePlan);
mkdirIfMissing(ReleaseFolder);

ReleaseInfo = struct();
ReleaseInfo.PipelineVersion = VersionInfo;
ReleaseInfo.ProjectRoot = ProjectRoot;
ReleaseInfo.ReleaseFolder = ReleaseFolder;
ReleaseInfo.Created = char(datetime('now','Format','yyyy-MM-dd HH:mm:ss'));
ReleaseInfo.CopiedFiles = strings(0,1);
ReleaseInfo.CopiedFolders = strings(0,1);
ReleaseInfo.Skipped = strings(0,1);
ReleaseInfo.SourcePolicySHA256 = SourcePlan.PolicySHA256;
ReleaseInfo.UnverifiedAssets = SourcePlan.UnverifiedAssets;
ReleaseInfo.ReleaseReady = false;

[ReleaseInfo,ManifestRows] = copyReleaseContents(ProjectRoot,ReleaseFolder,SourcePlan,ReleaseInfo);
ReleaseInfo.ManifestPath = fullfile(ReleaseFolder,'RELEASE_MANIFEST.txt');
ReleaseInfo = writeReleaseManifest(ReleaseInfo,ManifestRows);
ReleaseInfo.ZipPath = [ReleaseFolder,'.zip'];
% Anchor archive entries at the candidate root, never an absolute host path.
zip(ReleaseInfo.ZipPath,[SourcePlan.RelativePaths; {'RELEASE_MANIFEST.txt'}],ReleaseFolder);

fprintf('Release package created:\n%s\n%s\n',ReleaseInfo.ReleaseFolder,ReleaseInfo.ZipPath);

end

function [ReleaseInfo,ManifestRows] = copyReleaseContents(ProjectRoot,ReleaseFolder,SourcePlan,ReleaseInfo)

ManifestRows = strings(0,1);
for FileIdx = 1:numel(SourcePlan.RelativePaths)
    RelativePath = SourcePlan.RelativePaths{FileIdx};
    Source = fullfile(ProjectRoot,RelativePath);
    assert(strcmp(oxygenFileSHA256(Source),SourcePlan.SHA256{FileIdx}), ...
        'OxygenDynamics:ReleaseSourceChanged','Source changed before copy: %s.',RelativePath);
    Destination = fullfile(ReleaseFolder,RelativePath);
    mkdirIfMissing(fileparts(Destination));
    copyfile(Source,Destination);
    assert(strcmp(oxygenFileSHA256(Destination),SourcePlan.SHA256{FileIdx}), ...
        'OxygenDynamics:ReleaseSourceChanged','Copied source differs: %s.',RelativePath);
    ReleaseInfo.CopiedFiles(end+1,1) = Destination;
    ManifestRows(end+1,1) = manifestRow(ProjectRoot,Source,'file'); %#ok<AGROW>
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
fprintf(FileId,'Exact source policy SHA256: %s\n',ReleaseInfo.SourcePolicySHA256);
fprintf(FileId,'NOT RELEASE READY: broader runtime, licensing, hosted CI and live validation gates remain open.\n');
fprintf(FileId,'Sources use an exact file list; no folder is copied recursively.\n');
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
