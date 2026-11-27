function pct=boiPairPercent(intensity,reference,offset)
% Preserve the historical operation order for an uncalibrated recording.
if isempty(offset)
    pct=100*(intensity/reference-1);
elseif isfinite(reference) && reference>offset
    pct=100*(intensity-reference)/(reference-offset);
else
    pct=nan(size(intensity));
end
end
