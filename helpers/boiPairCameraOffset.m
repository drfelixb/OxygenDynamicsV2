function offset=boiPairCameraOffset(options,channel)
letters='AB'; field=['CameraOffsetCounts' letters(channel)];
offset=[];
if isfield(options,field),offset=boiCameraOffset(options.(field));end
end
