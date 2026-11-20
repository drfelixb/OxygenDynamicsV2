function [IM_Zframetime,IM_Zframetime_smoothed,SupportAudit] = preprocessDetectionStack(IM_Notrend,smooth,varargin)
%PREPROCESSDETECTIONSTACK Z-score, convolve, and smooth a detection stack.
%
% Optional name-value inputs:
%   scaleSmoothedToUint8  Convert legacy smoothed values to uint8 after smoothing.
%   eligibleMask          Logical native ROI; default [] preserves whole-image replay.
% The third output records restricted policies and the included-neighbor weights.

Parser = inputParser();
Parser.addParameter('scaleSmoothedToUint8',false,@islogical);
Parser.addParameter('eligibleMask',[],@(x)islogical(x)||isempty(x));
Parser.parse(varargin{:});
Options = Parser.Results;

fprintf('Z-scoring data... \n');
tic;
SupportAudit=struct();
Mask=Options.eligibleMask;
if isempty(Mask)
    [~,IM_Zframetime] = normalizeToZStat(IM_Notrend);
else
    validateBOIDetectionMask(Mask,[size(IM_Notrend,1),size(IM_Notrend,2)]);
    assert(~Options.scaleSmoothedToUint8,'OxygenDynamics:UnsupportedROIScaling', ...
        'ROI detection uses floating-point values; display scaling is a separate operation.');
    [~,IM_Zframetime] = normalizeToZStat(IM_Notrend,Mask);
end
toc;

fprintf('Convolving data... \n');
tic;
ConvWin = ones(2 * smooth + 1,2 * smooth + 1) / (2 * smooth + 1)^2;
IM_Zframetime_conv = single(zeros(size(IM_Zframetime)));
if ~isempty(Mask)
    Weight=conv2(double(Mask),ConvWin,'same');
    SupportAudit=struct('Schema','boi-detection-support-1', ...
        'Profile','craniotomy-roi-1','MaskPixels',find(Mask),'NeighborWeightMap',Weight, ...
        'KernelWidthPixels',2*smooth+1,'SpatialNormalization','ROI_mean_sample_SD', ...
        'TemporalNormalization','per_included_pixel_mean_sample_SD', ...
        'SpatialSmoothing','included_neighbor_weight_normalized_same_kernel', ...
        'CandidatePolicy','sign_eligible_percentile_intersection_before_components', ...
        'ExteriorFill','zero_computational_sentinel_not_observation');
end
for FrameIdx = 1:size(IM_Zframetime,3)
    if isempty(Mask)
        IM_Zframetime_conv(:,:,FrameIdx) = single(conv2(IM_Zframetime(:,:,FrameIdx),ConvWin,'same'));
    else
        V=conv2(double(IM_Zframetime(:,:,FrameIdx)).*double(Mask),ConvWin,'same');
        F=zeros(size(Mask),'single');F(Mask)=single(V(Mask)./Weight(Mask));
        IM_Zframetime_conv(:,:,FrameIdx)=F;
    end
end
toc;

disp('Smoothing data...');
IM_Zframetime_smoothed = smoothdata(IM_Zframetime_conv,3,'gaussian',smooth/2);

if Options.scaleSmoothedToUint8
    IM_Zframetime_smoothed = scaleStackToUint8(IM_Zframetime_smoothed);
end

end
