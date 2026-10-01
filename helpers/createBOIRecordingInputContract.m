function [Contract,QC,Frames] = createBOIRecordingInputContract(Info,RecordingID,FrameSize)
%CREATEBOIRECORDINGINPUTCONTRACT Audit saved source, time model and native tissue.
% Numerical consistency is not scientific eligibility. No live sidecar lookup.
N=Info.NFrames;fs=Info.AnalysisParams.fs;px=Info.AnalysisParams.PixelSize;
assert(numel(FrameSize)==2&&all(isfinite(FrameSize))&&all(FrameSize>=1)&&all(FrameSize==fix(FrameSize)), ...
    'OxygenDynamics:InvalidInputContract','Two positive image dimensions are required.');
assert(isscalar(px)&&isfinite(px)&&px>0,'OxygenDynamics:InvalidInputContract','Positive pixel calibration is required.');
Snapshot=[];if isfield(Info,'BOIAcquisitionMetadata'),Snapshot=Info.BOIAcquisitionMetadata;end
[Contract,QC]=resolveBOIAcquisitionMetadata(Snapshot,N,fs,Info.RawSHA256);
Contract.RecordingID=char(string(RecordingID));Contract.NFrames=N;Contract.SampleHz=fs;
Contract.PixelSizeUm=px;Contract.FrameSize=FrameSize(:)';Contract.DecodedAxes='row,column,frame';
Contract.RawSHA256=Info.RawSHA256;Contract.DenoisedSHA256=Info.DenoisedSHA256;
Contract.QuantificationSource='preserved_input_TIFF';
Contract.DetectionSource='preserved_input_TIFF';
if ~isempty(Info.DenoisedSHA256),Contract.DetectionSource='separate_denoised_TIFF';end
Contract.ModelTimeOrigin='first_image_interval_start_is_zero; not an aligned acquisition clock';
Contract.ExposureBasis='uniform_frame_intervals_not_camera_integration_duration';
Contract.TissueMaskSource='saved_intensity_derived_static_mask; sign_specific_border_support';
Contract.TissueValidityStatus='static_mask_not_independently_validated';
Contract.ScientificEligibility='not_established_by_input_contract';
Contract.AcquisitionSnapshot=Snapshot;
TissueSnapshot=[];
if isfield(Info,'BOITissueSupport'),TissueSnapshot=Info.BOITissueSupport;end
[ReviewedMask,TissueDecision]=resolveBOITissueSupport(TissueSnapshot,FrameSize,Info.RawSHA256);
Contract.TissueSnapshot=TissueSnapshot;
Contract.TissueSupportExtension='boi-static-tissue-support-1';
Contract.TissueDecision=TissueDecision;
for sign={'Sink','Surge'}
    name=[sign{1} 'EligibleTissuePixels'];v=Info.(name);
    assert(isnumeric(v)&&(isempty(v)||isvector(v))&&all(isfinite(v))&&all(v==fix(v))&&all(v>=1)&& ...
        all(v<=prod(FrameSize))&&numel(unique(v))==numel(v), ...
        'OxygenDynamics:InvalidTissueSupport','Saved tissue pixels must be unique, one-based indices inside the image.');
    Contract.(name)=v(:);
end
A=numel(Contract.SinkEligibleTissuePixels)*px^2;
assert(isfinite(Info.RecordingAreaUm2)&&abs(A-Info.RecordingAreaUm2)<=1e-9*max(1,A), ...
    'OxygenDynamics:TissueAreaMismatch','Saved sink area disagrees with eligible mask and pixel calibration.');
if isfield(Info,'SurgeRecordingAreaUm2')
    surgeA=numel(Contract.SurgeEligibleTissuePixels)*px^2;
    assert(isfinite(Info.SurgeRecordingAreaUm2)&&abs(surgeA-Info.SurgeRecordingAreaUm2)<=1e-9*max(1,surgeA), ...
        'OxygenDynamics:TissueAreaMismatch','Saved surge area disagrees with eligible mask and pixel calibration.');
end
if isempty(ReviewedMask)
    QC(end+1,:)={"R1-STATIC-TISSUE","review","Occupied fraction, area-normalized rates and cross-acquisition comparison", ...
        "Analyzed tissue is a static intensity-derived mask with sign-specific support; dynamic tissue validity is not established.", ...
        "Inspect motion, borders and tissue coverage before final eligibility. Unusual event morphology alone is not an exclusion."};
else
    ExpectedSink=false(FrameSize);border=Info.AnalysisParams.Pixel_frame;
    ExpectedSink(border+1:end-border,border+1:end-border)=ReviewedMask(border+1:end-border,border+1:end-border);
    assert(isequal(sort(Contract.SurgeEligibleTissuePixels),find(ReviewedMask))&& ...
        isequal(sort(Contract.SinkEligibleTissuePixels),find(ExpectedSink)), ...
        'OxygenDynamics:TissueDecisionMismatch','Saved eligible pixels disagree with the source-bound mask and sign-specific border rule.');
    assert(isfield(Info,'TissueSupportAudit'),'OxygenDynamics:TissueDecisionMismatch','Automatic-to-reviewed support comparison is missing.');
    Audit=Info.TissueSupportAudit;
    Auto=false(FrameSize);v=Audit.AutomaticTissuePixels;
    assert(isnumeric(v)&&(isempty(v)||isvector(v))&&all(isfinite(v))&&all(v==fix(v))&& ...
        all(v>=1)&&all(v<=prod(FrameSize))&&numel(unique(v))==numel(v), ...
        'OxygenDynamics:TissueDecisionMismatch','Invalid saved automatic support.');
    Auto(v)=true;
    assert(strcmp(Audit.Schema,'boi-tissue-support-application-1')&& ...
        isequal(Audit.AddedPixels(:),find(ReviewedMask & ~Auto))&& ...
        isequal(Audit.RemovedPixels(:),find(~ReviewedMask & Auto)), ...
        'OxygenDynamics:TissueDecisionMismatch','Saved support-change ledger disagrees with the masks.');
    Contract.TissueSupportAudit=Audit;
    Contract.TissueMaskSource='source_bound_reviewed_static_mask; sign_specific_border_support';
    Contract.TissueValidityStatus='reviewed_static_support_declared; dynamic_validity_not_established';
    QC(end+1,:)={"R1-REVIEWED-TISSUE","review","Occupied fraction, area-normalized rates and candidate support", ...
        "Static support decision " + string(TissueDecision.DecisionID) + " by " + string(TissueDecision.Actor) + ...
        ". Evidence: " + string(TissueDecision.Evidence) + ". Alignment: " + string(TissueDecision.AlignmentEvidence), ...
        "Assess the declared evidence and motion over time. Existing candidate overlap limits remain; native event footprints and amplitudes are not clipped to tissue. A declaration does not establish scientific eligibility."};
end
if strcmp(getBOISupportProfile(Info),'craniotomy-roi-1')
    q=find(QC.IssueID=="R1-REVIEWED-TISSUE");
    QC.Action(q)="Assess anatomy and motion over time. ROI normalization and candidate intersection precede component filtering; final native containment is required. Source quantification uses the resulting event footprint. Physiological eligibility remains unresolved.";
end
if A==0
    QC(end+1,:)={"R1-ZERO-TISSUE","measurement_unavailable","Sink area-normalized summaries", ...
        "The saved sink tissue mask has zero area; a normalized value cannot be calculated.", ...
        "Review tissue eligibility. Do not report unavailable normalized measurements as zero."};
end
QC.RecordingID=repmat(string(RecordingID),height(QC),1);
Frame=(1:N)';ModeledStartSec=(Frame-1)/fs;ModeledEndSec=Frame/fs;FrameIntervalSec=ones(N,1)/fs;
Frames=table(repmat(string(RecordingID),N,1),Frame,ModeledStartSec,ModeledEndSec,FrameIntervalSec, ...
    Contract.DeclaredFrameTimesSec,Contract.CameraExposureSec,Contract.DeclaredFrameValid,true(N,1), ...
    repmat(A,N,1),repmat(numel(Contract.SurgeEligibleTissuePixels)*px^2,N,1), ...
    'VariableNames',{'RecordingID','Frame','ModeledStartSec','ModeledEndSec','FrameIntervalSec', ...
    'DeclaredFrameTimeSec','CameraExposureSec','DeclaredFrameValid','ModeledFrameIncluded','SinkAnalyzedArea_um2','SurgeAnalyzedArea_um2'});
Frames.SourceClockTimeSec=Contract.SourceClockTimesSec;
end
