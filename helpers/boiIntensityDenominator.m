function [denominator,blocked]=boiIntensityDenominator(reference,offset)
% Keep the observed reference and numerator in their original count units.
denominator=reference;
blocked=false(size(reference));
if ~isempty(offset)
    denominator=reference-offset;
    blocked=isfinite(reference)&denominator<=0;
end
end
