function [Info,Links]=createSurgeGapReview(Runs,Info,fs,maxGapSec,minOverlap)
% Geometric review candidates only: a dropout and true brief separation can
% produce identical masks. Never join runs, fill pixels or qualify duration.
assert(isscalar(fs)&&isfinite(fs)&&fs>0&&isscalar(maxGapSec)&&isfinite(maxGapSec)&&maxGapSec>=0);
assert(isscalar(minOverlap)&&isfinite(minOverlap)&&minOverlap>0&&minOverlap<=1);
N=size(Runs,2);starts=cell(1,N);n=height(Info);
Info.CandidateRunID=(1:n)';Info.PotentialGapContinuation=false(n,1);
Info.PotentialGapPredecessors=zeros(n,1);Info.PotentialGapSuccessors=zeros(n,1);
Links=table('Size',[0 5],'VariableTypes',repmat({'double'},1,5),'VariableNames', ...
 {'PreviousCandidateRunID','NextCandidateRunID','GapFrames','GapSec','EndpointMutualCoverage'});
for r=1:n,t=Info.NativeStartFrame(r);starts{t}(end+1)=r;end
for a=1:n
 last=Info.NativeEndFrame(a);left=Runs{a,last};
 for f=last+2:min(N,last+1+floor(maxGapSec*fs))
  for b=starts{f}
   right=Runs{b,f};coverage=numel(intersect(left,right))/max(numel(left),numel(right));
   if coverage<minOverlap,continue;end
   Links(end+1,:)={a,b,f-last-1,(f-last-1)/fs,coverage}; %#ok<AGROW>
   Info.PotentialGapContinuation([a b])=true;
   Info.PotentialGapSuccessors(a)=Info.PotentialGapSuccessors(a)+1;
   Info.PotentialGapPredecessors(b)=Info.PotentialGapPredecessors(b)+1;
  end
 end
end
end
