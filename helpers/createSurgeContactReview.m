function [Info,Frames]=createSurgeContactReview(Runs,Info,Edges,fs,pixelSize)
% Contact exposure uses entire candidate masks at contact endpoints. It is
% not an estimate of contaminated pixels, physiological identity or pO2.
assert(isscalar(fs)&&isfinite(fs)&&fs>0&&isscalar(pixelSize)&&isfinite(pixelSize)&&pixelSize>0);
n=height(Info);assert(n==size(Runs,1)&&isequal(Info.CandidateRunID,(1:n)'));
Info.ContactFrameCount=zeros(n,1);Info.ContactFrames=strings(n,1);
Info.ContactDurationSec=zeros(n,1);Info.ContactFrameFraction=zeros(n,1);
Info.ContactFrameFootprintFraction=zeros(n,1);
Info.ContactEdgeCount=zeros(n,1);Info.LinkedContactEdgeCount=zeros(n,1);
Info.ContactNeighborCandidateRunIDs=strings(n,1);Info.ContactWithRejectedCandidate=false(n,1);
C=Edges(Edges.Contact,:);
nodes=unique([C.PreviousCandidateRunID C.FromFrame;C.NextCandidateRunID C.ToFrame],'rows');
Frames=table('Size',[size(nodes,1) 8],'VariableTypes',repmat({'double'},1,8),'VariableNames', ...
 {'CandidateRunID','Frame','TimeSec','CandidatePixels','CandidateAreaUm2', ...
 'IncomingContactEdges','OutgoingContactEdges','LinkedContactEdges'});
for j=1:size(nodes,1)
 r=nodes(j,1);f=nodes(j,2);incoming=C.NextCandidateRunID==r & C.ToFrame==f;
 outgoing=C.PreviousCandidateRunID==r & C.FromFrame==f;
 px=Runs{r,f};assert(~isempty(px));
 Frames(j,:)={r,f,(f-1)/fs,numel(px),numel(px)*pixelSize^2,nnz(incoming),nnz(outgoing),nnz((incoming|outgoing)&C.Linked)};
end
for r=reshape(unique(nodes(:,1)),1,[])
 f=nodes(nodes(:,1)==r,2)';incident=C.PreviousCandidateRunID==r | C.NextCandidateRunID==r;
 neighbors=unique([C.PreviousCandidateRunID(incident);C.NextCandidateRunID(incident)]);neighbors(neighbors==r)=[];
 Info.ContactFrameCount(r)=numel(f);Info.ContactFrames(r)=strjoin(string(f),';');
 Info.ContactDurationSec(r)=numel(f)/fs;Info.ContactFrameFraction(r)=numel(f)/Info.DurationFrames(r);
 allPixels=unique(vertcat(Runs{r,:}));contactPixels=unique(vertcat(Runs{r,f}));
 Info.ContactFrameFootprintFraction(r)=numel(contactPixels)/numel(allPixels);
 Info.ContactEdgeCount(r)=nnz(incident);Info.LinkedContactEdgeCount(r)=nnz(incident & C.Linked);
 Info.ContactNeighborCandidateRunIDs(r)=strjoin(string(neighbors'),';');
 Info.ContactWithRejectedCandidate(r)=any(~Info.KeptAsEvent(neighbors));
end
assert(isequal(Info.AmbiguousTracking,Info.ContactFrameCount>0),'Contact ledger disagrees with tracking ambiguity.');
end
