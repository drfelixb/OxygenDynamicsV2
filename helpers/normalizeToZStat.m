function [IM2_zsc_frame,IM2_zsc_frame_time] = normalizeToZStat(IM)
%NORMALIZETOZSTAT Z-score image stacks frame-wise and then over time.

assert(isnumeric(IM)&&isreal(IM)&&all(isfinite(IM(:))), ...
    'OxygenDynamics:InvalidDetectionInput','Detection requires finite real input; repair or exclude invalid acquisition data explicitly.');
IM = double(IM);
StackSize = [size(IM,1),size(IM,2),size(IM,3)];
PixelsByFrame = reshape(IM,[],StackSize(3));

FrameMean = mean(PixelsByFrame,1,'omitnan');
FrameStd = std(PixelsByFrame,0,1,'omitnan');
FrameStd(FrameStd == 0) = Inf;

IM2_zsc_frame = nan(StackSize);
for FrameIdx = 1:StackSize(3)
    IM2_zsc_frame(:,:,FrameIdx) = (IM(:,:,FrameIdx) - FrameMean(FrameIdx)) ./ FrameStd(FrameIdx);
end

ZFrameMean = mean(IM2_zsc_frame,3,'omitnan');
ZFrameStd = std(IM2_zsc_frame,0,3,'omitnan');
ZFrameStd(max(IM2_zsc_frame,[],3)==min(IM2_zsc_frame,[],3) | ZFrameStd==0) = Inf;

IM2_zsc_frame_time = nan(StackSize);
for FrameIdx = 1:StackSize(3)
    IM2_zsc_frame_time(:,:,FrameIdx) = (IM2_zsc_frame(:,:,FrameIdx) - ZFrameMean) ./ ZFrameStd;
end

IM2_zsc_frame(~isfinite(IM2_zsc_frame)) = 0;
IM2_zsc_frame_time(~isfinite(IM2_zsc_frame_time)) = 0;

IM2_zsc_frame = single(IM2_zsc_frame);
IM2_zsc_frame_time = single(IM2_zsc_frame_time);

end
