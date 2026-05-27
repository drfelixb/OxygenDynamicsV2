function FigureList = buildOxygenFigureListItems(FigureFiles,FigureFolder,FigureManifest)
%BUILDOXYGENFIGURELISTITEMS Build GUI-ready figure labels and file paths.

if nargin<1 || isempty(FigureFiles)
    FigureFiles = {};
end
if nargin<2
    FigureFolder = '';
end
if nargin<3
    FigureManifest = table();
end

if isempty(FigureManifest) && ~isempty(FigureFolder) && isfolder(FigureFolder)
    FigureManifest = readOxygenFigureManifest(FigureFolder);
end

if isempty(FigureFiles) && ~isempty(FigureFolder) && isfolder(FigureFolder)
    if ~isempty(FigureManifest) && istable(FigureManifest) && ...
            ismember('FilePath',FigureManifest.Properties.VariableNames)
        FigureFiles = cellstr(string(FigureManifest.FilePath));
    else
        Files = dir(fullfile(FigureFolder,'*.png'));
        FigureFiles = fullfile({Files.folder},{Files.name})';
    end
end

FigureFiles = FigureFiles(:);
ExistingFiles = FigureFiles(cellfun(@isfile,FigureFiles));
FilteredManifest = filterFigureManifest(FigureManifest,ExistingFiles);
DisplayNames = figureDisplayNames(ExistingFiles,FilteredManifest);

FigureList = struct();
FigureList.Files = ExistingFiles;
FigureList.DisplayNames = DisplayNames;
FigureList.Manifest = FilteredManifest;

end

function Manifest = readOxygenFigureManifest(FigureFolder)

Manifest = table();
ManifestWorkbook = fullfile(FigureFolder,'OxygenSummaryFigureMetrics.xlsx');
if ~isfile(ManifestWorkbook)
    return
end
try
    Sheets = sheetnames(ManifestWorkbook);
    if any(Sheets=="FigureManifest")
        Manifest = readtable(ManifestWorkbook,'Sheet','FigureManifest','TextType','string');
    end
catch
    Manifest = table();
end

end

function Manifest = filterFigureManifest(Manifest,FigureFiles)

if isempty(Manifest) || ~istable(Manifest) || ~ismember('FilePath',Manifest.Properties.VariableNames)
    Manifest = table();
    return
end
[Found,Idx] = ismember(string(FigureFiles),string(Manifest.FilePath));
Manifest = Manifest(Idx(Found),:);

end

function Names = figureDisplayNames(FigureFiles,FigureManifest)

Names = cell(size(FigureFiles));
for FileIdx = 1:numel(FigureFiles)
    if ~isempty(FigureManifest) && height(FigureManifest)>=FileIdx && ...
            all(ismember({'FigureType','Label'},FigureManifest.Properties.VariableNames))
        Names{FileIdx} = sprintf('%s: %s', ...
            char(string(FigureManifest.FigureType(FileIdx))), ...
            char(string(FigureManifest.Label(FileIdx))));
    else
        [~,Name,Ext] = fileparts(FigureFiles{FileIdx});
        Names{FileIdx} = [Name,Ext];
    end
end

end
