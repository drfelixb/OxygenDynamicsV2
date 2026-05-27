function rgb = hex2rgb(hex,range)
% hex2rgb converts hex color values to RGB arrays.

assert(nargin>0 && nargin<3,'hex2rgb function must have one or two inputs.') 
if nargin==2
    assert(isscalar(range),'Range must be a scalar, either "1" to scale from 0 to 1 or "256" to scale from 0 to 255.')
end

if iscell(hex)
    assert(isvector(hex),'Unexpected dimensions of input hex values.')
    if isrow(hex)
        hex = hex'; 
    end
    hex = cell2mat(hex);
end

if strcmpi(hex(1,1),'#')
    hex(:,1) = [];
end
if nargin == 1
    range = 1; 
end

switch range
    case 1
        rgb = reshape(sscanf(hex.','%2x'),3,[]).'/255;
    case {255,256}
        rgb = reshape(sscanf(hex.','%2x'),3,[]).';
    otherwise
        error('Range must be either "1" to scale from 0 to 1 or "256" to scale from 0 to 255.')
end
end
