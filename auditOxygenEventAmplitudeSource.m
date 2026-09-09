function [Audit,Traces]=auditOxygenEventAmplitudeSource(recordingFolder,varargin)
%AUDITOXYGENEVENTAMPLITUDESOURCE Audit both signs using preserved source pixels.
% [Audit,Traces] = auditOxygenEventAmplitudeSource(recordingFolder)
% Optional 'reconstructDetection',true rebuilds full-precision detection stages.
% Optional 'outputFolder',newFolder writes CSV, MAT and flagged-event PNGs.
% Processed TIFFs are display-scaled and must not be used as numerical inputs.
setupOxygenDynamicsPath;
p=inputParser;p.addParameter('reconstructDetection',false,@islogical);
p.addParameter('outputFolder','',@(x)ischar(x)||isstring(x));p.parse(varargin{:});o=p.Results;
if strlength(string(o.outputFolder))>0
    assert(~isfolder(o.outputFolder),'OxygenDynamics:AuditOutputExists','Use a new audit output folder.');
end
S=readUnique(recordingFolder,'OxygenSinks_Output*','OxygenSinks_Urefined*.mat');
G=readUnique(recordingFolder,'OxygenSurges_Output*','OxygenSurges*.mat');
I=S.AnalysisInfo;J=G.AnalysisInfo;
assert(isequaln(I,J),'OxygenDynamics:AuditSourceMismatch','Sink/surge provenance differs.');
validateOxygenPipelineContract(I,struct('SampleF',I.AnalysisParams.fs,'PixelSize',I.AnalysisParams.PixelSize));
assert(strcmp(oxygenFileSHA256(I.RawFile),I.RawSHA256),'OxygenDynamics:SourceChanged','Preserved source has changed.');
[Raw,~,~]=loadtiff(I.RawFile);
assert(size(Raw,3)==I.NFrames,'OxygenDynamics:AuditDimensions','Source frame count differs.');
[A,T]=auditOxygenEventFootprints(S.Table_OxygenSinks_Out,S.Table_OxygenSinkEvents_Out, ...
    G.Table_OxygenSurges_Out,Raw,round(I.AnalysisParams.quantBaselineWindowSec*I.AnalysisParams.fs),'sink');
[B,U]=auditOxygenEventFootprints(G.Table_OxygenSurges_Out,G.Table_OxygenSurgeEvents_Out, ...
    S.Table_OxygenSinks_Out,Raw,round(I.AnalysisParams.surgeBaselineWindowSec*I.AnalysisParams.fs),'surge');
Audit=[A;B];Traces=[T;U];
Audit.Condition=[string(S.Table_OxygenSinkEvents_Out.Condition);string(G.Table_OxygenSurgeEvents_Out.Condition)];
if o.reconstructDetection
    Detection=Raw;
    if ~isempty(I.DenoisedFile)
        assert(strcmp(oxygenFileSHA256(I.DenoisedFile),I.DenoisedSHA256),'OxygenDynamics:SourceChanged','Detection source has changed.');
        [Detection,~,~]=loadtiff(I.DenoisedFile);
        assert(isequal(size(Detection),size(Raw)),'OxygenDynamics:AuditDimensions','Detection source dimensions differ.');
    end
    D=single(detrend_custom(Detection,3));clear Detection Raw
    [Z,F]=preprocessDetectionStack(D,I.AnalysisParams.smooth);
    % Reconstruct saved site traces before interpreting event-footprint stages.
    verifySiteTraces(S.Table_OxygenSinks_Out,S.Mean_OxySink_TraceZ,Z,true);
    verifySiteTraces(S.Table_OxygenSinks_Out,S.Mean_OxySink_Trace_Convo,F,true);
    verifySiteTraces(G.Table_OxygenSurges_Out,G.Mean_OxySurge_TraceZ,Z,false);
    D=reshape(D,[],I.NFrames);Z=reshape(Z,[],I.NFrames);F=reshape(F,[],I.NFrames);
    frameMean=zeros(1,I.NFrames);frameSD=frameMean;
    for frame=1:I.NFrames
        values=double(D(:,frame));frameMean(frame)=mean(values);frameSD(frame)=std(values);
    end
    frameSD(frameSD==0)=Inf;
    Audit.NativeFilteredMean=nan(height(Audit),1);Audit.NativeZMean=nan(height(Audit),1);
    Audit.RawExtremeFrame=nan(height(Audit),1);Audit.RawChangeAtExtremePercent=nan(height(Audit),1);
    Audit.CubicTrendContributionPercent=nan(height(Audit),1);Audit.ResidualContributionPercent=nan(height(Audit),1);
    Audit.DetrendedChangeAtRawExtreme=nan(height(Audit),1);
    Audit.SpatialZChangeAtRawExtreme=nan(height(Audit),1);Audit.TemporalZChangeAtRawExtreme=nan(height(Audit),1);
    for e=1:height(Audit)
        t=Traces{e};px=t.Footprint;
        t.DetectionDetrended=mean(double(D(px,:)),1);t.Normalized=mean(double(Z(px,:)),1);
        t.Filtered=mean(double(F(px,:)),1);
        t.SpatialNormalized=mean(double(single((double(D(px,:))-frameMean)./frameSD)),1);
        if Audit.EventType(e)=="sink"
            t.SiteNormalized=double(S.Mean_OxySink_TraceZ(Audit.SiteID(e),:));
            t.TimingTrace=double(S.Mean_OxySink_Trace_Convo(Audit.SiteID(e),:));
            [ct,~,mt]=polyfit(1:I.NFrames,t.TimingTrace,7);
            t.TimingTrend=polyval(ct,1:I.NFrames,[],mt);
        else
            t.SiteNormalized=double(G.Mean_OxySurge_TraceZ(Audit.SiteID(e),:));
            t.TimingTrace=t.SiteNormalized;t.TimingTrend=nan(size(t.TimingTrace));
        end
        [coef,~,mu]=polyfit(1:I.NFrames,t.Raw,3);t.RawCubicTrend=polyval(coef,1:I.NFrames,[],mu);
        Audit.NativeFilteredMean(e)=mean(t.Filtered(t.DetectedFrames));
        Audit.NativeZMean(e)=mean(t.Normalized(t.DetectedFrames));
        if Audit.RecomputedStatus(e)=="valid"
            w=Audit.StartFrame(e):Audit.EndFrame(e);
            if Audit.EventType(e)=="sink",[~,idx]=min(t.Raw(w));else,[~,idx]=max(t.Raw(w));end
            q=w(idx);b=t.CleanBaselineFrames;B0=Audit.RecomputedBaseline(e);
            total=100*(t.Raw(q)-mean(t.Raw(b)))/B0;
            trend=100*(t.RawCubicTrend(q)-mean(t.RawCubicTrend(b)))/B0;
            residual=t.Raw-t.RawCubicTrend;rem=100*(residual(q)-mean(residual(b)))/B0;
            assert(abs(total-trend-rem)<1e-8,'OxygenDynamics:AuditDecomposition','Raw decomposition differs.');
            Audit.RawExtremeFrame(e)=q;Audit.RawChangeAtExtremePercent(e)=total;
            Audit.CubicTrendContributionPercent(e)=trend;Audit.ResidualContributionPercent(e)=rem;
            Audit.DetrendedChangeAtRawExtreme(e)=t.DetectionDetrended(q)-mean(t.DetectionDetrended(b));
            Audit.SpatialZChangeAtRawExtreme(e)=t.SpatialNormalized(q)-mean(t.SpatialNormalized(b));
            Audit.TemporalZChangeAtRawExtreme(e)=t.Normalized(q)-mean(t.Normalized(b));
        end
        Traces{e}=t;
    end
end
Audit.SourceRawSHA256=repmat(string(I.RawSHA256),height(Audit),1);
if strlength(string(o.outputFolder))>0
    mkdir(o.outputFolder);writetable(Audit,fullfile(o.outputFolder,'event-amplitude-audit.csv'));
    AnalysisInfo=I;save(fullfile(o.outputFolder,'event-amplitude-audit.mat'),'Audit','Traces','AnalysisInfo');
    if o.reconstructDetection,plotOxygenEventAudit(Audit,Traces,I,o.outputFolder);end
end
fprintf('Audited %d events; %d measurement mismatches; %d wrong-direction amplitudes.\n', ...
    height(Audit),sum(~Audit.MeasurementMatches),sum(Audit.WrongDirection));
end
function S=readUnique(root,folder,pattern)
files=dir(fullfile(root,folder,pattern));
assert(isscalar(files),'OxygenDynamics:AmbiguousAuditSource','Require exactly one matching %s file under %s.',pattern,root);
S=load(fullfile(files(1).folder,files(1).name));
end
function verifySiteTraces(S,stored,Z,subtractFifthOrder)
Z=reshape(Z,[],size(Z,3));
for s=1:height(S)
    c=S.FramePixels{s};px=unique(vertcat(c{:}));
    reconstructed=double(mean(Z(px,:),1));
    if subtractFifthOrder,reconstructed=detrend_custom(reconstructed,2);end
    actual=stored(s,:);
    assert(all(abs(double(reconstructed)-double(actual))<=1e-5*max(1,abs(double(actual)))), ...
        'OxygenDynamics:DetectionReconstructionMismatch','Reconstructed normalized site trace differs from saved analysis.');
end
end
