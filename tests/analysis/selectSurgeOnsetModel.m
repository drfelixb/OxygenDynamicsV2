function R=selectSurgeOnsetModel(rising,pulse,fs)
% Validation-only score comparison; never use waveform truth or amplitude size.
validateattributes(fs,{'numeric'},{'scalar','finite','positive'});
assert(isequaln(rising.FitStartFrame,pulse.FitStartFrame)&&isequaln(rising.FitEndFrame,pulse.FitEndFrame),'OxygenDynamics:OnsetContextMismatch','Fit contexts differ.');
R=struct('Status',"no_model_evidence",'OnsetFrame',NaN,'BaselineStartFrame',NaN, ...
 'BaselineEndFrame',NaN,'BaselineMean',NaN,'ProvisionalAmplitude',NaN, ...
 'BaselineStatus',"onset_unresolved",'SelectedModel',"none",'SelectedScore',NaN, ...
 'RisingScore',rising.ScoreImprovement-2*log(2),'PulseScore',pulse.ScoreImprovement-2*log(2), ...
 'RisingStatus',string(rising.Status),'PulseStatus',string(pulse.Status), ...
 'ModelGapSec',NaN,'CombinedProfileSpanSec',NaN,'PlausibleModels',0, ...
 'FitStartFrame',rising.FitStartFrame,'FitEndFrame',rising.FitEndFrame);
models={rising,pulse};names=["rising","pulse"];scores=[R.RisingScore R.PulseScore];
statuses=[string(rising.Status) string(pulse.Status)];
plausible=isfinite(scores)&scores>=10&ismember(statuses,["resolved","broad_profile_unresolved","search_boundary_unresolved"]);
R.PlausibleModels=nnz(plausible);
if ~any(plausible)
 if statuses(1)==statuses(2)&&ismember(statuses(1),["insufficient_clean_context","construction_unavailable","nonfinite_fit","nonpositive_scale"])
  R.Status=statuses(1);
  if R.Status=="construction_unavailable",R.BaselineStatus="construction_unavailable";end
 end
 return;
end
rank=scores;rank(~plausible)=-Inf;[best,j]=max(rank);winner=models{j};R.SelectedScore=best;
if string(winner.Status)~="resolved",R.Status="best_model_unresolved";return;end
other=3-j;
if plausible(other)&&scores(other)>=best-2
 challenger=models{other};
 if string(challenger.Status)~="resolved",R.Status="model_uncertainty";return;end
 R.ModelGapSec=abs(winner.OnsetFrame-challenger.OnsetFrame)/fs;
 R.CombinedProfileSpanSec=(max(winner.ProfileEndFrame,challenger.ProfileEndFrame)-min(winner.ProfileStartFrame,challenger.ProfileStartFrame))/fs;
 if R.ModelGapSec>5,R.Status="model_disagreement";return;end
 if R.CombinedProfileSpanSec>10,R.Status="model_uncertainty";return;end
end
R.Status="resolved";R.SelectedModel=names(j);
fields={'OnsetFrame','BaselineStartFrame','BaselineEndFrame','BaselineMean','ProvisionalAmplitude','BaselineStatus'};
for k=1:numel(fields),R.(fields{k})=winner.(fields{k});end
end
