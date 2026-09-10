function R=assessSurgeAmplitudeEligibility(trace,native,fs,blocked,onset,status)
% Validation-only necessary arithmetic/direction conditions, not biological QC.
validateattributes(trace,{'numeric'},{'vector','real','nonempty'});
validateattributes(fs,{'numeric'},{'scalar','finite','positive'});
validateattributes(native,{'numeric'},{'vector','integer','positive','nonempty'});
trace=double(trace(:)');native=native(:)';n=numel(trace);
assert(isequal(native,native(1):native(end))&&native(end)<=n);
validateattributes(blocked,{'logical','numeric'},{'vector','numel',n,'finite','binary'});
blocked=logical(blocked(:)');
R=struct('AmplitudeStatus',"onset_unresolved",'ArithmeticValid',false, ...
 'PositiveAmplitudeEligible',false,'SignedRawAmplitude',NaN, ...
 'ProvisionalPositiveAmplitude',NaN,'ReferenceStartFrame',NaN,'ReferenceEndFrame',NaN, ...
 'ReferenceMean',NaN,'NativePeakFrame',NaN,'NativePeakValue',NaN, ...
 'FirstHalfReferenceMean',NaN,'SecondHalfReferenceMean',NaN, ...
 'ReferenceHalfChangeFraction',NaN,'FirstHalfAmplitude',NaN, ...
 'SecondHalfAmplitude',NaN,'PositiveAcrossReferenceHalves',false);
if string(status)~="resolved",return;end
b=max(1,round(20*fs));
if ~isscalar(onset)||~isfinite(onset)||onset~=fix(onset)||onset>native(1)
 R.AmplitudeStatus="invalid_onset";return;
end
if onset-b<1,R.AmplitudeStatus="incomplete_reference";return;end
pre=onset-b:onset-1;R.ReferenceStartFrame=pre(1);R.ReferenceEndFrame=pre(end);
if any(blocked(pre)),R.AmplitudeStatus="overlapping_reference";return;end
if any(~isfinite(trace(pre))),R.AmplitudeStatus="nonfinite_reference";return;end
R.ReferenceMean=mean(trace(pre));
if ~isfinite(R.ReferenceMean),R.AmplitudeStatus="nonfinite_reference_mean";return;end
if R.ReferenceMean<=0,R.AmplitudeStatus="nonpositive_reference";return;end
if any(~isfinite(trace(native))),R.AmplitudeStatus="missing_native_signal";return;end
[peak,j]=max(trace(native));R.NativePeakFrame=native(j);R.NativePeakValue=peak;
R.SignedRawAmplitude=peak/R.ReferenceMean-1;R.ArithmeticValid=isfinite(R.SignedRawAmplitude);
if ~R.ArithmeticValid,R.AmplitudeStatus="nonfinite_amplitude";return;end
if numel(pre)>=2
 split=floor(numel(pre)/2);R.FirstHalfReferenceMean=mean(trace(pre(1:split)));
 R.SecondHalfReferenceMean=mean(trace(pre(split+1:end)));
 R.ReferenceHalfChangeFraction=(R.SecondHalfReferenceMean-R.FirstHalfReferenceMean)/R.ReferenceMean;
 if R.FirstHalfReferenceMean>0,R.FirstHalfAmplitude=peak/R.FirstHalfReferenceMean-1;end
 if R.SecondHalfReferenceMean>0,R.SecondHalfAmplitude=peak/R.SecondHalfReferenceMean-1;end
 R.PositiveAcrossReferenceHalves=isfinite(R.FirstHalfAmplitude)&&isfinite(R.SecondHalfAmplitude)&& ...
  R.FirstHalfAmplitude>0&&R.SecondHalfAmplitude>0;
end
if R.SignedRawAmplitude<0,R.AmplitudeStatus="raw_direction_conflict";
elseif R.SignedRawAmplitude==0,R.AmplitudeStatus="no_positive_raw_change";
else
 R.AmplitudeStatus="positive_raw_change_provisional";
 R.PositiveAmplitudeEligible=true;R.ProvisionalPositiveAmplitude=R.SignedRawAmplitude;
end
end
