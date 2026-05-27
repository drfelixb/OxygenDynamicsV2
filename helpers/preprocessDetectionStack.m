function [IM_Zframetime,IM_Zframetime_smoothed] = preprocessDetectionStack(IM_Notrend,smooth,varargin)
%PREPROCESSDETECTIONSTACK Z-score, convolve, and smooth a detection stack.
%
% Optional name-value inputs:
%   scaleSmoothedToUint8  Convert the smoothed stack to uint8 after smoothing.

Parser = inputParser();
Parser.addParameter('scaleSmoothedToUint8',false,@islogical);
Parser.parse(varargin{:});
Options = Parser.Results;

fprintf('Z-scoring data... \n');
tic;
[~,IM_Zframetime] = normalizeToZStat(IM_Notrend);
toc;

fprintf('Convolving data... \n');
tic;
ConvWin = ones(2 * smooth + 1,2 * smooth + 1) / (2 * smooth + 1)^2;
IM_Zframetime_conv = single(zeros(size(IM_Zframetime)));
for FrameIdx = 1:size(IM_Zframetime,3)
    IM_Zframetime_conv(:,:,FrameIdx) = single(conv2(IM_Zframetime(:,:,FrameIdx),ConvWin,'same'));
end
toc;

disp('Smoothing data...');
IM_Zframetime_smoothed = smoothdata(IM_Zframetime_conv,3,'gaussian',smooth/2);

if Options.scaleSmoothedToUint8
    IM_Zframetime_smoothed = scaleStackToUint8(IM_Zframetime_smoothed);
end

end
