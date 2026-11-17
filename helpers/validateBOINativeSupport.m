function validateBOINativeSupport(Sites,Eligible,FrameSize)
% Assert exact native containment after refinement; never repair by clipping.
mask=false(FrameSize);mask(Eligible)=true;
assert(ismember('FramePixels',Sites.Properties.VariableNames), ...
    'OxygenDynamics:NativeSupportViolation','Native frame footprints are required.');
for s=1:height(Sites)
    frames=Sites.FramePixels{s};
    for f=1:numel(frames)
        px=frames{f};
        assert(isnumeric(px)&&all(isfinite(px(:)))&&all(px(:)==fix(px(:)))&& ...
            all(px(:)>=1)&&all(px(:)<=numel(mask)), ...
            'OxygenDynamics:NativeSupportViolation','Native footprint has invalid indices.');
        assert(all(mask(px(:))),'OxygenDynamics:NativeSupportViolation', ...
            'Final native footprint at site %d, frame %d leaves its sign support. No clipping was applied.',s,f);
    end
end
end
