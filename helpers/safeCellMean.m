function out = safeCellMean(x)

if isempty(x)
    out = NaN;
    return
end

x = x(:);
x = x(isfinite(x));
if isempty(x)
    out = NaN;
else
    out = mean(x);
end

end
