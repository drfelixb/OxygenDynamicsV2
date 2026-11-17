function lines=formatBOIWorkflowPreflight(Request)
%FORMATBOIWORKFLOWPREFLIGHT Readable view of the validated, saved request.
o=Request.Options;r=Request.InputReview;a=r.Acquisition;
lines={ ...
    'RECORDING AND SUPPORT', ...
    ['Source folder: ' o.RecordingFolder], ...
    ['Source ID: ' char(string(a.SourceID))], ...
    sprintf('Image series: %d frames | raw SHA-256: %s',r.Files.RawTiffInfo.Frames,r.RawSHA256), ...
    sprintf('Frame schedule: %.9g Hz | %s',o.SampleHz,strrep(a.FrameTimingStatus,'_',' ')), ...
    ['Timing authority/evidence: ' char(string(a.SamplingRateEvidence))], ...
    sprintf('Pixel calibration: %.9g µm/pixel | evidence: %s',o.PixelSizeUm,char(string(a.PixelSizeEvidence))), ...
    ['Tissue support: ' o.SupportProfile ' | ' strrep(r.TissueStatus,'_',' ')], ...
    'Scientific eligibility: not established.', ...
    'OUTPUT AND EFFECTIVE SETTINGS', ...
    ['New output directory: ' o.OutputFolder], ...
    'This directory must not exist. Earlier runs are never overwritten.', ...
    'The established correction, detector and measurements are used without tuning.'};
for f=fieldnames(Request.SettingOrigins)'
    name=f{1};value=o.(name);
    if isnumeric(value),value=num2str(value,17);end
    lines{end+1}=sprintf('%s: %s [%s]',name,char(string(value)),Request.SettingOrigins.(name)); %#ok<AGROW>
end
for f=fieldnames(Request.AnalysisParams)'
    value=Request.AnalysisParams.(f{1});
    if isnumeric(value)&&isscalar(value)
        lines{end+1}=sprintf('%s: %.9g [established detector default]',f{1},value); %#ok<AGROW>
    end
end
lines{end+1}='REQUIRED CORRECTION';
blocked=r.QC.Disposition=="hold_recording" | r.QC.Disposition=="import_failure";
if ~any(blocked),lines{end+1}='None in this input review; Run may proceed after confirmation.';end
for k=find(blocked)'
    lines{end+1}=sprintf('%s: %s Action: %s',r.QC.IssueID(k),r.QC.Message(k),r.QC.Action(k)); %#ok<AGROW>
end
lines{end+1}='SCIENTIFIC WARNINGS (do not block Run)';
warn=r.QC.Disposition=="review" & r.QC.IssueID~="R1-EXPOSURE-UNKNOWN";
if ~any(warn),lines{end+1}='None recorded in this input review.';end
for k=find(warn)'
    lines{end+1}=sprintf('%s: %s Action: %s',r.QC.IssueID(k),r.QC.Message(k),r.QC.Action(k)); %#ok<AGROW>
end
lines{end+1}='UNAVAILABLE INFORMATION (not zero)';
if strcmp(a.ExposureStatus,'unknown')
    lines{end+1}='Camera exposure duration: unknown; separate from the frame interval.';
end
if strcmp(a.SourceID,'unknown'),lines{end+1}='Declared source ID: unknown.';end
if strcmp(a.SamplingRateEvidence,'unknown')
    lines{end+1}='Independent sampling-rate evidence: unknown; the supplied rate models elapsed time.';
end
if strcmp(a.PixelSizeEvidence,'unknown'),lines{end+1}='Independent pixel-calibration evidence: unknown.';end
end
