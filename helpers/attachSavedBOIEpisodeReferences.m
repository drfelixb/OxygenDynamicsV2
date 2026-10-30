function E=attachSavedBOIEpisodeReferences(E,SinkFile,SurgeFile,RecordingFolder,fs)
% Read-only adapter: derive from receipt-bound audits without reopening movies.
P=boiEpisodeReferencePolicy;
if ~istable(E)
    assert(isempty(E),'OxygenDynamics:EpisodeEvidence','Expected a saved event table.');E=table();
end
if ismember('EpisodeReferenceVersion',E.Properties.VariableNames)
    getBOISinkBurdenAmplitude(E); % validates supported version; preserve live derivation
    return
end
E=initializeBOIEpisodeReferences(E);
if isempty(E),return;end
auditFile=fullfile(RecordingFolder,'BOIReview','event-amplitude-audit.mat');
receiptFile=fullfile(RecordingFolder,'BOIReview','AuditCreationReceipt.json');
if ~isfile(auditFile)||~isfile(receiptFile),return;end
R=jsondecode(fileread(receiptFile));auditSHA=oxygenFileSHA256(auditFile);
assert(strcmp(R.Schema,'boi-created-event-audit-1')&&strcmp(R.AuditSHA256,auditSHA)&& ...
    numel(R.MasterSHA256)==2&&strcmp(R.MasterSHA256{1},oxygenFileSHA256(SinkFile))&& ...
    strcmp(R.MasterSHA256{2},oxygenFileSHA256(SurgeFile)), ...
    'OxygenDynamics:EpisodeSourceMismatch','Audit receipt does not bind these exact saved masters.');
S=load(SinkFile,'Table_OxygenSinks_Out','Table_OxygenSinkEvents_Out','AnalysisInfo');
U=load(SurgeFile,'Table_OxygenSurges_Out','AnalysisInfo');
A=load(auditFile,'Audit','Traces','AnalysisInfo');
assert(strcmp(R.SourceSHA256,S.AnalysisInfo.RawSHA256)&& ...
    strcmp(R.SourceSHA256,U.AnalysisInfo.RawSHA256)&&strcmp(R.SourceSHA256,A.AnalysisInfo.RawSHA256)&& ...
    fs==A.AnalysisInfo.AnalysisParams.fs&&fs==S.AnalysisInfo.AnalysisParams.fs&& ...
    fs==U.AnalysisInfo.AnalysisParams.fs&&R.EventCount==height(A.Audit)&&numel(A.Traces)==height(A.Audit), ...
    'OxygenDynamics:EpisodeSourceMismatch','Audit source identity, clock or event inventory differs.');
F=S.Table_OxygenSinkEvents_Out;
rows=find(string(A.Audit.EventType)=="sink");B=A.Audit(rows,:);traces=A.Traces(rows);
assert(height(B)==height(F)&&height(unique(B(:,{'SiteID','EventID'}),'rows'))==height(B), ...
    'OxygenDynamics:EpisodeSourceMismatch','Audit must contain exactly the full native sink inventory.');
evidence=cell(height(F),1);
for e=1:height(F)
    j=find(B.SiteID==F.SinkID(e)&B.EventID==F.EventID(e));
    assert(isscalar(j),'OxygenDynamics:EpisodeSourceMismatch','Missing or duplicate audited event.');
    T=traces{j};c=S.Table_OxygenSinks_Out.FramePixels{F.SinkID(e)};
    runs=regionprops(~cellfun(@isempty,c),'PixelIdxList');native=runs(F.EventID(e)).PixelIdxList;
    px=unique(vertcat(c{native}));
    assert(B.StartFrame(j)==F.StartFrame(e)&&B.EndFrame(j)==F.EndFrame(e)&& ...
        B.DetectedStartFrame(j)==native(1)&&B.DetectedEndFrame(j)==native(end)&& ...
        isequal(double(T.DetectedFrames(:)),double(native(:)))&&isequal(double(T.Footprint(:)),double(px(:)))&& ...
        strcmp(string(B.SourceRawSHA256(j)),R.SourceSHA256)&& ...
        sameNumber(B.StoredAmplitude(j),F.NormOxySinkAmp(e)), ...
        'OxygenDynamics:EpisodeSourceMismatch','Saved event identity, footprint or original amplitude differs.');
    evidence{e}=T;
end
N=A.AnalysisInfo.NFrames;
assert(S.AnalysisInfo.NFrames==N&&U.AnalysisInfo.NFrames==N, ...
    'OxygenDynamics:EpisodeSourceMismatch','Saved recording lengths differ.');
native=collectBOINativePixels(S.Table_OxygenSinks_Out,U.Table_OxygenSurges_Out,N);
F=deriveBOIPreEpisodeReferences(F,evidence,native,fs, ...
    S.AnalysisInfo.AnalysisParams.quantBaselineWindowSec,"saved_audit_verified");
F.EpisodeReferenceAuditSHA256(:)=string(auditSHA);
fields=F.Properties.VariableNames(startsWith(F.Properties.VariableNames,'Episode'));
for e=1:height(E)
    j=find(F.SinkID==E.SinkID(e)&F.EventID==E.EventID(e));
    assert(isscalar(j)&&F.StartFrame(j)==E.StartFrame(e)&&F.EndFrame(j)==E.EndFrame(e)&& ...
        sameNumber(F.NormOxySinkAmp(j),E.NormOxySinkAmp(e)), ...
        'OxygenDynamics:EpisodeSourceMismatch','Statistics event differs from its saved source.');
    for f=fields,E.(f{1})(e,:)=F.(f{1})(j,:);end
end
assert(all(E.EpisodeReferenceVersion==string(P.Version)));
end
function same=sameNumber(a,b)
same=(isnan(a)&&isnan(b))||(isfinite(a)&&isfinite(b)&&abs(a-b)<=1e-10*max(1,abs(b)));
end
