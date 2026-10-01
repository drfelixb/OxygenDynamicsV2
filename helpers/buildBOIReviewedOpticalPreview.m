function O=buildBOIReviewedOpticalPreview(Review,Index)
%BUILDBOIREVIEWEDOPTICALPREVIEW Separate exploratory results, never original Data.
D=getBOIReviewedOpticalDefinition;
P=buildBOIReviewedReferencePreview(Review,Index); % Revalidate audit, boundaries, judgments and both masters.
O=struct('Schema','boi-reviewed-optical-preview-1','Status','no_saved_interval','Message','Load saved onset and recovery frames.', ...
    'Role','exploratory_optical_calculation_no_global_scientific_adoption','Definition',D,'AuditPath',Review.AuditPath, ...
    'AuditSHA256',Review.AuditSHA256,'RawSourceSHA256',Review.AnalysisInfo.RawSHA256,'SampleHz',Review.AnalysisInfo.AnalysisParams.fs, ...
    'AcquisitionEvidence',Review.Acquisition,'AcquisitionQC',Review.QC,'FrameOrigin',1, ...
    'FixedFootprint',double(Review.Traces{Index}.Footprint(:)),'OriginalAutomatic',table2struct(Review.Audit(Index,:)), ...
    'ReferenceEvidence',P,'Intervals',[],'NewReferenceMeansOrAmplitudesCalculated',false);
if isempty(P.BoundaryReview.Annotation)||isempty(P.BoundaryReview.Annotation.OnsetFrames)||isempty(P.BoundaryReview.Annotation.RecoveryFrames),return;end
if ~strcmp(P.Status,'available')
    O.Status='native_sources_required';O.Message='Attach both matching native masters in Reviewed reference to bind support and overlap context.';return;
end
fs=O.SampleHz;
assert(fs==1,'OxygenDynamics:ReviewedOpticalClock','This reviewed calculation increment is verified for externally triggered 1 Hz recordings only.');
records={};a=P.BoundaryReview.Annotation;
for onset=a.OnsetFrames(:)'
    w=P.Windows([P.Windows.OnsetFrame]==onset);
    for recovery=a.RecoveryFrames(:)'
        M=computeBOIReviewedOpticalInterval(Review.Traces{Index}.Raw,w.ResearcherReferenceFrames,onset,recovery,fs,O.OriginalAutomatic.EventType);
        M.PreferredOnset=ismember(onset,a.PreferredOnsetFrame);M.PreferredRecovery=ismember(recovery,a.PreferredRecoveryFrame);
        M.RecognitionStatus=a.Status;M.OriginalRequiredReferenceSamples=w.RequiredSamples;
        M.MeetsOriginalSampleCount=w.ResearcherMeetsOriginalSampleCount;
        M.NativeEligibleWithinSelectedReference=w.ResearcherNativeEligibleCount;
        M.OriginalImmediateNativeEligibleCount=w.OptionAEligibleCount;
        M.Judgment=[];
        if ~isempty(P.ResearcherJudgments),M.Judgment=P.ResearcherJudgments([P.ResearcherJudgments.OnsetFrame]==onset);end
        records{end+1}=M; %#ok<AGROW>
    end
end
O.Intervals=vertcat(records{:});O.Status='available';O.Message='Exploratory reviewed optical results; original measurements and recognition are unchanged.';
O.NewReferenceMeansOrAmplitudesCalculated=any(isfinite([O.Intervals.ReferenceMean]));
end
