function IsConfigured = isOptionalMetadataValueConfigured(Value)
%ISOPTIONALMETADATAVALUECONFIGURED True when optional metadata has a value.

if iscell(Value) && isscalar(Value)
    Value = Value{1};
end
if isempty(Value)
    IsConfigured = false;
elseif isnumeric(Value) && isscalar(Value)
    IsConfigured = ~isnan(Value);
elseif isstring(Value)
    IsConfigured = ~ismissing(Value) && strlength(strtrim(Value))>0;
elseif ischar(Value)
    IsConfigured = ~isempty(strtrim(Value));
else
    IsConfigured = true;
end
end
