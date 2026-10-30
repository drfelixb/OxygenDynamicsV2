function Reviewed=createBOIReviewedBurdenMetrics(Automatic,Registry,Reviews,EventRevisions)
% Apply saved recognition decisions to a separate burden result.
% Unreviewed/uncertain events retain automatic ingredients and missingness.
id='OxygenDynamics:ReviewedBurdenIdentity';
assert(isstruct(Automatic)&&isfield(Automatic,'EventTable')&&istable(Automatic.EventTable),id,'Supply the saved automatic burden.');
E=Automatic.EventTable;
assert(all(ismember({'RecordingID','SinkID','StartFrame','EndFrame','SampleF','RecDuration', ...
    'BurdenArea_um2','PerEventBurdenContribution'},E.Properties.VariableNames)),id,'Saved burden ingredients are incomplete.');
[keys,~]=oxygenEventJoinKeys(E,E);assert(numel(unique(keys))==height(E),id,'Duplicate automatic event identities.');
assert(all(ismember(string(E.RecordingID),string(Registry.RecordingID)))&& ...
    numel(unique(string(Registry.RecordingID)))==height(Registry),id,'Recording exposure registry does not uniquely cover the events.');
if ~iscell(Reviews),Reviews={Reviews};end
n=height(E);status=repmat("not_reviewed",n,1);reviewer=strings(n,1);reason=reviewer;artifact=reviewer;hash=reviewer;
for k=1:numel(Reviews)
    R=Reviews{k};
    assert(isstruct(R)&&isfield(R,'BoundaryReview')&&~isempty(R.BoundaryReview), ...
        'OxygenDynamics:SavedReviewRequired','Load a saved researcher revision; drafts cannot govern exports.');
    assert(strcmp(oxygenFileSHA256(R.AuditPath),R.AuditSHA256),id,'The saved audit changed.');
    saved=loadBOIBoundaryReview(R,R.BoundaryReview.Path);
    assert(strcmp(saved.SHA256,R.BoundaryReview.SHA256),id,'The selected review revision changed.');
    R.BoundaryReview=saved;
    indices=unique([saved.Document.Revisions.AuditRow]);
    for ix=indices(:)'
        a=R.Audit(ix,:);if string(a.EventType)~="sink",continue;end
        b=getBOIBoundaryReview(R,ix);
        keytable=table(string(a.RecordingID),a.SiteID,a.EventID,'VariableNames',{'RecordingID','SinkID','EventIndex'});
        [~,key]=oxygenEventJoinKeys(E,keytable);j=find(keys==key);
        assert(isscalar(j),id,'A saved sink judgment does not match exactly one exported event.');
        assert(status(j)=="not_reviewed",id,'Multiple review snapshots claim this event. Select one reconciled revision.');
        assert(E.StartFrame(j)==a.StartFrame&&E.EndFrame(j)==a.EndFrame&& ...
            E.SampleF(j)==R.AnalysisInfo.AnalysisParams.fs&& ...
            abs(E.RecDuration(j)-R.AnalysisInfo.NFrames/R.AnalysisInfo.AnalysisParams.fs)<1e-9, ...
            id,'Review event bounds or acquisition clock differ from the automatic export.');
        ri=find(string(Registry.RecordingID)==string(a.RecordingID));
        assert(isscalar(ri)&&ismember('RawSHA256',Registry.Properties.VariableNames)&& ...
            string(Registry.RawSHA256(ri))==string(R.AnalysisInfo.RawSHA256),id,'Reviewed raw source differs from the recording registry.');
        if ismember('EpisodeReferenceAuditSHA256',E.Properties.VariableNames)
            assert(string(E.EpisodeReferenceAuditSHA256(j))==string(R.AuditSHA256),id,'The saved burden used a different event audit.');
        end
        status(j)=string(b.Status);reviewer(j)=string(b.Annotation.Reviewer);reason(j)=string(b.Annotation.Reason);
        artifact(j)=string(saved.Path);hash(j)=string(saved.SHA256);
    end
end
excluded=status=="not_recognized";
eventIndex=E.EventID;if ismember('EventIndex',E.Properties.VariableNames),eventIndex=E.EventIndex;end
Decisions=table((1:n)',string(E.RecordingID),E.SinkID,eventIndex,status,excluded,reviewer,reason,artifact,hash, ...
    'VariableNames',{'AutomaticRow','RecordingID','SinkID','EventIndex','RecognitionStatus','ExcludedFromReviewedBurden', ...
    'Reviewer','Reason','ReviewArtifact','ReviewSHA256'});
% Reuse the existing calculator with the exact SAVED burden areas. Do not
% infer a new footprint or substitute a new baseline for retained events.
kept=E(~excluded,:);specific=kept(:,intersect({'RecordingID','SinkID','EventIndex','EventID'},kept.Properties.VariableNames,'stable'));
specific.Area_um=kept.BurdenArea_um2;
Reviewed=createHypoxicBurdenMetrics(kept,specific,table(),Registry);
if ~isempty(kept)
    for f={'BurdenAmplitudePercent','BurdenArea_um2','BurdenDuration_sec','BurdenRecordingArea_um2', ...
            'BurdenRecordingDuration_sec','PerEventBurdenContribution','PerEventBurdenContribution_per_mm2_per_min'}
        assert(isequaln(Reviewed.EventTable.(f{1}),kept.(f{1})), ...
            'OxygenDynamics:ReviewedBurdenIngredientChanged','Retained saved ingredient changed: %s.',f{1});
    end
    % Preserve original automatic source descriptions and columns. Only rank
    % weighting is recalculated on the reviewed event membership.
    kept.BurdenRankAmplitudeQuantile=Reviewed.EventTable.BurdenRankAmplitudeQuantile;
    kept.PerEventBurdenRankAmplitude_per_mm2_per_min=Reviewed.EventTable.PerEventBurdenRankAmplitude_per_mm2_per_min;
end
Reviewed.EventTable=kept;
Reviewed.ReviewDecisions=Decisions;
Reviewed.ExcludedDetections=E(excluded,:);
Summary=Registry(:,{'RecordingID'});
fields={'AutomaticDetections','SavedRecognitionDecisions','RejectedDetections','RetainedDetections', ...
    'RetainedUnreviewedDetections','AvailableContributions','MissingContributions'};
for f=fields,Summary.(f{1})=zeros(height(Summary),1);end
for i=1:height(Summary)
    m=string(E.RecordingID)==string(Summary.RecordingID(i));retain=m&~excluded;
    Summary.AutomaticDetections(i)=sum(m);Summary.SavedRecognitionDecisions(i)=sum(m&status~="not_reviewed");
    Summary.RejectedDetections(i)=sum(m&excluded);Summary.RetainedDetections(i)=sum(retain);
    Summary.RetainedUnreviewedDetections(i)=sum(retain&status=="not_reviewed");
    Summary.AvailableContributions(i)=sum(retain&isfinite(E.PerEventBurdenContribution));
    Summary.MissingContributions(i)=sum(retain&~isfinite(E.PerEventBurdenContribution));
end
Reviewed.ReviewSummary=Summary;
Reviewed.ReviewPolicy=struct('Schema','boi-saved-recognition-burden-1', ...
    'ExcludedStatus','not_recognized','UnreviewedPolicy','retain automatic ingredients; not scientifically accepted by default', ...
    'UncertainPolicy','retain automatic ingredients and missingness','ReferencePolicy','unchanged', ...
    'TotalsPolicy','strict sum over retained detections; unavailable required contribution withholds complete total', ...
    'AutomaticResultsChanged',false,'PartialSums',false);
if nargin>=4&&~isempty(EventRevisions)
    if ~iscell(EventRevisions),EventRevisions={EventRevisions};end
    Reviewed=applyBOIReviewedBurdenEvents(Reviewed,Registry,EventRevisions);
end
end
