function offset=boiCameraOffset(source)
% A missing field or blank cell means unsupplied. Zero is a supplied offset.
if nargin==0,source=[];end
if isstruct(source)
    if isfield(source,'CameraOffsetCounts'),source=source.CameraOffsetCounts;else,source=[];end
end
if ischar(source)||(isstring(source)&&isscalar(source))
    source=strip(string(source));
    if ~ismissing(source)&&strlength(source)==0,source=[];else,source=str2double(source);end
end
if isempty(source),offset=[];return;end
validateattributes(source,{'numeric'},{'real','scalar','finite','nonnegative'},mfilename,'CameraOffsetCounts');
offset=double(source);
end
