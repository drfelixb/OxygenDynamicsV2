function PreviewRows = prioritizeOxygenStatsPreviewRows(PreviewRows)
%PRIORITIZEOXYGENSTATSPREVIEWROWS Move acceptance/review rows to the top.

if isempty(PreviewRows)
    return
end

Priority = zeros(size(PreviewRows,1),1);
for RowIdx = 1:size(PreviewRows,1)
    Priority(RowIdx) = statsPreviewRowPriority(PreviewRows{RowIdx,1},PreviewRows{RowIdx,2});
end
[~,Order] = sort(Priority,'ascend');
PreviewRows = PreviewRows(Order,:);

end

function Priority = statsPreviewRowPriority(Item,Value)

Item = string(Item);
Value = string(Value);
if Item=="Stats acceptance"
    Priority = 1;
elseif Item=="Stats acceptance review items"
    Priority = 2;
elseif startsWith(Item,"QC:") && startsWith(Value,"REVIEW")
    Priority = 3;
elseif Item=="Regression" && startsWith(Value,"FAIL")
    Priority = 4;
elseif startsWith(Item,"Regression")
    Priority = 5;
elseif startsWith(Item,"QC:") && startsWith(Value,"PASS")
    Priority = 6;
elseif startsWith(Item,"QC:") && startsWith(Value,"INFO")
    Priority = 7;
else
    Priority = 20;
end

end
