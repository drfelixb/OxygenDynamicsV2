function res = saveastiff(data, path, options)
%SAVEASTIFF Save a 2-D image or 3-D grayscale stack as a TIFF file.

if nargin<3
    options = struct();
end
if ~isfield(options,'overwrite'), options.overwrite = false; end
if ~isfield(options,'append'), options.append = false; end
if ~isfield(options,'compress'), options.compress = 'no'; end
if ~isfield(options,'message'), options.message = true; end
if ~isfield(options,'big'), options.big = false; end

if isempty(data)
    error('saveastiff:EmptyData','Input data is empty.');
end
if ndims(data)>3
    error('saveastiff:UnsupportedDimensions','Only 2-D images and 3-D grayscale stacks are supported.');
end
if exist(path,'file') && ~options.append && ~options.overwrite
    error('saveastiff:FileExists','File already exists: %s',path);
end

[pathstr,~,~] = fileparts(path);
if ~isempty(pathstr) && ~isfolder(pathstr)
    mkdir(pathstr);
end

if ismatrix(data)
    data = reshape(data,size(data,1),size(data,2),1);
end

tagstruct = makeTiffTags(data,options.compress);
s = whos('data');
if s.bytes > 2^32-1 || options.big
    mode = 'w8';
else
    mode = 'w';
end

tStart = tic;
tfile = Tiff(path,mode);
cleanupObj = onCleanup(@() closeTiff(tfile));

for frameIdx=1:size(data,3)
    tfile.setTag(tagstruct);
    tfile.write(data(:,:,frameIdx));
    if frameIdx<size(data,3)
        tfile.writeDirectory();
    end
end

delete(cleanupObj);
tfile.close();
res = 0;

if options.message
    fprintf('The file was saved successfully. Elapsed time : %.3f s.\n',toc(tStart));
end

end

function tagstruct = makeTiffTags(data,compression)

tagstruct.ImageLength = size(data,1);
tagstruct.ImageWidth = size(data,2);
tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
tagstruct.SamplesPerPixel = 1;
tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
tagstruct.RowsPerStrip = 512;

switch lower(string(compression))
    case "no"
        tagstruct.Compression = Tiff.Compression.None;
    case "lzw"
        tagstruct.Compression = Tiff.Compression.LZW;
    case "adobe"
        tagstruct.Compression = Tiff.Compression.AdobeDeflate;
    otherwise
        tagstruct.Compression = compression;
end

switch class(data)
    case {'uint8','uint16','uint32'}
        tagstruct.SampleFormat = Tiff.SampleFormat.UInt;
    case {'int8','int16','int32'}
        tagstruct.SampleFormat = Tiff.SampleFormat.Int;
    case {'single','double'}
        tagstruct.SampleFormat = Tiff.SampleFormat.IEEEFP;
    otherwise
        error('saveastiff:UnsupportedClass','Unsupported data type: %s',class(data));
end

switch class(data)
    case {'uint8','int8'}
        tagstruct.BitsPerSample = 8;
    case {'uint16','int16'}
        tagstruct.BitsPerSample = 16;
    case {'uint32','int32','single'}
        tagstruct.BitsPerSample = 32;
    case 'double'
        tagstruct.BitsPerSample = 64;
end

end

function closeTiff(tfile)

try
    tfile.close();
catch
end

end
