function ScriptOutput = runLegacyAnalysisScript(recordingFolder,scriptName,Context)
%RUNLEGACYANALYSISSCRIPT Run a legacy script in an isolated function workspace.
%
% The old analysis scripts still expect workspace variables such as SFs,
% Mous, PiSz, Tifffiles, and RecDur. This helper makes that dependency
% explicit while preventing the script from seeing the wrapper workspace.

setupOxygenDynamicsPath();

if nargin < 3 || isempty(Context)
    Context = struct();
end
if ~isfolder(recordingFolder)
    error('Recording folder not found: %s',recordingFolder);
end

Context.RecordingFolder = recordingFolder;

ScriptPath = which(scriptName);
if isempty(ScriptPath)
    error('Could not find script on MATLAB path: %s',scriptName);
end

FieldNames = fieldnames(Context);
for fieldi = 1:numel(FieldNames)
    FieldName = FieldNames{fieldi};
    if ~isvarname(FieldName)
        error('Invalid context field name "%s".',FieldName);
    end
    assigninLocal(FieldName,Context.(FieldName));
end

PreviousFolder = pwd;
RestoreFolder = onCleanup(@() cd(PreviousFolder));
cd(recordingFolder);
run(ScriptPath);

ScriptOutput = collectScriptOutput();

end

function assigninLocal(variableName,variableValue)
assignin('caller',variableName,variableValue);
end

function ScriptOutput = collectScriptOutput()

OutputFields = {'Tifffiles','RecDur','OutputFolders','AnalysisInfo','DatafileID'};
ScriptOutput = struct();

for fieldi = 1:numel(OutputFields)
    FieldName = OutputFields{fieldi};
    if evalin('caller',['exist(''',FieldName,''',''var'')'])
        ScriptOutput.(FieldName) = evalin('caller',FieldName);
    end
end

end
