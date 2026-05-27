function NumericList = parseNumericList(inputValue)
if isnumeric(inputValue)
    NumericList=inputValue(:)';
elseif isstring(inputValue) || ischar(inputValue)
    tokens=regexp(char(inputValue),'[-+]?\d*\.?\d+','match');
    NumericList=str2double(tokens);
else
    NumericList=[];
end

NumericList=NumericList(isfinite(NumericList));
end
