function Result = reviewLatestStatsAcceptance(StatsInput)
%REVIEWLATESTSTATSACCEPTANCE Print the latest stats acceptance checklist.
%
% Result = reviewLatestStatsAcceptance()
% Result = reviewLatestStatsAcceptance(ProjectRootOrStatsOutputOrDataOutput)

if nargin<1 || isempty(StatsInput)
    StatsPath = findLatestStatsOutputFolder(pwd);
else
    StatsPath = resolveStatsAcceptanceInput(StatsInput);
end

Result = getOxygenStatsAcceptanceStatus(StatsPath);
Result.StatsOutputPath = resolveStatsOutputFolder(StatsPath);
Result.DataOutputMat = resolveDataOutputPath(StatsPath);

printStatsAcceptanceStatus(Result);

end

function StatsPath = resolveStatsAcceptanceInput(StatsInput)

if isstruct(StatsInput)
    StatsPath = StatsInput;
    return
end

StatsPath = char(StatsInput);
if isfolder(StatsPath) && ~isfile(fullfile(StatsPath,'DataOutput.mat'))
    StatsPath = findLatestStatsOutputFolder(StatsPath);
end

end

function StatsOutputFolder = resolveStatsOutputFolder(StatsPath)

if isstruct(StatsPath)
    if isfield(StatsPath,'DataOutputMat') && isfile(StatsPath.DataOutputMat)
        StatsOutputFolder = fileparts(StatsPath.DataOutputMat);
    else
        StatsOutputFolder = '';
    end
elseif isfolder(StatsPath)
    StatsOutputFolder = char(StatsPath);
else
    StatsOutputFolder = fileparts(char(StatsPath));
end

end

function DataOutputPath = resolveDataOutputPath(StatsPath)

if isstruct(StatsPath)
    if isfield(StatsPath,'DataOutputMat')
        DataOutputPath = char(StatsPath.DataOutputMat);
    else
        DataOutputPath = '';
    end
elseif isfolder(StatsPath)
    DataOutputPath = fullfile(char(StatsPath),'DataOutput.mat');
else
    DataOutputPath = char(StatsPath);
end

end

function printStatsAcceptanceStatus(Result)

fprintf('\nStats acceptance review\n');
fprintf('Stats output: %s\n',Result.StatsOutputPath);
fprintf('DataOutput.mat: %s\n',Result.DataOutputMat);
fprintf('Overall status: %s\n',Result.OverallStatus);
fprintf('Message: %s\n',Result.Message);
fprintf('Review rows: %d\n\n',Result.ReviewCount);

if Result.ReviewCount>0
    disp(Result.ReviewRows(:,{'Item','Status','Message','WhereToLook','RecommendedAction'}));
else
    disp(Result.AcceptanceRows(:,{'Item','Status','Message','WhereToLook'}));
end

end
