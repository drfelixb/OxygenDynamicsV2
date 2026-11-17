function Series = computeOngoingRegionSeries(Rows,NFrames,PixelSize,kind)
% Counts use saved event intervals; occupied area uses unions of native frame masks.
Series=struct('Count',zeros(1,NFrames),'AreaNorm',zeros(1,NFrames), ...
    'AreaUm',zeros(1,NFrames),'Raster',false(height(Rows),NFrames));
if strcmp(kind,'sink'), start='Start'; duration='Duration'; area='RecAreaSize';
else, start='Start_Surge'; duration='Duration_Surge'; area='RecAreaSize_Surge'; end
for s=1:height(Rows)
    for e=1:numel(Rows.(start){s})
        f=Rows.(start){s}(e); d=Rows.(duration){s}(e);
        if ~isfinite(f) || ~isfinite(d), continue; end
        frames=max(1,f):min(NFrames,f+d-1);
        Series.Count(frames)=Series.Count(frames)+1;
        Series.Raster(s,frames)=true;
    end
end
if isempty(Rows), return; end
if ~ismember('EligibleTissuePixels',Rows.Properties.VariableNames) || ~ismember('FramePixels',Rows.Properties.VariableNames) || any(cellfun(@isempty,Rows.FramePixels))
    Series.AreaNorm(:)=NaN; Series.AreaUm(:)=NaN;
    return % Historical site union cannot recover instantaneous area.
end
A=Rows.(area){1};
for t=1:NFrames
    pixels=[];
    for s=1:height(Rows)
        pc=Rows.FramePixels{s};
        if t<=numel(pc), pixels=[pixels;pc{t}(:)]; end %#ok<AGROW>
    end
    Series.AreaUm(t)=numel(intersect(pixels,Rows.EligibleTissuePixels{1}))*PixelSize^2;
end
if isfinite(A) && A>0, Series.AreaNorm=Series.AreaUm/A; else, Series.AreaNorm(:)=NaN; end
end
