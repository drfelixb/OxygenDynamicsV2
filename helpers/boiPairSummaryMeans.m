function summary=boiPairSummaryMeans(summary,events)
% Arithmetic means of the same independent event populations as the RC1 medians.
for i=1:height(summary)
    selected=events.Channel==summary.Channel(i) & events.Sign==summary.Sign(i);
    summary.MeanDurationSec(i,1)=mean(events.DurationSec(selected),'omitnan');
    summary.MeanAreaUm2(i,1)=mean(events.MeanNativeAreaUm2(selected),'omitnan');
    summary.MeanDepthOrRisePct(i,1)=mean(events.OpticalDepthOrRisePct(selected),'omitnan');
end
end
