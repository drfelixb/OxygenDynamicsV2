function R = aggregateOxygenRecordingBurden(E,Registry)
% Recording-level event totals with strict missingness and independent exposure.
R=Registry;
numeric={'NumEvents','NumSinkSites','HypoxicBurden','HypoxicBurden_per_mm2', ...
'HypoxicBurden_per_sec','HypoxicBurden_per_min','HypoxicBurden_per_mm2_per_sec', ...
'HypoxicBurden_per_mm2_per_min','Burden_Occupancy','Burden_RankAmplitude','Burden_AmplitudeComposite', ...
'MeanEventBurdenContribution','MedianEventBurdenContribution','MeanEventBurdenContribution_per_mm2', ...
'MedianEventBurdenContribution_per_mm2','MeanBurdenAmplitudePercent','MeanBurdenArea_um2','MeanBurdenDuration_sec'};
for f=numeric, R.(f{1})=nan(height(R),1); end
R.MetricBasis=repmat({'RecordingEventSum'},height(R),1);
R.NumValidCompositeEvents=zeros(height(R),1);
for i=1:height(R)
    idx=false(height(E),1);
    if ismember('RecordingID',E.Properties.VariableNames), idx=string(E.RecordingID)==string(R.RecordingID(i)); end
    T=E(idx,:); R.NumEvents(i)=height(T);
    if isempty(T)
        R.NumSinkSites(i)=0; total=0; seconds=0; rank=0;
    else
        R.NumSinkSites(i)=numel(unique(T.SinkID));
        total=sum(T.PerEventBurdenContribution); seconds=sum(T.BurdenDuration_sec);
        rank=sum(T.BurdenDuration_sec.*T.BurdenRankAmplitudeQuantile);
        R.NumValidCompositeEvents(i)=sum(isfinite(T.PerEventBurdenContribution));
        pairs={'MeanEventBurdenContribution','PerEventBurdenContribution';'MeanEventBurdenContribution_per_mm2','PerEventBurdenContribution_per_mm2'; ...
            'MeanBurdenAmplitudePercent','BurdenAmplitudePercent';'MeanBurdenArea_um2','BurdenArea_um2';'MeanBurdenDuration_sec','BurdenDuration_sec'};
        for j=1:size(pairs,1), R.(pairs{j,1})(i)=mean(T.(pairs{j,2}),'omitnan'); end
        R.MedianEventBurdenContribution(i)=median(T.PerEventBurdenContribution,'omitnan');
        R.MedianEventBurdenContribution_per_mm2(i)=median(T.PerEventBurdenContribution_per_mm2,'omitnan');
    end
    R.HypoxicBurden(i)=total; R.Burden_AmplitudeComposite(i)=total;
    A=R.RecordingArea_um2(i); duration=R.RecordingDuration_sec(i);
    if ~isfinite(A)||A<=0, A=NaN; end
    if ~isfinite(duration)||duration<=0, duration=NaN; end
    R.HypoxicBurden_per_mm2(i)=total*1e6/A;
    R.HypoxicBurden_per_sec(i)=total/duration; R.HypoxicBurden_per_min(i)=60*total/duration;
    R.HypoxicBurden_per_mm2_per_sec(i)=total*1e6/A/duration;
    R.HypoxicBurden_per_mm2_per_min(i)=total*1e6/A/duration*60;
    R.Burden_Occupancy(i)=seconds*1e6/A/duration*60;
    R.Burden_RankAmplitude(i)=rank*1e6/A/duration*60;
end
R.EventOnsetRate_per_mm2_per_min=R.NumEvents.*1e6./R.RecordingArea_um2.*60./R.RecordingDuration_sec;
R.Burden_Occupancy_Units=repmat("event-seconds/mm2/min",height(R),1);
R.Burden_RankAmplitude_Units=repmat("rank-weighted event-seconds/mm2/min",height(R),1);
R.Burden_AmplitudeComposite_Units=repmat("percent*um2*seconds",height(R),1);
end
