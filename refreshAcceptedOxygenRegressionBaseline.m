function Baseline = refreshAcceptedOxygenRegressionBaseline(StatsOutputPath,BaselinePath)
%REFRESHACCEPTEDOXYGENREGRESSIONBASELINE Create baseline only from accepted stats.
%
% Baseline = refreshAcceptedOxygenRegressionBaseline()
% Baseline = refreshAcceptedOxygenRegressionBaseline(StatsOutputPath)
% Baseline = refreshAcceptedOxygenRegressionBaseline(StatsOutputPath,BaselinePath)

setupOxygenDynamicsPath();

if nargin<1 || isempty(StatsOutputPath)
    StatsOutputPath = findLatestStatsOutputFolder();
end
if nargin<2 || isempty(BaselinePath)
    BaselinePath = fullfile(pwd,'Regression_Baselines','OxygenRegressionBaseline.mat');
end

AcceptanceStatus = getOxygenStatsAcceptanceStatus(StatsOutputPath);
if ~AcceptanceStatus.Passed
    error('OxygenDynamics:BaselineStatsNotAccepted', ...
        ['Stats output was not accepted for baseline refresh. ', ...
        'Status: %s. Review rows: %d. Message: %s'], ...
        AcceptanceStatus.OverallStatus,AcceptanceStatus.ReviewCount,AcceptanceStatus.Message);
end

Baseline = createOxygenRegressionBaseline(StatsOutputPath,BaselinePath);
Baseline.AcceptanceStatusAtRefresh = AcceptanceStatus;
save(BaselinePath,'Baseline');

fprintf('Accepted stats baseline refreshed from:\n%s\n',Baseline.DataOutputPath);

end
