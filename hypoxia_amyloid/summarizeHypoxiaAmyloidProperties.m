function Summary = summarizeHypoxiaAmyloidProperties(EventTable,PocketTable,Options)
%SUMMARIZEHYPOXIAAMYLOIDPROPERTIES Summarize distance-property relationships.

if nargin<3 || isempty(Options)
    Options = struct();
end
if ~isfield(Options,'NearThresholdMicrometers')
    Options.NearThresholdMicrometers = 50;
end
if ~isfield(Options,'SensitivityThresholdsMicrometers')
    Options.SensitivityThresholdsMicrometers = [25 50 75 100];
end
if ~isfield(Options,'MinimumObservationsPerStratum')
    Options.MinimumObservationsPerStratum = 3;
end
if ~isfield(Options,'DistanceVariable')
    Options.DistanceVariable = 'CentroidDistance_um';
end

Definitions = { ...
    'DurationSec','Duration',EventTable,'Event'; ...
    'Area_um2','SpatialSize',EventTable,'Event'; ...
    'RecurrenceCount','Recurrence',PocketTable,'Pocket'};

CorrelationRows = cell(size(Definitions,1),1);
ThresholdRows = cell(size(Definitions,1)*numel(Options.SensitivityThresholdsMicrometers),1);
ThresholdRow = 0;

for PropertyIdx = 1:size(Definitions,1)
    VariableName = Definitions{PropertyIdx,1};
    PropertyName = Definitions{PropertyIdx,2};
    Data = Definitions{PropertyIdx,3};
    Unit = Definitions{PropertyIdx,4};
    Distance = Data.(Options.DistanceVariable);
    Values = Data.(VariableName);
    [Rho,PValue,N] = spearmanSummary(Distance,Values);
    CorrelationRows{PropertyIdx} = table(string(PropertyName),string(Unit), ...
        string(Options.DistanceVariable),Rho,PValue,N, ...
        'VariableNames',{'Property','AnalysisUnit','DistanceMetric','SpearmanRho', ...
        'SpearmanPValue','N'});

    for Threshold = Options.SensitivityThresholdsMicrometers(:)'
        ThresholdRow = ThresholdRow+1;
        ThresholdRows{ThresholdRow} = thresholdSummary(PropertyName,Unit, ...
            Distance,Values,Threshold,Options.MinimumObservationsPerStratum);
    end
end

Summary = struct();
Summary.Correlations = vertcat(CorrelationRows{:});
Summary.Thresholds = vertcat(ThresholdRows{1:ThresholdRow});
Summary.PrimaryThreshold = Summary.Thresholds( ...
    Summary.Thresholds.Threshold_um==Options.NearThresholdMicrometers,:);
Summary.Options = Options;
end

function [Rho,PValue,N] = spearmanSummary(Distance,Values)

Valid = isfinite(Distance) & isfinite(Values);
Distance = Distance(Valid);
Values = Values(Valid);
N = numel(Distance);
if N<3 || numel(unique(Distance))<2 || numel(unique(Values))<2
    Rho = NaN;
    PValue = NaN;
    return
end
[Rho,PValue] = corr(Distance(:),Values(:),'Type','Spearman','Rows','complete');
end

function Row = thresholdSummary(PropertyName,Unit,Distance,Values,Threshold,MinimumN)

Valid = isfinite(Distance) & isfinite(Values);
Near = Valid & Distance<=Threshold;
Far = Valid & Distance>Threshold;
NNear = nnz(Near);
NFar = nnz(Far);
MedianNear = median(Values(Near),'omitnan');
MedianFar = median(Values(Far),'omitnan');
IsValid = NNear>=MinimumN && NFar>=MinimumN;
Difference = MedianNear-MedianFar;
if ~IsValid
    Difference = NaN;
end

Row = table(string(PropertyName),string(Unit),Threshold,NNear,NFar, ...
    MedianNear,MedianFar,Difference,IsValid, ...
    'VariableNames',{'Property','AnalysisUnit','Threshold_um','NNear','NFar', ...
    'MedianNear','MedianFar','NearMinusFar','ValidComparison'});
end
