function Series = computeOngoingSurgeTimeSeries(Rows,NFrames,PixelSize)
if nargin<3, PixelSize=NaN; end
Series=computeOngoingRegionSeries(Rows,NFrames,PixelSize,'surge');
end
