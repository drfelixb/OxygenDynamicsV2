function SizeModulation = computeEventSizeModulation(trackedPixelList,regionIdx,eventPixelIdx)
%COMPUTEEVENTSIZEMODULATION Compare tracked-region size at event end versus start.

StartSize = length(trackedPixelList{regionIdx,eventPixelIdx(1)});
EndSize = length(trackedPixelList{regionIdx,eventPixelIdx(end)});
SizeModulation = (EndSize-StartSize)/StartSize;

end
