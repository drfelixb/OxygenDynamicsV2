function Store=saveBOIBoundaryReview(Review,Index,Annotation,NewPath,Previous)
%SAVEBOIBOUNDARYREVIEW Write a NEW immutable snapshot; never overwrite a revision.
if nargin<5,Previous=[];end
Annotation=validateBOIBoundaryAnnotation(Review,Index,Annotation);
assert(strcmp(oxygenFileSHA256(Review.AuditPath),Review.AuditSHA256),'OxygenDynamics:EventReviewChanged','Saved audit changed. Reopen before saving a judgment.');
if isempty(Previous)
    D=struct('Schema','boi-researcher-boundaries-1','AuditPath',Review.AuditPath,'AuditSHA256',Review.AuditSHA256, ...
        'RawSourceSHA256',Review.AnalysisInfo.RawSHA256,'NFrames',Review.AnalysisInfo.NFrames, ...
        'SampleHz',Review.AnalysisInfo.AnalysisParams.fs,'FrameOrigin',1,'ModeledTimeFormula','(Frame-1)/SampleHz', ...
        'BoundaryRole','researcher_judgment_only; no automatic measurement, label or native-mask changes', ...
        'AlternativesRole','discrete frame choices, not a continuous uncertainty interval; empty means unresolved', ...
        'Revisions',[],'PreviousArtifact',[]);
else
    assert(strcmp(oxygenFileSHA256(Previous.Path),Previous.SHA256),'OxygenDynamics:BoundaryReviewChanged','Previously loaded review changed. Reload and reconcile before saving.');
    checked=loadBOIBoundaryReview(Review,Previous.Path);D=checked.Document;
    D.PreviousArtifact=struct('Path',Previous.Path,'SHA256',Previous.SHA256);
end
previous=[];previousRevision=0;
for k=1:numel(D.Revisions)
    if D.Revisions(k).AuditRow==Index,previous=D.Revisions(k).Annotation;previousRevision=k;end
end
revision=struct('Revision',numel(D.Revisions)+1,'PreviousEventRevision',previousRevision,'AuditRow',Index, ...
    'Event',table2struct(Review.Audit(Index,{'RecordingID','EventType','SiteID','EventID','StartFrame','EndFrame','DetectedStartFrame','DetectedEndFrame'})), ...
    'Annotation',Annotation,'PreviousAnnotation',previous, ...
    'SaveImplementationSHA256',oxygenFileSHA256(which('saveBOIBoundaryReview')), ...
    'ValidatorImplementationSHA256',oxygenFileSHA256(which('validateBOIBoundaryAnnotation')), ...
    'CreatedUTC',char(datetime('now','TimeZone','UTC','Format','yyyy-MM-dd''T''HH:mm:ss''Z''')));
if isempty(D.Revisions),D.Revisions=revision;else,D.Revisions(end+1)=revision;end
bytes=unicode2native([jsonencode(D,'PrettyPrint',true) newline],'UTF-8');
NewPath=char(java.io.File(NewPath).getCanonicalPath());
% Atomic reservation refuses existing files, including another writer's result.
assert(java.io.File(NewPath).createNewFile(),'OxygenDynamics:BoundaryReviewOutputExists','Choose a new filename; earlier review revisions are preserved.');
try
    fid=fopen(NewPath,'w');assert(fid>=0,'Cannot open new review file.');
    try,count=fwrite(fid,bytes,'uint8');catch err,fclose(fid);rethrow(err);end
    closed=fclose(fid);assert(count==numel(bytes)&&closed==0,'Incomplete review write.');
    Store=loadBOIBoundaryReview(Review,NewPath);
catch err
    if isfile(NewPath),delete(NewPath);end
    rethrow(err);
end
end
