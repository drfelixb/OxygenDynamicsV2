function [NumEvents,Start,Duration,NormAmp,SizeModulation] = initializeEventMetricCells(numRegions)
%INITIALIZEEVENTMETRICCELLS Preallocate per-region event summary containers.

NumEvents = NaN(numRegions,1);
Start = cell(numRegions,1);
Duration = cell(numRegions,1);
NormAmp = cell(numRegions,1);
SizeModulation = cell(numRegions,1);

end
