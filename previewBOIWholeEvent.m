function Preview=previewBOIWholeEvent(E,P)
%PREVIEWBOIWHOLEEVENT Joint local excursion assessment of saved evidence only.
% E has full raw/corrected traces on the same fixed event footprint, SampleHz,
% SeedStartFrame/SeedEndFrame and optional NativeContact/NativeMaskPixels.
% Every P setting is explicit. No result can be passed to the burden exporter.
id='OxygenDynamics:WholeEventPreviewInput';
assert(isstruct(E)&&isscalar(E)&&isstruct(P)&&isscalar(P),id,'Supply one evidence and settings structure.');
required={'Raw','Corrected','SampleHz','SeedStartFrame','SeedEndFrame'};
assert(all(isfield(E,required)),id,'Saved raw/corrected traces, seed bounds and sampling rate are required.');
assert(isnumeric(E.Raw)&&isreal(E.Raw)&&isvector(E.Raw)&&isnumeric(E.Corrected)&&isreal(E.Corrected)&&isvector(E.Corrected),id,'Trace vectors must be real numeric data.');
raw=double(E.Raw(:));corrected=double(E.Corrected(:));N=numel(raw);
assert(N>=2&&numel(corrected)==N&&isscalar(E.SampleHz)&&isfinite(E.SampleHz)&&E.SampleHz>0,id,'Trace shapes or acquisition clock are invalid.');
seed=[E.SeedStartFrame E.SeedEndFrame];
assert(numel(seed)==2&&all(isfinite(seed)&seed==fix(seed))&&seed(1)>=1&&seed(1)<=seed(2)&&seed(2)<=N,id,'Seed bounds must be inside the saved trace.');
schema=boiWholeEventPreviewSettings;
assert(isequal(sort(fieldnames(P)),sort(fieldnames(schema)))&&strcmp(P.Version,schema.Version)&&isequal(P.ExperimentalOnly,true),id,'Use the explicit experimental settings contract.');
scalars={'LookBackSec','LookAheadSec','MinimumDipSec','RecoveryHoldSec','DipSigma','ReturnSigma','NoiseFloorPercent','MaximumBaselineDriftSigma','MaximumStageBoundaryDifferenceSec'};
for k=1:numel(scalars)
    v=P.(scalars{k});assert(isnumeric(v)&&isreal(v)&&isscalar(v)&&isfinite(v)&&v>0,id,'Settings must be finite positive scalars.');
end
assert(isnumeric(P.ReferenceDurationsSec)&&isreal(P.ReferenceDurationsSec)&&isvector(P.ReferenceDurationsSec)&& ...
    all(isfinite(P.ReferenceDurationsSec)&P.ReferenceDurationsSec>0)&&numel(unique(P.ReferenceDurationsSec))==numel(P.ReferenceDurationsSec)&& ...
    P.DipSigma>P.ReturnSigma,id,'Reference durations must be unique positive seconds; dip threshold must exceed return band.');
contact=optionalVector(E,'NativeContact',N);
assert(all(isnan(contact)|contact==0|contact==1),id,'Native contact must be known zero/one or unavailable (NaN).');
pixels=optionalVector(E,'NativeMaskPixels',N);
assert(all(isnan(pixels)|(isfinite(pixels)&pixels>=0&pixels==fix(pixels))),id,'Native pixel counts must be nonnegative integers or unavailable.');
fs=E.SampleHz;lo=max(1,seed(1)-floor(P.LookBackSec*fs));hi=min(N,seed(2)+floor(P.LookAheadSec*fs));
rows=cell(numel(P.ReferenceDurationsSec),1);
for k=1:numel(rows)
    seconds=P.ReferenceDurationsSec(k);L=max(2,ceil(seconds*fs));
    R=assessStage(raw,raw,contact,seed,lo,hi,fs,L,P);
    C=assessStage(corrected,raw,contact,seed,lo,hi,fs,L,P);
    status="no_complete_excursion";
    if R.Status=="complete"&&C.Status=="complete"
        delta=max(abs([R.OnsetFrame-C.OnsetFrame R.RecoveryFrame-C.RecoveryFrame]))/fs;
        if delta>P.MaximumStageBoundaryDifferenceSec,status="raw_corrected_boundary_disagreement";
        elseif ~R.BaselineScreened||~C.BaselineScreened,status="trace_candidate_reference_screening_unavailable";
        else,status="complete_trace_candidate";end
    elseif xor(R.Status=="complete",C.Status=="complete")
        status="raw_corrected_disagreement";
    elseif R.Status==C.Status,status=R.Status;
    else,status="unresolved_stage_disagreement";end
    spatial="unavailable";supported=sum(isfinite(pixels(seed(1):seed(2)))&pixels(seed(1):seed(2))>0);
    if all(isfinite(pixels(seed(1):seed(2))))
        spatial="no_native_support_at_seed";if supported>0,spatial="saved_native_support_only";end
    end
    if status=="complete_trace_candidate"&&spatial~="saved_native_support_only"
        status="trace_candidate_spatial_unavailable";
    end
    rows{k}=struct('ReferenceSec',seconds,'ReferenceSamples',L,'Status',status,'Raw',R,'Corrected',C, ...
        'SpatialStatus',spatial,'SupportedSeedFrames',supported);
end
Preview=struct('Schema',P.Version,'Role','experimental_preview_only','ScientificAcceptance',false, ...
    'Settings',P,'SeedStartFrame',seed(1),'SeedEndFrame',seed(2),'ContextStartFrame',lo, ...
    'ContextEndFrame',hi,'NFrames',N,'SampleHz',fs,'Candidates',vertcat(rows{:}), ...
    'BaselinePolicy','Individual contiguous pre-onset window; nearest supported departure, not largest amplitude or best recovery.', ...
    'RecoveryPolicy','First sustained return inside the reference noise band; first return sample is reported.', ...
    'SpatialQualification','Counts indicate existing native support only; spatial coherence and full-event area are not validated.', ...
    'Limitations',{{'Current spatial seeds and fixed footprints cannot reveal pockets missed by the candidate generator.', ...
    'Experimental thresholds are not validated biological criteria. No correction or background model is adopted.', ...
    'Unknown overlap, nonfinite samples and recording/context limits remain explicit.', ...
    'No burden, event membership, saved boundary, reference or scientific result is changed.'}}, ...
    'BurdenCalculated',false,'OriginalResultsChanged',false,'NewCorrectionFits',0);
end

function v=optionalVector(E,name,N)
v=nan(N,1);if ~isfield(E,name)||isempty(E.(name)),return;end
x=E.(name);assert((isnumeric(x)||islogical(x))&&isreal(x)&&isvector(x)&&numel(x)==N, ...
    'OxygenDynamics:WholeEventPreviewInput','Optional evidence vectors must span the full saved recording.');
v=double(x(:));
end

function S=assessStage(y,raw,contact,seed,lo,hi,fs,L,P)
S=struct('Status',"baseline_unresolved",'OnsetFrame',NaN,'RecoveryFrame',NaN, ...
    'RecoveryConfirmedThroughFrame',NaN,'ReferenceStartFrame',NaN,'ReferenceEndFrame',NaN, ...
    'ReferenceMean',NaN,'ReferenceNoise',NaN,'RawReferenceMean',NaN, ...
    'BaselineSlopePerSec',NaN,'BaselineScreened',false,'MinimumFrame',NaN,'DepthInputUnits',NaN, ...
    'SustainedDipRuns',0,'BaselineWindowsExamined',0,'BaselineWindowsUsable',0, ...
    'BaselineDriftWindows',0,'ContaminatedWindows',0,'NonfiniteWindows',0,'Message',"");
dipN=max(1,ceil(P.MinimumDipSec*fs));holdN=max(1,ceil(P.RecoveryHoldSec*fs));
if seed(1)==1
    S.Status="left_censored";S.Message="Recording begins without a pre-event reference; no recovered window is substituted.";return
end
if seed(1)<=L
    S.Status="insufficient_acquired_reference";S.Message="Fewer acquired pre-event samples than this reference requires.";return
end
for a=seed(1):-1:max(lo,L+1)
    b=(a-L):(a-1);S.BaselineWindowsExamined=S.BaselineWindowsExamined+1;
    if any(~isfinite(y(b)))||any(~isfinite(raw(b)))
        S.NonfiniteWindows=S.NonfiniteWindows+1;continue
    end
    if any(contact(b)==1),S.ContaminatedWindows=S.ContaminatedWindows+1;continue;end
    rawB=mean(raw(b));if rawB<=0,continue;end
    B=mean(y(b));d=diff(y(b));sigma=median(abs(d-median(d)))/(.674489750196082*sqrt(2));
    sigma=max(sigma,P.NoiseFloorPercent/100*rawB);
    fit=polyfit((0:L-1)'/fs,y(b),1);
    if abs(fit(1))*(L-1)/fs>P.MaximumBaselineDriftSigma*sigma
        S.BaselineDriftWindows=S.BaselineDriftWindows+1;continue
    end
    S.BaselineWindowsUsable=S.BaselineWindowsUsable+1;
    if ~isfinite(y(a))||y(a)>=B-P.ReturnSigma*sigma,continue;end
    % A missing value is a barrier; never bridge it to claim recovery.
    stop=hi;bad=find(~isfinite(y(a:hi))|~isfinite(raw(a:hi)),1);
    if ~isempty(bad),stop=a+bad-2;end
    if stop<a,continue;end
    f=(a:stop)';v=y(f);below=v<B-P.DipSigma*sigma;
    dipStarts=runStarts(below,dipN);
    if isempty(dipStarts),continue;end
    recovered=abs(v-B)<=P.ReturnSigma*sigma;
    recoveryStarts=runStarts(recovered,holdN);
    if ~isempty(recoveryStarts)&&recoveryStarts(1)<dipStarts(1),continue;end
    recoveryStarts=recoveryStarts(recoveryStarts>dipStarts(1)+dipN-1);
    r=[];if ~isempty(recoveryStarts),r=a+recoveryStarts(1)-1;end
    % The excursion must reach the selected original seed, not a prior pocket.
    if ~isempty(r)&&r<=seed(1),continue;end
    if a+dipStarts(1)-1>seed(2),continue;end
    S.OnsetFrame=a;S.ReferenceStartFrame=b(1);S.ReferenceEndFrame=b(end);
    S.ReferenceMean=B;S.ReferenceNoise=sigma;S.RawReferenceMean=rawB;
    S.BaselineSlopePerSec=fit(1);S.BaselineScreened=all(isfinite(contact(b)));
    last=stop;if ~isempty(r),last=r-1;end
    [minimum,j]=min(y(a:last));S.MinimumFrame=a+j-1;S.DepthInputUnits=B-minimum;
    S.SustainedDipRuns=numel(runStarts(y(a:last)<B-P.DipSigma*sigma,dipN));
    if ~isempty(r)
        S.RecoveryFrame=r;S.RecoveryConfirmedThroughFrame=r+holdN-1;S.Status="complete";
        S.Message="Sustained dip and return found on this trace; thresholds remain experimental.";
    elseif ~isempty(bad)
        S.Status="nonfinite_signal";S.Message="A missing sample prevents a continuous dip-to-recovery assessment.";
    elseif hi==numel(y)
        S.Status="right_censored";S.Message="No sustained return observed before the recording ends.";
    else
        S.Status="recovery_outside_context_or_absent";S.Message="No sustained return within the explicit look-ahead horizon.";
    end
    return % Never try older references merely to obtain a nicer recovery.
end
if S.BaselineWindowsUsable>0
    S.Status="no_sustained_dip";S.Message="Usable pre-event context found, but no associated sustained excursion meets these settings.";
elseif S.BaselineDriftWindows>0
    S.Status="baseline_drift";S.Message="Candidate pre-event windows drift beyond the experimental tolerance; no trend is removed.";
elseif S.NonfiniteWindows>0
    S.Status="nonfinite_reference";S.Message="Missing samples prevent a complete pre-event reference.";
else
    S.Message="No complete uncontaminated pre-event reference in the explicit context.";
end
end

function first=runStarts(mask,required)
mask=logical(mask(:));starts=find(diff([false;mask])==1);ends=find(diff([mask;false])==-1);
first=starts(ends-starts+1>=required);
end
