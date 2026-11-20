function writeBOIRecordingInputAudit(Folder,Workbook,Contracts,QC,Frames,WindowFrames)
%WRITEBOIRECORDINGINPUTAUDIT Readable review plus exact evidence/denominators.
% Includes source declarations; ordinary stats output is a local research export.
writetable(QC,Workbook,'Sheet','RecordingInputQC');
if height(Frames)<=1048575
    writetable(Frames,Workbook,'Sheet','RecordingFrameExposure');
end
writetable(QC,fullfile(Folder,'RecordingInputQC.csv'));
writetable(Frames,fullfile(Folder,'RecordingFrameExposure.csv'));
writetable(WindowFrames,fullfile(Folder,'WindowFrameIngredients.csv'));
% Per-window rows can exceed Excel's sheet capacity for cohorts; CSV/MAT are
% authoritative. Do not silently truncate them to fit a worksheet.
if height(WindowFrames)<=1048575
    writetable(WindowFrames,Workbook,'Sheet','WindowFrameIngredients');
end
fid=fopen(fullfile(Folder,'RecordingInputContracts.json'),'w');assert(fid>=0);
clean=onCleanup(@()fclose(fid));fprintf(fid,'%s\n',jsonencode(Contracts,'PrettyPrint',true));clear clean
lines=["# Recording input and denominator review";""; ...
    "Contract: boi-recording-input-1; window audit: boi-window-exposure-1."; ...
    "These are descriptive calculations under a static tissue mask and uniform frame intervals. Technical consistency does not establish scientific eligibility.";""; ...
    "CameraExposureSec is acquisition integration duration when declared. NaN means unknown. FrameIntervalSec is the modeled spacing used by the calculations; it is never substituted for camera exposure.";""; ...
    "SourceClockTimeSec retains unvalidated or known-unreliable source metadata. It never drives detection or tissue-time calculations. Confirmed uniform sampling requires explicit acquisition evidence; its modeled frame grid is not relabelled as measured timestamps. Source review issues retain evidence and actions in the JSON contract and QC table.";""; ...
    "For each recording/window, sum CoveredAreaTime_um2_sec in WindowFrameIngredients.csv and divide by sum AnalyzedTissueTime_um2_sec. Overlapping sink masks count once inside the saved eligible tissue. The denominator describes assumed observable tissue-time, not independently validated motion-free exposure.";""; ...
    "AcquisitionStartEvents are counted by the existing descriptive onset rule. OnsetsAfterAcquisitionStart is a separate diagnostic count, not a replacement rate or an accepted physiological onset policy. OngoingAtWindowStart events contribute active time but are not new onsets in that window.";""; ...
    "The JSON contract retains original acquisition declarations and saved tissue-pixel indices. DataOutput.mat retains the same contracts, frame exposure and window ingredients. MATLAB indices are one-based in row/column image coordinates. Missing masks, zero tissue and unresolved onset interpretation remain explicit.";""];
lines=[lines; "When reviewed static support is supplied, TissueSnapshot retains the original source-bound declaration, actor, reason, evidence and UTC time. TissueSupportAudit retains the automatic mask and added/removed pixels. The selected mask replaces automatic support before candidate filtering and spatial bins; sink border exclusion still applies. The whole-image profile retains its original normalization and candidate outside-fraction rule. The craniotomy-roi-1 profile uses ROI spatial normalization, weighted included-neighbor smoothing and ROI-restricted candidate components; final native support is checked exactly. Quantification uses the new event footprint on preserved source pixels, with no post-hoc clipping. The effective profile for each recording is listed below and in RecordingInputContracts.json. Neighbor weights remain in both original master MAT files. A reviewed mask does not alone establish scientific eligibility or dynamic tissue validity."; ""];
for i=1:numel(Contracts)
    c=Contracts{i};
    if isfield(c,'DetectionSupportProfile')
        lines(end+1)="- " + string(c.RecordingID) + ": detection support " + string(c.DetectionSupportProfile) + ...
            "; normalization " + string(c.PipelineContract.Normalization) + "; schema " + string(c.PipelineContract.Schema) + ".";
    end
end
lines=[lines;"";"ROI-only spatial standardization may suppress a response shared across the ROI. Native source traces, unresolved boundaries and biological variability still require scientific review. This method is not an absolute oxygen estimator.";""];
for i=1:height(QC)
    lines(end+1)="- " + QC.RecordingID(i) + " / " + QC.IssueID(i) + " (" + QC.Disposition(i) + "): " + QC.Message(i) + " Action: " + QC.Action(i);
end
fid=fopen(fullfile(Folder,'RecordingInputReview.md'),'w');assert(fid>=0);
clean=onCleanup(@()fclose(fid));fprintf(fid,'%s\n',lines);
end
