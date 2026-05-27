function Status = getOxygenStatsAcceptanceStatus(StatsInput)
%GETOXYGENSTATSACCEPTANCESTATUS Return a compact stats acceptance decision.

StatsResult = resolveStatsResult(StatsInput);
AcceptanceRows = buildOxygenStatsAcceptanceRows(StatsResult);

Status = struct();
Status.StatsResult = StatsResult;
Status.AcceptanceRows = AcceptanceRows;
Status.OverallStatus = "INFO";
Status.Message = "No stats acceptance rows were available.";
Status.ReviewRows = table();
Status.ReviewCount = 0;
Status.Passed = false;

if isempty(AcceptanceRows) || height(AcceptanceRows)==0
    return
end

OverallIdx = find(AcceptanceRows.Item=="Overall stats acceptance",1,'first');
if isempty(OverallIdx)
    OverallIdx = 1;
end

Status.OverallStatus = string(AcceptanceRows.Status(OverallIdx));
Status.Message = string(AcceptanceRows.Message(OverallIdx));
Status.ReviewRows = AcceptanceRows(AcceptanceRows.Status=="REVIEW",:);
Status.ReviewCount = height(Status.ReviewRows);
Status.Passed = Status.OverallStatus=="PASS" && Status.ReviewCount==0;

end

function StatsResult = resolveStatsResult(StatsInput)

if nargin<1 || isempty(StatsInput)
    StatsResult = struct();
    return
end

if isstruct(StatsInput)
    StatsResult = StatsInput;
elseif ischar(StatsInput) || isstring(StatsInput)
    StatsPath = char(StatsInput);
    if isfolder(StatsPath)
        StatsPath = fullfile(StatsPath,'DataOutput.mat');
    end
    StatsResult = struct('DataOutputMat',StatsPath);
else
    error('OxygenDynamics:InvalidStatsAcceptanceInput', ...
        'StatsInput must be a stats result struct, stats output folder, or DataOutput.mat path.');
end

if isfield(StatsResult,'DataOutputMat') && isfile(StatsResult.DataOutputMat) && ...
        ~isfield(StatsResult,'StatsInfo')
    Data = load(StatsResult.DataOutputMat,'StatsInfo');
    if isfield(Data,'StatsInfo')
        StatsResult.StatsInfo = Data.StatsInfo;
    end
end

end
