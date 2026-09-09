function [S,G,R] = createStatsAnalysisFilters(Sinks,Surges,Traces,Drugs,Conditions,Stim,Registry)
% Same complete biological grouping for site metrics and recording traces.
assert(nargin>=7,'OxygenDynamics:MissingRecordingRegistry','An explicit recording registry is required.');
cols={'DrugID','Condition','Genotype','Promoter','PuffStim'};
levels=unique(Registry(:,cols),'rows','stable');
S=cell(5,height(levels)); G=S; R=cell(4,height(levels));
for k=1:height(levels)
    label=char(string(levels.Condition(k))+" ["+string(levels.Genotype(k))+"; "+string(levels.Promoter(k))+"]");
    stim='Without stimulation'; if levels.PuffStim(k), stim='With stimulation'; end
    head={char(string(levels.DrugID(k)));label;stim};
    si=select(Sinks,levels(k,:),cols); gi=select(Surges,levels(k,:),cols);
    S(:,k)=[head;{si};{unique(Sinks.Mouse(si))}];
    G(:,k)=[head;{gi};{unique(Surges.Mouse(gi))}];
    R(:,k)=[head;{select(Registry,levels(k,:),cols)}];
end
end
function mask=select(T,L,cols)
mask=true(height(T),1);
for f=cols, mask=mask & string(T.(f{1}))==string(L.(f{1})); end
end
