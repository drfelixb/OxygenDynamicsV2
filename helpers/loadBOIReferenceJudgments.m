function Review=loadBOIReferenceJudgments(Review,Paths)
%LOADBOIREFERENCEJUDGMENTS Attach source-bound local judgments for display only.
id='OxygenDynamics:ReferenceJudgmentMismatch';
assert(isfield(Review,'BoundaryReview')&&~isempty(Review.BoundaryReview),id,'Load the matching saved boundary revision first.');
S=loadBOIBoundaryReview(Review,Review.BoundaryReview.Path);
assert(strcmp(S.SHA256,Review.BoundaryReview.SHA256),id,'Boundary file changed; reload before attaching judgments.');
Paths=cellstr(string(Paths));assert(~isempty(Paths),id,'Choose at least one judgment file.');
items=struct('Path',{},'SHA256',{},'AuditRow',{},'OnsetFrame',{},'Frames',{},'Document',{});
for k=1:numel(Paths)
    path=char(java.io.File(Paths{k}).getCanonicalPath());hash=oxygenFileSHA256(path);J=jsondecode(fileread(path));
    assert(strcmp(hash,oxygenFileSHA256(path)),id,'Judgment changed while loading.');
    required={'Schema','BoundaryReviewSHA256','AuditRow','SavedEvent','Reviewer','RecordedUTC','DecisionID','ReferenceJudgment'};
    assert(isstruct(J)&&isscalar(J)&&all(isfield(J,required)),id,'Incomplete judgment provenance.');
    assert(strcmp(J.BoundaryReviewSHA256,S.SHA256),id,'Judgment belongs to a different boundary revision.');
    row=J.AuditRow;assert(isnumeric(row)&&isscalar(row)&&isfinite(row)&&row==fix(row)&&row>=1&&row<=height(Review.Audit),id,'Invalid audit row.');
    B=getBOIBoundaryReview(Review,row);assert(~isempty(B.Annotation),id,'No saved boundaries for this judgment.');
    for field={'EventType','SiteID','EventID'}
        key=field{1};assert(isfield(J.SavedEvent,key)&&isequal(string(J.SavedEvent.(key)),string(B.Event.(key))),id,'Judgment event identity differs.');
    end
    for key=fieldnames(J.SavedEvent)'
        field=key{1};assert(isfield(B.Event,field)&&isequal(string(J.SavedEvent.(field)),string(B.Event.(field))),id,'Saved event metadata differs.');
    end
    if isfield(J,'SelectedEventRevision'),assert(J.SelectedEventRevision==B.History(end).Revision,id,'Event revision differs.');end
    if isfield(J,'AuditSHA256'),assert(strcmp(J.AuditSHA256,Review.AuditSHA256),id,'Judgment audit differs.');end
    switch J.Schema
        case 'boi-researcher-reference-acceptance-1'
            assert(all(isfield(J,{'BoundaryAnnotationUnchanged','AcceptedReferenceFrames','AcceptedSampleCount'})),id,'Incomplete reference judgment.');
            assert(isequaln(validateBOIBoundaryAnnotation(Review,row,J.BoundaryAnnotationUnchanged),B.Annotation),id,'Judgment annotation differs.');
            onset=B.Annotation.PreferredOnsetFrame;frames=J.AcceptedReferenceFrames;
            assert(numel(frames)==J.AcceptedSampleCount,id,'Judgment sample count differs.');
        case 'boi-researcher-reference-frame-judgment-1'
            required={'PreferredOnsetFrame','EligibleFramesWithExplicitJudgments','CandidateFrames','RemainingNativeExcludedFrames','EligibleCountWithExplicitJudgments','FullReferenceAvailableUnderRemainingRules','RecoveryAlternativesFrames','PreferredRecoveryFrame'};
            assert(all(isfield(J,required)),id,'Incomplete frame judgment.');
            onset=J.PreferredOnsetFrame;frames=J.EligibleFramesWithExplicitJudgments;
            assert(isequal(onset,B.Annotation.PreferredOnsetFrame)&&isequal(J.RecoveryAlternativesFrames(:),B.Annotation.RecoveryFrames(:))&&isequal(J.PreferredRecoveryFrame,B.Annotation.PreferredRecoveryFrame),id,'Frame judgment boundaries differ.');
            assert(J.FullReferenceAvailableUnderRemainingRules&&isempty(J.RemainingNativeExcludedFrames)&&isequal(frames(:),J.CandidateFrames(:))&&numel(frames)==J.EligibleCountWithExplicitJudgments,id,'Partial frame judgment is not a complete reference selection.');
        otherwise
            error(id,'Unsupported reference judgment schema.');
    end
    assert(startsWith(string(J.ReferenceJudgment),'accepted_as_'),id,'Judgment is not an accepted local reference.');
    assert(isnumeric(onset)&&isscalar(onset)&&ismember(onset,B.Annotation.OnsetFrames),id,'Judgment needs one saved onset.');
    n=round(20*Review.AnalysisInfo.AnalysisParams.fs);
    assert(isnumeric(frames)&&isreal(frames)&&isvector(frames)&&~isempty(frames)&&all(isfinite(frames))&&all(frames==fix(frames))&&all(diff(frames(:))>0),id,'Reference frames must be increasing unique integers.');
    assert(all(frames>=max(1,onset-n)&frames<onset),id,'This preview supports selected frames within the preceding 20-second candidate only.');
    assert(~any([items.AuditRow]==row&[items.OnsetFrame]==onset),id,'Duplicate judgments for the same event and onset; choose one revision.');
    items(end+1)=struct('Path',path,'SHA256',hash,'AuditRow',row,'OnsetFrame',onset,'Frames',frames(:),'Document',J); %#ok<AGROW>
end
Review.ReferenceJudgments=items;
end
