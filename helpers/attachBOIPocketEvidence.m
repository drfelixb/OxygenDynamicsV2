function Review=attachBOIPocketEvidence(Review,Index,Folder)
%ATTACHBOIPOCKETEVIDENCE Bind saved revision to selected automatic event.
S=loadBOIReviewedPocketEvidence(Folder);E=S.Document;t=Review.Traces{Index};row=Review.Audit(Index,:);
assert(strcmp(E.AuditSHA256,Review.AuditSHA256)&&E.AuditRow==Index&&strcmp(E.RawSourceSHA256,Review.AnalysisInfo.RawSHA256)&& ...
    strcmp(E.FixedFootprintSHA256,boiPocketDigest(double(t.Footprint(:))))&&isequaln(E.OriginalAutomatic,table2struct(row)), ...
    'OxygenDynamics:PocketIdentityMismatch','Saved reviewed artifact belongs to a different source, event or footprint.');
if ~isfield(Review,'PocketEvidence'),Review.PocketEvidence=cell(height(Review.Audit),1);end
Review.PocketEvidence{Index}=S;
end
