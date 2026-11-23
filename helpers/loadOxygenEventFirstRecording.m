function R = loadOxygenEventFirstRecording(folder,Context)
% Preserve TIFF intensity with existing source-selection loader; no legacy preprocessing.
if isfield(Context,'EventFirstRecording')
    R=Context.EventFirstRecording; return
end
[raw,den,~,~,~,rawFile,denFile]=loadOxygenStacks(folder);
R=struct('RecordingID',string(folder),'MouseID',string(Context.Mous),'SourceIdentity',string(fullfile(rawFile.folder,rawFile.name)), ...
    'SignalProvenance',"PreservedInputIntensity from TIFF; camera-count scaling unverified", ...
    'Intensity',raw,'NFrames',size(raw,3),'AxisOrder',"YXT",'PixelSizeUm',[Context.PiSz Context.PiSz], ...
    'fs',Context.SFs,'ValidMask',true(size(raw,1),size(raw,2)), ...
    'Condition',string(Context.Cond),'Genotype',string(Context.Gen),'Promoter',string(Context.Promo), ...
    'ExclusionReasons',"No registration mask supplied; full frame assumed observable pending review");
if ~isempty(den)
    R.DenoisedIntensity=den; R.DenoisedProvenance=string(fullfile(denFile.folder,denFile.name));
end
if isfield(Context,'EventFirstMetadata')
    fields=fieldnames(Context.EventFirstMetadata);
    for k=1:numel(fields), R.(fields{k})=Context.EventFirstMetadata.(fields{k}); end
end
end
