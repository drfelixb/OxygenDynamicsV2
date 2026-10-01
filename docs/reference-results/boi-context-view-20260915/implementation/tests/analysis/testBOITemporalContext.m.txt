function tests=testBOITemporalContext
tests=functiontests(localfunctions);
end
function setupOnce(~)
setupOxygenDynamicsPath;
end
function [path,root,masters]=fixture(nativeVariation)
if nargin<1,nativeVariation=false;end
root=tempname;mkdir(root);source=fullfile(root,'source.tif');
R=100*ones(4,5,30,'uint16');R(1,1,7:8)=80;R(2,1,15:16)=60;
if nativeVariation,R(3,1,7:8)=80;end
for k=1:30
    if k==1,imwrite(R(:,:,k),source);else,imwrite(R(:,:,k),source,'WriteMode','append');end
end
c=cell(1,30);c(7:8)={1};c(15:16)={2};Sites=table({c},'VariableNames',{'FramePixels'});
if nativeVariation,Sites.FramePixels{1}{7}=[1;3];end
Sites.RecordingID="R";Sites.SiteID=1;Sites.FrameSize={[4 5]};Sites.NFrames=30;Sites.SampleF=1;
E=table(["R";"R"],[1;1],[1;2],[7;15],[8;16],[100;100],["valid";"valid"],[4;4],[.2;.4], ...
    'VariableNames',{'RecordingID','SinkID','EventID','StartFrame','EndFrame','BaselineValue','BaselineStatus','BaselineValidSamples','NormOxySinkAmp'});
[A,T]=auditOxygenEventFootprints(Sites,E,Sites([],:),R,4,'sink');
Table_OxygenSinks_Out=Sites;Table_OxygenSinkEvents_Out=E;
E=renamevars(E,{'SinkID','NormOxySinkAmp'},{'SurgeID','NormOxySurgeAmp'});E.NormOxySurgeAmp=-E.NormOxySurgeAmp;
[B,U]=auditOxygenEventFootprints(Sites,E,Sites([],:),R,4,'surge');
Table_OxygenSurges_Out=Sites;Table_OxygenSurgeEvents_Out=E;
Audit=[A;B];Traces=[T;U];
AnalysisInfo=struct('RawFile',source,'RawSHA256',oxygenFileSHA256(source),'NFrames',30, ...
    'FrameSize',[4 5],'AnalysisParams',struct('fs',1));
Audit.SourceRawSHA256=repmat(string(AnalysisInfo.RawSHA256),height(Audit),1);
path=fullfile(root,'event-amplitude-audit.mat');save(path,'Audit','Traces','AnalysisInfo');
masters={fullfile(root,'sink-master.mat'),fullfile(root,'surge-master.mat')};
save(masters{1},'AnalysisInfo','Table_OxygenSinks_Out','Table_OxygenSinkEvents_Out');
save(masters{2},'AnalysisInfo','Table_OxygenSurges_Out','Table_OxygenSurgeEvents_Out');
end
function a=humanAnnotation()
a=struct('Status','recognized','OnsetFrames',[5 6],'RecoveryFrames',[9 10], ...
    'PreferredOnsetFrame',6,'PreferredRecoveryFrame',[],'Reviewer','Developer fixture — not researcher evidence', ...
    'Reason','Synthetic test: uncertain shoulders; retain explicit alternatives.');
end
function writeBoundaryTestJSON(path,J)
fid=fopen(path,'w');cleanup=onCleanup(@()fclose(fid));fprintf(fid,'%s',jsonencode(J));
end
function [R,jpath,J]=referenceJudgmentFixture(R,root)
a=humanAnnotation();a.OnsetFrames=[24 25];a.PreferredOnsetFrame=25;a.RecoveryFrames=27;
R.BoundaryReview=saveBOIBoundaryReview(R,1,a,fullfile(root,'human-boundary.json'));
B=getBOIBoundaryReview(R,1);
J=struct('Schema','boi-researcher-reference-acceptance-1','DecisionID','SYNTHETIC-ONLY', ...
    'Reviewer','Synthetic fixture','RecordedUTC','2026-09-15T00:00:00Z', ...
    'BoundaryReviewSHA256',R.BoundaryReview.SHA256,'AuditRow',1,'SavedEvent',B.Event, ...
    'BoundaryAnnotationUnchanged',B.Annotation,'AcceptedReferenceFrames',(7:18)', ...
    'AcceptedSampleCount',12,'ReferenceJudgment','accepted_as_shorter_event_specific_pre_event_reference');
jpath=fullfile(root,'reference.json');writeBoundaryTestJSON(jpath,J);
end
function testKnownShapeDefinitionsRemainUnchanged(t)
here=fileparts(mfilename('fullpath'));root=fileparts(fileparts(fileparts(here)));f=fullfile(root,'reference-validation','boi-fb2420-temporal-comparison-20260915','known-shape-tests.json');S=jsondecode(fileread(f));
for k=1:numel(S.Fixtures)
 q=S.Fixtures(k);D=computeBOITemporalContext(q.Input,q.StartFrame,q.EndFrame,q.ContextSamples);
 verifyEqual(t,jsondecode(jsonencode(D)),q.Result,'AbsTol',1e-12);
end
end
function testMissingSignalAndNativeSupportStayUnknown(t)
[path,root]=fixture;c=onCleanup(@()rmdir(root,'s'));R=loadBOIEventReview(path);P=buildBOITemporalContextPreview(R,1);
verifyEqual(t,P.NativeStatus,'not_attached');verifyEqual(t,numel(P.Rows),2);verifyTrue(t,all(isnan(P.CorrectedTrace)));
verifyEqual(t,P.Rows{1}.Descriptor.Interval.Status,'nonfinite_samples');verifyTrue(t,all(cellfun(@(v)isnan(v.AnyPixels),P.Rows{1}.BeforeNative)));
R.AnalysisInfo.AnalysisParams.fs=2;P=buildBOITemporalContextPreview(R,1);verifyEqual(t,P.Status,'unsupported_clock');verifyEmpty(t,P.Rows);
end
function testReferencesContactAndExportRemainSeparate(t)
[path,root,masters]=fixture;c=onCleanup(@()rmdir(root,'s'));addCorrected(path);R=loadBOIEventReview(path);[R,jpath]=referenceJudgmentFixture(R,root);R=loadBOIReferenceJudgments(R,jpath);R=attachBOIReferenceSources(R,masters{:});
original=R.Audit;P=buildBOITemporalContextPreview(R,1);verifyEqual(t,numel(P.Rows),6);verifyEqual(t,P.AcceptedReferences.Frames,(7:18)');
verifyEqual(t,P.Rows{5}.Descriptor.Before.Frames,15:24);verifyEqual(t,P.Rows{6}.Descriptor.Before.Frames,5:24);verifyEqual(t,P.NewBaselineCalculations,0);
verifyEqual(t,P.Rows{1}.NativeStatus,'available');verifyEqual(t,R.Audit,original);
out=fullfile(root,'context');Q=exportBOITemporalContext(R,1,out);verifyEqual(t,Q.AcceptedReferences.Frames,(7:18)');verifyTrue(t,isfile(fullfile(out,'ArtifactChecksums.json')));
verifyError(t,@()exportBOITemporalContext(R,1,out),'OxygenDynamics:ContextOutputExists');
end
function testMainGuiOptionalAndStaleSelectionClears(t)
[path,root]=fixture;c=onCleanup(@()rmdir(root,'s'));addCorrected(path);[fig,UI]=openBOIEventReview(path);cf=onCleanup(@()delete(fig));
verifyEmpty(t,UI.Context.Preview());UI.Context.Compute();verifyEqual(t,numel(UI.Context.Preview().Rows),2);verifyNotEmpty(t,findall(UI.Context.Axes,'Tag','BOIContextTrace'));
for scale=[20 10]
 UI.Context.Scale.Value=scale;UI.Context.Scale.ValueChangedFcn([],[]);
 trace=findall(UI.Context.Axes,'Tag','BOIContextTrace');limits=UI.Context.Axes.YLim;
 verifyLessThan(t,limits(1),min(trace.YData));verifyGreaterThan(t,limits(2),max(trace.YData));
end
verifyEqual(t,UI.Context.PlotHost.Layout.Row,3);verifyEqual(t,UI.Context.Table.Layout.Row,4);
UI.Select(2);verifyEmpty(t,UI.Context.Preview());verifyEmpty(t,findall(UI.Context.Axes,'Tag','BOIContextBound'));verifyEmpty(t,UI.Context.Table.Data);verifyEqual(t,UI.Context.Export.Enable,matlab.lang.OnOffSwitchState.off);
end
function testReferenceGuiAndChangedArtifactInvalidation(t)
[path,root,masters]=fixture;c=onCleanup(@()rmdir(root,'s'));addCorrected(path);R=loadBOIEventReview(path);[R,jpath,J]=referenceJudgmentFixture(R,root);
[fig,UI]=openBOIEventReview(path);cf=onCleanup(@()delete(fig));UI.LoadBoundaries(R.BoundaryReview.Path);UI.AttachReferenceSources(masters{:});UI.LoadReferenceJudgments(jpath);UI.Context.Compute();
marks=findall(UI.Context.Axes,'Tag','BOIContextAcceptedReference');verifyEqual(t,marks.XData,7:18);UI.Context.Choice.Value=3;UI.Context.Choice.ValueChangedFcn([],[]);
verifyTrue(t,any(contains(string(UI.Context.Info.Value),'12 samples')));verifyEqual(t,UI.Context.Preview().AcceptedReferences.Frames,(7:18)');
J.Reviewer='changed';writeBoundaryTestJSON(jpath,J);UI.Context.Scale.ValueChangedFcn([],[]);verifyEmpty(t,UI.Context.Preview());verifyEmpty(t,findall(UI.Context.Axes,'Tag','BOIContextAcceptedReference'));verifyTrue(t,any(contains(string(UI.Context.Info.Value),'unavailable')));
end
function testLegacyGeometryExplicitAndSourceBound(t)
[path,root,masters]=fixture;c=onCleanup(@()rmdir(root,'s'));addCorrected(path);
for f=[{path},masters],S=load(f{1});S.AnalysisInfo=rmfield(S.AnalysisInfo,'FrameSize');save(f{1},'-struct','S');end
before=oxygenFileSHA256(path);verifyError(t,@()loadBOITemporalReview(path),'OxygenDynamics:ContextGeometryRequired');R=loadBOITemporalReview(path,masters{1});verifyFalse(t,isfield(R.AnalysisInfo,'FrameSize'));verifyEqual(t,R.DiagnosticFrameSize,[4 5]);R=attachBOITemporalSources(R,masters{:});
P=buildBOITemporalContextPreview(R,1);verifyEqual(t,P.NativeStatus,'available');verifyEqual(t,oxygenFileSHA256(path),before);verifyEqual(t,P.GeometryEvidence.SHA256,oxygenFileSHA256(masters{1}));verifyFalse(t,P.GeometryEvidence.OriginalAnalysisInfoHadFrameSize);
[fig,UI]=openBOITemporalContext(path,masters{:});cf=onCleanup(@()delete(fig));UI.Context.Compute();verifyEqual(t,UI.Context.Preview().NativeStatus,'available');
end
function addCorrected(path)
S=load(path);for k=1:numel(S.Traces),S.Traces{k}.DetectionDetrended=double(S.Traces{k}.Raw(:))-100;end;save(path,'-struct','S');
end
