function [IM2_zsc_frame,IM2_zsc_frame_time] = normalizeToZStat(IM)
%NORMALIZETOZSTAT Z-score image stacks frame-wise and then over time.

IM = double(IM);
StackSize = size(IM);
PixelsByFrame = reshape(IM,[],StackSize(3));

FrameMean = mean(PixelsByFrame,1,'omitnan');
FrameStd = std(PixelsByFrame,0,1,'omitnan');
FrameStd(~isfinite(FrameStd) | FrameStd == 0) = eps;

IM2_zsc_frame = nan(StackSize);
for FrameIdx = 1:StackSize(3)
    IM2_zsc_frame(:,:,FrameIdx) = (IM(:,:,FrameIdx) - FrameMean(FrameIdx)) ./ FrameStd(FrameIdx);
end

ZFrameMean = mean(IM2_zsc_frame,3,'omitnan');
ZFrameStd = std(IM2_zsc_frame,0,3,'omitnan');
ZFrameStd(~isfinite(ZFrameStd) | ZFrameStd == 0) = eps;

IM2_zsc_frame_time = nan(StackSize);
for FrameIdx = 1:StackSize(3)
    IM2_zsc_frame_time(:,:,FrameIdx) = (IM2_zsc_frame(:,:,FrameIdx) - ZFrameMean) ./ sqrt(ZFrameStd);
end

IM2_zsc_frame(~isfinite(IM2_zsc_frame)) = 0;
IM2_zsc_frame_time(~isfinite(IM2_zsc_frame_time)) = 0;

IM2_zsc_frame = single(IM2_zsc_frame);
IM2_zsc_frame_time = single(IM2_zsc_frame_time);

end
