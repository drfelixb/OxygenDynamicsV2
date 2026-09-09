function R=estimateSurgeLocalOnset(trace,native,fs,blocked)
% Validation-only broken-line onset on fixed raw support. See protocol.
validateattributes(trace,{'numeric'},{'vector','real','nonempty'});
validateattributes(fs,{'numeric'},{'scalar','real','finite','positive'});
trace=double(trace(:)');blocked=logical(blocked(:)');
validateattributes(native,{'numeric'},{'vector','integer','positive'});
assert(numel(blocked)==numel(trace)&&isequal(native(:)',native(1):native(end))&&native(end)<=numel(trace));
b=max(1,round(20*fs));extension=max(1,floor(40*fs));look=floor(4*fs);
s=native(1);lo=s-extension;first=lo-b;last=min(native(end),s+look);
R=struct('Status',"unassessed",'OnsetFrame',NaN,'BestCandidateFrame',NaN, ...
 'FitStartFrame',first,'FitEndFrame',last,'ScoreImprovement',NaN, ...
 'ProfileStartFrame',NaN,'ProfileEndFrame',NaN,'ProfileSpanSec',NaN, ...
 'BaselineSlopePerSecOverFitMedian',NaN,'PostSlopePerSecOverFitMedian',NaN, ...
 'BaselineStartFrame',NaN,'BaselineEndFrame',NaN,'BaselineMean',NaN, ...
 'ProvisionalAmplitude',NaN,'BaselineStatus',"onset_unresolved");
if first<1,R.Status="recording_boundary_unresolved";return;end
if any(~isfinite(trace(first:last))),R.Status="nonfinite_fit";return;end
if any(blocked(first:s-1)),R.Status="overlapping_detection_in_fit";return;end
scale=median(abs(trace(first:last)));if scale<=0,R.Status="nonpositive_scale";return;end
t=((first:last)'-s)/fs;y=trace(first:last)'/scale;n=numel(t);D=[ones(n,1) t];
base=D\y;sse0=max(sum((y-D*base).^2),n*1e-20);
candidates=lo:s;scores=nan(size(candidates));coeff=zeros(3,numel(candidates));
for j=1:numel(candidates)
 H=[D max(0,t-(candidates(j)-1-s)/fs)];q=H\y;coeff(:,j)=q;
 sse=max(sum((y-H*q).^2),n*1e-20);scores(j)=n*log(sse0/sse)-2*log(n);
end
[best,j]=max(scores);k=candidates(j);R.BestCandidateFrame=k;R.ScoreImprovement=best;
profile=candidates(scores>=best-2);R.ProfileStartFrame=profile(1);R.ProfileEndFrame=profile(end);
R.ProfileSpanSec=(profile(end)-profile(1))/fs;
R.BaselineSlopePerSecOverFitMedian=coeff(2,j);R.PostSlopePerSecOverFitMedian=sum(coeff(2:3,j));
if best<10,R.Status="insufficient_improvement";return;end
if coeff(3,j)<=0||R.PostSlopePerSecOverFitMedian<=0,R.Status="not_a_rising_change";return;end
if k==lo||k==s,R.Status="search_boundary_unresolved";return;end
if R.ProfileSpanSec>10,R.Status="broad_profile_unresolved";return;end
R.Status="resolved";R.OnsetFrame=k;R.BaselineStartFrame=k-b;R.BaselineEndFrame=k-1;
R.BaselineMean=mean(trace(k-b:k-1));R.BaselineStatus="nonpositive_baseline";
if any(~isfinite(trace(native))),R.BaselineStatus="missing_native_signal";return;end
if R.BaselineMean>0
 R.BaselineStatus="provisional_valid";R.ProvisionalAmplitude=max(trace(native)/R.BaselineMean-1);
end
end
