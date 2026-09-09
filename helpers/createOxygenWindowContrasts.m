function C = createOxygenWindowContrasts(W,Pairs)
C=table(); if isempty(Pairs),return;end
assert(all(ismember({'RecordingID','BaselineWindowID','ComparisonWindowID'},Pairs.Properties.VariableNames)), ...
    'Window pairs require RecordingID, BaselineWindowID, ComparisonWindowID.');
metrics={'EventOnsetRate_per_mm2_per_min','MeanConcurrentEvents_per_mm2','MeanOccupiedTissueFraction','AmplitudeAreaTime_per_mm2_per_min'};
for i=1:height(Pairs)
    rec=string(W.RecordingID)==string(Pairs.RecordingID(i));
    b=find(rec & string(W.WindowID)==string(Pairs.BaselineWindowID(i)));
    f=find(rec & string(W.WindowID)==string(Pairs.ComparisonWindowID(i)));
    assert(isscalar(b)&&isscalar(f)&&b~=f,'Window pair must resolve to distinct windows.');
    for m=metrics
        B=W.(m{1})(b); F=W.(m{1})(f);D=F-B;P=NaN;status="valid";
        if ~isfinite(B)||~isfinite(F),status="missing_measurement";
        elseif B<=0,status="nonpositive_baseline";
        else,P=100*(F-B)/B;end
        row=table(string(W.Mouse(b)),string(W.RecordingID(b)),string(W.WindowID(b)),string(W.WindowID(f)), ...
            string(m{1}),B,F,D,P,status,'VariableNames',{'Mouse','RecordingID','BaselineWindowID','ComparisonWindowID','Metric','Baseline','Comparison','Difference','RelativeChangePercent','Status'});
        C=[C;row]; %#ok<AGROW>
    end
end
end
