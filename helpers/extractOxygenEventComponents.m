function Masks = extractOxygenEventComponents(Score,Valid,R,C)
% 26-connected hysteresis components. Ambiguous topology is retained, not split by guesswork.
% Recovery (no growth support) creates new identity. No gaps are filled or bridged.
[h,w,n]=size(Score); Masks=struct('Sign',{},'Frames',{},'PixelIdxList',{},'Footprint',{},'SeedCount',{},'Ambiguous',{},'BoundaryTruncated',{},'AdjacentUnknown',{});
for sign=[-1 1]
    growth=sign*Score>=C.GrowSD & Valid;
    seeds=sign*Score>=C.SeedSD & Valid;
    cc=bwconncomp(growth,26);
    for k=1:cc.NumObjects
        vox=cc.PixelIdxList{k};
        if ~any(seeds(vox)), continue; end
        frames=floor((vox-1)/(h*w))+1; spatial=mod(vox-1,h*w)+1;
        active=unique(frames)'; pixels=cell(1,numel(active)); topology=false;
        for j=1:numel(active)
            pixels{j}=uint32(sort(spatial(frames==active(j))));
            plane=false(h,w); plane(pixels{j})=true; parts=bwconncomp(plane,8);
            topology=topology || parts.NumObjects>1;
        end
        area=cellfun(@numel,pixels);
        minArea=1;
        if C.MinAreaUm2>0
            assert(all(isfinite(R.PixelSizeUm)),'eventFirst:Calibration','Physical area threshold requires pixel calibration.');
            minArea=max(1,ceil(C.MinAreaUm2/prod(R.PixelSizeUm)));
        end
        if numel(active)<max(1,ceil(C.MinDurationSec*R.fs)) || max(area)<minArea, continue; end
        [vy,vx,vt]=ind2sub([h w n],vox);
        by=min(vy); bx=min(vx); bt=min(vt);
        local=false(max(vy)-by+1,max(vx)-bx+1,max(2,max(vt)-bt+1));
        local(sub2ind(size(local),vy-by+1,vx-bx+1,vt-bt+1))=seeds(vox);
        seedcc=bwconncomp(local,26);
        fp=uint32(unique(spatial)); [yy,xx]=ind2sub([h w],double(fp));
        boundary=active(1)==1 || active(end)==n || any(yy==1|yy==h|xx==1|xx==w);
        unknown=false;
        for t=max(1,active(1)-1):min(n,active(end)+1)
            v=Valid(:,:,t); unknown=unknown || any(~v(fp));
        end
        Masks(end+1)=struct('Sign',sign,'Frames',active,'PixelIdxList',{pixels}, ...
            'Footprint',fp,'SeedCount',seedcc.NumObjects,'Ambiguous',topology||seedcc.NumObjects>1, ...
            'BoundaryTruncated',boundary,'AdjacentUnknown',unknown); %#ok<AGROW>
    end
end
if ~isempty(Masks)
    first=arrayfun(@(m)m.Frames(1),Masks); fp=arrayfun(@(m)double(m.Footprint(1)),Masks);
    [~,order]=sortrows([first(:) [Masks.Sign]' fp(:)],[1 2 3]); Masks=Masks(order);
end
end
