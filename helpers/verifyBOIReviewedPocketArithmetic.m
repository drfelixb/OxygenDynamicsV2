function M=verifyBOIReviewedPocketArithmetic(E)
%VERIFYBOIREVIEWEDPOCKETARITHMETIC Explicit replay only; no correction fit.
validateBOIPocketEvidence(E);
M=computeBOIReviewedPocketMeasures(E.Ingredients.Raw,E.Ingredients.Corrected,E.ReferenceFrames, ...
    E.EventFrames,E.Judgment.ReferenceSuitability,E.Judgment.ClockAuthority);
assert(isequaln(M,E.Measures),'OxygenDynamics:PocketArithmeticMismatch','Saved arithmetic differs from explicit replay.');
end
