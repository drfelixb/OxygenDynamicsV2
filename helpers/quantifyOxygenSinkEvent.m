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
if EventStart == 1
    BaselineStartIndx = min(size(rawtrace,2),EndIndx+1);
    BaselineEndIndx = min(size(rawtrace,2),EndIndx+baselineWindowFrames);
else
    BaselineStartIndx = max(1,StartIndx-baselineWindowFrames);
    BaselineEndIndx = max(1,StartIndx-1);
end

Baseline = mean(rawtrace(BaselineStartIndx:BaselineEndIndx),'omitnan');
EventMin = min(rawtrace(StartIndx:EndIndx),[],'omitnan');
NormAmp = NaN;
if isfinite(Baseline) && Baseline ~= 0
    NormAmp = (Baseline-EventMin)/Baseline;
end

EventMetrics = struct();
EventMetrics.StartFrame = StartIndx;
EventMetrics.EndFrame = EndIndx;
EventMetrics.DurationFrames = EndIndx-StartIndx;
EventMetrics.NormAmp = NormAmp;
EventMetrics.DetectionAmp = DetectionAmp;

end
