function Timestamp = formatRegressionTimestamp(TimeValue)
%FORMATREGRESSIONTIMESTAMP Return compact timestamp text for regression files.

if nargin<1 || isempty(TimeValue)
    DateTimeValue = datetime('now');
elseif isnumeric(TimeValue)
    DateTimeValue = datetime(TimeValue,'ConvertFrom','datenum');
else
    DateTimeValue = datetime(TimeValue);
end

DateTimeValue.Format = "yyyyMMdd'T'HHmmss";
Timestamp = char(DateTimeValue);

end
