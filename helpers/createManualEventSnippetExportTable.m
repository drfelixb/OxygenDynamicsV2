function ExportTable = createManualEventSnippetExportTable(manualEventSnips)
if isempty(manualEventSnips)
    ExportTable=[];
    return
end

ExportCells=cell(length(manualEventSnips),1);
for eventIdx=1:length(manualEventSnips)
    HeaderCells=(manualEventSnips{eventIdx}(:,1:5))';
    TraceCells=(num2cell(cell2mat(manualEventSnips{eventIdx}(:,6))))';
    CombinedCells=[HeaderCells;TraceCells];

    VariableNames=cell(1,size(manualEventSnips{eventIdx},1));
    for recordingIdx=1:size(manualEventSnips{eventIdx},1)
        VariableNames{recordingIdx}=strcat('Event',int2str(eventIdx),'Recording',int2str(recordingIdx));
    end

    ExportCells{eventIdx}=cell2table(CombinedCells,"VariableNames",VariableNames);
end

ExportTable=horzcat(ExportCells{:});
end
