function EventMetrics = quantifyiOSSinkEvent(eventPixelIdx,temptrace,tracetrend)
%QUANTIFYIOSSINKEVENT Calculate legacy iOS sink event timing and amplitude.

EventStart = eventPixelIdx(1);
EventEnd = eventPixelIdx(end);
TraceLength = numel(temptrace);

if EventStart > 11 && EventEnd < TraceLength-11
    [~,StartOffset] = min(abs(tracetrend(EventStart-10:EventStart)-temptrace(EventStart-10:EventStart)));
    StartIndx = EventStart-10+StartOffset;
    [~,EndOffset] = min(abs(tracetrend(EventEnd:EventEnd+10)-temptrace(EventEnd:EventEnd+10)));
    EndIndx = EventEnd+EndOffset;
    NormAmp = abs(abs(min(temptrace(StartIndx:EndIndx)))-abs(min(tracetrend(StartIndx:EndIndx))));
elseif EventStart < 11
    StartIndx = EventStart;
    [~,EndOffset] = min(abs(tracetrend(EventEnd:EventEnd+10)-temptrace(EventEnd:EventEnd+10)));
    EndIndx = EventEnd+EndOffset;
    NormAmp = abs(abs(min(temptrace(StartIndx:EndIndx)))-abs(min(tracetrend(StartIndx:EndIndx))));
else
    [~,StartOffset] = min(abs(tracetrend(EventStart-10:EventStart)-temptrace(EventStart-10:EventStart)));
    StartIndx = EventStart-10+StartOffset;
    EndIndx = EventEnd;
    NormAmp = abs(min(temptrace(StartIndx:EndIndx)))-abs(min(tracetrend(StartIndx:EndIndx)));
end

EventMetrics = struct();
EventMetrics.StartFrame = StartIndx;
EventMetrics.EndFrame = EndIndx;
EventMetrics.DurationFrames = EndIndx-StartIndx;
EventMetrics.NormAmp = NormAmp;

end
