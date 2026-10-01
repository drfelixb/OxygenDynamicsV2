function M=computeBOIReviewedOpticalInterval(raw,reference,onset,recovery,fs,kind)
%COMPUTEBOIREVIEWEDOPTICALINTERVAL Exact selected-reference arithmetic only.
% Caller binds audit, native support, saved judgment and definition provenance.
id='OxygenDynamics:InvalidReviewedOpticalInput';
assert(isnumeric(raw)&&isreal(raw)&&isvector(raw)&&~isempty(raw),id,'A preserved-input vector is required.');raw=double(raw(:));N=numel(raw);
assert(isnumeric(fs)&&isscalar(fs)&&isfinite(fs)&&fs>0,id,'Positive finite sampling rate required.');
assert(isnumeric(onset)&&isscalar(onset)&&isfinite(onset)&&onset==fix(onset)&&onset>=1&& ...
    isnumeric(recovery)&&isscalar(recovery)&&isfinite(recovery)&&recovery==fix(recovery)&&recovery>=onset&&recovery<=N,id,'Invalid inclusive event bounds.');
assert(ismember(string(kind),["sink","surge"])&&isscalar(string(kind)),id,'Saved event sign must be sink or surge.');
assert(isnumeric(reference)&&isreal(reference)&&(isempty(reference)||isvector(reference))&&all(isfinite(reference(:)))&& ...
    all(reference(:)==fix(reference(:)))&&all(reference(:)>=1&reference(:)<onset)&&all(diff(reference(:))>0),id,'Reference must contain increasing unique recorded frames strictly before onset.');
C=double(reference(:));E=(onset:recovery)';values=raw(E);
M=struct('OnsetFrame',onset,'RecoveryFrame',recovery,'SavedSign',char(kind),'Status','unavailable_no_accepted_reference', ...
    'ReferenceFrames',C,'ReferenceValues',raw(C),'ReferenceSampleCount',NaN,'ReferenceMean',NaN, ...
    'EventFrames',E,'EventValues',values,'EventSampleCount',numel(E),'DurationSec',numel(E)/fs,'EndpointSpanSec',(recovery-onset)/fs, ...
    'Numerator',nan(size(E)),'SignedFraction',nan(size(E)),'MinimumSignedChangeFraction',NaN,'MaximumSignedChangeFraction',NaN, ...
    'MinimumFrames',zeros(0,1),'MaximumFrames',zeros(0,1),'SavedSignDirectionalAmplitudeFraction',NaN, ...
    'MeanSignedChangeFraction',NaN,'SignedTraceIntegralSec',NaN);
if isempty(C),return;end
M.ReferenceSampleCount=numel(C);
if ~all(isfinite(raw(C))),M.Status='unavailable_nonfinite_reference_samples';return;end
B=mean(raw(C));if isfinite(B),M.ReferenceMean=B;end
if ~isfinite(B)||B<=0,M.Status='unavailable_nonpositive_or_nonfinite_reference_mean';return;end
if ~all(isfinite(values)),M.Status='unavailable_nonfinite_event_samples';return;end
numerator=values-B;q=numerator/B;
% Finite inputs can still overflow intermediate arithmetic; never export Inf.
if ~all(isfinite(numerator))||~all(isfinite(q))||~all(isfinite(100*q))
    M.Status='unavailable_nonfinite_derived_arithmetic';return;
end
integral=sum(q)/fs;average=mean(q);
if ~isfinite(integral)||~isfinite(average),M.Status='unavailable_nonfinite_derived_arithmetic';return;end
M.Numerator=numerator;M.SignedFraction=q;M.MinimumSignedChangeFraction=min(q);M.MaximumSignedChangeFraction=max(q);
M.MinimumFrames=E(q==min(q));M.MaximumFrames=E(q==max(q));
if strcmp(kind,'sink'),M.SavedSignDirectionalAmplitudeFraction=-min(q);else,M.SavedSignDirectionalAmplitudeFraction=max(q);end
M.MeanSignedChangeFraction=average;M.SignedTraceIntegralSec=integral;M.Status='computed_exploratory';
end
