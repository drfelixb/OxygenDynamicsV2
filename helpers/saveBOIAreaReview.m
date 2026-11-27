function Store=saveBOIAreaReview(D,Folder,Previous)
% Save progress or a complete result to a NEW folder; never overwrite history.
if nargin<3,Previous=[];end
validateBOIAreaReview(D);id='OxygenDynamics:AreaReviewOutput';
Folder=char(java.io.File(Folder).getCanonicalPath());assert(~isfolder(Folder)&&~isfile(Folder),id,'Choose a new revision folder.');
if isempty(Previous)
    D.Revision=1;D.PreviousArtifact=[];
else
    old=loadBOIAreaReview(Previous.Path);assert(strcmp(old.SHA256,Previous.SHA256)&&strcmp(old.Document.ContextSHA256,D.ContextSHA256),id,'Previous area revision changed or belongs to another event.');
    D.Revision=old.Document.Revision+1;D.PreviousArtifact=struct('Path',old.Path,'SHA256',old.SHA256);
end
D.CreatedUTC=char(datetime('now','TimeZone','UTC','Format','yyyy-MM-dd''T''HH:mm:ss''Z'''));
validateBOIAreaReview(D);Q=computeBOIReviewedArea(D);C=D.Context;
[ok,~,msgid]=mkdir(Folder);assert(ok&&isempty(msgid),id,'Could not claim a new revision folder.');
writeBOIRunJSON(fullfile(Folder,'Status.json'),struct('Status','writing'));
try
    path=fullfile(Folder,'AreaReview.json');writeBOIRunJSON(path,D);Store=loadBOIAreaReview(path);
    state=string({D.FrameDecisions.Status})';origin=string({D.FrameDecisions.Origin})';
    T=table(C.Frames(:),state,Q.FramePixels,Q.OutsideFootprintPixels,origin, ...
        'VariableNames',{'Frame','ReviewStatus','ReviewedAreaPixels','OutsideAcceptedFootprintPixels','MaskOrigin'});
    writetable(T,fullfile(Folder,'AreaFrames.csv'));
    S=struct('Schema','boi-reviewed-single-event-burden-2','RecordingID',C.RecordingID,'EventType','sink','SiteID',C.SiteID,'EventID',C.EventID, ...
        'AuditRow',C.AuditRow,'StartFrame',C.Frames(1),'EndFrame',C.Frames(end),'DurationSec',C.DurationSec,'SampleHz',C.SampleHz, ...
        'ReferenceStartFrame',C.ReferenceFrames(1),'ReferenceEndFrame',C.ReferenceFrames(end),'ReferenceSamples',numel(C.ReferenceFrames), ...
        'RawReferenceMean',C.RawReferenceMean,'RawMinimum',C.RawMinimum,'BurdenAmplitudePercent',C.AmplitudePercent, ...
        'BurdenArea_um2',Q.MeanAreaUm2,'BurdenRecordingArea_um2',C.RecordingAreaUm2,'BurdenRecordingDuration_sec',C.RecordingDurationSec, ...
        'PerEventBurdenContribution',Q.Contribution,'PerEventBurdenContribution_per_mm2_per_min',Q.NormalizedContribution, ...
        'AreaStatus',Q.Status,'AreaMeanFrameCount',numel(C.Frames),'ReviewedAreaFrames',Q.ReviewedFrames, ...
        'AreaReviewFile','AreaReview.json','AreaReviewSHA256',Store.SHA256,'AreaRemeasured',Q.Complete, ...
        'AreaQualification',['researcher-reviewed complete-interval frame masks; status: ' Q.Status], ...
        'OriginalAutomaticStartFrame',C.OriginalAutomaticStartFrame,'OriginalAutomaticEndFrame',C.OriginalAutomaticEndFrame, ...
        'OriginalAutomaticArea_um2',C.OriginalAutomaticAreaUm2,'AuditPath',C.AuditPath,'AuditSHA256',C.AuditSHA256, ...
        'RawSourceSHA256',C.RawSourceSHA256,'BoundaryPath',C.BoundaryPath,'BoundarySHA256',C.BoundarySHA256, ...
        'ReferencePath',C.ReferencePath,'ReferenceSHA256',C.ReferenceSHA256,'OriginalResultsChanged',false, ...
        'GlobalDefaultsChanged',false,'RecordingTotalCalculated',false,'PartialSumCalculated',false);
    S.ReviewedOpticalVersion=boiReviewedOpticalVersion(C); S.CameraOffsetCounts=boiCameraOffset(C);
    if isfield(C,'AmplitudeStatus'),S.AmplitudeStatus=C.AmplitudeStatus;end
    if isempty(S.BurdenAmplitudePercent),S.BurdenAmplitudePercent=NaN;end
    cal=boiIntensityCalibration(C); S.CameraOffsetSource=cal.CameraOffsetSource; S.IntensityRatiosOffsetCorrected=cal.IntensityRatiosOffsetCorrected;
    S.ReferencesAtOrBelowOffset=cal.ReferencesAtOrBelowOffset;
    M=computeBOIReviewedArea(D);ReviewedEventBurden=S;AreaReview=D; %#ok<NASGU>
    save(fullfile(Folder,'ReviewedEventBurden.mat'),'ReviewedEventBurden','AreaReview','M');
    writeBOIRunJSON(fullfile(Folder,'ReviewedEventBurden.json'),S);writetable(struct2table(S,'AsArray',true),fullfile(Folder,'ReviewedEventBurden.csv'));
    writeBOIRunJSON(fullfile(Folder,'Status.json'),struct('Status','complete','AreaStatus',Q.Status,'BurdenAvailable',isfinite(Q.Contribution)));
    files=dir(Folder);manifest=struct('Path',{},'SHA256',{});
    for k=1:numel(files)
        if files(k).isdir,continue;end
        manifest(end+1)=struct('Path',files(k).name,'SHA256',oxygenFileSHA256(fullfile(Folder,files(k).name))); %#ok<AGROW>
    end
    writeBOIRunJSON(fullfile(Folder,'Checksums.json'),manifest);
catch err
    writeBOIRunJSON(fullfile(Folder,'Status.json'),struct('Status','failed','ErrorID',err.identifier,'ErrorMessage',err.message));rethrow(err);
end
end
