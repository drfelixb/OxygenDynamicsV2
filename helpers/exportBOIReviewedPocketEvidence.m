function Store=exportBOIReviewedPocketEvidence(Saved,OutputFolder)
%EXPORTBOIREVIEWEDPOCKETEVIDENCE Export only immutable saved revision, never UI draft.
checked=loadBOIReviewedPocketEvidence(Saved.Path);
assert(strcmp(checked.SHA256,Saved.SHA256),'OxygenDynamics:PocketRevisionMismatch','Saved reviewed artifact changed; reload before exporting.');
Store=saveBOIReviewedPocketEvidence(checked.Document,OutputFolder);
end
