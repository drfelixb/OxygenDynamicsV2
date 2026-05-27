function Z = safeZScore(values)
%SAFEZSCORE Toolbox-free z-score with stable constant-trace handling.

Z = values;
FiniteMask = isfinite(values);
if ~any(FiniteMask(:))
    Z(:) = NaN;
    return
end

Mu = mean(values(FiniteMask));
Sigma = std(values(FiniteMask));
Z(FiniteMask) = values(FiniteMask)-Mu;
if Sigma>0
    Z(FiniteMask) = Z(FiniteMask)./Sigma;
else
    Z(FiniteMask) = 0;
end
Z(~FiniteMask) = NaN;

end
