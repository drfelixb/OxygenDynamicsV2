function R=assessSurgeExpandedPeak(trace,native,fs,preNativeBlocked,onset,status)
% Validation-only expansion; check added frames, preserve native diagnostics.
R=assessSurgeAmplitudeEligibility(trace,native,fs,preNativeBlocked,onset,status);
R.ExpandedStatus=R.AmplitudeStatus;R.ExpandedArithmeticValid=false;
R.ExpandedPositiveEligible=false;R.ExpandedSignedAmplitude=NaN;
R.ExpandedPositiveAmplitude=NaN;R.ExpandedPeakFrame=NaN;R.ExpandedPeakValue=NaN;
R.AddedFrameCount=NaN;R.AddedNeighborFrames=NaN;R.AddedNonfiniteFrames=NaN;
R.PeakPrecedesNative=false;R.AmplitudeIncrease=NaN;
if ~R.ArithmeticValid,return;end
added=onset:native(1)-1;R.AddedFrameCount=numel(added);
R.AddedNeighborFrames=nnz(preNativeBlocked(added));
R.AddedNonfiniteFrames=nnz(~isfinite(trace(added)));
if R.AddedNeighborFrames>0,R.ExpandedStatus="added_interval_neighbor_overlap";return;end
if R.AddedNonfiniteFrames>0,R.ExpandedStatus="nonfinite_added_interval";return;end
expanded=onset:native(end);[peak,j]=max(double(trace(expanded)));
R.ExpandedPeakFrame=expanded(j);R.ExpandedPeakValue=peak;
R.ExpandedSignedAmplitude=peak/R.ReferenceMean-1;
if ~isfinite(R.ExpandedSignedAmplitude),R.ExpandedStatus="nonfinite_amplitude";return;end
R.ExpandedArithmeticValid=true;R.PeakPrecedesNative=R.ExpandedPeakFrame<native(1);
R.AmplitudeIncrease=R.ExpandedSignedAmplitude-R.SignedRawAmplitude;
if R.ExpandedSignedAmplitude<0,R.ExpandedStatus="raw_direction_conflict";
elseif R.ExpandedSignedAmplitude==0,R.ExpandedStatus="no_positive_raw_change";
else
 R.ExpandedStatus="positive_raw_change_provisional";R.ExpandedPositiveEligible=true;
 R.ExpandedPositiveAmplitude=R.ExpandedSignedAmplitude;
end
end
