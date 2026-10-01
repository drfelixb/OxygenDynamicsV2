function Request=prepareBOIRecordingRequest(Options)
%PREPAREBOIRECORDINGREQUEST Read-only, shared GUI/batch settings boundary.
% Required: RecordingFolder, OutputFolder (new), SampleHz, PixelSizeUm,
% SupportProfile. Labels are optional and default explicitly to unspecified.
setupOxygenDynamicsPath;
required={'RecordingFolder','OutputFolder','SampleHz','PixelSizeUm','SupportProfile'};
labels={'Mouse','Condition','DrugID','Genotype','Promoter'};
assert(isstruct(Options)&&isscalar(Options)&&all(isfield(Options,required)), ...
    'OxygenDynamics:InvalidRunRequest','Supply one options struct with recording/output folders, sample rate, pixel size and support profile.');
unknown=setdiff(fieldnames(Options),[required labels]);
assert(isempty(unknown),'OxygenDynamics:InvalidRunRequest','Unsupported request fields: %s.',strjoin(unknown,', '));
supplied=fieldnames(Options);
for k=1:numel(labels)
    if ~isfield(Options,labels{k}),Options.(labels{k})='unspecified';end
end
for field=[{'RecordingFolder','OutputFolder','SupportProfile'} labels]
    v=Options.(field{1});
    assert((ischar(v)&&isrow(v)||isstring(v)&&isscalar(v))&&strlength(strtrim(string(v)))>0, ...
        'OxygenDynamics:InvalidRunRequest','%s must contain explicit text.',field{1});
    Options.(field{1})=char(v);
end
for field={'SampleHz','PixelSizeUm'}
    v=Options.(field{1});
    assert(isnumeric(v)&&isscalar(v)&&isreal(v)&&isfinite(v)&&v>0, ...
        'OxygenDynamics:InvalidRunRequest','%s must be a positive finite number.',field{1});
    Options.(field{1})=double(v);
end
Options.RecordingFolder=char(java.io.File(Options.RecordingFolder).getCanonicalPath());
Options.OutputFolder=char(java.io.File(Options.OutputFolder).getCanonicalPath());
assert(~isfolder(Options.OutputFolder)&&~isfile(Options.OutputFolder), ...
    'OxygenDynamics:RunOutputExists','Choose a new run directory; previous results are never overwritten.');
assert(~strcmp(Options.OutputFolder,Options.RecordingFolder)&& ...
    ~startsWith(Options.OutputFolder,[Options.RecordingFolder filesep]), ...
    'OxygenDynamics:InvalidRunRequest','Keep the new run outside the source recording folder.');
profile=getBOISupportProfile(struct('BOISupportProfile',Options.SupportProfile));
Review=reviewBOIRecordingInput(Options.RecordingFolder,Options.SampleHz,Options.PixelSizeUm);
assert(Review.Files.IsValid&&Review.InputCompatible&&~startsWith(Review.Status,'held_'), ...
    'OxygenDynamics:RunInputHeld','Input preflight did not pass. %s',strjoin(Review.QC.Message,' '));
params=createOxygenMasterParams(Options.PixelSizeUm,Options.SampleHz);
if strcmp(profile,'craniotomy-roi-1')
    sz=[Review.Files.RawTiffInfo.Height Review.Files.RawTiffInfo.Width];
    mask=resolveBOITissueSupport(Review.TissueSnapshot,sz,Review.RawSHA256);
    validateBOIDetectionMask(mask,sz);
    b=params.Pixel_frame;
    assert(all(sz>2*b),'OxygenDynamics:InvalidDetectionSupport','Recording is smaller than the existing sink border exclusion.');
    validateBOIDetectionMask(mask(b+1:end-b,b+1:end-b),sz-2*b);
end
paths={Review.Files.RawFile};
if ~isempty(Review.Files.DenoisedFile),paths{end+1}=Review.Files.DenoisedFile;end
for k=1:numel(Review.DeclarationFiles)
    paths{end+1}=fullfile(Options.RecordingFolder,Review.DeclarationFiles(k).Name); %#ok<AGROW>
end
sources=struct('Name',{},'SHA256',{});
for k=1:numel(paths)
    [~,name,ext]=fileparts(paths{k});
    sources(k)=struct('Name',[name ext],'SHA256',oxygenFileSHA256(paths{k}));
end
context=createLegacyRecordingContext(Options.SampleHz,Options.Mouse,Options.Condition, ...
    Options.PixelSizeUm,Options.Genotype,Options.Promoter,Options.DrugID,NaN,NaN,NaN,'N',profile);
context.SaveBOIReviewEvidence=true;
provenance=struct();
for f=fieldnames(Options)'
    provenance.(f{1})='explicit';
    if ~ismember(f{1},supplied),provenance.(f{1})='default: unspecified';end
end
Request=struct('Schema','boi-recording-request-1','Options',Options,'Sources',sources, ...
    'Context',context,'AnalysisParams',params,'SettingOrigins',provenance,'InputReview',Review);
end
