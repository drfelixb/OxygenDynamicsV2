function EventMetrics = quantifyOxygenSurgeEvent(eventPixelIdx,surgeTrace,baselineWindowFrames,useAbsoluteRatio)
%QUANTIFYOXYGENSURGEEVENT Calculate timing and baseline-normalized amplitude for one surge.

if nargin < 4
    useAbsoluteRatio = false;
end

StartFrame = eventPixelIdx(1);
EndFrame = eventPixelIdx(end);
DurationFrames = numel(eventPixelIdx);

if StartFrame-baselineWindowFrames > 1
    BaselineStartIndx = StartFrame-baselineWindowFrames;
    BaselineEndIndx = StartFrame-1;
else
    BaselineStartIndx = min(numel(surgeTrace),EndFrame+1);
    BaselineEndIndx = min(numel(surgeTrace),EndFrame+baselineWindowFrames);
end

AmplitudeRatio = mean(surgeTrace(eventPixelIdx))/mean(surgeTrace(BaselineStartIndx:BaselineEndIndx));
if useAbsoluteRatio
    AmplitudeRatio = abs(AmplitudeRatio);
end

EventMetrics = struct();
EventMetrics.StartFrame = StartFrame;
EventMetrics.EndFrame = EndFrame;
EventMetrics.DurationFrames = DurationFrames;
EventMetrics.NormAmp = AmplitudeRatio;

end
