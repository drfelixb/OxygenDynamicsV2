function V=loadBOIReviewedBurdenEvent(Folder)
% Validate a saved, explicitly reviewed single-event contribution for import.
id='OxygenDynamics:ReviewedBurdenEvent';Folder=char(java.io.File(Folder).getCanonicalPath());
status=jsondecode(fileread(fullfile(Folder,'Status.json')));assert(strcmp(status.Status,'complete'),id,'Single-event result is incomplete.');
manifestPath=fullfile(Folder,'Checksums.json');manifestHash=oxygenFileSHA256(manifestPath);
manifest=jsondecode(fileread(manifestPath));assert(~isempty(manifest),id,'Missing event artifact checksums.');
for k=1:numel(manifest)
    p=char(java.io.File(fullfile(Folder,manifest(k).Path)).getCanonicalPath());
    assert(startsWith(p,[Folder filesep])&&strcmp(oxygenFileSHA256(p),manifest(k).SHA256),id,'A saved event artifact changed.');
end
assert(any(strcmp({manifest.Path},'ReviewedEventBurden.json')),id,'Event JSON is not in the manifest.');
S=jsondecode(fileread(fullfile(Folder,'ReviewedEventBurden.json')));
areaRevision=strcmp(S.Schema,'boi-reviewed-single-event-burden-2');
assert((strcmp(S.Schema,'boi-reviewed-single-event-burden-1')||areaRevision)&&strcmp(S.EventType,'sink')&& ...
    ~S.OriginalResultsChanged&&~S.GlobalDefaultsChanged&&~S.RecordingTotalCalculated&&~S.PartialSumCalculated,id,'Unsupported single-event result.');
R=loadBOIEventReview(S.AuditPath);assert(strcmp(R.AuditSHA256,S.AuditSHA256)&&strcmp(R.AnalysisInfo.RawSHA256,S.RawSourceSHA256),id,'Saved source differs.');
R.BoundaryReview=loadBOIBoundaryReview(R,S.BoundaryPath);assert(strcmp(R.BoundaryReview.SHA256,S.BoundarySHA256),id,'Boundary revision differs.');
R=loadBOIReferenceJudgments(R,{S.ReferencePath});assert(isscalar(R.ReferenceJudgments)&&strcmp(R.ReferenceJudgments.SHA256,S.ReferenceSHA256),id,'Reference revision differs.');
ix=S.AuditRow;B=getBOIBoundaryReview(R,ix);a=R.Audit(ix,:);
assert(string(a.RecordingID)==string(S.RecordingID)&&string(a.EventType)=="sink"&&a.SiteID==S.SiteID&&a.EventID==S.EventID&& ...
    strcmp(B.Status,'recognized')&&B.Annotation.PreferredOnsetFrame==S.StartFrame&&B.Annotation.PreferredRecoveryFrame==S.EndFrame, ...
    id,'Reviewed recognition or preferred boundaries differ.');
f=R.ReferenceJudgments.Frames;
assert(numel(f)==S.ReferenceSamples&&f(1)==S.ReferenceStartFrame&&f(end)==S.ReferenceEndFrame&& ...
    a.StartFrame==S.OriginalAutomaticStartFrame&&a.EndFrame==S.OriginalAutomaticEndFrame,id,'Reference or automatic identity differs.');
M=computeBOIReviewedOpticalInterval(R.Traces{ix}.Raw,f,S.StartFrame,S.EndFrame,R.AnalysisInfo.AnalysisParams.fs,'sink');
assert(strcmp(M.Status,'computed_exploratory'),id,'Reviewed arithmetic is unavailable.');
amp=100*M.SavedSignDirectionalAmplitudeFraction;A=S.BurdenRecordingArea_um2;D=S.BurdenRecordingDuration_sec;
if areaRevision
    for name={'BurdenArea_um2','PerEventBurdenContribution','PerEventBurdenContribution_per_mm2_per_min'}
        if isempty(S.(name{1})),S.(name{1})=NaN;end % JSON null means unavailable.
        assert(isnumeric(S.(name{1}))&&isscalar(S.(name{1})),id,'Invalid optional area/burden scalar.');
    end
    areaPath=char(java.io.File(fullfile(Folder,S.AreaReviewFile)).getCanonicalPath());
    assert(startsWith(areaPath,[Folder filesep]),id,'Area revision must be inside the event artifact.');
    areaStore=loadBOIAreaReview(areaPath);C=areaStore.Document.Context;Q=areaStore.Measures;
    assert(strcmp(areaStore.SHA256,S.AreaReviewSHA256)&&strcmp(C.AuditSHA256,S.AuditSHA256)&&C.AuditRow==ix&& ...
        strcmp(C.BoundarySHA256,S.BoundarySHA256)&&strcmp(C.ReferenceSHA256,S.ReferenceSHA256)&& ...
        C.Frames(1)==S.StartFrame&&C.Frames(end)==S.EndFrame&&C.DurationSec==S.DurationSec&& ...
        C.RecordingAreaUm2==A&&C.RecordingDurationSec==D&&abs(C.AmplitudePercent-amp)<1e-9&& ...
        strcmp(Q.Status,S.AreaStatus)&&S.AreaMeanFrameCount==numel(C.Frames)&&S.ReviewedAreaFrames==Q.ReviewedFrames&& ...
        sameNumber(S.OriginalAutomaticArea_um2,C.OriginalAutomaticAreaUm2)&& ...
        sameNumber(S.BurdenArea_um2,Q.MeanAreaUm2)&&sameNumber(S.PerEventBurdenContribution,Q.Contribution)&& ...
        sameNumber(S.PerEventBurdenContribution_per_mm2_per_min,Q.NormalizedContribution),id,'Reviewed area or missingness does not replay.');
else
    assert(isfinite(S.BurdenArea_um2)&&S.BurdenArea_um2>0,id,'Invalid legacy event area.');
end
area=S.BurdenArea_um2;
assert(all(isfinite([amp A D]))&&amp>=0&&all([A D]>0)&& ...
    (isnan(area)||(isfinite(area)&&area>=0)),id,'Invalid event amplitude, area or exposure.');
product=amp*area*M.DurationSec;
expected=[M.ReferenceMean,min(M.EventValues),amp,M.DurationSec,product,product*(1e6/A)*(60/D)];
actual=[S.RawReferenceMean,S.RawMinimum,S.BurdenAmplitudePercent,S.DurationSec,S.PerEventBurdenContribution,S.PerEventBurdenContribution_per_mm2_per_min];
assert(all(arrayfun(@sameNumber,actual,expected)),id,'Saved event values do not replay from the approved source/reference.');
assert(strcmp(manifestHash,oxygenFileSHA256(manifestPath)),id,'Event manifest changed while loading.');
V=struct('Path',Folder,'ManifestSHA256',manifestHash,'Document',S);
end
function yes=sameNumber(a,b)
yes=(isnan(a)&&isnan(b))||(isfinite(a)&&isfinite(b)&&abs(a-b)<=1e-9+1e-12*abs(b));
end
