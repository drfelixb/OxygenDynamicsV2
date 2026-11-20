function [Pixels,Logical]=filterSinkRunsByDuration(Pixels,minFrames,maxFrames)
% Retain every duration-qualified native sink run, including close neighbors.
assert(isscalar(minFrames)&&isfinite(minFrames)&&minFrames>0);
assert(isscalar(maxFrames)&&isfinite(maxFrames)&&maxFrames>=minFrames);
Logical=~cellfun(@isempty,Pixels);
for s=1:size(Pixels,1)
 runs=regionprops(Logical(s,:),'Area','PixelIdxList');
 for k=1:numel(runs)
  if runs(k).Area<minFrames||runs(k).Area>maxFrames
   Pixels(s,runs(k).PixelIdxList)={[]};Logical(s,runs(k).PixelIdxList)=false;
  end
 end
end
keep=any(Logical,2);Pixels=Pixels(keep,:);Logical=Logical(keep,:);
end
