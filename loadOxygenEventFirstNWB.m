function R = loadOxygenEventFirstNWB(File,Series,Metadata,Layout)
% Narrow HDF5 adapter: caller must specify MATLABAxisOrder (e.g. TXY).
% FrameCount supports a temporal prefix only; spatial coordinates stay full-frame.
assert(isfile(File),'eventFirst:NWB','Local NWB required; this adapter never downloads.');
assert(isfield(Layout,'MATLABAxisOrder'),'eventFirst:NWB','Explicit MATLABAxisOrder required; time is never inferred from size.');
a=char(Layout.MATLABAxisOrder);
assert(numel(a)==3 && isequal(sort(a),'TXY'),'eventFirst:NWB','Unsupported axes.');
info=h5info(File,[Series '/data']); dims=info.Dataspace.Size;
assert(numel(dims)==3,'eventFirst:NWB','Only 3D image series supported.');
count=dims; ti=find(a=='T');
if isfield(Layout,'FrameCount'), count(ti)=Layout.FrameCount; end
assert(count(ti)>=3&&count(ti)<=dims(ti)&&count(ti)==floor(count(ti)),'eventFirst:NWB','Invalid temporal prefix.');
try
    fs=h5readatt(File,[Series '/starting_time'],'rate'); origin=h5read(File,[Series '/starting_time']);
catch
    error('eventFirst:NWB','Only explicit starting_time/rate series supported.');
end
% Reject timestamp-driven layouts even if redundant starting_time exists.
seriesInfo=h5info(File,Series);
assert(~any(strcmp({seriesInfo.Datasets.Name},'timestamps')),'eventFirst:NWB','Timestamp-driven NWB unsupported in this adapter.');
x=h5read(File,[Series '/data'],[1 1 1],count);
R=Metadata; R.Intensity=permute(x,[find(a=='Y') find(a=='X') ti]);
R.NFrames=size(R.Intensity,3); R.fs=double(fs); R.FrameTimestampsSec=double(origin)+(0:R.NFrames-1)/R.fs;
R.AxisOrder="YXT"; R.SourceIdentity=string(File)+"#"+string(Series);
R.SignalProvenance="PreservedInputIntensity; NWB unit/scaling not assumed to be camera counts";
R.SourceSHA256=oxygenEventFirstSHA256(File);
if isfield(Layout,'ExpectedSHA256')
    assert(strcmpi(R.SourceSHA256,string(Layout.ExpectedSHA256)),'eventFirst:Checksum','NWB SHA256 mismatch.');
end
R.SourceLayout=Layout; R.SourceOriginalDimensions=dims; R.SourceFrameRange=[1 R.NFrames];
R.SourceDataAttributes=info.Attributes;
R.SourceScaling="HDF5 numeric values unchanged; attributes retained without inferred calibration";
if ~isfield(R,'ValidMask')
    error('eventFirst:NWB','Metadata.ValidMask required; use explicit all-true support with a documented limitation if unverified.');
end
end
