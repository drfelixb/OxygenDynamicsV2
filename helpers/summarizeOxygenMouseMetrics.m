function G = summarizeOxygenMouseMetrics(R)
% Equal-mouse summaries; multiple recordings first averaged within mouse/group.
G=table(); if isempty(R), return; end
cols={'DrugID','Condition','PuffStim','Genotype','Promoter'};
cols=cols(ismember(cols,R.Properties.VariableNames));
[G,~,group]=unique(R(:,cols),'rows','stable');
G.NumRecordings=zeros(height(G),1); G.NumMice=zeros(height(G),1);
G.NumEvents=zeros(height(G),1); G.NumSinkSites=zeros(height(G),1);
metrics={'HypoxicBurden','HypoxicBurden_per_mm2','HypoxicBurden_per_sec','HypoxicBurden_per_min', ...
    'HypoxicBurden_per_mm2_per_sec','HypoxicBurden_per_mm2_per_min','Burden_Occupancy','Burden_RankAmplitude', ...
    'Burden_AmplitudeComposite','MeanBurdenAmplitudePercent','MeanBurdenArea_um2','MeanBurdenDuration_sec','EventOnsetRate_per_mm2_per_min'};
metrics=metrics(ismember(metrics,R.Properties.VariableNames));
for f=metrics
    G.([f{1} '_Mean'])=nan(height(G),1);G.([f{1} '_SEM'])=nan(height(G),1);G.([f{1} '_NValidMice'])=zeros(height(G),1);
end
for i=1:height(G)
    rows=R(group==i,:); [mice,~,mi]=unique(string(rows.Mouse));
    G.NumRecordings(i)=height(rows);G.NumMice(i)=numel(mice);
    G.NumEvents(i)=sum(rows.NumEvents);G.NumSinkSites(i)=sum(rows.NumSinkSites);
    for f=metrics
        v=splitapply(@(x)mean(x),rows.(f{1}),mi); % incomplete mouse remains missing
        v=v(isfinite(v)); n=numel(v);
        G.([f{1} '_Mean'])(i)=mean(v); G.([f{1} '_NValidMice'])(i)=n;
        if n>1, G.([f{1} '_SEM'])(i)=std(v)/sqrt(n); end
    end
end
G.MetricBasis=repmat("EqualMouseMeans_WithinGroup",height(G),1);
end
