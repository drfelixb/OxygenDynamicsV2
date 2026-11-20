function validateOxygenSourceFiles(Info,RecordingFolder)
% Resolve source names inside this recording, so moving intact data is allowed.
assert(all(isfield(Info,{'RawFile','DenoisedFile','RawSHA256','DenoisedSHA256'})), ...
    'OxygenDynamics:ReanalysisRequired','Input fingerprints are missing. Rerun the master.');
inventory=inspectOxygenTiffs(RecordingFolder);
assert(numel(inventory.RawFiles)==1 && numel(inventory.DenoisedFiles)==double(~isempty(Info.DenoisedFile)), ...
    'OxygenDynamics:SourceChanged','Source TIFF inventory changed. Rerun the master with the intended inputs.');
for prefix={'Raw','Denoised'}
    p=prefix{1};field=[p 'File'];fingerprint=[p 'SHA256'];
    assert(isfield(Info,field)&&isfield(Info,fingerprint), ...
        'OxygenDynamics:ReanalysisRequired','Input fingerprints are missing. Rerun the master.');
    if isempty(Info.(field))
        assert(strcmp(p,'Denoised') && isempty(Info.(fingerprint)), ...
            'OxygenDynamics:ReanalysisRequired','Raw source identity is missing.');
        continue
    end
    [~,name,extension]=fileparts(Info.(field));
    path=fullfile(RecordingFolder,[name,extension]);
    assert(isfile(path),'OxygenDynamics:MissingSource','Source file missing: %s',path);
    assert(strcmp(oxygenFileSHA256(path),Info.(fingerprint)), ...
        'OxygenDynamics:SourceChanged','Input contents changed since analysis. Rerun the master: %s',path);
end
if isfield(Info,'BOIAcquisitionMetadata')
    snapshot=Info.BOIAcquisitionMetadata;
    metadataFile=fullfile(RecordingFolder,'BOIInputMetadata.json');
    if strcmp(snapshot.State,'captured')
        assert(isfile(metadataFile)&&strcmp(oxygenFileSHA256(metadataFile),snapshot.SHA256), ...
            'OxygenDynamics:InputMetadataChanged','Acquisition declarations changed or disappeared since the master. Preserve the prior run and rerun with the intended metadata.');
    else
        assert(~isfile(metadataFile),'OxygenDynamics:InputMetadataChanged', ...
            'Acquisition metadata was added after the master. Rerun to capture it; statistics cannot apply it retrospectively.');
    end
end
tissueFile=fullfile(RecordingFolder,'BOITissueSupport.json');
if isfield(Info,'BOITissueSupport') && strcmp(Info.BOITissueSupport.State,'captured')
    assert(isfile(tissueFile)&&strcmp(oxygenFileSHA256(tissueFile),Info.BOITissueSupport.SHA256), ...
        'OxygenDynamics:TissueSupportChanged','Reviewed tissue declaration changed or disappeared. Preserve the prior run and rerun the master with the intended support.');
else
    assert(~isfile(tissueFile),'OxygenDynamics:TissueSupportChanged', ...
        'Tissue support was added after the master. Statistics cannot apply it retrospectively; use a fresh master run.');
end
end
