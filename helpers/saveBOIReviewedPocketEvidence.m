function Store=saveBOIReviewedPocketEvidence(E,OutputFolder)
%SAVEBOIREVIEWEDPOCKETEVIDENCE New immutable folder; manifest published last.
validateBOIPocketEvidence(E); % Required-file/identity validation before mkdir.
assert(~isfolder(OutputFolder)&&~isfile(OutputFolder),'OxygenDynamics:PocketOutputExists','Choose a NEW folder; earlier evidence is preserved.');
if isfile(E.AuditPath)
    assert(strcmp(oxygenFileSHA256(E.AuditPath),E.AuditSHA256),'OxygenDynamics:PocketIdentityMismatch','External audit changed; reopen before saving/exporting.');
end
mkdir(OutputFolder);
try
    save(fullfile(OutputFolder,'ReviewedPocket.mat'),'E');
    write(fullfile(OutputFolder,'ReviewedPocket.json'),jsonencode(E,'PrettyPrint',true));
    write(fullfile(OutputFolder,'Definition.json'),jsonencode(E.Definition,'PrettyPrint',true));
    R=E.ReferenceFrames(:);W=E.EventFrames(:);F=[R;W];kind=[repmat("reference",numel(R),1);repmat("episode",numel(W),1)];
    raw=E.Ingredients.Raw(F);corrected=nan(size(F));
    if ~isempty(E.Ingredients.Corrected),corrected=E.Ingredients.Corrected(F);end
    rawq=[nan(numel(R),1);E.Measures.RawSignedPercent];cq=[nan(numel(R),1);E.Measures.CorrectedSignedPercent];
    writetable(table(F,F-1,kind,raw,corrected,rawq,cq,'VariableNames', ...
        {'Frame','ModeledTimeSec','Role','RawInput','SavedCorrectedInput','RawSignedPercent','CorrectedSignedPercent'}), ...
        fullfile(OutputFolder,'ReviewedPocketSamples.csv'));
    [row,col]=ind2sub(E.FrameSize,E.FixedFootprint);
    writetable(table(E.FixedFootprint,row,col,'VariableNames',{'MatlabLinearPixel','PixelRow','PixelColumn'}),fullfile(OutputFolder,'ReviewedPocketFootprint.csv'));
    summary=table(string(E.Measures.PrimaryStatus),string(E.Measures.CompanionStatus),E.Measures.CorrectedSignedTroughPercent, ...
        E.Measures.RawSignedTroughPercent,E.Measures.ReferenceSampleCount,string(E.Judgment.ReferenceSuitability), ...
        string(E.Judgment.EndpointStatus),string(E.FootprintOrigin),'VariableNames', ...
        {'PrimaryStatus','CompanionStatus','CorrectedSignedTroughPercent','RawSignedTroughPercent','ReferenceSamples','Suitability','EndpointStatus','SavedFootprintOrigin'});
    writetable(summary,fullfile(OutputFolder,'ReviewedPocketMeasures.csv'));
    write(fullfile(OutputFolder,'Evidence.md'),formatBOIPocketEvidence(E));
    files=dir(OutputFolder);entries=struct('Name',{},'SHA256',{});
    for k=1:numel(files)
        if ~files(k).isdir,entries(end+1)=struct('Name',files(k).name,'SHA256',oxygenFileSHA256(fullfile(OutputFolder,files(k).name)));end %#ok<AGROW>
    end
    M=struct('Schema','boi-reviewed-pocket-artifact-1','EvidenceFile','ReviewedPocket.mat','EvidenceSHA256',boiPocketDigest(E),'Files',entries);
    write(fullfile(OutputFolder,'Manifest.json'),jsonencode(M,'PrettyPrint',true));
    Store=loadBOIReviewedPocketEvidence(OutputFolder);
catch err
    % Preserve incomplete evidence; never make an earlier artifact overwriteable.
    write(fullfile(OutputFolder,'Incomplete.json'),jsonencode(struct('ErrorID',err.identifier,'Message',err.message),'PrettyPrint',true));
    rethrow(err);
end
end
function write(p,s)
f=fopen(p,'w');assert(f>=0,'OxygenDynamics:PocketWriteFailed','Cannot write reviewed evidence.');c=onCleanup(@()fclose(f));fprintf(f,'%s\n',s);
end
