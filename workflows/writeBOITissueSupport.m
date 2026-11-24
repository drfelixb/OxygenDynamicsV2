function Snapshot = writeBOITissueSupport(RecordingFolder,ProposalFolder,Decision)
%WRITEBOITISSUESUPPORT Record an explicit review decision for a fresh BOI run.
% Decision fields: DecisionID, Actor, Reason, Evidence, AlignmentEvidence.
% A declaration is not independent scientific validation. Existing decisions
% and master results are never overwritten by this function.
setupOxygenDynamicsPath;
file=fullfile(RecordingFolder,'BOITissueSupport.json');
assert(~isfile(file),'OxygenDynamics:TissueDecisionExists','Existing tissue decision must be preserved. Use a fresh recording stage for a new decision.');
assert(~isfolder(fullfile(RecordingFolder,'OxygenSinks_Output'))&& ...
    ~isfolder(fullfile(RecordingFolder,'OxygenSurges_Output')), ...
    'OxygenDynamics:TissueMasterExists','Preserve the earlier master. Stage the unchanged source in a new folder before adopting support.');
fields={'DecisionID','Actor','Reason','Evidence','AlignmentEvidence'};
assert(isstruct(Decision)&&isscalar(Decision)&&isequal(sort(fieldnames(Decision)),sort(fields(:))), ...
    'OxygenDynamics:InvalidTissueDeclaration','Provide exactly DecisionID, Actor, Reason, Evidence and AlignmentEvidence.');
P=jsondecode(fileread(fullfile(ProposalFolder,'Proposal.json')));
assert(strcmp(P.Schema,'boi-tissue-proposal-1')&&strcmp(P.Status,'proposed_not_adopted')&&strcmp(P.MaskFile,'ProposedMask.mat'), ...
    'OxygenDynamics:InvalidTissueDeclaration','Unsupported proposal.');
assert(strcmp(oxygenFileSHA256(fullfile(ProposalFolder,P.MaskFile)),P.MaskFileSHA256), ...
    'OxygenDynamics:TissueProposalChanged','Proposed mask changed after the preview. Generate a new proposal and inspect it.');
files=inspectOxygenTiffs(RecordingFolder);
assert(numel(files.RawFiles)==1,'OxygenDynamics:InvalidTissueSupport','Exactly one original TIFF is required.');
source=fullfile(files.RawFiles(1).folder,files.RawFiles(1).name);
rawHash=oxygenFileSHA256(source);
assert(strcmp(rawHash,P.RawSHA256),'OxygenDynamics:TissueSourceMismatch','Proposal belongs to different source pixels.');
tif=Tiff(source,'r');cleanup=onCleanup(@()close(tif));shape=[getTag(tif,'ImageLength') getTag(tif,'ImageWidth')];clear cleanup
data=load(fullfile(ProposalFolder,P.MaskFile),'Mask');Mask=data.Mask;
assert(islogical(Mask)&&isequal(size(Mask),shape)&&isequal(P.FrameSize(:)',shape)&&any(Mask(:)), ...
    'OxygenDynamics:TissueShapeMismatch','Proposal mask must match native source dimensions.');
D=struct('Schema','boi-static-tissue-support-1','Modality','BOI','RawSHA256',rawHash, ...
    'FrameSize',shape,'IndexConvention','MATLAB_one_based_column_major_row_column', ...
    'MaskPixels',find(Mask),'ReviewStatus','reviewed_for_static_support', ...
    'DecisionID',Decision.DecisionID,'Actor',Decision.Actor,'Reason',Decision.Reason, ...
    'Evidence',Decision.Evidence,'AlignmentEvidence',Decision.AlignmentEvidence, ...
    'RecordedUTC',char(datetime('now','TimeZone','UTC','Format',"yyyy-MM-dd'T'HH:mm:ss'Z'")));
Snapshot=struct('State','captured','FileName','BOITissueSupport.json','RawJSON',jsonencode(D,'PrettyPrint',true),'SHA256','');
resolveBOITissueSupport(Snapshot,shape,rawHash);
fid=fopen(file,'w');assert(fid>=0);cleanup=onCleanup(@()fclose(fid));fprintf(fid,'%s\n',Snapshot.RawJSON);clear cleanup
Snapshot=captureBOITissueSupport(RecordingFolder,shape,rawHash);
fprintf('Recorded tissue decision %s. Run a fresh master to apply it.\n',D.DecisionID);
end
