function Paths=boiBatchHistoryPaths(Value,BaseFolder)
%BOIBATCHHISTORYPATHS Decode software attempt references without executing them.
Paths=strings(0,1);
assert(isstring(Value)&&isscalar(Value)&&~ismissing(Value), ...
    'OxygenDynamics:InvalidBatchHistory','Attempt history must be one JSON text value.');
if strlength(strtrim(Value))==0,return;end
try,decoded=jsondecode(char(Value));
catch,error('OxygenDynamics:InvalidBatchHistory','Attempt history is invalid JSON.');end
if isempty(decoded),return;end
assert(iscell(decoded)||isstring(decoded),'OxygenDynamics:InvalidBatchHistory','Attempt history must be a JSON list of snapshot paths.');
for k=1:numel(decoded)
    if iscell(decoded),value=decoded{k};else,value=decoded(k);end
    assert((ischar(value)&&isrow(value))||(isstring(value)&&isscalar(value)&&~ismissing(value)), ...
        'OxygenDynamics:InvalidBatchHistory','Attempt history contains an invalid snapshot path.');
    assert(strlength(strtrim(string(value)))>0,'OxygenDynamics:InvalidBatchHistory','Attempt history contains a blank snapshot path.');
    file=java.io.File(char(value));
    if ~file.isAbsolute(),file=java.io.File(fullfile(BaseFolder,char(value)));end
    Paths(end+1,1)=string(char(file.getCanonicalPath())); %#ok<AGROW>
end
assert(numel(unique(Paths))==numel(Paths),'OxygenDynamics:InvalidBatchHistory','Attempt history repeats a snapshot path.');
end
