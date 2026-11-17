function BW=surgeEvidenceTruthMask(M,k,q,t)
% Prescribed support, including changing radius; no support outside its window.
BW=false(M.Height,M.Width);a=M.Windows(q,1);b=M.Windows(q,2);
if t<a||t>b,return;end
[y,x]=ndgrid(1:M.Height,1:M.Width);cx=M.CentersXY(k,1);cy=M.CentersXY(k,2);
if isfield(M,'RadiusUmByFrame')
 radius=M.RadiusUmByFrame(t)/M.SourceProfile.PixelSize;
else
 radius=M.RadiusPixels;
 if q==8,cx=round(cx+M.MotionUmPerSec*(t-101)/M.SampleHz/M.SourceProfile.PixelSize);end
end
BW=(x-cx).^2+(y-cy).^2<=radius^2;
end
