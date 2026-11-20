function R=analyzeSurgeAmplitudeCounterfactual(X,Y,Positive,Negative,event,pre,clean,window,required)
% TEST ONLY: exact paired-source decomposition, not a baseline correction.
% Unscreened fields intentionally retain diagnostic values when detected-event
% overlap makes the strict reported amplitude unavailable. They are not exports
% for biological pooling. X is unavailable for an actual spontaneous event.
X=double(X(:)');Y=double(Y(:)');Positive=double(Positive(:)');Negative=double(Negative(:)');
assert(isequal(size(X),size(Y),size(Positive),size(Negative))&&~isempty(event)&&~isempty(window));
assert(required>=1&&required==fix(required)&&numel(pre)<=required&&numel(unique(pre))==numel(pre));
assert(all(ismember(clean,pre))&&numel(unique(clean))==numel(clean));
assert(all(isfinite([X Y Positive Negative]))&&all(Positive>=0)&&all(Negative<=0));
assert(all(event>=1&event<=numel(X)&event==fix(event))&&all(diff(event)==1));
assert(isequal(reshape(pre,1,[]),max(1,event(1)-required):event(1)-1));
assert(all(window>=1&window<=numel(X)&window==fix(window))&&all(diff(window)==1));
assert(all(abs(Y-X-Positive-Negative)<=1e-8*max(1,abs(Y))));
R=struct('StrictBaselineStatus',"insufficient_clean_prebaseline",'StrictMeasuredPeakFraction',NaN, ...
 'CleanBaselineFrames',numel(clean),'PrebaselineFrames',numel(pre),'NativePeakFrame',NaN, ...
 'UnscreenedObservedBaseline',NaN,'UnscreenedSourceBaseline',NaN,'UnscreenedObservedPeakFraction',NaN, ...
 'UnscreenedCounterfactualPeakFraction',NaN,'UnscreenedSourcePeakFraction',NaN, ...
 'UnscreenedBaselinePositiveFraction',NaN,'UnscreenedBaselineNegativeFraction',NaN, ...
 'UnscreenedBaselineImposedFraction',NaN,'UnscreenedBaselineEffectFraction',NaN, ...
 'UnscreenedBackgroundAtObservedPeak',NaN,'UnscreenedAppliedAtObservedPeak',NaN, ...
 'PeakPositiveAppliedVsSameFrameSource',NaN,'MinimumNegativeAppliedVsSameFrameSource',NaN, ...
 'PeakNetAppliedVsSameFrameSource',NaN,'PeakPositiveAppliedInNativeIntersection',NaN, ...
 'NativeIntersectionFrames',numel(intersect(event,window)),'PreFramesWithPositiveIncrement',nnz(Positive(pre)>0), ...
 'PreFramesWithNegativeIncrement',nnz(Negative(pre)<0));
if all(X(window)>0)
 R.PeakPositiveAppliedVsSameFrameSource=max(Positive(window)./X(window));
 R.MinimumNegativeAppliedVsSameFrameSource=min(Negative(window)./X(window));
 R.PeakNetAppliedVsSameFrameSource=max((Y(window)-X(window))./X(window));
 inside=intersect(event,window);
 if ~isempty(inside),R.PeakPositiveAppliedInNativeIntersection=max(Positive(inside)./X(inside));end
end
if numel(pre)~=required,return;end
B=mean(Y(pre));Bsource=mean(X(pre));R.UnscreenedObservedBaseline=B;R.UnscreenedSourceBaseline=Bsource;
[peak,at]=max(Y(event));R.NativePeakFrame=event(at);
if B>0,R.UnscreenedObservedPeakFraction=(peak-B)/B;end
if Bsource>0
 R.UnscreenedCounterfactualPeakFraction=(peak-Bsource)/Bsource;
 R.UnscreenedSourcePeakFraction=(max(X(event))-Bsource)/Bsource;
 R.UnscreenedBaselinePositiveFraction=mean(Positive(pre))/Bsource;
 R.UnscreenedBaselineNegativeFraction=mean(Negative(pre))/Bsource;
 R.UnscreenedBaselineImposedFraction=(B-Bsource)/Bsource;
 R.UnscreenedBackgroundAtObservedPeak=(X(R.NativePeakFrame)-Bsource)/Bsource;
 R.UnscreenedAppliedAtObservedPeak=(Y(R.NativePeakFrame)-X(R.NativePeakFrame))/Bsource;
 R.UnscreenedBaselineEffectFraction=R.UnscreenedObservedPeakFraction-R.UnscreenedCounterfactualPeakFraction;
 assert(abs(R.UnscreenedCounterfactualPeakFraction-R.UnscreenedBackgroundAtObservedPeak-R.UnscreenedAppliedAtObservedPeak)<1e-10);
 assert(abs(R.UnscreenedBaselineImposedFraction-R.UnscreenedBaselinePositiveFraction-R.UnscreenedBaselineNegativeFraction)<1e-10);
 if B>0
  c=R.UnscreenedBaselineImposedFraction;
  assert(abs(R.UnscreenedObservedPeakFraction-(R.UnscreenedCounterfactualPeakFraction-c)/(1+c))<1e-10);
 end
end
if numel(clean)==required
 R.StrictBaselineStatus="nonpositive_baseline_or_missing_event_signal";
 if B>0,R.StrictBaselineStatus="valid";R.StrictMeasuredPeakFraction=R.UnscreenedObservedPeakFraction;end
end
end
