function [Definitions,Dictionary,SourcePath] = getBOIMeasurementDictionary(SourcePath)
%GETBOIMEASUREMENTDICTIONARY Shared, versioned BOI definitions and open limits.
% Proposed outcome priorities do not imply scientific acceptance.
if nargin<1 || isempty(SourcePath)
    root=fileparts(fileparts(mfilename('fullpath')));
    SourcePath=fullfile(root,'docs','planning','boi-measurement-dictionary.json');
end
Dictionary=jsondecode(fileread(SourcePath));
assert(strcmp(Dictionary.Schema,'boi-measurement-dictionary-1'), ...
    'OxygenDynamics:DictionarySchema','Unsupported BOI dictionary schema.');
Definitions=struct2table(Dictionary.Measurements);
for name=Definitions.Properties.VariableNames
    Definitions.(name{1})=string(Definitions.(name{1}));
end
assert(numel(unique(Definitions.MeasurementID))==height(Definitions), ...
    'OxygenDynamics:DictionaryIdentity','Duplicate measurement identity.');
assert(all(Definitions.DefinitionVersion==string(Dictionary.Version)), ...
    'OxygenDynamics:DictionaryVersion','Mixed dictionary definition versions.');
end
