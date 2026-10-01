function [W,FrameIngredients] = createOxygenAnalysisWindows(Registry,Sites,Events,Windows,kind)
% Windowed sign-specific metrics; Registry must hold the selected sign's area.
if nargin<5,kind='sink';end
assert(ismember(string(kind),["sink","surge"]),'OxygenDynamics:InvalidWindowSign','Choose sink or surge.');
if nargin<4 || isempty(Windows)
    Windows=Registry(:,{'RecordingID'});
    Windows.WindowID=repmat("whole_recording",height(Registry),1);
    Windows.StartSec=zeros(height(Registry),1); Windows.EndSec=Registry.RecordingDuration_sec;
end
assert(all(ismember({'RecordingID','WindowID','StartSec','EndSec'},Windows.Properties.VariableNames)), ...
    'Windows require RecordingID, WindowID, StartSec, EndSec.');
W=table(); frameRows=cell(height(Windows),1);
for i=1:height(Windows)
    idx=find(string(Registry.RecordingID)==string(Windows.RecordingID(i)));
    assert(isscalar(idx),'Window recording must resolve uniquely.');
    R=Registry(idx,:); fs=R.SampleF; n=R.NFrames;
    assert(isfinite(fs)&&fs>0&&isfinite(n)&&n>=1&&n==fix(n), ...
        'OxygenDynamics:InvalidExposure','A positive uniform clock and frame count are required.');
    if ismember('AnalysisStatus',R.Properties.VariableNames)
        assert(string(R.AnalysisStatus)=="loaded",'OxygenDynamics:RecordingNotAnalyzed', ...
            'A failed or unprocessed recording cannot be summarized as a valid zero.');
    end
    a=Windows.StartSec(i);b=Windows.EndSec(i);
    assert(isfinite(a)&&isfinite(b)&&a>=0&&b>a&&b<=R.RecordingDuration_sec,'Invalid window interval.');
    mask=false(height(Events),1);
    if ismember('RecordingID',Events.Properties.VariableNames),mask=string(Events.RecordingID)==R.RecordingID;end
    E=Events(mask,:);A=R.RecordingArea_um2;T=b-a;
    count=0;seconds=0;composite=0;boundaryActive=0;boundaryCounted=0;ongoing=0;
    if ~isempty(E)
        count=sum(E.StartSec>=a & E.StartSec<b);
        overlap=max(0,min(E.EndSec,b)-max(E.StartSec,a));
        seconds=sum(overlap);
        active=overlap>0;
        boundaryActive=sum(active & E.StartSec==0);
        boundaryCounted=sum(E.StartSec==0 & E.StartSec>=a & E.StartSec<b);
        ongoing=sum(E.StartSec<a & E.EndSec>a);
        if strcmp(kind,'sink') && ismember('EventArea_um2',E.Properties.VariableNames)
            amplitude=E.NormOxySinkAmpPercent(active);
            amplitude(amplitude<0)=NaN; % wrong-direction raw signal is not a hypoxic composite
            composite=sum(amplitude.*E.EventArea_um2(active).*overlap(active));
        elseif any(active), composite=NaN; end
    end
    occupied=NaN;areaSeries=nan(1,n);occupancyStatus="unavailable_native_masks";
    dt=max(0,min((1:n)/fs,b)-max((0:n-1)/fs,a));
    assert(abs(sum(dt)-T)<=1e-10*max(1,T),'OxygenDynamics:InvalidExposure','Frame intervals do not cover the requested window.');
    sm=false(height(Sites),1);
    if ismember('RecordingID',Sites.Properties.VariableNames),sm=string(Sites.RecordingID)==R.RecordingID;end
    S=Sites(sm,:);
    if isempty(S) && isempty(E)
        occupied=0;areaSeries=zeros(1,n);occupancyStatus="zero_events_static_support_assumed";
    elseif ~isempty(S) && ismember('EligibleTissuePixels',S.Properties.VariableNames) && ismember('FramePixels',S.Properties.VariableNames) && all(~cellfun(@isempty,S.FramePixels))
        % Area already in physical units; no requirement for event summary geometry.
        if ismember('PixelSize',R.Properties.VariableNames),px=R.PixelSize;else,px=NaN;end
        assert(all(cellfun(@(v)iscell(v)&&numel(v)==n,S.FramePixels)), ...
            'OxygenDynamics:InvalidNativeSupport','Each site must retain one native pixel list per recording frame.');
        for site=1:height(S)
            assert(isequal(S.EligibleTissuePixels{site}(:),S.EligibleTissuePixels{1}(:)), ...
                'OxygenDynamics:InvalidNativeSupport','Sites disagree on the recording tissue mask.');
        end
        if isfinite(A) && A>=0 && isfinite(px) && px>0
            maskArea=numel(unique(S.EligibleTissuePixels{1}))*px^2;
            assert(abs(maskArea-A)<=1e-9*max(1,A),'OxygenDynamics:TissueAreaMismatch', ...
                'Window denominator disagrees with saved tissue pixels and calibration.');
        end
        series=computeOngoingRegionSeries(S,n,px,kind);
        areaSeries=series.AreaUm;
        occupied=sum(areaSeries(dt>0).*dt(dt>0));
        occupancyStatus="descriptive_static_uniform_assumptions";
    end
    denominator=R.RecordingArea_um2*T;
    if ~isfinite(A)||A<=0
        A=NaN;occupancyStatus="unavailable_tissue_denominator";
    end
    row=R(:,{'RecordingID','Mouse','Condition','DrugID','Genotype','Promoter','PuffStim'});
    row.WindowID=string(Windows.WindowID(i));row.StartSec=a;row.EndSec=b;row.DurationSec=T;
    row.AreaUm2=A;row.EventOnsets=count;row.ActiveEventSeconds=seconds;
    row.EventOnsetRate_per_mm2_per_min=count*1e6/A*60/T;
    row.MeanConcurrentEvents_per_mm2=seconds*1e6/A/T;
    row.MeanOccupiedTissueFraction=occupied/A/T;
    if strcmp(kind,'surge'),composite=NaN;end % No accepted surge amplitude-area-time composite.
    row.AmplitudeAreaTimePercent_um2_sec=composite;
    row.AmplitudeAreaTime_per_mm2_per_min=composite*1e6/A*60/T;
    row.WindowAuditVersion="boi-window-exposure-1";
    row.CoveredAreaTime_um2_sec=occupied;
    row.AnalyzedTissueTime_um2_sec=denominator;
    row.AnalyzedTissueTime_mm2_min=denominator/1e6/60;
    row.AcquisitionStartEvents=boundaryActive;
    row.AcquisitionStartOnsetsCounted=boundaryCounted;
    row.OnsetsAfterAcquisitionStart=count-boundaryCounted;
    row.OngoingAtWindowStart=ongoing;
    row.OnsetPolicy="descriptive_including_acquisition_boundary; physiological_admission_unresolved";
    row.OccupancyStatus=occupancyStatus;
    row.ExposureBasis="static_analyzed_tissue_times_uniform_frame_intervals";
    row.FrameTimingStatus="uniform_assumed_from_sampling_rate";
    if ismember('FrameTimingStatus',R.Properties.VariableNames),row.FrameTimingStatus=R.FrameTimingStatus;end
    row.CameraExposureStatus="unknown";
    if ismember('CameraExposureStatus',R.Properties.VariableNames),row.CameraExposureStatus=R.CameraExposureStatus;end
    if strcmp(kind,'surge')
        row.WindowAuditVersion="boi-surge-window-exposure-1";
        row.EventType="surge";row.CompositeStatus="not_defined_for_surge";
    end
    selected=find(dt>0)';
    frameRows{i}=table(repmat(string(R.RecordingID),numel(selected),1), ...
        repmat(string(Windows.WindowID(i)),numel(selected),1),selected,(selected-1)/fs,selected/fs, ...
        dt(selected)',areaSeries(selected)',repmat(R.RecordingArea_um2,numel(selected),1), ...
        (areaSeries(selected).*dt(selected))',R.RecordingArea_um2*dt(selected)', ...
        repmat(occupancyStatus,numel(selected),1),'VariableNames', ...
        {'RecordingID','WindowID','Frame','ModeledStartSec','ModeledEndSec','WindowOverlapSec', ...
        'OccupiedArea_um2','AnalyzedArea_um2','CoveredAreaTime_um2_sec','AnalyzedTissueTime_um2_sec','OccupancyStatus'});
    W=[W;row]; %#ok<AGROW>
end
assert(height(unique(W(:,{'RecordingID','WindowID'}),'rows'))==height(W),'Duplicate window identifiers.');
FrameIngredients=vertcat(frameRows{:});
end
