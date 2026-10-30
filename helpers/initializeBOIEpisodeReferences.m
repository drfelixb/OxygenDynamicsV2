function E=initializeBOIEpisodeReferences(E,status,source)
% Append only derived fields; leave all original automatic columns intact.
if nargin<2,status="saved_evidence_unavailable";end
if nargin<3,source="unavailable";end
P=boiEpisodeReferencePolicy;n=height(E);
E.EpisodeReferenceVersion=repmat(string(P.Version),n,1);
E.EpisodeReferenceSource=repmat(string(source),n,1);
E.EpisodeReferenceStatus=repmat(string(status),n,1);
E.EpisodeReferenceKind=repmat("unavailable",n,1);
E.EpisodeReferenceStartFrame=nan(n,1);E.EpisodeReferenceEndFrame=nan(n,1);
E.EpisodeReferenceValue=nan(n,1);E.EpisodeAmplitudePercent=nan(n,1);
E.EpisodeReferenceValidSamples=zeros(n,1);E.EpisodeReferenceRequiredSamples=nan(n,1);
E.EpisodeReferenceShiftSec=nan(n,1);E.EpisodeReferenceMaxShiftSec=repmat(P.MaxReferenceShiftSec,n,1);
E.EpisodeHeadEventID=nan(n,1);E.EpisodeRecurrent=false(n,1);
E.EpisodeAcquisitionStart=false(n,1);E.EpisodeReferenceNeedsReview=true(n,1);
E.EpisodeReferenceAuditSHA256=repmat("",n,1);
end
