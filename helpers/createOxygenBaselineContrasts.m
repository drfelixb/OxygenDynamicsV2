function C = createOxygenBaselineContrasts(R,Pairs)
% Explicit recording pairs only; preserve undefined zero-baseline relative change.
C=table(); if isempty(Pairs), return; end
required={'BaselineRecordingID','ComparisonRecordingID'};
assert(all(ismember(required,Pairs.Properties.VariableNames)),'Pair table must name baseline and comparison recording IDs.');
assert(numel(unique(string(R.RecordingID)))==height(R),'Recording IDs must be unique.');
metrics={'EventOnsetRate_per_mm2_per_min','Burden_Occupancy','Burden_AmplitudeComposite', ...
    'HypoxicBurden_per_mm2_per_min','MeanBurdenAmplitudePercent','MeanBurdenArea_um2','MeanBurdenDuration_sec'};
for i=1:height(Pairs)
    b=find(string(R.RecordingID)==string(Pairs.BaselineRecordingID(i)));
    f=find(string(R.RecordingID)==string(Pairs.ComparisonRecordingID(i)));
    assert(isscalar(b)&&isscalar(f),'Each pair must resolve to two recording rows.');
    assert(string(R.Mouse(b))==string(R.Mouse(f)),'A paired contrast must use the same mouse.');
    assert(b~=f,'Baseline and comparison must be different recordings.');
    for m=metrics
        B=R.(m{1})(b); F=R.(m{1})(f); difference=F-B; fold=NaN; percent=NaN;
        status="valid";
        if ~isfinite(B)||~isfinite(F), status="missing_measurement";
        elseif B==0, status="zero_baseline";
        elseif B<0, status="nonpositive_baseline";
        else, fold=F/B; percent=100*(F-B)/B; end
        row=table(string(R.Mouse(b)),string(R.RecordingID(b)),string(R.RecordingID(f)),string(m{1}),B,F,difference,fold,percent,status, ...
            'VariableNames',{'Mouse','BaselineRecordingID','ComparisonRecordingID','Metric','Baseline','Comparison','Difference','FoldChange','RelativeChangePercent','Status'});
        C=[C;row]; %#ok<AGROW>
    end
end
end
