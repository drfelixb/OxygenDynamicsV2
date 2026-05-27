function EventTable = ensureStatsEventPuffStim(EventTable,PuffStim)
%ENSURESTATSEVENTPUFFSTIM Add PuffStim to legacy event tables when missing.

if isempty(EventTable) || ismember('PuffStim',EventTable.Properties.VariableNames)
    return
end

EventPuffStim = repmat(logical(PuffStim),height(EventTable),1);
EventTable = addvars(EventTable,EventPuffStim,'After','Promoter','NewVariableNames','PuffStim');

end
