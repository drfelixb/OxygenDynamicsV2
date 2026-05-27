function StackOut = scaleStackToUint16(StackIn)
%SCALESTACKTOUINT16 Scale a numeric stack to the full uint16 range.

StackIn = single(StackIn);
FiniteValues = StackIn(isfinite(StackIn));
if isempty(FiniteValues)
    StackOut = uint16(zeros(size(StackIn)));
    return
end

StackIn(~isfinite(StackIn)) = 0;
MinValue = min(FiniteValues);
MaxValue = max(FiniteValues);

if MaxValue == MinValue
    StackOut = uint16(zeros(size(StackIn)));
    return
end

StackOut = uint16((StackIn - MinValue) .* single(intmax('uint16')) ./ (MaxValue - MinValue));

end
