function validateBOIDetectionMask(Mask,FrameSize)
% No resizing, numeric coercion, empty support or all-exterior zero result.
assert(islogical(Mask)&&ismatrix(Mask)&&isequal(size(Mask),FrameSize)&&any(Mask(:)), ...
    'OxygenDynamics:InvalidDetectionSupport','Detection support must be a nonempty logical mask of the exact native image dimensions.');
end
