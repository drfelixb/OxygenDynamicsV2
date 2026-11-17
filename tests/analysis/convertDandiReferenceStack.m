function info=convertDandiReferenceStack(nwbFile,tiffFile,P)
% Preserve selected archive pixels; time-axis selection is explicit in profile.
assert(~isfile(tiffFile),'Reference TIFF already exists.');
assert(strcmp(oxygenFileSHA256(nwbFile),P.ArchiveSHA256), ...
    'OxygenDynamics:ReferenceChecksum','Reference NWB checksum mismatch.');
assert(P.TimeAxisHdf5==3,'OxygenDynamics:ReferenceAxes','Only explicitly selected HDF5 time-last profiles are supported.');
D=h5info(nwbFile,[P.Series '/data']);expected=fliplr(P.NwbShape(:)');
assert(isequal(D.Dataspace.Size,expected),'OxygenDynamics:ReferenceShape','Unexpected NWB dimensions.');
rate=h5readatt(nwbFile,[P.Series '/starting_time'],'rate');
assert(rate==P.SampleHz,'OxygenDynamics:ReferenceRate','Unexpected sampling rate.');
comments=h5readatt(nwbFile,P.Series,'comments');
token=regexp(comments,'Resolution:\s*([0-9.]+)\s*um/pixel','tokens','once');
assert(~isempty(token)&&str2double(token{1})==P.PixelSize, ...
    'OxygenDynamics:ReferenceCalibration','NWB calibration differs from reference profile.');
assert(expected(1)==P.Frames && expected(1)>0);
range=[Inf -Inf];pixelClass='';
for frame=1:P.Frames
    plane=reshape(h5read(nwbFile,[P.Series '/data'],[frame 1 1],[1 expected(2:3)]),expected(2:3));
    assert(isa(plane,'uint16')||isa(plane,'uint8'), ...
        'OxygenDynamics:ReferencePixelType','Only lossless uint8/uint16 conversion is supported; no implicit rescaling.');
    pixelClass=class(plane);
    range=[min(range(1),double(min(plane(:)))) max(range(2),double(max(plane(:))))];
    if frame==1,imwrite(plane,tiffFile,'Compression','none');
    else,imwrite(plane,tiffFile,'WriteMode','append','Compression','none');end
end
for frame=1:P.Frames
    plane=reshape(h5read(nwbFile,[P.Series '/data'],[frame 1 1],[1 expected(2:3)]),expected(2:3));
    assert(isequal(imread(tiffFile,frame),plane),'OxygenDynamics:ReferenceRoundtrip','TIFF conversion changed pixels.');
end
info=struct('NwbSHA256',P.ArchiveSHA256,'TiffSHA256',oxygenFileSHA256(tiffFile), ...
    'IntensityRange',range,'PixelClass',pixelClass,'MatlabInputShape',expected, ...
    'PixelRoundtripVerified',true,'AddedDenoising',false);
end
