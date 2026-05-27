function ArchiveSummary = archiveOldOutputs(varargin)
%ARCHIVEOLDOUTPUTS Move generated root-level outputs into organized folders.
%
% By default this moves known generated files/folders out of the project
% root and into Run_Logs, QC_Output, and Stats_Runs. Use:
%
%   archiveOldOutputs('dryRun',true)
%
% to preview what would be moved.

setupOxygenDynamicsPath();

Config = struct();
Config.rootFolder = fileparts(mfilename('fullpath'));
Config.dryRun = false;
Config = parseNameValueConfig(Config,varargin{:});

ArchiveSummary = struct();
ArchiveSummary.RootFolder = Config.rootFolder;
ArchiveSummary.DryRun = Config.dryRun;
ArchiveSummary.Moved = {};
ArchiveSummary.Skipped = {};

Targets = { ...
    'Stats_Output_*','Stats_Runs','directory'; ...
    'Figures_Output_*','Stats_Runs','directory'; ...
    'RawDenoisedQC_*','QC_Output','file'; ...
    '*WrapperRunInfo.mat','Run_Logs','file'; ...
    '*failures.mat','Run_Logs','file'};

for targeti = 1:size(Targets,1)
    Pattern = Targets{targeti,1};
    DestinationFolder = fullfile(Config.rootFolder,Targets{targeti,2});
    TargetType = Targets{targeti,3};
    ArchiveSummary = moveMatches(ArchiveSummary,Config,Pattern,DestinationFolder,TargetType);
end

fprintf('Archive summary: moved %d item(s), skipped %d item(s).\n', ...
    numel(ArchiveSummary.Moved),numel(ArchiveSummary.Skipped));

end

function ArchiveSummary = moveMatches(ArchiveSummary,Config,pattern,destinationFolder,targetType)

if strcmp(targetType,'directory')
    Matches = dir(fullfile(Config.rootFolder,pattern));
    Matches = Matches([Matches.isdir]);
else
    Matches = dir(fullfile(Config.rootFolder,pattern));
    Matches = Matches(~[Matches.isdir]);
end

if isempty(Matches)
    return
end

if ~Config.dryRun
    mkdirIfMissing(destinationFolder);
end

for matchi = 1:numel(Matches)
    Source = fullfile(Matches(matchi).folder,Matches(matchi).name);
    Destination = fullfile(destinationFolder,Matches(matchi).name);
    if strcmp(Source,Destination)
        continue
    end
    if isfile(Destination) || isfolder(Destination)
        ArchiveSummary.Skipped{end+1,1} = sprintf('Exists: %s',Destination);
        continue
    end
    if Config.dryRun
        ArchiveSummary.Moved{end+1,1} = sprintf('%s -> %s',Source,Destination);
        continue
    end
    try
        movefile(Source,Destination);
        ArchiveSummary.Moved{end+1,1} = sprintf('%s -> %s',Source,Destination);
    catch ME
        ArchiveSummary.Skipped{end+1,1} = sprintf('%s: %s',Source,ME.message);
    end
end

end

function Config = parseNameValueConfig(Config,varargin)

if mod(numel(varargin),2)~=0
    error('Optional arguments must be name/value pairs.');
end

for argi = 1:2:numel(varargin)
    Name = varargin{argi};
    Value = varargin{argi+1};
    if ~isfield(Config,Name)
        error('Unknown option "%s".',Name);
    end
    Config.(Name) = Value;
end

end
