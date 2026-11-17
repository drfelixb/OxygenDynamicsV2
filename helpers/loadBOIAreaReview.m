function Store=loadBOIAreaReview(Path)
% Load a source-bound immutable revision; do not trust saved derived scalars.
Path=char(java.io.File(Path).getCanonicalPath());before=oxygenFileSHA256(Path);D=jsondecode(fileread(Path));
validateBOIAreaReview(D);assert(D.Revision>=1,'OxygenDynamics:InvalidAreaReview','Choose a saved revision.');
if D.Revision==1
    assert(isempty(D.PreviousArtifact),'OxygenDynamics:AreaReviewChanged','Initial revision has an unexpected parent.');
else
    P=D.PreviousArtifact;
    assert(isstruct(P)&&isfield(P,'Path')&&isfield(P,'SHA256')&&isfile(P.Path)&& ...
        strcmp(oxygenFileSHA256(P.Path),P.SHA256),'OxygenDynamics:AreaReviewChanged','Previous area revision is missing or changed.');
    parent=jsondecode(fileread(P.Path));
    assert(parent.Revision==D.Revision-1&&strcmp(parent.ContextSHA256,D.ContextSHA256), ...
        'OxygenDynamics:AreaReviewChanged','Previous revision number or source context differs.');
end
C=D.Context;R=loadBOIEventReview(C.AuditPath);
assert(strcmp(R.AuditSHA256,C.AuditSHA256),'OxygenDynamics:AreaReviewSource','Audit changed.');
expected=createBOIAreaReview(R,C.AuditRow,C.MeasurementFolder,C.RecoveredFrames);
assert(strcmp(expected.ContextSHA256,D.ContextSHA256),'OxygenDynamics:AreaReviewSource','Area revision differs from the approved measurement/source.');
assert(strcmp(before,oxygenFileSHA256(Path)),'OxygenDynamics:AreaReviewChanged','Area revision changed while loading.');
Store=struct('Path',Path,'SHA256',before,'Document',D,'Measures',computeBOIReviewedArea(D));
end
