function P=buildBOITemporalContextPreview(Review,Index)
%BUILDBOITEMPORALCONTEXTPREVIEW Read-only corrected-trace context, never a baseline.
assert(strcmp(oxygenFileSHA256(Review.AuditPath),Review.AuditSHA256),'OxygenDynamics:ContextSourceChanged','Audit changed; reopen before calculating context.');
if isfield(Review,'BoundaryReview')&&~isempty(Review.BoundaryReview)
 B=loadBOIBoundaryReview(Review,Review.BoundaryReview.Path);assert(strcmp(B.SHA256,Review.BoundaryReview.SHA256),'OxygenDynamics:ContextSourceChanged','Saved boundaries changed; reload them.');Review.BoundaryReview=B;
end
if isfield(Review,'ReferenceJudgments')&&~isempty(Review.ReferenceJudgments)
 old=Review.ReferenceJudgments;Review=loadBOIReferenceJudgments(Review,{old.Path});assert(isequal({old.SHA256},{Review.ReferenceJudgments.SHA256}),'OxygenDynamics:ContextSourceChanged','Reference judgments changed; reload them.');
end
A=Review.Audit;assert(isscalar(Index)&&Index==fix(Index)&&Index>=1&&Index<=height(A));row=A(Index,:);t=Review.Traces{Index};I=Review.AnalysisInfo;
B=getBOIBoundaryReview(Review,Index);[stage,F]=buildBOITimingReviewData(t,I,Review);y=F.CorrectedIntensity;
P=struct('Schema','boi-temporal-context-preview-1','DefinitionVersion','1.0.0-diagnostic','Status','available','Message','Descriptive context only; neither window is an accepted baseline or recognition test.', ...
 'AuditPath',Review.AuditPath,'AuditSHA256',Review.AuditSHA256,'RawSourceSHA256',I.RawSHA256,'Event',table2struct(row), ...
 'SampleHz',I.AnalysisParams.fs,'Clock','External 1 Hz; frame 1 = 0 s. Frame interval is not exposure.', ...
 'Footprint',double(t.Footprint(:)),'CorrectedTrace',y,'CorrectedStage',stage.Corrected,'BoundaryReview',B,'BoundaryHistory',[], ...
 'ReferenceStatus','not_loaded','AcceptedReferences',[],'NativeStatus','not_attached','NativeSourceEvidence',[], ...
 'HumanContactSources',[],'Rows',{{}},'NewBaselineCalculations',0,'DetectorRuns',0,'CorrectionFits',0,'ScientificRuleAdopted',false);
if isfield(Review,'DiagnosticGeometryEvidence')
 P.GeometryEvidence=Review.DiagnosticGeometryEvidence;g=P.GeometryEvidence;
 assert(strcmp(oxygenFileSHA256(g.Path),g.SHA256),'OxygenDynamics:ContextSourceChanged','Geometry source changed; reopen.');
else
 P.GeometryEvidence=struct('Source','saved_audit_AnalysisInfo_FrameSize','Path',Review.AuditPath,'SHA256',Review.AuditSHA256,'FrameSize',I.FrameSize,'OriginalAnalysisInfoHadFrameSize',true);
end
if isfield(Review,'BoundaryReview')&&~isempty(Review.BoundaryReview),P.BoundaryHistory=Review.BoundaryReview.Document;end
if isfield(Review,'ReferenceJudgments')&&~isempty(Review.ReferenceJudgments)
 P.ReferenceStatus='loaded';P.AcceptedReferences=Review.ReferenceJudgments([Review.ReferenceJudgments.AuditRow]==Index);
 if isempty(P.AcceptedReferences),P.ReferenceStatus='no_loaded_reference_for_this_event';end
end
if I.AnalysisParams.fs~=1,P.Status='unsupported_clock';P.Message='This diagnostic is verified for external 1 Hz only; no resampling or substitute duration is used.';return;end
intervals=struct('ID','automatic','Role','saved_automatic_interval','StartFrame',row.StartFrame,'EndFrame',row.EndFrame,'Revision',0,'PreferredOnset',false,'PreferredRecovery',false);
if ~isempty(B.Annotation)
 for a=B.Annotation.OnsetFrames(:)'
  for b=B.Annotation.RecoveryFrames(:)'
   intervals(end+1)=struct('ID',sprintf('saved-%d-%d',a,b),'Role','saved_researcher_interval','StartFrame',a,'EndFrame',b, ...
    'Revision',B.History(end).Revision,'PreferredOnset',ismember(a,B.Annotation.PreferredOnsetFrame),'PreferredRecovery',ismember(b,B.Annotation.PreferredRecoveryFrame)); %#ok<AGROW>
  end
 end
end
H=struct('ID',{},'ParentObservation',{},'Role',{},'AuditRow',{},'SourceBinding',{},'BoundCertainty',{},'StartFrame',{},'EndFrame',{},'Footprint',{});
for r=1:height(A)
 if string(A.RecordingID(r))~=string(row.RecordingID),continue;end
 other=getBOIBoundaryReview(Review,r);if isempty(other.Annotation),continue;end
 for a=other.Annotation.OnsetFrames(:)'
  for b=other.Annotation.RecoveryFrames(:)'
   H(end+1)=struct('ID',sprintf('row%d-revision%d-%d-%d',r,other.History(end).Revision,a,b),'ParentObservation',sprintf('row%d',r), ...
    'Role','current_saved_researcher_interval','AuditRow',r,'SourceBinding','BoundaryHistory', ...
    'BoundCertainty',['Saved status ' other.Status '; discrete alternatives, not exact physiological boundaries'],'StartFrame',a,'EndFrame',b,'Footprint',double(Review.Traces{r}.Footprint(:)')); %#ok<AGROW>
  end
 end
end
if isfield(Review,'ReferenceJudgments')
 for j=1:numel(Review.ReferenceJudgments)
  q=Review.ReferenceJudgments(j);r=q.AuditRow;if string(A.RecordingID(r))~=string(row.RecordingID)||~isfield(q.Document,'PrecedingPocketObservation'),continue;end
  c=q.Document.PrecedingPocketObservation;f=c.ApproximateFrameInterval;
  H(end+1)=struct('ID',sprintf('reference-row%d-preceding-pocket',r),'ParentObservation',sprintf('reference-row%d-context',r),'Role','contextual_pocket_interval', ...
   'AuditRow',r,'SourceBinding',q.SHA256,'BoundCertainty',c.ExactBoundaryCertainty,'StartFrame',f(1),'EndFrame',f(2),'Footprint',double(Review.Traces{r}.Footprint(:)')); %#ok<AGROW>
 end
end
P.HumanContactSources=H;frames=[];
for k=1:numel(intervals),c=intervals(k);frames=union(frames,max(1,c.StartFrame-20):min(I.NFrames,c.EndFrame+20));end
if isfield(Review,'ReferenceSources')&&~isempty(Review.ReferenceSources)
 S=Review.ReferenceSources;assert(strcmp(S.AuditSHA256,Review.AuditSHA256),'OxygenDynamics:ContextSourceChanged','Native sources belong to another audit.');
 for k=1:2,assert(strcmp(oxygenFileSHA256(S.MasterPaths{k}),S.MasterSHA256{k}),'OxygenDynamics:ContextSourceChanged','Native source changed; reattach matching masters.');end
 N=repmat(struct('AuditRow',0,'Sign','','SiteID',0,'EventID',0,'Frames',[],'FramePixels',{{}}),height(A),1);
 for r=1:height(A),N(r)=struct('AuditRow',r,'Sign',char(A.EventType(r)),'SiteID',A.SiteID(r),'EventID',A.EventID(r),'Frames',Review.Traces{r}.DetectedFrames(:)','FramePixels',{S.EventFramePixels{r}});end
 N=N(string(A.RecordingID)==string(row.RecordingID));
 C=buildBOITemporalNativeContacts(frames,P.Footprint,N);P.NativeStatus='available';P.NativeSourceEvidence=rmfield(S,'EventFramePixels');
else
 C=cell(numel(frames),1);for j=1:numel(frames),C{j}=struct('Frame',frames(j),'FootprintPixels',numel(P.Footprint),'SinkPixels',NaN,'SurgePixels',NaN,'AnyPixels',NaN,'Contributors',{{}});end
end
cf=cellfun(@(v)v.Frame,C);
for k=1:numel(intervals)
 c=intervals(k);
 for W=[10 20]
  d=computeBOITemporalContext(y,c.StartFrame,c.EndFrame,W);q=struct('Interval',c,'ContextSamples',W,'Descriptor',d,'NativeStatus',P.NativeStatus);
  for part={'Before','Interval','After'},name=part{1};f=d.(name).Frames;q.([name 'Native'])=C(ismember(cf,f));q.([name 'Human'])=buildBOITemporalHumanContacts(f,P.Footprint,H);end
  P.Rows{end+1}=q;
 end
end
end
