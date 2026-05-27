function IsConfigured = isStatsOptionalInputConfigured(Value)
%ISSTATSOPTIONALINPUTCONFIGURED True when an optional stats input is present.

if isempty(Value)
    IsConfigured = false;
elseif isnumeric(Value)
    IsConfigured = any(~isnan(Value(:)) & Value(:)~=0);
elseif isstring(Value)
    NonMissingValue = Value(~ismissing(Value));
    IsConfigured = any(arrayfun(@isConfiguredText,string(NonMissingValue(:))));
elseif ischar(Value)
    IsConfigured = isConfiguredText(string(Value));
elseif iscell(Value)
    IsConfigured = any(cellfun(@isStatsOptionalInputConfigured,Value));
else
    IsConfigured = true;
end
end

function IsConfigured = isConfiguredText(Value)

Text = strtrim(char(Value));
FalseMarkers = {'','f','false','no','n','0','nan','na','n/a','none','missing','[]'};
IsConfigured = ~any(strcmpi(Text,FalseMarkers));

end
