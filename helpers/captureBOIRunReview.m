function AuditPath=captureBOIRunReview(D,I,MasterPaths)
%CAPTUREBOIRUNREVIEW Capture existing full-precision stages, never reconstruct.
% Quantitative optical replay still uses the original raw input and baseline.
out=fullfile(D.RecordingFolder,'BOIReview');
assert(~isfolder(out),'OxygenDynamics:AuditOutputExists','Use a new recording run for review capture.');
[A,T]=auditOxygenEventFootprints(D.Table_OxygenSinks_Out,D.Table_OxygenSinkEvents_Out, ...
    D.Table_OxygenSurges_Out,D.ReviewRaw,round(I.AnalysisParams.quantBaselineWindowSec*I.AnalysisParams.fs),'sink');
[B,U]=auditOxygenEventFootprints(D.Table_OxygenSurges_Out,D.Table_OxygenSurgeEvents_Out, ...
    D.Table_OxygenSinks_Out,D.ReviewRaw,round(I.AnalysisParams.surgeBaselineWindowSec*I.AnalysisParams.fs),'surge');
Audit=[A;B];Traces=[T;U];
Audit.Condition=[string(D.Table_OxygenSinkEvents_Out.Condition);string(D.Table_OxygenSurgeEvents_Out.Condition)];
Audit.SourceRawSHA256=repmat(string(I.RawSHA256),height(Audit),1);
corrected=reshape(D.IM_Notrend,[],I.NFrames);
score=reshape(D.IM_Zframetime_smoothed,[],I.NFrames);
for e=1:height(Audit)
    t=Traces{e};px=t.Footprint;
    t.DetectionDetrended=mean(double(corrected(px,:)),1);
    t.Filtered=mean(double(score(px,:)),1);
    if Audit.EventType(e)=="sink"
        t.SiteNormalized=double(D.Mean_OxySink_TraceZ(Audit.SiteID(e),:));
        t.TimingTrace=double(D.Mean_OxySink_Trace_Convo(Audit.SiteID(e),:));
    else
        t.SiteNormalized=double(D.Mean_OxySurge_TraceZ(Audit.SiteID(e),:));
        t.TimingTrace=t.SiteNormalized;
    end
    Traces{e}=t;
end
assert(all(Audit.MeasurementMatches),'OxygenDynamics:RunReviewMismatch', ...
    'Independent optical replay disagrees with saved measurements. Retain this incomplete run for investigation.');
mkdir(out);AnalysisInfo=I;
AuditPath=fullfile(out,'event-amplitude-audit.mat');
save(AuditPath,'Audit','Traces','AnalysisInfo');
writetable(Audit,fullfile(out,'event-amplitude-audit.csv'));
Receipt=struct('Schema','boi-created-event-audit-1','AuditSHA256',oxygenFileSHA256(AuditPath), ...
    'SourceSHA256',I.RawSHA256,'MasterPaths',{MasterPaths}, ...
    'MasterSHA256',{{oxygenFileSHA256(MasterPaths{1}),oxygenFileSHA256(MasterPaths{2})}}, ...
    'EventCount',height(Audit),'MeasurementMismatches',sum(~Audit.MeasurementMatches), ...
    'WrongDirectionCount',sum(Audit.WrongDirection),'DetectorReruns',0,'StatisticsReruns',0, ...
    'StageOrigin','existing_in_memory_full_precision_stages','ScientificStatus','not_established');
writeBOIRunJSON(fullfile(out,'AuditCreationReceipt.json'),Receipt);
end
