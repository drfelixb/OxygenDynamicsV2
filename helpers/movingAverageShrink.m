function Smoothed = movingAverageShrink(values,span)
% movingAverageShrink returns a centered moving average with shorter endpoint windows.

if nargin < 2 || isempty(span)
    span = 5;
end

WasRow = isrow(values);
values = double(values(:));
span = max(1,round(span));

ValidValues = isfinite(values);
ValuesForSum = values;
ValuesForSum(~ValidValues) = 0;

Kernel = ones(span,1);
WindowSum = conv(ValuesForSum,Kernel,'same');
WindowCount = conv(double(ValidValues),Kernel,'same');

Smoothed = WindowSum ./ WindowCount;
Smoothed(WindowCount==0) = NaN;

if WasRow
    Smoothed = Smoothed.';
end
end
