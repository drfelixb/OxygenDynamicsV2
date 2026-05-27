function tf = shouldRunOutputStep(outputFolder,reanalyseExisting,overwritePreviousAnalysis)
%SHOULDRUNOUTPUTSTEP True when a wrapper step should be run.

if nargin<3
    overwritePreviousAnalysis = false;
end

tf = ~isfolder(outputFolder) || isYesFlag(reanalyseExisting) || isYesFlag(overwritePreviousAnalysis);

end

function tf = isYesFlag(value)
if islogical(value)
    tf = value;
elseif isstring(value) || ischar(value)
    tf = strcmpi(char(value),'Y') || strcmpi(char(value),'Yes') || strcmpi(char(value),'true');
else
    tf = false;
end
end
