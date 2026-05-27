function GrayValues = safeMat2Gray(values)
%SAFEMAT2GRAY Toolbox-free scaling to the [0, 1] interval.

GrayValues = values;
FiniteMask = isfinite(values);
if ~any(FiniteMask(:))
    GrayValues(:) = NaN;
    return
end

MinValue = min(values(FiniteMask));
MaxValue = max(values(FiniteMask));
RangeValue = MaxValue - MinValue;
if RangeValue > 0
    GrayValues(FiniteMask) = (values(FiniteMask) - MinValue) ./ RangeValue;
else
    GrayValues(FiniteMask) = 0;
end
GrayValues(~FiniteMask) = NaN;

end
