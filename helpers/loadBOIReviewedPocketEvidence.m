function Store=loadBOIReviewedPocketEvidence(Folder)
%LOADBOIREVIEWEDPOCKETEVIDENCE Display stored values; no replay or recording IO.
if isfile(Folder),Folder=fileparts(Folder);end
id='OxygenDynamics:InvalidPocketEvidence';
assert(~isfile(fullfile(Folder,'Incomplete.json'))&&isfile(fullfile(Folder,'Manifest.json')),id,'Reviewed folder is incomplete. Retain it and choose completed evidence.');
p=fullfile(Folder,'Manifest.json');M=jsondecode(fileread(p));
assert(strcmp(M.Schema,'boi-reviewed-pocket-artifact-1')&&strcmp(M.EvidenceFile,'ReviewedPocket.mat'), ...
    'OxygenDynamics:UnsupportedPocketSchema','Unsupported reviewed artifact schema.');
required={'ReviewedPocket.mat','ReviewedPocket.json','Definition.json','ReviewedPocketSamples.csv','ReviewedPocketFootprint.csv','ReviewedPocketMeasures.csv','Evidence.md'};
assert(isequal(sort(string({M.Files.Name})),sort(string(required))),id,'Required reviewed files differ.');
for k=1:numel(M.Files)
    name=M.Files(k).Name;assert(~contains(name,{'/','\\'})&&isfile(fullfile(Folder,name))&& ...
        strcmp(oxygenFileSHA256(fullfile(Folder,name)),M.Files(k).SHA256),id,'Saved reviewed file changed or is missing: %s',name);
end
S=load(fullfile(Folder,M.EvidenceFile),'E');assert(isfield(S,'E'),id,'Reviewed MAT has no evidence.');E=S.E;
validateBOIPocketEvidence(E);assert(strcmp(boiPocketDigest(E),M.EvidenceSHA256),id,'Embedded reviewed payload changed.');
external='unavailable_original_audit_not_present';
if isfile(E.AuditPath)
    assert(strcmp(oxygenFileSHA256(E.AuditPath),E.AuditSHA256),'OxygenDynamics:PocketIdentityMismatch','Original audit changed since this review.');
    external='original_audit_hash_matches_source_recording_not_opened';
end
Store=struct('Path',char(java.io.File(Folder).getCanonicalPath()),'SHA256',oxygenFileSHA256(p), ...
    'Document',E,'ExternalAuditVerification',external,'ReplayedOnOpen',false);
end
