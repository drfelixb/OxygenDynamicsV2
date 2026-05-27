function Entropy = safeShannonEntropy(weights)
%SAFESHANNONENTROPY Shannon entropy in bits from nonnegative weights.

Weights = weights(isfinite(weights) & weights>0);
TotalWeight = sum(Weights);
if isempty(Weights) || TotalWeight<=0
    Entropy = NaN;
    return
end

Probabilities = Weights./TotalWeight;
Entropy = -sum(Probabilities.*log2(Probabilities));

end
