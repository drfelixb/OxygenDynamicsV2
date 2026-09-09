function EventMetrics = quantifyOxygenSinkEvent(eventPixelIdx,temptrace,tracetrend,rawtrace, ...
    eventBaselineReturnTolerance,baselineWindowFrames,maxExtensionFrames,leftLimit,rightLimit)
%QUANTIFYOXYGENSINKEVENT Calculate timing and raw-domain amplitude for one sink event.

Timing=resolveSinkEventTiming(eventPixelIdx,temptrace,tracetrend, ...
    eventBaselineReturnTolerance,maxExtensionFrames,leftLimit,rightLimit);
StartIndx=Timing.StartFrame;EndIndx=Timing.EndFrame;

DetectionAmp = abs(abs(min(temptrace(StartIndx:EndIndx)))-abs(min(tracetrend(StartIndx:EndIndx))));
BaselineStartIndx = StartIndx-baselineWindowFrames;
BaselineEndIndx = StartIndx-1;
Baseline=NaN; NormAmp=NaN;
if BaselineStartIndx>=1 && BaselineEndIndx>=BaselineStartIndx
    baselineValues=rawtrace(BaselineStartIndx:BaselineEndIndx);
    if all(isfinite(baselineValues)), Baseline=mean(baselineValues); end
end
EventMin=min(rawtrace(StartIndx:EndIndx),[],'omitnan');
if isfinite(Baseline) && Baseline>0, NormAmp=(Baseline-EventMin)/Baseline; end

EventMetrics = struct();
EventMetrics.Timing=Timing;
EventMetrics.StartFrame = StartIndx;
EventMetrics.EndFrame = EndIndx;
EventMetrics.DurationFrames = EndIndx-StartIndx+1;
EventMetrics.NormAmp = NormAmp;
EventMetrics.DetectionAmp = DetectionAmp;

end
