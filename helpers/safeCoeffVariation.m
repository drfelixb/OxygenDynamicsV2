function CV = safeCoeffVariation(values)
%SAFECOEFFVARIATION Coefficient of variation with zero-mean guard.

FiniteValues = values(isfinite(values));
if isempty(FiniteValues)
    CV = NaN;
    return
end

MeanValue = mean(FiniteValues);
if MeanValue==0
    CV = NaN;
else
    CV = std(FiniteValues)./MeanValue;
end

end
