function writeBOIPairedSheet(T,workbook,sheet)
% Excel reserves one of its 1,048,576 rows for the table header.
limit=1048575;
if height(T)<=limit
    writetable(T,workbook,'Sheet',sheet);
    return
end
for first=1:limit:height(T)
    part=1+floor((first-1)/limit);
    suffix=sprintf(' %d',part);
    name=[sheet(1:min(numel(sheet),31-numel(suffix))) suffix];
    writetable(T(first:min(first+limit-1,height(T)),:),workbook,'Sheet',name);
end
end
