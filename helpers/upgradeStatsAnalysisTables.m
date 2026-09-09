function [S,E] = upgradeStatsAnalysisTables(S,E,M,MatFile,kind)
% Validate current-run inputs. No legacy duration or amplitude conversion.
Info=loadOptionalMatVar(MatFile,'AnalysisInfo',struct());
validateOxygenPipelineContract(Info,M);
if strcmp(kind,'sink'), traceName='Mean_OxySink_Trace_Convo'; rec='RecDuration'; dur='Duration'; amp='NormOxySinkAmp';
else, traceName='Mean_ROI_TraceZ';rec='RecDuration_Surge';dur='Duration_Surge';amp='NormOxySurgeAmp';end
if strcmp(kind,'sink'), support='SinkEligibleTissuePixels';else,support='SurgeEligibleTissuePixels';end
if isfield(Info,support),S.EligibleTissuePixels=repmat({Info.(support)},height(S),1);end
if ~ismember('SiteID',S.Properties.VariableNames), S.SiteID=(1:height(S))'; end
trace=loadOptionalMatVar(MatFile,traceName,[]); N=size(trace,2);
if isfield(Info,'NFrames'), N=Info.NFrames; end
assert(isfield(M,'SampleF') && isfinite(M.SampleF) && M.SampleF>0, ...
    'OxygenDynamics:MissingSampleRate','A positive recording SampleF is required.');
fs=M.SampleF;
S.NFrames=repmat(N,height(S),1); S.SampleF=repmat(fs,height(S),1);
S.(rec)=repmat({N/fs},height(S),1);
if ~istable(E) && height(S)>0
    error('OxygenDynamics:MissingEventRows','This recording has sites but no event table. Rerun the master analysis before computing event statistics.');
end
if istable(E)
    if ~ismember('RecAreaSize',E.Properties.VariableNames)
        E.RecAreaSize=nan(height(E),1);
        if strcmp(kind,'sink'), sid='SinkID'; area='RecAreaSize'; else, sid='SurgeID'; area='RecAreaSize_Surge'; end
        for i=1:height(E)
            j=find(S.SiteID==E.(sid)(i),1);
            if ~isempty(j), E.RecAreaSize(i)=S.(area){j}; end
        end
    end
    E.RecDuration=repmat(N/fs,height(E),1);
    E.NFrames=repmat(N,height(E),1); E.SampleF=repmat(fs,height(E),1);
    E.StartSec=(E.StartFrame-1)/fs; E.EndSec=E.EndFrame/fs;
    E.DurationFrames=E.EndFrame-E.StartFrame+1; E.DurationSec=E.DurationFrames/fs;
end
end
