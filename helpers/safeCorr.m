function R = safeCorr(x,y)
%SAFECORR Toolbox-free Pearson correlation for paired finite samples.

x = x(:);
y = y(:);
FiniteMask = isfinite(x) & isfinite(y);
if nnz(FiniteMask)<2
    R = NaN;
    return
end

x = x(FiniteMask);
y = y(FiniteMask);
if std(x)==0 || std(y)==0
    R = NaN;
    return
end

C = corrcoef(x,y);
R = C(1,2);

end
