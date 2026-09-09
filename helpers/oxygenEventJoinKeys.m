function [AKeys,BKeys]=oxygenEventJoinKeys(A,B)
% Explicit recording/site/event identities only; no parsing of display labels.
AKeys=keys(A);BKeys=keys(B);
end
function K=keys(T)
assert(all(ismember({'RecordingID','SinkID'},T.Properties.VariableNames)), ...
    'OxygenDynamics:MissingRecordingIdentity','Event joins require RecordingID and SinkID.');
if ismember('EventIndex',T.Properties.VariableNames),event=T.EventIndex;else,event=T.EventID;end
assert(isnumeric(event),'OxygenDynamics:MissingEventIdentity','Event index must be numeric, not a display label.');
K=strings(height(T),1);
for i=1:height(T)
    K(i)=string(jsonencode({char(string(T.RecordingID(i))),char(string(T.SinkID(i))),char(string(event(i)))}));
end
end
