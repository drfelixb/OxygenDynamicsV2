function [Plane,Mask]=readBOIEventReviewFrame(Review,Index,Frame,Mode)
%READBOIEVENTREVIEWFRAME Read one checksum-matched source frame, never a movie.
I=Review.AnalysisInfo;
if nargin<4,Mode='fixed';end
Mode=validatestring(Mode,{'fixed','native'});
assert(isscalar(Frame)&&Frame>=1&&Frame<=I.NFrames&&Frame==fix(Frame));
pixels=Review.Traces{Index}.Footprint;
if strcmp(Mode,'native')
    attachment=validateBOINativeMaskSource(Review,Index);pixels=attachment.FramePixels{Frame};
end
assert(isfile(I.RawFile),'OxygenDynamics:ReviewSourceMissing','Preserved source unavailable. Saved traces remain inspectable; reconnect the source to view pixels.');
assert(strcmp(oxygenFileSHA256(I.RawFile),I.RawSHA256), ...
    'OxygenDynamics:ReviewSourceChanged','Source checksum differs. Image withheld; saved traces have not been replaced.');
Plane=imread(I.RawFile,Frame);
assert(isequal(size(Plane),I.FrameSize),'OxygenDynamics:ReviewSourceShape','Image dimensions differ from saved audit.');
Mask=false(size(Plane));Mask(pixels)=true;
end
