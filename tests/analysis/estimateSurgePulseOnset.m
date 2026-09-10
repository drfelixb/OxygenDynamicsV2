function Results=estimateSurgePulseOnset(traces,native,fs,blocked)
% Validation-only batch of raw traces sharing support and native bounds.
validateattributes(traces,{'numeric'},{'2d','real','nonempty'});
validateattributes(fs,{'numeric'},{'scalar','finite','positive'});
validateattributes(native,{'numeric'},{'vector','integer','positive','nonempty'});
traces=double(traces);blocked=logical(blocked(:)');N=size(traces,2);
assert(numel(blocked)==N&&isequal(native(:)',native(1):native(end))&&native(end)<=N);
b=max(1,round(20*fs));s=native(1);first=max(1,s-max(1,floor(40*fs))-b);
neighbor=find(blocked(first:s-1),1,'last');if ~isempty(neighbor),first=first+neighbor;end
lo=max(s-max(1,floor(40*fs)),first+b);last=min(native(end),s+floor(4*fs));
R=struct('Status',"unassessed",'OnsetFrame',NaN,'BestCandidateFrame',NaN, ...
 'FitStartFrame',first,'FitEndFrame',last,'ScoreImprovement',NaN, ...
 'ProfileStartFrame',NaN,'ProfileEndFrame',NaN,'ProfileSpanSec',NaN, ...
 'BaselineStartFrame',NaN,'BaselineEndFrame',NaN,'BaselineMean',NaN, ...
 'ProvisionalAmplitude',NaN,'BaselineStatus',"onset_unresolved", ...
 'TemplateRiseSec',NaN,'TemplatePlateauSec',NaN,'TemplateRecoverySec',NaN, ...
 'TemplateShape',"unassessed",'PulseCoefficientOverFitMedian',NaN);
Results=repmat(R,size(traces,1),1);
if lo>=s-1,[Results.Status]=deal("insufficient_clean_context");return;end
valid=all(isfinite(traces(:,first:last)),2);scale=median(abs(traces(:,first:last)),2);
for j=1:numel(Results)
 if ~valid(j),Results(j).Status="nonfinite_fit";
 elseif scale(j)<=0,Results(j).Status="nonpositive_scale";valid(j)=false;end
end
if ~any(valid),return;end
frames=(first:last)';n=numel(frames);D=[ones(n,1) (frames-s)/fs];[Q,~]=qr(D,0);
rise=[2 5 10 15 20 30 45 60];hold=[0 5 10 20 40 60];fall=rise;
[rr,hh,ff,ss]=ndgrid(rise,hold,fall,1:2);params=[rr(:) hh(:) ff(:) ss(:)];
candidates=lo:s;U=[];Meta=[];Groups=cell(numel(candidates),1);
for k=1:numel(candidates)
 elapsed=(frames-candidates(k)+1)/fs;nativeElapsed=(s-candidates(k)+1)/fs;
 H=pulses(elapsed,params);atNative=pulses(nativeElapsed,params);
 H=H-Q*(Q'*H);norms=sqrt(sum(H.^2,1));keep=atNative>0&norms>1e-10;
 H=H(:,keep)./norms(keep);start=size(U,2)+1;
 U=[U H];Meta=[Meta;[repmat(candidates(k),nnz(keep),1) params(keep,:) norms(keep)']]; %#ok<AGROW>
 Groups{k}=start:size(U,2);
end
indices=find(valid);Y=traces(valid,first:last)'./scale(valid)';Z=Y-Q*(Q'*Y);
sse0=max(sum(Z.^2,1),n*1e-20);projection=max(0,U'*Z);
sse=max(sse0-projection.^2,n*1e-20);
% Avoid cancellation when a template matches a noiseless trace exactly.
for j=1:numel(indices)
 tiny=find(sse(:,j)<1e-10*sse0(j));
 if ~isempty(tiny)
  residual=Z(:,j)-U(:,tiny).*projection(tiny,j)';
  sse(tiny,j)=max(sum(residual.^2,1)',n*1e-20);
 end
end
score=n*log(sse0./sse)-5*log(n)-2*log(2);
for j=1:numel(indices)
 out=indices(j);r=Results(out);profileScores=zeros(size(candidates));bestTemplates=zeros(size(candidates));
 for k=1:numel(candidates)
  [profileScores(k),ii]=max(score(Groups{k},j));bestTemplates(k)=Groups{k}(ii);
 end
 [best,k]=max(profileScores);ii=bestTemplates(k);onset=candidates(k);p=Meta(ii,:);
 profile=candidates(profileScores>=best-2);r.BestCandidateFrame=onset;r.ScoreImprovement=best;
 r.ProfileStartFrame=profile(1);r.ProfileEndFrame=profile(end);r.ProfileSpanSec=(profile(end)-profile(1))/fs;
 r.TemplateRiseSec=p(2);r.TemplatePlateauSec=p(3);r.TemplateRecoverySec=p(4);
 shapes=["linear","sine_squared"];r.TemplateShape=shapes(p(5));
 r.PulseCoefficientOverFitMedian=projection(ii,j)/p(6);
 if best<10,r.Status="insufficient_improvement";
 elseif onset==lo||onset==s,r.Status="search_boundary_unresolved";
 elseif r.ProfileSpanSec>10,r.Status="broad_profile_unresolved";
 else
  r.Status="resolved";r.OnsetFrame=onset;r.BaselineStartFrame=onset-b;r.BaselineEndFrame=onset-1;
  r.BaselineMean=mean(traces(out,onset-b:onset-1));r.BaselineStatus="nonpositive_baseline";
  if any(~isfinite(traces(out,native))),r.BaselineStatus="missing_native_signal";
  elseif r.BaselineMean>0
   r.BaselineStatus="provisional_valid";r.ProvisionalAmplitude=max(traces(out,native))/r.BaselineMean-1;
  end
 end
 Results(out)=r;
end
end
function H=pulses(t,p)
up=max(0,min(1,t./p(:,1)'));down=max(0,min(1,(p(:,1)'+p(:,2)'+p(:,3)'-t)./p(:,3)'));
H=min(up,down);smooth=p(:,4)==2;H(:,smooth)=sin(pi*H(:,smooth)/2).^2;
end
