function hash=boiBatchQueueDigest(value)
%BOIBATCHQUEUEDIGEST Stable confirmation guard for plain queue data and tables.
hash=boiPocketDigest(plain(value));
end
function value=plain(value)
if istable(value)
    value=struct('Names',{value.Properties.VariableNames},'Values',{table2cell(value)});
end
if isstruct(value)
    names=fieldnames(value);
    for row=1:numel(value)
        for k=1:numel(names),value(row).(names{k})=plain(value(row).(names{k}));end
    end
elseif iscell(value)
    for k=1:numel(value),value{k}=plain(value{k});end
end
end
