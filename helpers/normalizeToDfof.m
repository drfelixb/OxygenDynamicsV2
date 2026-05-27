function [IM_dFoF_global,IM_dFoF_frame] = normalizeToDfof(IM)
%NORMALIZETODFOF Compute global and frame-wise delta-F/F stacks.

IM = double(IM);
IM_dFoF_global = nan(size(IM));
IM_dFoF_frame = nan(size(IM));

GlobalMean = mean(IM(:),'omitnan');
if ~isfinite(GlobalMean) || GlobalMean == 0
    GlobalMean = eps;
end

IM_dFoF_global(:,:,:) = (IM(:,:,:) - GlobalMean) ./ GlobalMean;

FrameMean = squeeze(mean(mean(IM,1,'omitnan'),2,'omitnan'));
for FrameIdx = 1:size(IM,3)
    Denominator = FrameMean(FrameIdx);
    if ~isfinite(Denominator) || Denominator == 0
        Denominator = eps;
    end
    IM_dFoF_frame(:,:,FrameIdx) = (IM(:,:,FrameIdx) - Denominator) ./ Denominator;
end

IM_dFoF_global = replaceNonFiniteWithExtrema(IM_dFoF_global);
IM_dFoF_frame = replaceNonFiniteWithExtrema(IM_dFoF_frame);

IM_dFoF_global = single(IM_dFoF_global);
IM_dFoF_frame = single(IM_dFoF_frame);

end

function IM = replaceNonFiniteWithExtrema(IM)

FiniteValues = IM(isfinite(IM));
if isempty(FiniteValues)
    IM(:) = 0;
    return
end

IM(IM == -inf) = min(FiniteValues);
IM(IM == inf) = max(FiniteValues);
IM(isnan(IM)) = 0;

end
