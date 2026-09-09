function W = createOxygenAnalysisWindows(Registry,Sites,Events,Windows)
% Windowed sink metrics with explicit physical boundaries and mask support.
if nargin<4 || isempty(Windows)
    Windows=Registry(:,{'RecordingID'});
    Windows.WindowID=repmat("whole_recording",height(Registry),1);
    Windows.StartSec=zeros(height(Registry),1); Windows.EndSec=Registry.RecordingDuration_sec;
end
assert(all(ismember({'RecordingID','WindowID','StartSec','EndSec'},Windows.Properties.VariableNames)), ...
    'Windows require RecordingID, WindowID, StartSec, EndSec.');
W=table();
for i=1:height(Windows)
    idx=find(string(Registry.RecordingID)==string(Windows.RecordingID(i)));
    assert(isscalar(idx),'Window recording must resolve uniquely.');
    R=Registry(idx,:); fs=R.SampleF; n=R.NFrames;
    a=Windows.StartSec(i);b=Windows.EndSec(i);
    assert(isfinite(a)&&isfinite(b)&&a>=0&&b>a&&b<=R.RecordingDuration_sec,'Invalid window interval.');
    mask=false(height(Events),1);
    if ismember('RecordingID',Events.Properties.VariableNames),mask=string(Events.RecordingID)==R.RecordingID;end
    E=Events(mask,:);A=R.RecordingArea_um2;T=b-a;
    count=0;seconds=0;composite=0;
    if ~isempty(E)
        count=sum(E.StartSec>=a & E.StartSec<b);
        overlap=max(0,min(E.EndSec,b)-max(E.StartSec,a));
        seconds=sum(overlap);
        active=overlap>0;
        if ismember('EventArea_um2',E.Properties.VariableNames)
            amplitude=E.NormOxySinkAmpPercent(active);
            amplitude(amplitude<0)=NaN; % wrong-direction raw signal is not a hypoxic composite
            composite=sum(amplitude.*E.EventArea_um2(active).*overlap(active));
        elseif any(active), composite=NaN; end
    end
    occupied=NaN;
    sm=false(height(Sites),1);
    if ismember('RecordingID',Sites.Properties.VariableNames),sm=string(Sites.RecordingID)==R.RecordingID;end
    S=Sites(sm,:);
    if isempty(S), occupied=0;
    elseif ismember('EligibleTissuePixels',S.Properties.VariableNames) && ismember('FramePixels',S.Properties.VariableNames) && all(~cellfun(@isempty,S.FramePixels))
        % Area already in physical units; no requirement for event summary geometry.
        if ismember('PixelSize',R.Properties.VariableNames),px=R.PixelSize;else,px=NaN;end
        series=computeOngoingSinkTimeSeries(S,n,px);
        dt=max(0,min((1:n)/fs,b)-max((0:n-1)/fs,a));
        occupied=sum(series.AreaUm.*dt);
    end
    if ~isfinite(A)||A<=0,A=NaN;end
    row=R(:,{'RecordingID','Mouse','Condition','DrugID','Genotype','Promoter','PuffStim'});
    row.WindowID=string(Windows.WindowID(i));row.StartSec=a;row.EndSec=b;row.DurationSec=T;
    row.AreaUm2=A;row.EventOnsets=count;row.ActiveEventSeconds=seconds;
    row.EventOnsetRate_per_mm2_per_min=count*1e6/A*60/T;
    row.MeanConcurrentEvents_per_mm2=seconds*1e6/A/T;
    row.MeanOccupiedTissueFraction=occupied/A/T;
    row.AmplitudeAreaTimePercent_um2_sec=composite;
    row.AmplitudeAreaTime_per_mm2_per_min=composite*1e6/A*60/T;
    W=[W;row]; %#ok<AGROW>
end
assert(height(unique(W(:,{'RecordingID','WindowID'}),'rows'))==height(W),'Duplicate window identifiers.');
end
