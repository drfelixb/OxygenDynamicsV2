function EventMetrics = quantifyOxygenSinkEvent(eventPixelIdx,temptrace,tracetrend,rawtrace, ...
    eventBaselineReturnTolerance,baselineWindowFrames)
%QUANTIFYOXYGENSINKEVENT Calculate timing and raw-domain amplitude for one sink event.

EventStart = eventPixelIdx(1);
EventEnd = eventPixelIdx(end);
TraceLength = numel(temptrace);

if EventStart > 1
    StartIndx = find(abs(tracetrend(1:EventStart)-temptrace(1:EventStart)) < ...
        eventBaselineReturnTolerance,1,'last');
    if isempty(StartIndx)
        StartIndx = EventStart;
    end
else
    StartIndx = EventStart;
end

if EventEnd < TraceLength
    EndIndx = EventEnd+find(abs(tracetrend(EventEnd:end)-temptrace(EventEnd:end)) < ...
        eventBaselineReturnTolerance,1,'first')-1;
    if isempty(EndIndx)
        EndIndx = EventEnd;
    end
else
    EndIndx = EventEnd;
end

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
EventMetrics.StartFrame = StartIndx;
EventMetrics.EndFrame = EndIndx;
EventMetrics.DurationFrames = EndIndx-StartIndx+1;
EventMetrics.NormAmp = NormAmp;
EventMetrics.DetectionAmp = DetectionAmp;

end
