function Report = runBOIHPInputPreflight(EvidenceRoot)
%RUNBOIHPINPUTPREFLIGHT Verify R1-HP-INPUT-001 on a staged, unchanged source.
% No detector, image display, source edits, or biological acceptance.
RepoRoot=fileparts(fileparts(fileparts(mfilename('fullpath'))));
addpath(RepoRoot);setupOxygenDynamicsPath;
Started=tic;
Manifest=jsondecode(fileread(fullfile(EvidenceRoot,'stage-manifest.json')));
RecordingFolder=fileparts(Manifest.staged_path);
OutputFolder=fullfile(EvidenceRoot,'matlab-preflight');
assert(~isfolder(OutputFolder),'Preserve the existing preflight; use a new evidence folder.');
mkdir(OutputFolder);
assert(strcmp(oxygenFileSHA256(Manifest.staged_path),Manifest.sha256),'Staged source hash mismatch.');
Review=reviewBOIRecordingInput(RecordingFolder,Manifest.sample_hz,Manifest.pixel_size_um);
save(fullfile(OutputFolder,'InputReview.mat'),'Review','Manifest','-v7.3');
writetable(Review.QC,fullfile(OutputFolder,'InputQC.csv'));
assert(Review.Files.IsValid,'The preserved TIFF did not pass file import.');
assert(Review.Files.RawTiffInfo.Frames==1200 && Review.Files.RawTiffInfo.Width==512 ...
    && Review.Files.RawTiffInfo.Height==512,'Unexpected selected recording dimensions.');
assert(strcmp(Review.Status,'held_for_current_uniform_time_pipeline'), ...
    'Recorded nonuniform source timing must remain held.');
assert(any(Review.QC.IssueID=="R1-TIMING" & Review.QC.Disposition=="hold_recording"));
Original=jsondecode(Review.MetadataSnapshot.RawJSON);
assert(isequal(Review.Acquisition.DeclaredFrameTimesSec,Original.FrameTimesSec(:)), ...
    'Source timing was modified.');
assert(all(Review.Acquisition.CameraExposureSec==0.96),'Exposure must retain the 960 ms setting.');
assert(all(isnan(Review.Acquisition.DeclaredFrameValid)),'Unreviewed validity must stay unknown.');
CaughtIdentifier='';
try
    captureBOIAcquisitionMetadata(RecordingFolder,1200,1,Manifest.sha256,true);
catch ME
    CaughtIdentifier=ME.identifier;
end
assert(strcmp(CaughtIdentifier,'OxygenDynamics:UnsupportedBOIInput'), ...
    'The master acquisition guard must reject this declared timing before detection.');
Report=struct('DecisionID','R1-HP-INPUT-001','Status','technical_preflight_verified_recording_held', ...
    'MATLABVersion',version,'RecordedUTC',char(datetime('now','TimeZone','UTC', ...
    'Format','yyyy-MM-dd''T''HH:mm:ss.SSS''Z''')), ...
    'ReviewStatus',Review.Status,'Frames',1200,'Width',512,'Height',512, ...
    'NominalSampleHz',Manifest.sample_hz,'ProvisionalPixelSizeUm',Manifest.pixel_size_um, ...
    'SourceSHA256',Manifest.sha256,'MetadataSHA256',Review.MetadataSnapshot.SHA256, ...
    'SourceTimingPreserved',true,'ExposureSec',0.96,'FrameValidity','unknown', ...
    'MasterGuardError',CaughtIdentifier,'QC',table2struct(Review.QC), ...
    'DetectorRuns',0,'BiologicalEligibility','not_established', ...
    'ElapsedSec',toc(Started));
SourceFiles={mfilename('fullpath'),fullfile(RepoRoot,'reviewBOIRecordingInput.m'), ...
    fullfile(RepoRoot,'helpers','validateOxygenRecording.m'), ...
    fullfile(RepoRoot,'helpers','captureBOIAcquisitionMetadata.m'), ...
    fullfile(RepoRoot,'helpers','resolveBOIAcquisitionMetadata.m')};
if ~endsWith(SourceFiles{1},'.m'),SourceFiles{1}=[SourceFiles{1},'.m'];end
for k=1:numel(SourceFiles)
    Report.SourceFiles(k).Path=erase(SourceFiles{k},[RepoRoot,filesep]);
    Report.SourceFiles(k).SHA256=oxygenFileSHA256(SourceFiles{k});
end
fid=fopen(fullfile(OutputFolder,'preflight-report.json'),'w');
assert(fid>=0,'Could not create report.');Cleanup=onCleanup(@() fclose(fid));
fprintf(fid,'%s\n',jsonencode(Report,'PrettyPrint',true));
disp(Report.Status);
end
