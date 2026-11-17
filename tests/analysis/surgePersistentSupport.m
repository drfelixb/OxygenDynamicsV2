function pixels=surgePersistentSupport(FramePixels,frames,fraction)
% TEST ONLY: fixed support from occupancy, without ranking raw intensity.
assert(isscalar(fraction)&&isfinite(fraction)&&fraction>=0&&fraction<=1);
assert(~isempty(frames)&&all(frames>=1&frames<=numel(FramePixels))&&numel(unique(frames))==numel(frames));
joined=[];
for f=reshape(frames,1,[])
 p=FramePixels{f}(:);assert(numel(unique(p))==numel(p),'Duplicate native pixels.');
 joined=[joined;p]; %#ok<AGROW>
end
if isempty(joined),pixels=zeros(0,1);return;end
[values,~,group]=unique(joined);counts=accumarray(group,1);
pixels=values(counts>=max(1,ceil(fraction*numel(frames))));
end
