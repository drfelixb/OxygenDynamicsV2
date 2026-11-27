function D=createBOIAreaReview(R,Index,MeasurementFolder,RecoveredFrames)
% Source-bound draft. A saved detection is never an accepted frame judgment.
if nargin<4,RecoveredFrames=[];end
id='OxygenDynamics:AreaReviewSource';
folder=char(java.io.File(MeasurementFolder).getCanonicalPath());
status=jsondecode(fileread(fullfile(folder,'Status.json')));assert(strcmp(status.Status,'complete'),id,'Approved optical evidence is incomplete.');
manifest=jsondecode(fileread(fullfile(folder,'Checksums.json')));
for k=1:numel(manifest)
    p=char(java.io.File(fullfile(folder,manifest(k).Path)).getCanonicalPath());
    assert(startsWith(p,[folder filesep])&&strcmp(oxygenFileSHA256(p),manifest(k).SHA256),id,'Approved optical evidence changed.');
end
path=fullfile(folder,'ReviewedMeasurement.json');S=jsondecode(fileread(path));
assert(strcmp(S.Schema,'boi-reviewed-amplitude-duration-evidence-1')&&strcmp(S.AuditSHA256,R.AuditSHA256)&&S.EventID==R.Audit.EventID(Index)&& ...
    S.SiteID==R.Audit.SiteID(Index)&&strcmp(S.EventType,'sink')&&strcmp(S.RecordingID,char(R.Audit.RecordingID(Index))),id,'Measurement identity differs.');
R.BoundaryReview=loadBOIBoundaryReview(R,S.BoundaryPath);assert(strcmp(R.BoundaryReview.SHA256,S.BoundarySHA256),id,'Approved boundary changed.');
R=loadBOIReferenceJudgments(R,{S.ReferencePath});assert(strcmp(R.ReferenceJudgments.SHA256,S.ReferenceSHA256),id,'Approved reference changed.');
B=getBOIBoundaryReview(R,Index);assert(strcmp(B.Status,'recognized')&&B.Annotation.PreferredOnsetFrame==S.StartFrame&&B.Annotation.PreferredRecoveryFrame==S.EndFrame,id,'Save explicit recognized endpoints first.');
version=boiReviewedOpticalVersion(S,true);
getBOIReviewedOpticalDefinition([],version);
M=computeBOIReviewedOpticalInterval(R.Traces{Index}.Raw,R.ReferenceJudgments.Frames,S.StartFrame,S.EndFrame,R.AnalysisInfo.AnalysisParams.fs,'sink',boiCameraOffset(S));
blocked=strcmp(M.Status,'reference_at_or_below_camera_offset');
if blocked && isempty(S.RawAmplitudePercent),S.RawAmplitudePercent=NaN;end
computed=strcmp(M.Status,'computed_exploratory') && abs(100*M.SavedSignDirectionalAmplitudeFraction-S.RawAmplitudePercent)<1e-9;
assert((computed || (blocked && isscalar(S.RawAmplitudePercent) && isnan(S.RawAmplitudePercent))) && ...
    M.DurationSec==S.DurationSec,id,'Approved amplitude does not replay.');
I=R.AnalysisInfo;master=R.AuditCreationReceipt.MasterPaths{1};masterHash=char(string(R.AuditCreationReceipt.MasterSHA256(1)));
assert(strcmp(oxygenFileSHA256(master),masterHash),id,'Native master differs from the audit receipt.');
native=load(master,'AnalysisInfo','Table_OxygenSinkEvents_Out');E=native.Table_OxygenSinkEvents_Out;
j=find(string(E.RecordingID)==string(S.RecordingID)&E.SinkID==S.SiteID&E.EventID==S.EventID);
assert(isscalar(j)&&isequaln(native.AnalysisInfo,I)&&E.StartFrame(j)==S.OriginalAutomaticStartFrame&&E.EndFrame(j)==S.OriginalAutomaticEndFrame,id,'Original native event identity differs.');
foot=sort(double(R.Traces{Index}.Footprint(:)));assert(numel(foot)==S.FixedTraceFootprintPixels,id,'Approved footprint differs.');
C=struct('Schema','boi-reviewed-area-context-1','AuditPath',R.AuditPath,'AuditSHA256',R.AuditSHA256, ...
    'AuditRow',Index,'RecordingID',S.RecordingID,'EventType','sink','SiteID',S.SiteID,'EventID',S.EventID, ...
    'Frames',(S.StartFrame:S.EndFrame)','ReferenceFrames',R.ReferenceJudgments.Frames(:),'RecoveredFrames',double(RecoveredFrames(:)), ...
    'FrameSize',double(I.FrameSize(:)'),'FixedFootprint',foot,'PixelSizeUm',I.AnalysisParams.PixelSize, ...
    'SampleHz',I.AnalysisParams.fs,'FrameOrigin',1,'AmplitudePercent',S.RawAmplitudePercent,'DurationSec',S.DurationSec, ...
    'RawReferenceMean',S.RawReferenceMean,'RawMinimum',S.RawMinimum,'RecordingAreaUm2',I.RecordingAreaUm2,'RecordingDurationSec',I.NFrames/I.AnalysisParams.fs, ...
    'RawFile',I.RawFile,'RawSourceSHA256',I.RawSHA256,'DenoisedFile',I.DenoisedFile,'DenoisedSHA256',I.DenoisedSHA256, ...
    'NativeMasterPath',master,'NativeMasterSHA256',masterHash,'MeasurementFolder',folder, ...
    'MeasurementJSONSHA256',oxygenFileSHA256(path),'MeasurementManifestSHA256',oxygenFileSHA256(fullfile(folder,'Checksums.json')), ...
    'BoundaryPath',S.BoundaryPath,'BoundarySHA256',S.BoundarySHA256,'ReferencePath',S.ReferencePath,'ReferenceSHA256',S.ReferenceSHA256, ...
    'OriginalAutomaticStartFrame',S.OriginalAutomaticStartFrame,'OriginalAutomaticEndFrame',S.OriginalAutomaticEndFrame, ...
    'OriginalAutomaticAreaUm2',E.EventArea_um2(j));
% Historical revisions hash the exact original context. Preserve that layout.
if isfield(S,'ReviewedOpticalVersion') || ~isempty(boiCameraOffset(S))
    C.ReviewedOpticalVersion=version;C.CameraOffsetCounts=boiCameraOffset(S);C.AmplitudeStatus=M.Status;
    if isfield(S,'ReferencesAtOrBelowOffset')
        C.ReferencesAtOrBelowOffset=S.ReferencesAtOrBelowOffset;
    else
        calibration=boiIntensityCalibration(I);
        C.ReferencesAtOrBelowOffset=calibration.ReferencesAtOrBelowOffset+double(blocked);
    end
    if blocked,C.AmplitudePercent=[];end % Preserve the unavailable value across JSON hash replay.
end
F=repmat(struct('Frame',0,'Status','unreviewed','Pixels',[],'Origin','none','Note','','Reviewer','','DecidedUTC',''),numel(C.Frames),1);
for k=1:numel(F),F(k).Frame=C.Frames(k);end
D=struct('Schema','boi-reviewed-event-area-1','Context',C,'ContextSHA256',boiPocketDigest(C), ...
    'Revision',0,'PreviousArtifact',[],'Reviewer','','Reason','','CreatedUTC','', ...
    'Definition','mean of all explicitly reviewed frame areas; unreviewed/uncertain is unavailable; zero requires explicit empty judgment', ...
    'FrameDecisions',F,'AutomaticResultsChanged',false);
validateBOIAreaReview(D);
end
