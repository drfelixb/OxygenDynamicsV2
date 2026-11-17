function NativeFrame = writeBOIEventInspection(SourceTiff,FramePixels,Event,TimeSec,SignedFraction,fs,OutputPath)
%WRITEBOIEVENTINSPECTION Display image and native mask from the SAME frame.
% Quantitative trace uses the full event footprint, not this single mask.
NativeFrame=Event.NativeStartFrame;
plane=imread(SourceTiff,NativeFrame);
eventMask=false(size(plane));eventMask(FramePixels{NativeFrame})=true;
fig=figure('Visible','off','Position',[100 100 1100 450]);
cleanup=onCleanup(@()close(fig));
tiledlayout(1,2);nexttile;imagesc(plane);axis image;colormap gray;hold on;
contour(eventMask,[.5 .5],'r');
title(sprintf('Preserved input and native mask: frame %d',NativeFrame));
xlabel('Image column (pixel)');ylabel('Image row (pixel)');
nexttile;plot(TimeSec,SignedFraction*100,'k');hold on;
yline(0,':');xline((Event.StartFrame-1)/fs,'r');xline(Event.EndFrame/fs,'r');
xline((Event.BaselineStartFrame-1)/fs,'b:');xline(Event.BaselineEndFrame/fs,'b:');
xlabel('Recording time (s)');ylabel('Optical change from baseline (%)');
title('Fixed native event footprint; red event / blue baseline');
exportgraphics(fig,OutputPath,'Resolution',130);
end
