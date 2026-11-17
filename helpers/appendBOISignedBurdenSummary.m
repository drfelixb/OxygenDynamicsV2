function B=appendBOISignedBurdenSummary(B,P)
% Descriptive sign/availability fields; never change products or totals.
if nargin<2
    if isfield(B,'SelectionPolicy'),P=boiBurdenSelectionPolicy(B.EventTable,B.SelectionPolicy);
    else,P=boiBurdenSelectionPolicy(B.EventTable);end
end
if ~P.IncludeFiniteNegative,return;end
B.SelectionPolicy=struct2table(P);E=B.EventTable;
E.BurdenSelectionPolicyVersion=repmat(string(P.Version),height(E),1);
a=nan(height(E),1);c=a;
if ismember('BurdenAmplitudePercent',E.Properties.VariableNames),a=E.BurdenAmplitudePercent;end
if ismember('PerEventBurdenContribution',E.Properties.VariableNames),c=E.PerEventBurdenContribution;end
[E.BurdenAmplitudeNegative,E.BurdenAmplitudeSignStatus]=negative(a);
[E.BurdenContributionNegative,E.BurdenContributionSignStatus]=negative(c);
B.EventTable=E;R=B.RecordingTable;
R.BurdenSelectionPolicyVersion=repmat(string(P.Version),height(R),1);
R.NumNegativeBurdenAmplitudes=zeros(height(R),1);
R.NumNegativeBurdenContributions=zeros(height(R),1);
R.NumAvailableBurdenContributions=zeros(height(R),1);
R.NumRequiredBurdenContributions=zeros(height(R),1);
for i=1:height(R)
    m=true(height(E),1);
    keys=intersect({'RecordingID','Experiment','Mouse','Condition','DrugID','Genotype','Promoter','PuffStim'}, ...
        intersect(R.Properties.VariableNames,E.Properties.VariableNames),'stable');
    for f=keys,m=m & string(E.(f{1}))==string(R.(f{1})(i));end
    R.NumNegativeBurdenAmplitudes(i)=sum(m&isfinite(a)&a<0);
    R.NumNegativeBurdenContributions(i)=sum(m&isfinite(c)&c<0);
    R.NumAvailableBurdenContributions(i)=sum(m&isfinite(c));
    R.NumRequiredBurdenContributions(i)=sum(m);
end
[R.BurdenTotalNegative,R.BurdenTotalSign]=totalSign(R.HypoxicBurden);
[R.NormalizedBurdenTotalNegative,R.NormalizedBurdenTotalSign]=totalSign(R.HypoxicBurden_per_mm2_per_min);
B.RecordingTable=R;
if isfield(B,'TimeSeriesTable')
    B.TimeSeriesTable.BurdenSelectionPolicyVersion=repmat(string(P.Version),height(B.TimeSeriesTable),1);
end
if isfield(B,'ReviewSummary')
    Q=B.ReviewSummary;Q.NegativeContributions=zeros(height(Q),1);
    for i=1:height(Q),Q.NegativeContributions(i)=sum(string(E.RecordingID)==string(Q.RecordingID(i))&isfinite(c)&c<0);end
    B.ReviewSummary=Q;
end
if isfield(B,'MetricBasis')&&~any(string(B.MetricBasis{:,1})=="BurdenSelectionPolicyVersion")
    row={'BurdenSelectionPolicyVersion',P.Version, ...
        'Finite signed contributions included; negative values subtract and are flagged. Missing stays unavailable. Formula/normalization unchanged; original sources retain their policy.'};
    B.MetricBasis=[B.MetricBasis;cell2table(row,'VariableNames',B.MetricBasis.Properties.VariableNames)];
end
end
function [flag,status]=negative(v)
flag=nan(size(v));valid=isfinite(v);flag(valid)=double(v(valid)<0);
status=repmat("not_assessable",size(v));status(valid)="nonnegative";status(valid&v<0)="negative";
end
function [flag,status]=totalSign(v)
[flag,~]=negative(v);status=repmat("not_assessable",size(v));
status(isfinite(v)&v>0)="positive";status(isfinite(v)&v==0)="zero";status(isfinite(v)&v<0)="negative";
end
