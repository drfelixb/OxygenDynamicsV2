function E=initializeBOIEventReferences(E,status,source)
% Append new columns only; strict, pre-episode and saved AUC remain evidence.
if nargin<2,status="saved_evidence_unavailable";end
if nargin<3,source="unavailable";end
P=boiEventReferencePolicy;n=height(E);
assert(~ismember('EventReferenceVersion',E.Properties.VariableNames), ...
    'OxygenDynamics:EventReferenceExists','Preserve an existing versioned event reference.');
E.EventReferenceVersion=repmat(string(P.Version),n,1);
E.EventReferenceSource=repmat(string(source),n,1);
E.EventReferenceFootprintSource=repmat("unavailable",n,1);
E.EventReferenceAuditSHA256=repmat("",n,1);
E.EventReferenceStatus=repmat(string(status),n,1);
E.EventReferenceKind=repmat("unavailable",n,1);
for f={'StartFrame','EndFrame','Value','RequestedSamples','ObservedSamples','FiniteSamples','MissingSamples','OverlapFrames'}
    E.(['EventReference' f{1}])=nan(n,1);
    E.(['RecordingReference' f{1}])=nan(n,1);
end
E.EventReferenceOverlapStatus=repmat("not_assessed",n,1);
E.EventAmplitudePercent=nan(n,1);E.EventMinimumValue=nan(n,1);
E.EventAmplitudeAvailable=false(n,1);E.EventSignalComplete=false(n,1);
E.EventAmplitudeNegative=false(n,1);
for f={'Short','Overlapping','PostEvent','MissingSamplesFlag','RecoveryUnverified'}
    E.(['EventReference' f{1}])=false(n,1);
end
E.EventReferenceNeedsReview=true(n,1);
E.RecordingReferenceVersion=repmat(string(P.RecordingComparisonVersion),n,1);
E.RecordingReferenceSource=repmat("unavailable",n,1);
E.RecordingReferenceEvidenceSource=repmat(string(source),n,1);
E.RecordingReferenceStatus=repmat(string(status),n,1);
E.RecordingReferenceRequestedStartFrame=nan(n,1);
E.RecordingReferenceRequestedEndFrame=nan(n,1);
E.RecordingReferenceOverlapStatus=repmat("not_assessed",n,1);
for f={'Short','Overlapping','MissingSamplesFlag','Override','Preceding'}
    E.(['RecordingReference' f{1}])=false(n,1);
end
E.RecordingReferenceNeedsReview=true(n,1);
E.AboveRecordingReference=nan(n,1);
end
