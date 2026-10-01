function Store=loadBOIBoundaryReview(Review,Path)
%LOADBOIBOUNDARYREVIEW Load a self-contained history bound to this saved audit.
id='OxygenDynamics:InvalidBoundaryReview';
Path=char(java.io.File(Path).getCanonicalPath());before=oxygenFileSHA256(Path);
D=jsondecode(fileread(Path));
assert(isstruct(D)&&isscalar(D)&&all(isfield(D,{'Schema','AuditSHA256','RawSourceSHA256','NFrames','SampleHz','FrameOrigin','Revisions','PreviousArtifact'})),id,'Incomplete boundary review.');
assert(strcmp(D.Schema,'boi-researcher-boundaries-1')&&strcmp(D.AuditSHA256,Review.AuditSHA256)&& ...
    strcmp(D.RawSourceSHA256,Review.AnalysisInfo.RawSHA256)&&isequal(D.NFrames,Review.AnalysisInfo.NFrames)&& ...
    isequal(D.SampleHz,Review.AnalysisInfo.AnalysisParams.fs)&&isequal(D.FrameOrigin,1),id,'Boundary review does not match this audit/source and frame clock.');
assert(isstruct(D.Revisions)&&~isempty(D.Revisions),id,'A saved boundary review must contain revisions.');
latest=cell(height(Review.Audit),1);lastRevision=zeros(height(Review.Audit),1);
for k=1:numel(D.Revisions)
    R=D.Revisions(k);
    assert(all(isfield(R,{'Revision','PreviousEventRevision','AuditRow','Event','Annotation','PreviousAnnotation','CreatedUTC','SaveImplementationSHA256','ValidatorImplementationSHA256'})),id,'Incomplete revision.');
    for field={'SaveImplementationSHA256','ValidatorImplementationSHA256'}
        assert(ischar(R.(field{1}))&&~isempty(regexp(R.(field{1}),'^[0-9a-f]{64}$','once')),id,'Revision implementation checksum is missing or malformed.');
    end
    A=validateBOIBoundaryAnnotation(Review,R.AuditRow,R.Annotation);index=R.AuditRow;
    expected=table2struct(Review.Audit(index,{'RecordingID','EventType','SiteID','EventID','StartFrame','EndFrame','DetectedStartFrame','DetectedEndFrame'}));
    assert(isequal(R.Revision,k)&&isequal(R.PreviousEventRevision,lastRevision(index))&& ...
        strcmp(jsonencode(R.Event),jsonencode(expected)),id,'Revision sequence or event identity differs from the saved audit.');
    previous=R.PreviousAnnotation;
    if ~isempty(previous),previous=validateBOIBoundaryAnnotation(Review,index,previous);end
    assert(isequal(previous,latest{index}),id,'Previous annotation does not match the preceding event revision.');
    assert(ischar(R.CreatedUTC)&&~isempty(regexp(R.CreatedUTC,'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$','once')),id,'Revision UTC timestamp is missing or invalid.');
    D.Revisions(k).Annotation=A;D.Revisions(k).PreviousAnnotation=previous;
    latest{index}=A;lastRevision(index)=k;
end
assert(strcmp(before,oxygenFileSHA256(Path)),'OxygenDynamics:BoundaryReviewChanged','Boundary review changed while loading.');
Store=struct('Path',Path,'SHA256',before,'Document',D);
end
