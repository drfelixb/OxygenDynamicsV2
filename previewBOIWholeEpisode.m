function R=previewBOIWholeEpisode(E,P)
%PREVIEWBOIWHOLEEPISODE Full saved-trace experimental episode proposals.
% The seed is annotation only. No correction, reference, burden or save calls.
started=tic;validate(E,P);raw=double(E.Raw(:));corrected=double(E.Corrected(:));
R=struct('Schema',P.Version,'Role','experimental_episode_proposals_only', ...
    'ScientificAcceptance',false,'BurdenCalculated',false,'OriginalResultsChanged',false, ...
    'NewCorrectionFits',0,'Settings',P,'SampleHz',E.SampleHz,'NFrames',numel(raw));
for name={'Identity','AuditPath','AuditSHA256','RawSourceSHA256','FootprintPixels','SeedStartFrame','SeedEndFrame'}
    if isfield(E,name{1}),R.(name{1})=E.(name{1});end
end
R.Raw=scan(raw,E.SampleHz,P);R.Corrected=scan(corrected,E.SampleHz,P);
R.StageMatches=matchStages(R.Raw.Proposals,R.Corrected.Proposals);
R.SpatialQualification='Saved detector support only; independent spatial coherence and full-event area are not established.';
R.Limitations={'Search is limited to the retained fixed footprint, not spatial locations missed by the old detector.', ...
    'Fit scores, margins and shape/duration grids are computational assumptions, not calibrated pocket probabilities.', ...
    'Fitted background is a display/model component, never a measurement reference or a new correction.', ...
    'Similar background and episode explanations, clipping, gaps and incomplete phases retain uncertainty.', ...
    'Native support comes from the existing detector and cannot independently confirm a pocket.', ...
    'No scientific boundary, baseline, amplitude, area, burden, automatic result or reviewed result is changed.'};
R.ElapsedSec=toc(started);
end
function validate(E,P)
id='OxygenDynamics:WholeEpisodeInput';S=boiWholeEpisodeSettings;
assert(isstruct(E)&&isscalar(E)&&all(isfield(E,{'Raw','Corrected','SampleHz'})),id,'Supply full saved raw/corrected traces and sampling rate.');
assert(isnumeric(E.Raw)&&isreal(E.Raw)&&isvector(E.Raw)&&isnumeric(E.Corrected)&&isreal(E.Corrected)&&isvector(E.Corrected)&& ...
    numel(E.Raw)==numel(E.Corrected)&&numel(E.Raw)>=4,id,'Saved traces must have equal real vector shapes.');
assert(isscalar(E.SampleHz)&&isnumeric(E.SampleHz)&&isfinite(E.SampleHz)&&E.SampleHz>0,id,'A positive explicit sampling rate is required.');
assert(~any(isinf(E.Raw(:)))&&~any(isinf(E.Corrected(:))),id,'Missing samples must be NaN, not infinity.');
assert(isstruct(P)&&isscalar(P)&&isequal(sort(fieldnames(P)),sort(fieldnames(S)))&&strcmp(P.Version,S.Version)&&isequal(P.ExperimentalOnly,true),id,'Use the explicit experimental settings contract.');
assert(isnumeric(P.DurationsSec)&&isreal(P.DurationsSec)&&isvector(P.DurationsSec)&&all(isfinite(P.DurationsSec)&P.DurationsSec>0)&&all(diff(P.DurationsSec)>0),id,'Search durations must be increasing positive seconds.');
assert(isnumeric(P.Profiles)&&isreal(P.Profiles)&&size(P.Profiles,2)==2&&~isempty(P.Profiles)&&all(isfinite(P.Profiles(:)))&&all(P.Profiles(:,1)>0)&all(P.Profiles(:,2)<1)&&all(P.Profiles(:,1)<=P.Profiles(:,2)),id,'Shape profile positions must satisfy 0 < first <= last < 1.');
assert(isscalar(P.EpisodeBackgroundDegree)&&ismember(P.EpisodeBackgroundDegree,[1 2]),id,'Episode background degree must be1 or2.');
for f={'ScorePenalty','ScoreMargin','ProposalSigma','MaximumScreenedPerStage','AlternativeScoreBand','BoundaryContextSec','BoundarySampleSec','BoundaryScreenSigma'}
    v=P.(f{1});assert(isnumeric(v)&&isscalar(v)&&isreal(v)&&isfinite(v)&&v>0,id,'Numerical limits must be positive finite scalars.');
end
assert(P.MaximumScreenedPerStage==fix(P.MaximumScreenedPerStage)&&isscalar(P.DuplicateIntersectionFraction)&&isfinite(P.DuplicateIntersectionFraction)&&P.DuplicateIntersectionFraction>0&&P.DuplicateIntersectionFraction<=1,id,'Invalid proposal or duplicate limits.');
assert(P.BoundaryContextSec>P.BoundarySampleSec,id,'Boundary context must exceed its sample window.');
for f={'SeedStartFrame','SeedEndFrame'}
 if isfield(E,f{1}),v=E.(f{1});assert(isnumeric(v)&&isscalar(v)&&isfinite(v)&&v==fix(v)&&v>=1&&v<=numel(E.Raw),id,'Saved annotation is outside the trace.');end
end
if all(isfield(E,{'SeedStartFrame','SeedEndFrame'})),assert(E.SeedStartFrame<=E.SeedEndFrame,id,'Invalid saved annotation order.');end
end
function S=scan(y,fs,P)
N=numel(y);good=isfinite(y);segments=runs(good);d=diff(y);d=d(isfinite(d));
if isempty(d),noise=NaN;else,noise=median(abs(d-median(d)))/(.674489750196082*sqrt(2));end
v=y(good);floorValue=1e-10;if ~isempty(v),floorValue=floorValue*max(1,max(abs(v)));end
noise=max(noise,floorValue);S=struct('Status','scanned','NoiseScale',noise,'FiniteSegments',segments, ...
    'FiniteFraction',mean(good),'ProposalSeeds',0,'ScreenedSeeds',0,'ScreeningCapReached',false, ...
    'UnsupportedDurationsSec',[],'Proposals',repmat(emptyProposal,0,1),'BoundaryAssessments',struct([]));
if numel(v)<4||~isfinite(noise),S.Status='insufficient_finite_samples';return;end
seeds=zeros(0,4); % screen statistic, frame centre, duration in samples, profile
clean=y-median(v);clean(~good)=0;
for duration=P.DurationsSec
 w=max(4,round(duration*fs));h=ceil(w);offset=(-h:h)';L=numel(offset);t=offset/max(1,h);
 if w+7>N,S.UnsupportedDurationsSec(end+1)=duration;continue;end %#ok<AGROW>
 % Exact weighted linear projection on the observed (possibly recording-edge
 % clipped) context. A gap inside that context remains a barrier.
 expected=conv(ones(N,1),ones(L,1),'same');coverage=conv(double(good),ones(L,1),'same');
 st=conv(double(good),flipud(t),'same');stt=conv(double(good),flipud(t.^2),'same');
 sy=conv(clean,ones(L,1),'same');syt=conv(clean,flipud(t),'same');
 determinant=coverage.*stt-st.^2;
 valid=coverage>=expected-.5 & determinant>eps;
 positions=(1:N)';valid=valid & positions-w/2>=4 & positions+w/2<=N-3;
 for profile=1:size(P.Profiles,1)
    pulse=pulseShape(offset,-w/2,w/2,P.Profiles(profile,:));q=-pulse;
    sq=conv(double(good),flipud(q),'same');stq=conv(double(good),flipud(t.*q),'same');
    sqq=conv(double(good),flipud(q.^2),'same');syq=conv(clean,flipud(q),'same');
    u=(stt.*sq-st.*stq)./max(determinant,eps);z=(coverage.*stq-st.*sq)./max(determinant,eps);
    energy=max(0,sqq-sq.*u-stq.*z);
    score=(syq-sy.*u-syt.*z)./(noise*sqrt(max(energy,eps)));score(~valid|energy<=eps)=-Inf;
    peak=find(score>=P.ProposalSigma & score>=[-Inf;score(1:end-1)] & score>[score(2:end);-Inf]);
    seeds=[seeds;score(peak) peak repmat(w,numel(peak),1) repmat(profile,numel(peak),1)]; %#ok<AGROW>
 end
end
S.ProposalSeeds=size(seeds,1);
if ~isempty(seeds)
 [~,order]=sortrows([-seeds(:,1) seeds(:,2) seeds(:,3) seeds(:,4)],[1 2 3 4]);seeds=seeds(order,:);
 S.ScreeningCapReached=size(seeds,1)>P.MaximumScreenedPerStage;seeds=seeds(1:min(end,P.MaximumScreenedPerStage),:);S.ScreenedSeeds=size(seeds,1);
 candidates=repmat(emptyProposal,size(seeds,1),1);
 for k=1:size(seeds,1),candidates(k)=fitProposal(y,fs,noise,seeds(k,:),P);end
 % Retain every screened hypothesis. Group near-duplicate proposals and retain
 % competing timing ranges without turning them into biological event merges.
 [~,order]=sortrows([-[candidates.ScoreGain]' [candidates.StartFrame]' [candidates.EndFrame]'],[1 2 3]);
 candidates=candidates(order);selected=repmat(emptyProposal,0,1);
 for k=1:numel(candidates)
  c=candidates(k);match=[];
  for j=1:numel(selected)
   a=selected(j);intersection=max(0,min(c.EndFrame,a.EndFrame)-max(c.StartFrame,a.StartFrame)+1);
   union=max(c.EndFrame,a.EndFrame)-min(c.StartFrame,a.StartFrame)+1;
   if intersection/union>=P.DuplicateIntersectionFraction,match=j;break;end
  end
  if isempty(match),c.ProposalID=numel(selected)+1;selected(end+1,1)=c; %#ok<AGROW>
  else
   a=selected(match);a.AlternativeCount=a.AlternativeCount+1;
   if c.ScoreGain>=a.ScoreGain-P.AlternativeScoreBand
    a.OnsetRange=[min(a.OnsetRange(1),c.StartFrame) max(a.OnsetRange(2),c.StartFrame)];
    a.RecoveryRange=[min(a.RecoveryRange(1),c.EndFrame) max(a.RecoveryRange(2),c.EndFrame)];
   end
   selected(match)=a;
  end
 end
 [~,o]=sort([selected.StartFrame]);selected=selected(o);
 for k=1:numel(selected),selected(k).ProposalID=k;end
 S.Proposals=selected;S.ScreenedHypotheses=candidates;
else,S.ScreenedHypotheses=repmat(emptyProposal,0,1);end
S.BoundaryAssessments=boundaryAssessments(y,segments,fs,noise,P);
end
function c=fitProposal(y,fs,noise,seed,P)
center=seed(2);w=seed(3);profile=P.Profiles(seed(4),:);a=max(1,round(center-w/2));b=min(numel(y),round(center+w/2));
lo=max(1,center-w);hi=min(numel(y),center+w);f=(lo:hi)';t=(f-center)/w;v=y(f);n=numel(f);
B=[ones(n,1) t];Q=[B t.^2];pulse=pulseShape(f,a,b,profile);
[linearScore,~,~]=fit(B,v,noise,P.ScorePenalty,2);
[curvedScore,~,~]=fit(Q,v,noise,P.ScorePenalty,3);
transitionScore=Inf;transitionKind='';transitionFrame=NaN;
[~,changes]=sort(abs(diff(v)),'descend');changes=changes(1:min(4,numel(changes)));
knots=unique([a center b f(changes+1)']);knots=knots(knots>lo+1&knots<hi-1);
for knot=knots
 for kind=1:2
  h=double(f>=knot);name='step';if kind==2,h=max(0,(f-knot)/w);name='slope_change';end
  score=fit([B h],v,noise,P.ScorePenalty,4);
  if score<transitionScore,transitionScore=score;transitionKind=name;transitionFrame=knot;end
 end
end
background=B;if P.EpisodeBackgroundDegree==2,background=Q;end
[episodeScore,coeff,predicted]=fit([background -pulse],v,noise,P.ScorePenalty,size(background,2)+4);
amp=coeff(end);if amp<=0,episodeScore=Inf;end
[bgScore,bg]=min([linearScore curvedScore transitionScore]);names={'linear_trend','curved_trend',transitionKind};
fittedBackground=background*coeff(1:end-1);residual=v-fittedBackground;
pre=f<a;post=f>b;inside=f>=a&f<=b;trough=min(residual(inside));
preLevel=median(residual(pre));postLevel=median(residual(post));
decline=preLevel-trough;recovery=postLevel-trough;
status='uncertain';gain=bgScore-episodeScore;
if gain>P.ScoreMargin&&decline>2*noise&&recovery>2*noise,status='pocket_candidate';elseif gain< -P.ScoreMargin,status='background_like';end
c=emptyProposal;c.StartFrame=a;c.EndFrame=b;c.CenterFrame=center;c.DurationSec=(b-a+1)/fs;c.ProfileIndex=seed(4);
c.ContextStartFrame=lo;c.ContextEndFrame=hi;c.ScreenStatistic=seed(1);c.EpisodeScore=episodeScore;c.BackgroundScore=bgScore;
c.LinearScore=linearScore;c.CurvedScore=curvedScore;c.TransitionScore=transitionScore;c.BackgroundExplanation=names{bg};c.TransitionFrame=transitionFrame;
c.ScoreGain=gain;c.Status=status;c.DepthInputUnits=amp;c.DeclineNoiseUnits=decline/noise;c.RecoveryNoiseUnits=recovery/noise;
c.OnsetRange=[a a];c.RecoveryRange=[b b];c.BackgroundCoefficients=coeff(1:end-1)';c.FitRSS=sum((v-predicted).^2);c.ObservedPhases='preceding_state_decline_and_return_context';
c.Message='Model-selected interval and competing scores; biological review required. Timing ranges cover screened near-duplicate fits, not confidence intervals.';
end
function [score,coeff,predicted]=fit(X,y,noise,penalty,k)
coeff=X\y;predicted=X*coeff;RSS=sum((y-predicted).^2);n=numel(y);
score=n*log(max(RSS/n,noise^2))+penalty*k*log(n);
end
function p=pulseShape(x,a,b,profile)
p=zeros(size(x));left=a+(b-a)*profile(1);right=a+(b-a)*profile(2);
i=x>a&x<left;p(i)=(x(i)-a)/(left-a);
i=x>=left&x<=right;p(i)=1;
i=x>right&x<b;p(i)=(b-x(i))/(b-right);
end
function B=boundaryAssessments(y,segments,fs,noise,P)
B=struct('BoundaryFrame',{},'Side',{},'Status',{},'RelativeLowSigma',{},'ContextFrames',{},'Message',{});
for j=1:size(segments,1)
 a=segments(j,1);b=segments(j,2);L=min(b-a+1,max(4,round(P.BoundaryContextSec*fs)));m=max(1,min(floor(L/3),round(P.BoundarySampleSec*fs)));
 if L<4,continue;end
 for side=1:2
  f=(a:a+L-1)';edge='left';if side==2,f=(b:-1:b-L+1)';edge='right';end
  low=(median(y(f(end-m+1:end)))-median(y(f(1:m))))/noise;
  if low<P.BoundaryScreenSigma,continue;end
  msg='Boundary is lower than observed interior context; preceding state or recovery is unobserved. A trend is also possible; no complete pocket is asserted.';
  if a>1&&side==1||b<numel(y)&&side==2,msg=['Missing-sample boundary. ' msg];end
  B(end+1)=struct('BoundaryFrame',f(1),'Side',edge,'Status','uncertain_incomplete', ...
      'RelativeLowSigma',low,'ContextFrames',[min(f) max(f)],'Message',msg); %#ok<AGROW>
 end
end
end
function T=matchStages(A,B)
T=struct('RawProposal',{},'CorrectedProposal',{},'Status',{},'IntersectionOverUnion',{});used=false(numel(B),1);
for i=1:numel(A)
 overlap=zeros(numel(B),1);
 for j=1:numel(B),overlap(j)=max(0,min(A(i).EndFrame,B(j).EndFrame)-max(A(i).StartFrame,B(j).StartFrame)+1)/(max(A(i).EndFrame,B(j).EndFrame)-min(A(i).StartFrame,B(j).StartFrame)+1);end
 [best,j]=max(overlap);status='raw_only_context';match=NaN;
 if ~isempty(best)&&best>=.3
  match=j;used(j)=true;status='raw_corrected_disagreement';
  if strcmp(A(i).Status,B(j).Status),status='matching_model_outcomes';end
 else,best=0;end
 T(end+1)=struct('RawProposal',i,'CorrectedProposal',match,'Status',status,'IntersectionOverUnion',best); %#ok<AGROW>
end
for j=find(~used)',T(end+1)=struct('RawProposal',NaN,'CorrectedProposal',j,'Status','corrected_only_context','IntersectionOverUnion',0);end %#ok<AGROW>
end
function pairs=runs(good)
edges=diff([false;good(:);false]);pairs=[find(edges==1) find(edges==-1)-1];
end
function c=emptyProposal
c=struct('ProposalID',0,'StartFrame',NaN,'EndFrame',NaN,'CenterFrame',NaN,'DurationSec',NaN, ...
    'ProfileIndex',NaN,'ContextStartFrame',NaN,'ContextEndFrame',NaN,'ScreenStatistic',NaN, ...
    'EpisodeScore',NaN,'BackgroundScore',NaN,'LinearScore',NaN,'CurvedScore',NaN, ...
    'TransitionScore',NaN,'BackgroundExplanation','','TransitionFrame',NaN,'ScoreGain',NaN, ...
    'Status','','DepthInputUnits',NaN,'DeclineNoiseUnits',NaN,'RecoveryNoiseUnits',NaN, ...
    'OnsetRange',[NaN NaN],'RecoveryRange',[NaN NaN],'AlternativeCount',0, ...
    'BackgroundCoefficients',[],'FitRSS',NaN,'ObservedPhases','','Message','');
end
