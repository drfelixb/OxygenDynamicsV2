function Data=buildBOIWindowReviewData(Review,Index,kind)
%BUILDBOIWINDOWREVIEWDATA Independently replay saved arithmetic, not analysis.
if nargin<3,kind='sink';end
assert(ismember(string(kind),["sink","surge"]),'OxygenDynamics:InvalidWindowSign','Choose sink or surge.');
support='SinkEligibleTissuePixels';siteID='SinkID';
if strcmp(kind,'surge')
    assert(isfield(Review,'HasSurgeWindows')&&Review.HasSurgeWindows,'OxygenDynamics:WindowReviewMissingEvidence','Saved surge window outcomes are unavailable, not zero.');
    Review.RecordingWindowMetrics=Review.SurgeRecordingWindowMetrics;
    Review.WindowFrameIngredients=Review.SurgeWindowFrameIngredients;
    Review.Table_OxygenSinkEvents_OutCombo=Review.Table_OxygenSurgeEvents_OutCombo;
    support='SurgeEligibleTissuePixels';siteID='SurgeID';
end
assert(isscalar(Index)&&Index>=1&&Index<=height(Review.RecordingWindowMetrics)&&Index==fix(Index));
W=Review.RecordingWindowMetrics(Index,:);r=find(string(Review.RecordingRegistry.RecordingID)==string(W.RecordingID));
C=Review.BOIInputContracts{r};N=C.NFrames;fs=C.SampleHz;px=C.PixelSizeUm;a=W.StartSec;b=W.EndSec;
assert(isfinite(a)&&isfinite(b)&&a>=0&&b>a&&b<=N/fs,'OxygenDynamics:InvalidWindowReview','Saved window bounds lie outside the recording.');
F=Review.WindowFrameIngredients;F=sortrows(F(string(F.RecordingID)==string(W.RecordingID)&string(F.WindowID)==string(W.WindowID),:),'Frame');
assert(all(isfinite(F.Frame)&F.Frame>=1&F.Frame<=N&F.Frame==fix(F.Frame)), ...
    'OxygenDynamics:InvalidWindowReview','Window frame indices are invalid.');
E=Review.Table_OxygenSinkEvents_OutCombo;E=E(string(E.RecordingID)==string(W.RecordingID),:);
assert(all(isfinite(E.StartSec)&isfinite(E.EndSec)&E.StartSec>=0&E.EndSec>E.StartSec&E.EndSec<=N/fs), ...
    'OxygenDynamics:InvalidWindowReview','Event intervals must be finite and within the recording.');
E=E(:,{'RecordingID',siteID,'EventID','StartSec','EndSec'});
E.OnsetInWindow=E.StartSec>=a&E.StartSec<b;
E.OverlapSec=max(0,min(E.EndSec,b)-max(E.StartSec,a));
E.AcquisitionStartOnset=E.OnsetInWindow&E.StartSec==0;
E.OngoingAtWindowStart=E.StartSec<a&E.EndSec>a;
area=numel(C.(support))*px^2;
dt=max(0,min((1:N)'/fs,b)-max((0:N-1)'/fs,a));expectedFrames=find(dt>0);
covered=sum(F.CoveredAreaTime_um2_sec);denominator=sum(F.AnalyzedTissueTime_um2_sec);
onsets=sum(E.OnsetInWindow);active=sum(E.OverlapSec);
values=nan(3,1);
if isfinite(denominator)&&denominator>0
    values=[covered/denominator;onsets*1e6*60/denominator;active*1e6/denominator];
end
stored=[W.MeanOccupiedTissueFraction;W.EventOnsetRate_per_mm2_per_min;W.MeanConcurrentEvents_per_mm2];
statuses=strings(3,1);for k=1:3,statuses(k)=compare(stored(k),values(k));end
Metrics=table(["BOI-M01";"BOI-M02";"BOI-M03"], ...
    ["Occupied tissue fraction";"Event onset rate";"Concurrent event density"], ...
    ["fraction";"events/mm²/min";"events/mm²"],stored,values,statuses, ...
    'VariableNames',{'MeasurementID','Measurement','Units','Saved','Replayed','ArithmeticStatus'});
Checks=table(strings(0,1),strings(0,1),'VariableNames',{'Check','Status'});
check('Frame coverage',isequal(F.Frame,expectedFrames));
check('Frame starts',same(F.ModeledStartSec,(F.Frame-1)/fs));check('Frame ends',same(F.ModeledEndSec,F.Frame/fs));
check('Clipped frame exposure',same(F.WindowOverlapSec,dt(F.Frame)));
check('Window duration',same(sum(F.WindowOverlapSec),b-a)&&same(W.DurationSec,b-a));
check('Tissue area from saved pixels',same(F.AnalyzedArea_um2,repmat(area,height(F),1)));
check('Per-frame tissue-time',same(F.AnalyzedTissueTime_um2_sec,F.AnalyzedArea_um2.*F.WindowOverlapSec));
check('Per-frame covered area-time',same(F.CoveredAreaTime_um2_sec,F.OccupiedArea_um2.*F.WindowOverlapSec));
check('Coverage within tissue',all(isnan(F.OccupiedArea_um2)|(isfinite(F.OccupiedArea_um2)&F.OccupiedArea_um2>=0&F.OccupiedArea_um2<=F.AnalyzedArea_um2+1e-9*max(1,area))));
check('Saved tissue-time sum',same(W.AnalyzedTissueTime_um2_sec,denominator)&&same(denominator,area*(b-a)));
check('Saved covered area-time sum',same(W.CoveredAreaTime_um2_sec,covered));
check('Saved event onset count',same(W.EventOnsets,onsets));check('Saved active event-time',same(W.ActiveEventSeconds,active));
if ismember('AcquisitionStartOnsetsCounted',W.Properties.VariableNames)
    check('Acquisition-boundary onset count',same(W.AcquisitionStartOnsetsCounted,sum(E.AcquisitionStartOnset)));
end
if ismember('OngoingAtWindowStart',W.Properties.VariableNames)
    check('Ongoing events at window start',same(W.OngoingAtWindowStart,sum(E.OngoingAtWindowStart)));
end
check('Recording analysis completed',string(Review.RecordingRegistry.AnalysisStatus(r))=="loaded");
QC=Review.RecordingInputQC;
QC=QC(string(QC.RecordingID)==string(W.RecordingID),:);
Exposure=Review.RecordingFrameExposure;
Exposure=Exposure(string(Exposure.RecordingID)==string(W.RecordingID),:);
check('Recording exposure frame coverage',isequal(sort(Exposure.Frame),(1:N)'));
camera=Exposure.CameraExposureSec;camera=camera(isfinite(camera));
cameraNote="Camera integration exposure: unavailable; not replaced with frame spacing.";
if ~isempty(camera)
    cameraNote="Camera integration exposure: "+min(camera)+"–"+max(camera)+" s on "+numel(camera)+"/"+N+" frames; distinct from frame spacing.";
end
Data=struct('EventType',char(kind),'Window',W,'Contract',C,'Frames',F,'Events',E,'RecordingExposure',Exposure,'QC',QC,'Metrics',Metrics, ...
    'Checks',Checks,'CoveredAreaTime',covered,'TissueTime',denominator,'ScientificStatus','not_established');
surgeNote="Saved surge window outcomes are unavailable in this export; they are not zero and are not inferred from sink results.";
if isfield(Review,'HasSurgeWindows')&&Review.HasSurgeWindows
    surgeNote="Separate surge window outcomes are available. Select each sign to inspect its own support and denominator; signs never cancel. No surge amplitude-area-time composite is defined.";
end
lines=["Recording: "+string(W.RecordingID)+" | window: "+string(W.WindowID)+" | "+string(kind); ...
    "Scientific eligibility: not established. Arithmetic agreement does not validate tissue or physiology."; ...
    surgeNote; ...
    "Window ["+a+", "+b+") seconds; duration "+(b-a)+" s. Fractional frame overlap is retained."; ...
    "Covered area-time = sum of native "+string(kind)+"-mask union area inside saved tissue × window overlap: "+covered+" µm²·s."; ...
    "Analyzed tissue-time = sum of saved tissue area × window overlap: "+denominator+" µm²·s."; ...
    "Occupied fraction = covered area-time / analyzed tissue-time = "+values(1)+" ("+100*values(1)+"%)."; ...
    "Onset rate = "+onsets+" onsets / "+denominator/1e6/60+" mm²·min = "+values(2)+" events/mm²/min."; ...
    "Concurrent density = "+active+" event-seconds / "+denominator/1e6+" mm²·s = "+values(3)+" events/mm²."; ...
    "Acquisition-boundary onsets counted: "+sum(E.AcquisitionStartOnset)+"; ongoing at window start: "+sum(E.OngoingAtWindowStart)+"."; ...
    "Onset policy: "+string(W.OnsetPolicy); ...
    "Occupancy availability: "+string(W.OccupancyStatus); ...
    "Timing: "+fs+" Hz; "+string(C.FrameTimingStatus)+". Camera exposure is separate from modeled frame intervals."; ...
    cameraNote; ...
    "Tissue: "+string(C.TissueValidityStatus)+". Selected "+string(kind)+" support "+numel(C.(support))+" pixels; supplied scale "+px+" µm/pixel."; ...
    "Surge support is separately retained ("+numel(C.SurgeEligibleTissuePixels)+" pixels); it is never replaced by sink support."; ...
    "No animal pooling, physiological onset decision or dynamic-validity acceptance is performed."; ...
    "The frame ledger replays saved union areas; it does not independently reconstruct all source masks.";"";"Saved issues:"];
for k=1:height(QC),lines=[lines;QC.IssueID(k)+": "+QC.Message(k);"Action: "+QC.Action(k)];end %#ok<AGROW>
lines=[lines;"";"Saved results SHA256: "+string(Review.SHA256);"Source SHA256: "+string(C.RawSHA256)];
Data.Details=cellstr(lines);
    function check(name,ok)
        status="match";if ~ok,status="mismatch";end
        Checks(end+1,:)={string(name),status};
    end
end
function ok=same(a,b)
ok=isequal(size(a),size(b))&&all((isnan(a(:))&isnan(b(:)))| ...
    (isfinite(a(:))&isfinite(b(:))&abs(a(:)-b(:))<=1e-9*max(1,abs(b(:)))));
end
function status=compare(a,b)
if isnan(a)&&isnan(b),status="unavailable";elseif same(a,b),status="match";else,status="mismatch";end
end
