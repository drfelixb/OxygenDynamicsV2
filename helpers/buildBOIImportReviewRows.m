function [Rows,Details]=buildBOIImportReviewRows(Reviews,Mice)
%BUILDBOIIMPORTREVIEWROWS Plain-language rendering shared by UI verification.
Rows=cell(numel(Reviews),6);Details=cell(numel(Reviews),1);
for i=1:numel(Reviews)
    R=Reviews{i};input='Readable; review open';timing='Not assessed';tissue='Not assessed';
    if strcmp(R.Status,'import_failure'),input='Import failed';
    elseif ~R.InputCompatible,input='Held: unsupported input';end
    if isfield(R.Acquisition,'FrameTimingStatus')
        timing=sprintf('Assumed uniform: %g Hz',R.SampleHz);
        switch R.Acquisition.FrameTimingStatus
            case 'uniform_confirmed_from_acquisition_evidence'
                timing=sprintf('Confirmed uniform: %g Hz',R.SampleHz);
            case 'declared_uniform_compatible'
                timing=sprintf('Declared uniform: %g Hz',R.SampleHz);
            otherwise
                if ~R.InputCompatible,timing='Inspect acquisition evidence';end
        end
    end
    if ~isempty(R.TissueSnapshot)
        tissue='Automatic estimate; unreviewed';
        if strcmp(R.TissueSnapshot.State,'captured'),tissue='Reviewed mask declared';end
    end
    Rows(i,:)={i,char(string(Mice(i))),input,timing,tissue,'Not established'};
    acquisitionLines=strings(0,1);
    if isfield(R.Acquisition,'CameraExposureSec')
        A=R.Acquisition;known=A.CameraExposureSec(isfinite(A.CameraExposureSec));exposure="unknown";
        if ~isempty(known)
            exposure=string(min(known)) + " to " + string(max(known)) + " s";
            if all(known==known(1)),exposure=string(known(1)) + " s";end
            exposure=exposure + " (declared for " + numel(known) + "/" + numel(A.CameraExposureSec) + " frames)";
        end
        acquisitionLines=["Declared source ID: " + string(A.SourceID);"Selected series: " + string(A.SelectedSeries); ...
            "Declared source axes: " + string(A.SourceAxes); ...
            "Sampling evidence: " + string(A.SamplingRateEvidence); ...
            "Camera exposure: " + exposure + "; distinct from frame spacing"; ...
            "Exposure evidence: " + string(A.ExposureEvidence); ...
            "Pixel calibration evidence: " + string(A.PixelSizeEvidence); ...
            "Intensity history: " + string(A.IntensityHistory); ...
            "Motion-correction history: " + string(A.MotionCorrectionHistory)];
    end
    text=["Recording: " + string(Mice(i));"Scientific eligibility: not established"; ...
        "Input: " + string(input);"Sampling: " + string(timing);"Tissue: " + string(tissue); ...
        acquisitionLines(startsWith(acquisitionLines,"Camera exposure:")); ...
        "";"Evidence and required actions:"];
    priority=3*ones(height(R.QC),1);
    priority(startsWith(R.QC.IssueID,"SOURCE-"))=1;
    priority(contains(R.QC.IssueID,"TISSUE"))=2;
    priority(R.QC.Disposition~="review")=0;
    [~,order]=sort(priority);
    for j=order(:)'
        disposition=replace(R.QC.Disposition(j),"_"," ");
        text=[text;"";upper(disposition) + " — " + R.QC.IssueID(j); ...
            "Affects: " + R.QC.AffectedMeasurements(j);R.QC.Message(j);"Action: " + R.QC.Action(j)]; %#ok<AGROW>
    end
    text=[text;"";"Source and acquisition details:"; ...
        "Quantification source: " + string(R.Files.RawFile); ...
        "Detection uses the denoised TIFF when supplied; otherwise the preserved input TIFF."; ...
        "Denoised source: " + string(R.Files.DenoisedFile); ...
        "Source SHA-256: " + string(R.RawSHA256); ...
        "Pixel size supplied: " + string(R.PixelSizeUm) + " um/pixel; independent calibration is a separate review."; acquisitionLines; ...
        "";"This review reads current inputs. It does not change an earlier master or establish that existing output folders are scientifically accepted. Statistics separately checks saved source identity, settings and declarations."; ...
        "Acquisition-reference candidates are distinct from historical analysis outputs. Exploratory AQuA2 outputs are not evidence of a reviewed anatomical mask."; ...
        "Exact captured declarations and their evidence are retained in the verification MAT/JSON export."];
    Details{i}=cellstr(text);
end
end
