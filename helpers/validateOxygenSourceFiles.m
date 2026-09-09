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
end
