function Restored = restoreOxygenRegressionBaseline(ArchivedBaselinePath,BaselinePath,varargin)
%RESTOREOXYGENREGRESSIONBASELINE Restore an archived regression baseline.

setupOxygenDynamicsPath();

Options = parseRestoreOptions(varargin{:});
if nargin<1 || isempty(ArchivedBaselinePath)
    error('OxygenDynamics:RestoreBaselineMissingArchive', ...
        'Archived baseline MAT path is required.');
end
if nargin<2 || isempty(BaselinePath)
    BaselinePath = fullfile(pwd,'Regression_Baselines','OxygenRegressionBaseline.mat');
end
if ~isfile(ArchivedBaselinePath)
    error('OxygenDynamics:RestoreBaselineArchiveNotFound', ...
        'Archived baseline was not found: %s',ArchivedBaselinePath);
end

[BaselineFolder,BaselineName] = fileparts(BaselinePath);
ArchivedFolder = fileparts(ArchivedBaselinePath);
ArchivedWorkbookPath = fullfile(ArchivedFolder,[BaselineName '.xlsx']);
if ~isfolder(BaselineFolder)
    mkdir(BaselineFolder);
end

if ~Options.overwriteCurrent
    archiveCurrentBaselineBeforeRestore(BaselinePath);
end

copyfile(ArchivedBaselinePath,BaselinePath,'f');
RestoredWorkbookPath = fullfile(BaselineFolder,[BaselineName '.xlsx']);
if isfile(ArchivedWorkbookPath)
    copyfile(ArchivedWorkbookPath,RestoredWorkbookPath,'f');
end

Restored = struct();
Restored.BaselinePath = BaselinePath;
Restored.BaselineWorkbook = RestoredWorkbookPath;
Restored.ArchivedBaselinePath = ArchivedBaselinePath;
Restored.ArchivedWorkbookPath = ArchivedWorkbookPath;

fprintf('Regression baseline restored from archive:\n%s\n',ArchivedBaselinePath);
fprintf('Current regression baseline:\n%s\n',BaselinePath);

end

function Options = parseRestoreOptions(varargin)

Options = struct('overwriteCurrent',false);

if mod(numel(varargin),2)~=0
    error('OxygenDynamics:RestoreBaselineOptions', ...
        'Optional arguments must be name-value pairs.');
end

for i = 1:2:numel(varargin)
    Name = char(varargin{i});
    Value = varargin{i+1};
    if ~isfield(Options,Name)
        error('OxygenDynamics:RestoreBaselineOptions', ...
            'Unknown restore option: %s',Name);
    end
    Options.(Name) = Value;
end

end

function archiveCurrentBaselineBeforeRestore(BaselinePath)

[BaselineFolder,BaselineName] = fileparts(BaselinePath);
CurrentFiles = {BaselinePath,fullfile(BaselineFolder,[BaselineName '.xlsx'])};
CurrentFiles = CurrentFiles(cellfun(@isfile,CurrentFiles));
if isempty(CurrentFiles)
    return
end

ArchiveFolder = fullfile(BaselineFolder,'Archive',['restore_previous_' formatRegressionTimestamp()]);
if ~isfolder(ArchiveFolder)
    mkdir(ArchiveFolder);
end

for FileIdx = 1:numel(CurrentFiles)
    [~,Name,Ext] = fileparts(CurrentFiles{FileIdx});
    movefile(CurrentFiles{FileIdx},fullfile(ArchiveFolder,[Name Ext]));
end

end
