function O = prepareBOIMultichannel(O)
% Validate two explicitly assigned, prealigned and synchronized grayscale movies.
setupOxygenDynamicsPath;
required = {'RecordingID','Mode','RawFiles','Sensors','Promoters','SampleHz', ...
    'PixelSizeUm','AlignedAndSynchronized','OutputFolder'};
assert(isstruct(O) && isscalar(O) && all(isfield(O,required)), ...
    'BOIPair:Inputs','Supply recording identity, mode, two movies and labels, calibration, synchronization and a new output folder.');
O.Mode = string(validatestring(O.Mode,{'dual-bli','bli-fluorescence'}));
assert(islogical(O.AlignedAndSynchronized) && isequal(O.AlignedAndSynchronized,true), ...
    'BOIPair:Synchronization','Confirm both movies have the same aligned pixels and frame-by-frame timing.');
validateattributes(O.SampleHz,{'numeric'},{'scalar','real','finite','positive'});
validateattributes(O.PixelSizeUm,{'numeric'},{'scalar','real','finite','positive'});
O.RecordingID = strtrim(string(O.RecordingID));
assert(isscalar(O.RecordingID) && ~ismissing(O.RecordingID) && strlength(O.RecordingID)>0,'BOIPair:Identity','Supply the recording ID.');
if ~isfield(O,'DenoisedFiles'), O.DenoisedFiles = ["",""]; end
for name = ["Sensors","Promoters","RawFiles","DenoisedFiles"]
    values = strtrim(string(O.(name)));
    assert(numel(values)==2 && ~any(ismissing(values)),'BOIPair:Inputs','Specify two entries for %s.',name);
    O.(name) = reshape(values,1,2);
end
assert(all(strlength(O.Sensors)>0) && all(strlength(O.Promoters)>0),'BOIPair:Identity', ...
    'Give each channel a sensor and promoter label. Use unspecified when unknown.');
assert(O.Mode=="dual-bli" || O.DenoisedFiles(2)=="",'BOIPair:Detection','Fluorescence uses its preserved intensity movie.');
assert(strlength(string(O.OutputFolder))>0,'BOIPair:Destination','Choose a new output folder.');
O.OutputFolder = char(java.io.File(char(O.OutputFolder)).getCanonicalPath());
assert(~isfile(O.OutputFolder) && ~isfolder(O.OutputFolder),'BOIPair:Destination','Choose a new output folder.');
O.CameraOffsetCountsA=boiPairCameraOffset(O,1);
O.CameraOffsetCountsB=boiPairCameraOffset(O,2);
shape = [];
used = strings(0,1);
for channel = 1:2
    for role = ["RawFiles","DenoisedFiles"]
        path = O.(role)(channel);
        if role=="DenoisedFiles" && path=="", continue; end
        assert(isfile(path),'BOIPair:Source','Movie missing: %s',path);
        path = string(java.io.File(char(path)).getCanonicalPath());
        assert(~ismember(path,used),'BOIPair:Duplicate','A TIFF was selected for multiple inputs.');
        used(end+1,1) = path; %#ok<AGROW>
        O.(role)(channel) = path;
        assert(~startsWith(string(O.OutputFolder),string(fileparts(path))+filesep), ...
            'BOIPair:Destination','Choose an output location outside the input movie folders.');
        info = imfinfo(path);
        assert(numel(info)>1 && all([info.Width]==info(1).Width) && all([info.Height]==info(1).Height) ...
            && all(strcmp({info.ColorType},'grayscale')),'BOIPair:Movie','Expected a multipage grayscale time series: %s',path);
        current = [info(1).Height info(1).Width numel(info)];
        if isempty(shape), shape = current; end
        assert(isequal(shape,current),'BOIPair:Grid','Image grid or frame count differs: %s',path);
    end
end
O.FrameSize = shape(1:2);
O.NFrames = shape(3);
end
