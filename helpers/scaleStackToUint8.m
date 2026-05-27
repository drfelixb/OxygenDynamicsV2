function StackOut = scaleStackToUint8(StackIn)
%SCALESTACKTOUINT8 Scale a numeric stack to the full uint8 range.

StackIn = single(StackIn);
FiniteValues = StackIn(isfinite(StackIn));
if isempty(FiniteValues)
    StackOut = uint8(zeros(size(StackIn)));
    return
end

StackIn(~isfinite(StackIn)) = 0;
MinValue = min(FiniteValues);
MaxValue = max(FiniteValues);

if MaxValue == MinValue
    StackOut = uint8(zeros(size(StackIn)));
    return
end

StackOut = uint8((StackIn - MinValue) .* single(intmax('uint8')) ./ (MaxValue - MinValue));

end
