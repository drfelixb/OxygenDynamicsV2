function A=validateBOIBoundaryAnnotation(Review,Index,A)
%VALIDATEBOIBOUNDARYANNOTATION Validate explicit human judgments, without snapping.
id='OxygenDynamics:InvalidBoundaryReview';
assert(isscalar(Index)&&Index==fix(Index)&&Index>=1&&Index<=height(Review.Audit),id,'Invalid audit row.');
fields={'Status','OnsetFrames','RecoveryFrames','PreferredOnsetFrame','PreferredRecoveryFrame','Reviewer','Reason'};
assert(isstruct(A)&&isscalar(A)&&isequal(sort(fieldnames(A)),sort(fields(:))),id,'Boundary annotation fields are incomplete or unknown.');
for name={'Status','Reviewer','Reason'}
    value=A.(name{1});assert((ischar(value)&&isrow(value))||(isstring(value)&&isscalar(value)&&~ismissing(value)),id,'Status, reviewer and reason must be text.');
    A.(name{1})=strtrim(char(value));assert(~isempty(A.(name{1})),id,'Status, reviewer and reason are required.');
end
assert(ismember(A.Status,{'recognized','uncertain','not_recognized'}),id,'Unknown recognition status.');
for name={'OnsetFrames','RecoveryFrames','PreferredOnsetFrame','PreferredRecoveryFrame'}
    v=A.(name{1});assert(isnumeric(v)&&isreal(v)&&(isempty(v)||isvector(v))&&all(isfinite(v(:)))&& ...
        all(v(:)==fix(v(:)))&&all(v(:)>=1)&&all(v(:)<=Review.AnalysisInfo.NFrames),id,'Boundaries must be recorded integer frames, or empty.');
    assert(numel(unique(v))==numel(v),id,'Repeated boundary alternatives are not allowed.');if isempty(v),A.(name{1})=[];else,A.(name{1})=sort(double(v(:)'));end
end
assert(numel(A.PreferredOnsetFrame)<=1&&numel(A.PreferredRecoveryFrame)<=1,id,'Choose at most one preferred frame per endpoint.');
assert(all(ismember(A.PreferredOnsetFrame,A.OnsetFrames))&&all(ismember(A.PreferredRecoveryFrame,A.RecoveryFrames)),id,'A preferred frame must be one of the explicit alternatives.');
assert(isempty(A.OnsetFrames)||isempty(A.RecoveryFrames)||max(A.OnsetFrames)<=min(A.RecoveryFrames),id,'Each onset alternative must be at or before each recovery alternative.');
assert(~strcmp(A.Status,'not_recognized')||(isempty(A.OnsetFrames)&&isempty(A.RecoveryFrames)),id,'A not-recognized judgment has no current boundaries; earlier marks remain in history.');
end
