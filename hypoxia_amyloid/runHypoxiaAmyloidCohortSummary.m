function Cohort = runHypoxiaAmyloidCohortSummary(RecordingResults,OutputRoot,Options)
%RUNHYPOXIAAMYLOIDCOHORTSUMMARY Animal-level plaque-distance inference.

if nargin<3 || isempty(Options)
    Options = struct();
end
Options = applyDefaults(Options);
RecordingResults = RecordingResults(~cellfun(@isempty,RecordingResults));
if isempty(RecordingResults)
    Cohort = struct();
    return
end

EventTables = cellfun(@(R) R.Properties.EventTable,RecordingResults, ...
    'UniformOutput',false);
PocketTables = cellfun(@(R) R.Properties.PocketTable,RecordingResults, ...
    'UniformOutput',false);
RecordingTables = cellfun(@(R) R.RecordingSummary,RecordingResults, ...
    'UniformOutput',false);
NullTables = cellfun(@(R) R.Properties.SpatialNull,RecordingResults, ...
    'UniformOutput',false);
AllEvents = vertcat(EventTables{:});
AllPockets = vertcat(PocketTables{:});
RecordingSummary = vertcat(RecordingTables{:});
AllSpatialNull = vertcat(NullTables{:});

[AnimalCorrelations,AnimalThresholds] = createAnimalSummaries( ...
    AllEvents,AllPockets,RecordingSummary,Options.PropertyOptions);
AnimalInclusion = createInclusionTable(AnimalThresholds, ...
    Options.PropertyOptions.MinimumObservationsPerStratum);
AnimalSpatialNull = createAnimalSpatialNull(AnimalThresholds, ...
    AllSpatialNull);
GroupResults = createGroupResults(AnimalCorrelations,AnimalThresholds, ...
    AnimalSpatialNull,AllSpatialNull,Options);
TreatmentComparisonResults = createTreatmentComparisons(AnimalCorrelations, ...
    AnimalThresholds,AnimalSpatialNull,Options);
FactorialInteractionResults = createFactorialInteractions(AnimalCorrelations, ...
    AnimalThresholds,AnimalSpatialNull,Options);
AgeComparisonResults = TreatmentComparisonResults( ...
    TreatmentComparisonResults.ContrastType=="AgeWithinCondition",:);
[GroupDefinitions,AnalysisAvailability] = createGroupDefinitions( ...
    RecordingSummary,Options.ConfiguredAnimals);

Timestamp = char(datetime('now','Format','yyyyMMdd''T''HHmmss'));
OutputFolder = fullfile(OutputRoot,['HypoxiaAmyloid_Cohort_',Timestamp]);
mkdirIfMissing(OutputFolder);
writetable(RecordingSummary,fullfile(OutputFolder,'RecordingSummary.csv'));
writetable(AllEvents,fullfile(OutputFolder,'PerPocketTable.csv'));
writetable(AllEvents,fullfile(OutputFolder,'AllEventMetrics.csv'));
writetable(AllPockets,fullfile(OutputFolder,'AllPocketMetrics.csv'));
writetable(AnimalCorrelations,fullfile(OutputFolder,'AnimalCorrelations.csv'));
writetable(AnimalThresholds,fullfile(OutputFolder,'PerAnimalSummary.csv'));
writetable(AnimalThresholds, ...
    fullfile(OutputFolder,'AnimalThresholdSensitivity.csv'));
writetable(AnimalInclusion,fullfile(OutputFolder,'AnimalInclusion.csv'));
writetable(AllSpatialNull,fullfile(OutputFolder,'AllSpatialNullShifts.csv'));
writetable(AnimalSpatialNull, ...
    fullfile(OutputFolder,'AnimalSpatialNullSummary.csv'));
writetable(GroupResults,fullfile(OutputFolder,'GroupResults.csv'));
writetable(GroupResults,fullfile(OutputFolder,'CohortTests.csv'));
writetable(GroupDefinitions,fullfile(OutputFolder,'GroupDefinitions.csv'));
writetable(AnalysisAvailability, ...
    fullfile(OutputFolder,'AnalysisAvailability.csv'));
writetable(TreatmentComparisonResults, ...
    fullfile(OutputFolder,'TreatmentComparisonResults.csv'));
writetable(FactorialInteractionResults, ...
    fullfile(OutputFolder,'FactorialInteractionResults.csv'));
writetable(AgeComparisonResults, ...
    fullfile(OutputFolder,'AgeComparisonResults.csv'));

Cohort = struct();
Cohort.OutputFolder = OutputFolder;
Cohort.RecordingSummary = RecordingSummary;
Cohort.AllEvents = AllEvents;
Cohort.AllPockets = AllPockets;
Cohort.AllSpatialNull = AllSpatialNull;
Cohort.AnimalCorrelations = AnimalCorrelations;
Cohort.AnimalThresholds = AnimalThresholds;
Cohort.AnimalInclusion = AnimalInclusion;
Cohort.AnimalSpatialNull = AnimalSpatialNull;
Cohort.GroupResults = GroupResults;
Cohort.CohortTests = GroupResults;
Cohort.GroupDefinitions = GroupDefinitions;
Cohort.AnalysisAvailability = AnalysisAvailability;
Cohort.TreatmentComparisonResults = TreatmentComparisonResults;
Cohort.FactorialInteractionResults = FactorialInteractionResults;
Cohort.AgeComparisonResults = AgeComparisonResults;
Cohort.Options = Options;
save(fullfile(OutputFolder,'HypoxiaAmyloid_Cohort.mat'),'Cohort','-v7.3');
writeCohortFigure(Cohort);
writeMethodsSummary(Cohort);
end

function Options = applyDefaults(Options)

if ~isfield(Options,'PropertyOptions'), Options.PropertyOptions = struct(); end
if ~isfield(Options.PropertyOptions,'NearThresholdMicrometers')
    Options.PropertyOptions.NearThresholdMicrometers = 50;
end
if ~isfield(Options.PropertyOptions,'SensitivityThresholdsMicrometers')
    Options.PropertyOptions.SensitivityThresholdsMicrometers = [25 50 75 100];
end
if ~isfield(Options.PropertyOptions,'MinimumObservationsPerStratum')
    Options.PropertyOptions.MinimumObservationsPerStratum = 3;
end
if ~isfield(Options.PropertyOptions,'DistanceVariable')
    Options.PropertyOptions.DistanceVariable = 'CentroidDistance_um';
end
if ~isfield(Options,'NumPermutations'), Options.NumPermutations = 10000; end
if ~isfield(Options,'BootstrapIterations'), Options.BootstrapIterations = 5000; end
if ~isfield(Options,'RandomSeed'), Options.RandomSeed = 1; end
if ~isfield(Options,'ConfiguredAnimals'), Options.ConfiguredAnimals = table(); end
end

function [Correlations,Thresholds] = createAnimalSummaries( ...
    Events,Pockets,RecordingSummary,PropertyOptions)

Mice = unique(RecordingSummary.Mouse,'stable');
CorrelationTables = cell(numel(Mice),1);
ThresholdTables = cell(numel(Mice),1);
for MouseIdx = 1:numel(Mice)
    Mouse = Mice(MouseIdx);
    MouseEvents = Events(Events.Mouse==Mouse,:);
    MousePockets = Pockets(Pockets.Mouse==Mouse,:);
    AnimalSummary = summarizeHypoxiaAmyloidProperties( ...
        MouseEvents,MousePockets,PropertyOptions);
    Age = firstString(MouseEvents,'Age',MousePockets,'Age');
    Genotype = firstString(MouseEvents,'Genotype',MousePockets,'Genotype');
    Condition = firstString(MouseEvents,'Condition',MousePockets,'Condition');
    DrugID = firstString(MouseEvents,'DrugID',MousePockets,'DrugID');
    CorrelationTables{MouseIdx} = addAnimalMetadata( ...
        AnimalSummary.Correlations,Mouse,Age,Genotype,Condition,DrugID);
    ThresholdTables{MouseIdx} = addAnimalMetadata( ...
        AnimalSummary.Thresholds,Mouse,Age,Genotype,Condition,DrugID);
end
Correlations = vertcat(CorrelationTables{:});
Thresholds = vertcat(ThresholdTables{:});
end

function Value = firstString(First,FirstName,Second,SecondName)

Value = "";
if ~isempty(First) && ismember(FirstName,First.Properties.VariableNames)
    Value = string(First.(FirstName)(1));
elseif ~isempty(Second) && ismember(SecondName,Second.Properties.VariableNames)
    Value = string(Second.(SecondName)(1));
end
end

function TableOut = addAnimalMetadata(TableIn,Mouse,Age,Genotype,Condition,DrugID)

N = height(TableIn);
AnalysisGroup = string(DrugID)+" | "+string(Condition);
TableOut = addvars(TableIn,repmat(string(Mouse),N,1), ...
    repmat(string(Age),N,1),repmat(string(Genotype),N,1), ...
    repmat(string(Condition),N,1),repmat(string(DrugID),N,1), ...
    repmat(AnalysisGroup,N,1),'Before',1, ...
    'NewVariableNames',{'Mouse','Age','Genotype','Condition','DrugID', ...
    'AnalysisGroup'});
end

function Inclusion = createInclusionTable(Thresholds,MinimumN)

Inclusion = Thresholds(:,{'Mouse','Age','Genotype','Condition','DrugID', ...
    'AnalysisGroup','Property','AnalysisUnit', ...
    'Threshold_um','NNear','NFar','ValidComparison'});
Reasons = repmat("Included",height(Inclusion),1);
LowNear = Inclusion.NNear<MinimumN;
LowFar = Inclusion.NFar<MinimumN;
Reasons(LowNear & ~LowFar) = "Excluded: too few near observations";
Reasons(~LowNear & LowFar) = "Excluded: too few far observations";
Reasons(LowNear & LowFar) = "Excluded: too few near and far observations";
Inclusion.ExclusionReason = Reasons;
end

function Summary = createAnimalSpatialNull(Observed,AllNull)

Rows = cell(height(Observed),1);
RowIdx = 0;
for Idx = 1:height(Observed)
    RowIdx = RowIdx+1;
    Mouse = Observed.Mouse(Idx);
    Age = Observed.Age(Idx);
    Genotype = Observed.Genotype(Idx);
    Condition = Observed.Condition(Idx);
    DrugID = Observed.DrugID(Idx);
    AnalysisGroup = Observed.AnalysisGroup(Idx);
    Property = Observed.Property(Idx);
    Unit = Observed.AnalysisUnit(Idx);
    Threshold = Observed.Threshold_um(Idx);
    NullRows = AllNull(AllNull.Mouse==Mouse & ...
        AllNull.Property==Property & AllNull.Threshold_um==Threshold & ...
        AllNull.ValidComparison,:);
    if isempty(NullRows)
        NullValues = [];
    else
        [Groups,~] = findgroups(NullRows.ShiftIndex);
        NullValues = splitapply(@(X) median(X,'omitnan'), ...
            NullRows.NearMinusFar,Groups);
        NullValues = NullValues(isfinite(NullValues));
    end
    ObservedDifference = Observed.NearMinusFar(Idx);
    NullMedian = median(NullValues,'omitnan');
    NullMean = mean(NullValues,'omitnan');
    NullCI = percentileInterval(NullValues,[2.5 97.5]);
    Corrected = ObservedDifference-NullMedian;
    SpatialP = empiricalTwoSidedP(ObservedDifference,NullValues);
    Rows{RowIdx} = table(Mouse,Age,Genotype,Condition,DrugID,AnalysisGroup, ...
        Property,Unit,Threshold, ...
        Observed.NNear(Idx),Observed.NFar(Idx),Observed.ValidComparison(Idx), ...
        ObservedDifference,numel(NullValues),NullMean,NullMedian, ...
        NullCI(1),NullCI(2),Corrected,SpatialP, ...
        'VariableNames',{'Mouse','Age','Genotype','Condition','DrugID', ...
        'AnalysisGroup','Property','AnalysisUnit', ...
        'Threshold_um','NNear','NFar','Included','ObservedNearMinusFar', ...
        'NValidShifts','NullMean','NullMedian','NullCI_Lower', ...
        'NullCI_Upper','NullCorrectedEffect','AnimalSpatialNullP'});
end
Summary = vertcat(Rows{1:RowIdx});
end

function Results = createGroupResults(Correlations,Thresholds,SpatialNull, ...
    AllSpatialNull,Options)

rng(Options.RandomSeed);
Scopes = createScopeDefinitions(Correlations);
Properties = unique(Correlations.Property,'stable');
ThresholdValues = Options.PropertyOptions.SensitivityThresholdsMicrometers(:)';
Rows = cell(height(Scopes)*numel(Properties)*(1+2*numel(ThresholdValues)),1);
RowIdx = 0;

for ScopeIdx = 1:height(Scopes)
    Scope = Scopes(ScopeIdx,:);
    for PropertyIdx = 1:numel(Properties)
        Property = Properties(PropertyIdx);
        CorrRows = Correlations(Correlations.Property==Property & ...
            scopeMask(Correlations,Scope),:);
        RowIdx = RowIdx+1;
        Rows{RowIdx} = oneSampleResult(Scope,Property, ...
            propertyUnit(Property),"ContinuousSpearman",NaN, ...
            CorrRows.SpearmanRho,numel(CorrRows.SpearmanRho), ...
            Options.BootstrapIterations);

        for Threshold = ThresholdValues
            BinaryRows = Thresholds(Thresholds.Property==Property & ...
                Thresholds.Threshold_um==Threshold & ...
                scopeMask(Thresholds,Scope),:);
            Values = BinaryRows.NearMinusFar(BinaryRows.ValidComparison);
            RowIdx = RowIdx+1;
            Rows{RowIdx} = oneSampleResult(Scope,Property, ...
                propertyUnit(Property),"NearVsFar",Threshold,Values, ...
                height(BinaryRows),Options.BootstrapIterations);

            NullRows = SpatialNull(SpatialNull.Property==Property & ...
                SpatialNull.Threshold_um==Threshold & ...
                SpatialNull.Included & scopeMask(SpatialNull,Scope),:);
            RowIdx = RowIdx+1;
            Rows{RowIdx} = oneSampleResult(Scope,Property, ...
                propertyUnit(Property),"SpatialNullCorrected",Threshold, ...
                NullRows.NullCorrectedEffect,height(BinaryRows), ...
                Options.BootstrapIterations);
            Rows{RowIdx}.SpatialNullGroupP = groupSpatialNullP( ...
                NullRows,AllSpatialNull,Property,Threshold, ...
                Options.NumPermutations);
        end
    end
end
Results = vertcat(Rows{1:RowIdx});
Results.FDR_Q = nan(height(Results),1);
for ScopeIdx = 1:height(Scopes)
    ScopeName = Scopes.Scope(ScopeIdx);
    for Analysis = ["ContinuousSpearman","NearVsFar","SpatialNullCorrected"]
        Mask = Results.Scope==ScopeName & Results.Analysis==Analysis;
        if Analysis~="ContinuousSpearman"
            Mask = Mask & Results.Threshold_um== ...
                Options.PropertyOptions.NearThresholdMicrometers;
        end
        Results.FDR_Q(Mask) = benjaminiHochberg(Results.WilcoxonP(Mask));
    end
end
end

function Scopes = createScopeDefinitions(Correlations)

Scopes = table("All animals (descriptive)","All","","", ...
    'VariableNames',{'Scope','GroupType','DrugID','Condition'});
Pairs = unique(Correlations(:,{'DrugID','Condition'}),'rows','stable');
for Idx = 1:height(Pairs)
    Scope = Pairs.DrugID(Idx)+" | "+Pairs.Condition(Idx);
    Scopes = [Scopes; table(Scope,"DrugID x Condition", ...
        Pairs.DrugID(Idx),Pairs.Condition(Idx), ...
        'VariableNames',Scopes.Properties.VariableNames)]; %#ok<AGROW>
end
end

function Mask = scopeMask(Data,Scope)

if Scope.GroupType=="All"
    Mask = true(height(Data),1);
else
    Mask = Data.DrugID==Scope.DrugID & Data.Condition==Scope.Condition;
end
end

function Row = oneSampleResult(Scope,Property,Unit,Analysis,Threshold, ...
    Values,NAvailable,BootstrapIterations)

Values = Values(isfinite(Values));
N = numel(Values);
MedianEffect = median(Values,'omitnan');
MeanEffect = mean(Values,'omitnan');
CI = bootstrapMedianCI(Values,BootstrapIterations);
P = NaN;
if N>=2 && any(Values~=0)
    P = signrank(Values,0);
end
RankBiserial = signedRankBiserial(Values);
Row = table(Scope.Scope,Scope.GroupType,Scope.DrugID,Scope.Condition, ...
    Property,string(Unit),Analysis,Threshold,N,NAvailable-N, ...
    MeanEffect,MedianEffect,CI(1),CI(2),P,RankBiserial,NaN, ...
    'VariableNames',{'Scope','GroupType','DrugID','Condition','Property', ...
    'AnalysisUnit','Analysis', ...
    'Threshold_um','NIncluded','NExcluded','MeanAnimalEffect', ...
    'MedianAnimalEffect','CI_Lower','CI_Upper','WilcoxonP', ...
    'RankBiserial','SpatialNullGroupP'});
end

function P = groupSpatialNullP(Rows,AllNull,Property,Threshold, ...
    NumPermutations)

if isempty(Rows)
    P = NaN;
    return
end
Observed = median(Rows.ObservedNearMinusFar,'omitnan');
NullCenters = Rows.NullMedian;
CenteredObserved = Observed-median(NullCenters,'omitnan');
if ~isfinite(CenteredObserved)
    P = NaN;
    return
end
NullDraws = nan(NumPermutations,height(Rows));
for Idx = 1:height(Rows)
    MouseRows = AllNull(AllNull.Mouse==Rows.Mouse(Idx) & ...
        AllNull.Property==Property & AllNull.Threshold_um==Threshold & ...
        AllNull.ValidComparison,:);
    if isempty(MouseRows)
        continue
    end
    [ShiftGroups,~] = findgroups(MouseRows.ShiftIndex);
    Values = splitapply(@(X) median(X,'omitnan'), ...
        MouseRows.NearMinusFar,ShiftGroups);
    Values = Values(isfinite(Values));
    if ~isempty(Values)
        NullDraws(:,Idx) = Values(randi(numel(Values),NumPermutations,1));
    end
end
NullGroup = median(NullDraws,2,'omitnan');
NullCenter = median(NullCenters,'omitnan');
P = (1+sum(abs(NullGroup-NullCenter)>=abs(CenteredObserved))) / ...
    (NumPermutations+1);
end

function Unit = propertyUnit(Property)

if Property=="Recurrence"
    Unit = "Pocket";
else
    Unit = "Event";
end
end

function Results = createTreatmentComparisons(Correlations,Thresholds, ...
    SpatialNull,Options)

rng(Options.RandomSeed+1);
ContrastDefinitions = createContrastDefinitions(Correlations);
if isempty(ContrastDefinitions)
    Results = emptyTreatmentComparisonResults();
    return
end
Properties = unique(Correlations.Property,'stable');
ThresholdValues = Options.PropertyOptions.SensitivityThresholdsMicrometers(:)';
Rows = cell(height(ContrastDefinitions)*numel(Properties)* ...
    (1+2*numel(ThresholdValues)),1);
RowIdx = 0;

for ContrastIdx = 1:height(ContrastDefinitions)
    Contrast = ContrastDefinitions(ContrastIdx,:);
    for PropertyIdx = 1:numel(Properties)
        Property = Properties(PropertyIdx);
        Data = effectTable(Correlations,Property,"ContinuousSpearman",NaN);
        RowIdx = RowIdx+1;
        Rows{RowIdx} = comparisonRow(Contrast,Data,Property, ...
            "ContinuousSpearman",NaN,Options.BootstrapIterations);
        for Threshold = ThresholdValues
            Data = effectTable(Thresholds,Property,"NearVsFar",Threshold);
            RowIdx = RowIdx+1;
            Rows{RowIdx} = comparisonRow(Contrast,Data,Property, ...
                "NearVsFar",Threshold,Options.BootstrapIterations);
            Data = effectTable(SpatialNull,Property, ...
                "SpatialNullCorrected",Threshold);
            RowIdx = RowIdx+1;
            Rows{RowIdx} = comparisonRow(Contrast,Data,Property, ...
                "SpatialNullCorrected",Threshold,Options.BootstrapIterations);
        end
    end
end
Results = vertcat(Rows{1:RowIdx});
Results.FDR_Q = nan(height(Results),1);
Labels = unique(Results.ContrastLabel,'stable');
for Label = Labels'
    for Analysis = ["ContinuousSpearman","NearVsFar","SpatialNullCorrected"]
        Mask = Results.ContrastLabel==Label & Results.Analysis==Analysis;
        if Analysis~="ContinuousSpearman"
            Mask = Mask & Results.Threshold_um== ...
                Options.PropertyOptions.NearThresholdMicrometers;
        end
        Results.FDR_Q(Mask) = benjaminiHochberg(Results.RankSumP(Mask));
    end
end
end

function Results = emptyTreatmentComparisonResults()

Names = {'ContrastType','Stratum','ContrastLabel','Group1','Group2', ...
    'Property','AnalysisUnit','Analysis','Threshold_um','NGroup1','NGroup2', ...
    'MedianGroup1','MedianGroup2','DifferenceGroup2MinusGroup1', ...
    'CI_Lower','CI_Upper','RankSumP','RankBiserialGroup2Vs1','FDR_Q'};
Types = {'string','string','string','string','string','string','string', ...
    'string','double','double','double','double','double','double','double', ...
    'double','double','double','double'};
Results = table('Size',[0 numel(Names)],'VariableTypes',Types, ...
    'VariableNames',Names);
end

function Contrasts = createContrastDefinitions(Correlations)

Rows = cell(4,1);
RowIdx = 0;
DrugIDs = orderedDrugIDs(Correlations);
Conditions = orderedConditions(Correlations);
for DrugID = DrugIDs'
    Available = unique(Correlations.Condition(Correlations.DrugID==DrugID));
    if all(ismember(Conditions,Available)) && numel(Conditions)>=2
        RowIdx = RowIdx+1;
        Rows{RowIdx} = contrastDefinition("TreatmentWithinAge",DrugID, ...
            DrugID,Conditions(1),DrugID,Conditions(2));
    end
end
for Condition = Conditions'
    Available = unique(Correlations.DrugID(Correlations.Condition==Condition));
    if all(ismember(DrugIDs,Available)) && numel(DrugIDs)>=2
        RowIdx = RowIdx+1;
        Rows{RowIdx} = contrastDefinition("AgeWithinCondition",Condition, ...
            DrugIDs(1),Condition,DrugIDs(2),Condition);
    end
end
if RowIdx==0
    Contrasts = emptyContrastDefinitions();
else
    Contrasts = vertcat(Rows{1:RowIdx});
end
end

function Row = contrastDefinition(Type,Stratum,Drug1,Condition1,Drug2,Condition2)

Group1 = Drug1+" | "+Condition1;
Group2 = Drug2+" | "+Condition2;
Label = Group2+" vs "+Group1;
Row = table(Type,string(Stratum),Label,Drug1,Condition1,Drug2,Condition2, ...
    Group1,Group2,'VariableNames',{'ContrastType','Stratum', ...
    'ContrastLabel','Group1DrugID','Group1Condition','Group2DrugID', ...
    'Group2Condition','Group1','Group2'});
end

function TableOut = emptyContrastDefinitions()

TableOut = table('Size',[0 9], ...
    'VariableTypes',repmat({'string'},1,9), ...
    'VariableNames',{'ContrastType','Stratum','ContrastLabel', ...
    'Group1DrugID','Group1Condition','Group2DrugID','Group2Condition', ...
    'Group1','Group2'});
end

function DrugIDs = orderedDrugIDs(Data)

Pairs = unique(Data(:,{'DrugID','Age'}),'rows','stable');
Order = zeros(height(Pairs),1);
Order(Pairs.Age=="4 months") = 1;
Order(Pairs.Age=="6 months") = 2;
Order(Order==0) = 3+(1:nnz(Order==0))';
[~,Idx] = sort(Order);
DrugIDs = Pairs.DrugID(Idx);
end

function Conditions = orderedConditions(Data)

Conditions = unique(Data.Condition,'stable');
Priority = zeros(numel(Conditions),1);
Priority(Conditions=="IsoCtrl") = 1;
Priority(Conditions=="Ly6G") = 2;
Priority(Priority==0) = 3+(1:nnz(Priority==0))';
[~,Idx] = sort(Priority);
Conditions = Conditions(Idx);
end

function Data = effectTable(Source,Property,Analysis,Threshold)

Mask = Source.Property==Property;
if Analysis=="ContinuousSpearman"
    Values = Source.SpearmanRho;
elseif Analysis=="NearVsFar"
    Mask = Mask & Source.Threshold_um==Threshold & Source.ValidComparison;
    Values = Source.NearMinusFar;
else
    Mask = Mask & Source.Threshold_um==Threshold & Source.Included;
    Values = Source.NullCorrectedEffect;
end
Mask = Mask & isfinite(Values);
Data = Source(Mask,{'Mouse','Age','Genotype','Condition','DrugID', ...
    'AnalysisGroup'});
Data.Effect = Values(Mask);
end

function Row = comparisonRow(Contrast,Data,Property,Analysis,Threshold,NBoot)

Group1Mask = Data.DrugID==Contrast.Group1DrugID & ...
    Data.Condition==Contrast.Group1Condition;
Group2Mask = Data.DrugID==Contrast.Group2DrugID & ...
    Data.Condition==Contrast.Group2Condition;
Group1Values = Data.Effect(Group1Mask);
Group2Values = Data.Effect(Group2Mask);
Difference = median(Group2Values,'omitnan')-median(Group1Values,'omitnan');
CI = bootstrapAgeDifferenceCI(Group1Values,Group2Values,NBoot);
P = NaN;
if numel(Group1Values)>=2 && numel(Group2Values)>=2
    P = ranksum(Group1Values,Group2Values);
end
Effect = independentRankBiserial(Group2Values,Group1Values);
Row = table(Contrast.ContrastType,Contrast.Stratum,Contrast.ContrastLabel, ...
    Contrast.Group1,Contrast.Group2,Property,propertyUnit(Property), ...
    Analysis,Threshold,numel(Group1Values),numel(Group2Values), ...
    median(Group1Values,'omitnan'),median(Group2Values,'omitnan'), ...
    Difference,CI(1),CI(2),P,Effect, ...
    'VariableNames',{'ContrastType','Stratum','ContrastLabel','Group1', ...
    'Group2','Property','AnalysisUnit','Analysis','Threshold_um', ...
    'NGroup1','NGroup2','MedianGroup1','MedianGroup2', ...
    'DifferenceGroup2MinusGroup1','CI_Lower','CI_Upper','RankSumP', ...
    'RankBiserialGroup2Vs1'});
end

function Results = createFactorialInteractions(Correlations,Thresholds, ...
    SpatialNull,Options)

rng(Options.RandomSeed+2);
Properties = unique(Correlations.Property,'stable');
ThresholdValues = Options.PropertyOptions.SensitivityThresholdsMicrometers(:)';
Rows = cell(numel(Properties)*(1+2*numel(ThresholdValues)),1);
RowIdx = 0;
for PropertyIdx = 1:numel(Properties)
    Property = Properties(PropertyIdx);
    Data = effectTable(Correlations,Property,"ContinuousSpearman",NaN);
    RowIdx = RowIdx+1;
    Rows{RowIdx} = interactionRow(Data,Property,"ContinuousSpearman",NaN,Options);
    for Threshold = ThresholdValues
        Data = effectTable(Thresholds,Property,"NearVsFar",Threshold);
        RowIdx = RowIdx+1;
        Rows{RowIdx} = interactionRow(Data,Property,"NearVsFar",Threshold,Options);
        Data = effectTable(SpatialNull,Property,"SpatialNullCorrected",Threshold);
        RowIdx = RowIdx+1;
        Rows{RowIdx} = interactionRow(Data,Property, ...
            "SpatialNullCorrected",Threshold,Options);
    end
end
Results = vertcat(Rows{1:RowIdx});
Results.FDR_Q = nan(height(Results),1);
for Analysis = ["ContinuousSpearman","NearVsFar","SpatialNullCorrected"]
    Mask = Results.Analysis==Analysis;
    if Analysis~="ContinuousSpearman"
        Mask = Mask & Results.Threshold_um== ...
            Options.PropertyOptions.NearThresholdMicrometers;
    end
    Results.FDR_Q(Mask) = benjaminiHochberg(Results.InteractionP(Mask));
end
end

function Row = interactionRow(Data,Property,Analysis,Threshold,Options)

Age = double(Data.Age=="6 months");
Treatment = double(Data.Condition=="Ly6G");
CellCounts = [sum(Age==0 & Treatment==0),sum(Age==0 & Treatment==1), ...
    sum(Age==1 & Treatment==0),sum(Age==1 & Treatment==1)];
Interaction = NaN;
CI = [NaN NaN];
P = NaN;
if all(CellCounts>=2)
    XReduced = [ones(height(Data),1),Age,Treatment];
    XFull = [XReduced,Age.*Treatment];
    Beta = XFull\Data.Effect;
    Interaction = Beta(4);
    Fitted = XReduced*(XReduced\Data.Effect);
    Residuals = Data.Effect-Fitted;
    Null = nan(Options.NumPermutations,1);
    for Idx = 1:Options.NumPermutations
        Permuted = Fitted+Residuals(randperm(numel(Residuals)));
        PermutedBeta = XFull\Permuted;
        Null(Idx) = PermutedBeta(4);
    end
    P = (1+sum(abs(Null)>=abs(Interaction)))/(Options.NumPermutations+1);
    Boot = nan(Options.BootstrapIterations,1);
    CellMasks = {Age==0 & Treatment==0,Age==0 & Treatment==1, ...
        Age==1 & Treatment==0,Age==1 & Treatment==1};
    for BootIdx = 1:Options.BootstrapIterations
        Selected = zeros(0,1);
        for CellIdx = 1:4
            Members = find(CellMasks{CellIdx});
            Selected = [Selected; Members(randi(numel(Members), ...
                numel(Members),1))]; %#ok<AGROW>
        end
        BootBeta = XFull(Selected,:)\Data.Effect(Selected);
        Boot(BootIdx) = BootBeta(4);
    end
    CI = percentileInterval(Boot,[2.5 97.5]);
end
Row = table(Property,propertyUnit(Property),Analysis,Threshold, ...
    CellCounts(1),CellCounts(2),CellCounts(3),CellCounts(4), ...
    Interaction,CI(1),CI(2),P, ...
    'VariableNames',{'Property','AnalysisUnit','Analysis','Threshold_um', ...
    'N4MonthIsoCtrl','N4MonthLy6G','N6MonthIsoCtrl','N6MonthLy6G', ...
    'AgeByTreatmentInteraction','CI_Lower','CI_Upper','InteractionP'});
end

function [Definitions,Availability] = createGroupDefinitions( ...
    RecordingSummary,ConfiguredAnimals)

Groups = unique(RecordingSummary(:,{'DrugID','Condition','Genotype','Age'}), ...
    'rows','stable');
NAnalyzed = zeros(height(Groups),1);
NConfigured = zeros(height(Groups),1);
NWithAmyloidFile = zeros(height(Groups),1);
Availability = createAvailabilityTable(RecordingSummary,ConfiguredAnimals,Groups);
for Idx = 1:height(Groups)
    Mask = RecordingSummary.DrugID==Groups.DrugID(Idx) & ...
        RecordingSummary.Condition==Groups.Condition(Idx);
    NAnalyzed(Idx) = numel(unique(RecordingSummary.Mouse(Mask)));
    AvailabilityMask = Availability.DrugID==Groups.DrugID(Idx) & ...
        Availability.Condition==Groups.Condition(Idx);
    NConfigured(Idx) = nnz(AvailabilityMask);
    NWithAmyloidFile(Idx) = nnz(AvailabilityMask & ...
        Availability.HasMethoxyStaining);
end
AnalysisGroup = Groups.DrugID+" | "+Groups.Condition;
Definitions = addvars(Groups,AnalysisGroup,NConfigured,NWithAmyloidFile, ...
    NAnalyzed,'After','Condition');
end

function Availability = createAvailabilityTable(RecordingSummary,Configured,Groups)

if isempty(Configured)
    Availability = RecordingSummary(:,{'Mouse','Genotype','Condition','DrugID', ...
        'AmyloidFile'});
    Availability = unique(Availability,'rows','stable');
else
    Required = {'Mouse','Genotype','Condition','DrugID'};
    if ~all(ismember(Required,Configured.Properties.VariableNames))
        error('HypoxiaAmyloid:ConfiguredAnimalMetadata', ...
            'ConfiguredAnimals must contain Mouse, Genotype, Condition, and DrugID.');
    end
    Availability = Configured(:,Required);
    if ismember('AmyloidFile',Configured.Properties.VariableNames)
        Availability.AmyloidFile = Configured.AmyloidFile;
    else
        Availability.AmyloidFile = repmat({''},height(Availability),1);
    end
    if ismember('Paths',Configured.Properties.VariableNames)
        Availability.Paths = Configured.Paths;
    end
end
TextColumns = intersect({'Mouse','Genotype','Condition','DrugID', ...
    'AmyloidFile','Paths'},Availability.Properties.VariableNames,'stable');
for Idx = 1:numel(TextColumns)
    Name = TextColumns{Idx};
    Availability.(Name) = string(Availability.(Name));
end
Keep = false(height(Availability),1);
for Idx = 1:height(Groups)
    Keep = Keep | (Availability.DrugID==Groups.DrugID(Idx) & ...
        Availability.Condition==Groups.Condition(Idx));
end
Availability = Availability(Keep,:);
Availability.AnalysisGroup = Availability.DrugID+" | "+Availability.Condition;
Availability.HasMethoxyStaining = ...
    strlength(strtrim(Availability.AmyloidFile))>0;
Availability.Analyzed = ismember(Availability.Mouse,RecordingSummary.Mouse);
Status = repmat("Not analyzed",height(Availability),1);
Status(~Availability.HasMethoxyStaining) = ...
    "Not analyzed: no AmyloidFile configured";
Status(Availability.Analyzed) = "Analyzed";
Availability.AnalysisStatus = Status;
end

function Effect = signedRankBiserial(Values)

Values = Values(isfinite(Values) & Values~=0);
if isempty(Values)
    Effect = NaN;
    return
end
Ranks = averageRanks(abs(Values));
Effect = (sum(Ranks(Values>0))-sum(Ranks(Values<0)))/sum(Ranks);
end

function Effect = independentRankBiserial(First,Second)

if isempty(First) || isempty(Second)
    Effect = NaN;
    return
end
Wins = 0;
Ties = 0;
for Idx = 1:numel(First)
    Wins = Wins+sum(First(Idx)>Second);
    Ties = Ties+sum(First(Idx)==Second);
end
CommonLanguage = (Wins+0.5*Ties)/(numel(First)*numel(Second));
Effect = 2*CommonLanguage-1;
end

function Ranks = averageRanks(Values)

[Sorted,Order] = sort(Values);
RanksSorted = zeros(size(Sorted));
StartIdx = 1;
while StartIdx<=numel(Sorted)
    EndIdx = StartIdx;
    while EndIdx<numel(Sorted) && Sorted(EndIdx+1)==Sorted(StartIdx)
        EndIdx = EndIdx+1;
    end
    RanksSorted(StartIdx:EndIdx) = mean(StartIdx:EndIdx);
    StartIdx = EndIdx+1;
end
Ranks = zeros(size(Values));
Ranks(Order) = RanksSorted;
end

function CI = bootstrapMedianCI(Values,NBoot)

Values = Values(isfinite(Values));
if isempty(Values)
    CI = [NaN NaN];
    return
end
Boot = nan(NBoot,1);
for Idx = 1:NBoot
    Boot(Idx) = median(Values(randi(numel(Values),numel(Values),1)));
end
CI = percentileInterval(Boot,[2.5 97.5]);
end

function CI = bootstrapAgeDifferenceCI(Four,Six,NBoot)

if isempty(Four) || isempty(Six)
    CI = [NaN NaN];
    return
end
Boot = nan(NBoot,1);
for Idx = 1:NBoot
    FourDraw = Four(randi(numel(Four),numel(Four),1));
    SixDraw = Six(randi(numel(Six),numel(Six),1));
    Boot(Idx) = median(SixDraw)-median(FourDraw);
end
CI = percentileInterval(Boot,[2.5 97.5]);
end

function CI = percentileInterval(Values,Percentiles)

Values = sort(Values(isfinite(Values)));
if isempty(Values)
    CI = [NaN NaN];
else
    CI = prctile(Values,Percentiles);
end
end

function P = empiricalTwoSidedP(Observed,NullValues)

NullValues = NullValues(isfinite(NullValues));
if ~isfinite(Observed) || isempty(NullValues)
    P = NaN;
    return
end
Center = median(NullValues);
P = (1+sum(abs(NullValues-Center)>=abs(Observed-Center))) / ...
    (numel(NullValues)+1);
end

function Q = benjaminiHochberg(P)

Q = nan(size(P));
Valid = find(isfinite(P));
if isempty(Valid), return, end
[Sorted,Order] = sort(P(Valid));
Count = numel(Sorted);
Adjusted = Sorted.*Count./(1:Count)';
Adjusted = flipud(cummin(flipud(Adjusted)));
Adjusted = min(Adjusted,1);
Q(Valid(Order)) = Adjusted;
end

function writeCohortFigure(Cohort)

Properties = ["Duration","SpatialSize","Recurrence"];
YLabels = {'Duration (s)','Area (\mum^2)','Recurrence (events/pocket)'};
Primary = Cohort.Options.PropertyOptions.NearThresholdMicrometers;
FigureHandle = figure('Color','w','Visible','off', ...
    'Position',[100 100 1500 1200]);
Layout = tiledlayout(FigureHandle,3,3,'TileSpacing','compact', ...
    'Padding','compact');

for Idx = 1:numel(Properties)
    Property = Properties(Idx);
    Rows = Cohort.AnimalThresholds( ...
        Cohort.AnimalThresholds.Property==Property & ...
        Cohort.AnimalThresholds.Threshold_um==Primary & ...
        Cohort.AnimalThresholds.ValidComparison,:);

    nexttile(Layout,Idx);
    hold on
    for RowIdx = 1:height(Rows)
        Color = groupColor(Rows.Age(RowIdx),Rows.Condition(RowIdx));
        LineColor = 0.45*Color+0.55*[1 1 1];
        plot([1 2],[Rows.MedianNear(RowIdx),Rows.MedianFar(RowIdx)], ...
            '-','Color',LineColor,'LineWidth',1);
        scatter([1 2],[Rows.MedianNear(RowIdx),Rows.MedianFar(RowIdx)], ...
            34,Color,'filled');
    end
    xlim([0.6 2.4]);
    xticks([1 2]);
    xticklabels({'Near','Far'});
    ylabel(YLabels{Idx});
    title(sprintf('A. %s (<=%g \\mum)',Property,Primary));
    if Idx==1
        Handles = gobjects(4,1);
        Handles(1) = scatter(nan,nan,34,groupColor("4 months","IsoCtrl"),'filled');
        Handles(2) = scatter(nan,nan,34,groupColor("4 months","Ly6G"),'filled');
        Handles(3) = scatter(nan,nan,34,groupColor("6 months","IsoCtrl"),'filled');
        Handles(4) = scatter(nan,nan,34,groupColor("6 months","Ly6G"),'filled');
        legend(Handles,{'4m IsoCtrl','4m Ly6G','6m IsoCtrl','6m Ly6G'}, ...
            'Location','best','Box','off');
    end
    box off

    nexttile(Layout,Idx+3);
    CorrRows = Cohort.AnimalCorrelations( ...
        Cohort.AnimalCorrelations.Property==Property,:);
    hold on
    for RowIdx = 1:height(CorrRows)
        scatter(1+(rand-0.5)*0.12,CorrRows.SpearmanRho(RowIdx),42, ...
            groupColor(CorrRows.Age(RowIdx),CorrRows.Condition(RowIdx)),'filled');
    end
    yline(0,'--k');
    xlim([0.7 1.3]);
    xticks([]);
    ylabel('Within-animal Spearman rho');
    title(sprintf('B. %s vs distance',Property));
    box off

    nexttile(Layout,Idx+6);
    NullRows = Cohort.AnimalSpatialNull( ...
        Cohort.AnimalSpatialNull.Property==Property & ...
        Cohort.AnimalSpatialNull.Threshold_um==Primary & ...
        Cohort.AnimalSpatialNull.Included,:);
    hold on
    for RowIdx = 1:height(NullRows)
        Color = groupColor(NullRows.Age(RowIdx),NullRows.Condition(RowIdx));
        LineColor = 0.45*Color+0.55*[1 1 1];
        plot([1 2],[NullRows.NullMedian(RowIdx), ...
            NullRows.ObservedNearMinusFar(RowIdx)],'-','Color',LineColor);
        scatter([1 2],[NullRows.NullMedian(RowIdx), ...
            NullRows.ObservedNearMinusFar(RowIdx)],34,Color,'filled');
    end
    yline(0,':k');
    xlim([0.6 2.4]);
    xticks([1 2]);
    xticklabels({'Shift null','Observed'});
    ylabel('Near minus far');
    title(sprintf('C. %s spatial null',Property));
    box off
end

exportgraphics(FigureHandle,fullfile(Cohort.OutputFolder, ...
    'HypoxiaAmyloid_Figure2Candidate.png'),'Resolution',300);
exportgraphics(FigureHandle,fullfile(Cohort.OutputFolder, ...
    'HypoxiaAmyloid_MainFigure.png'),'Resolution',300);
close(FigureHandle);
end

function Color = groupColor(Age,Condition)

if Age=="4 months" && Condition=="IsoCtrl"
    Color = [0.15 0.45 0.75];
elseif Age=="4 months" && Condition=="Ly6G"
    Color = [0.15 0.65 0.45];
elseif Age=="6 months" && Condition=="IsoCtrl"
    Color = [0.85 0.45 0.15];
elseif Age=="6 months" && Condition=="Ly6G"
    Color = [0.75 0.2 0.3];
else
    Color = [0.35 0.35 0.35];
end
end

function writeMethodsSummary(Cohort)

Path = fullfile(Cohort.OutputFolder,'Methods_Statistics.txt');
FileID = fopen(Path,'w');
if FileID<0, return, end
Cleanup = onCleanup(@() fclose(FileID));
fprintf(FileID,'Hypoxia-amyloid property analysis\n');
fprintf(FileID,'Animal is the unit of inference; pockets are not pooled across animals.\n');
fprintf(FileID,'Primary near threshold: %g um.\n', ...
    Cohort.Options.PropertyOptions.NearThresholdMicrometers);
fprintf(FileID,'Sensitivity thresholds: %s um.\n',mat2str( ...
    Cohort.Options.PropertyOptions.SensitivityThresholdsMicrometers));
fprintf(FileID,'Minimum observations per near/far stratum: %d.\n', ...
    Cohort.Options.PropertyOptions.MinimumObservationsPerStratum);
fprintf(FileID,['Continuous effects are within-animal Spearman rho values tested ', ...
    'against zero by one-sample Wilcoxon signed-rank.\n']);
fprintf(FileID,['Binary effects are within-animal median near-minus-far values ', ...
    'tested by one-sample Wilcoxon signed-rank.\n']);
fprintf(FileID,['Effect size is signed rank-biserial correlation; confidence ', ...
    'intervals are percentile bootstrap intervals across animals.\n']);
fprintf(FileID,['Spatial control circularly shifts the plaque mask relative to ', ...
    'the fixed pocket data and recomputes each property difference. ', ...
    'Shifted distances use the circular (toroidal) boundary implied by ', ...
    'the circular-shift null.\n']);
fprintf(FileID,['Results are reported for all animals descriptively and for each ', ...
    'DrugID-by-Condition group inferentially.\n']);
fprintf(FileID,['Primary biological groups are the DrugID-by-Condition cells, ', ...
    'matching the main oxygen statistics pipeline.\n']);
fprintf(FileID,['Treatment comparisons test Ly6G versus IsoCtrl within each age; ', ...
    'age comparisons test 6 versus 4 months within each condition.\n']);
fprintf(FileID,['Age-by-treatment interactions are tested on animal-level effects ', ...
    'using a reduced-model residual permutation test with bootstrap ', ...
    'confidence intervals.\n']);
end
