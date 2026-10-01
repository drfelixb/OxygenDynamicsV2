function [IM2_zsc_frame,IM2_zsc_frame_time] = normalizeToZStat(IM,Mask)
%NORMALIZETOZSTAT Z-score image stacks frame-wise and then over time.
% Optional logical Mask restricts both reductions to included pixels. Exterior
% output zeros are computational fill; downstream processing must retain Mask.

assert(isnumeric(IM)&&isreal(IM)&&all(isfinite(IM(:))), ...
    'OxygenDynamics:InvalidDetectionInput','Detection requires finite real input; repair or exclude invalid acquisition data explicitly.');
IM = double(IM);
StackSize = [size(IM,1),size(IM,2),size(IM,3)];
PixelsByFrame = reshape(IM,[],StackSize(3));
if nargin>1
    validateBOIDetectionMask(Mask,StackSize(1:2));
    V=PixelsByFrame(Mask(:),:);
    mu=mean(V,1);sigma=std(V,0,1);sigma(sigma==0)=Inf;
    A=(V-mu)./sigma;
    muT=mean(A,2);sigmaT=std(A,0,2);
    sigmaT(max(A,[],2)==min(A,[],2)|sigmaT==0)=Inf;
    Z=(A-muT)./sigmaT;
    A(~isfinite(A))=0;Z(~isfinite(Z))=0;
    IM2_zsc_frame=zeros(size(PixelsByFrame),'single');
    IM2_zsc_frame_time=IM2_zsc_frame;
    IM2_zsc_frame(Mask(:),:)=single(A);
    IM2_zsc_frame_time(Mask(:),:)=single(Z);
    IM2_zsc_frame=reshape(IM2_zsc_frame,StackSize);
    IM2_zsc_frame_time=reshape(IM2_zsc_frame_time,StackSize);
    return
end

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
