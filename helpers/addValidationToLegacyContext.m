function Context = addValidationToLegacyContext(Context,Validation,fs)
%ADDVALIDATIONTOLEGACYCONTEXT Add raw TIFF and recording-duration info.

if isfield(Validation,'RawFile') && ~isempty(Validation.RawFile) && isfile(Validation.RawFile)
    RawFile = dir(Validation.RawFile);
    Context.Tifffiles = RawFile;
end

if isfield(Validation,'RawTiffInfo') && isfield(Validation.RawTiffInfo,'Frames') && ...
        isnumeric(fs) && isscalar(fs) && isfinite(fs) && fs>0
    Context.RecDur = Validation.RawTiffInfo.Frames / fs;
end

end
