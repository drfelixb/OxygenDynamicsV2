function ExportreadySinksalligned = createAlignedSinkTraceExport(filtersROIsAndEvents,sinksTraces)
ExportreadySinksalligned=cell(2,size(filtersROIsAndEvents,2));

for groupIdx=1:size(filtersROIsAndEvents,2)
    ExportreadySinksalligned{1,groupIdx}=[filtersROIsAndEvents{1,groupIdx}, ...
        filtersROIsAndEvents{2,groupIdx},filtersROIsAndEvents{3,groupIdx}];

    TraceCells=sinksTraces(filtersROIsAndEvents{4,groupIdx},7);
    Metadata=sinksTraces(filtersROIsAndEvents{4,groupIdx},1:5);
    if isempty(TraceCells)
        ExportreadySinksalligned{2,groupIdx}=table();
        continue
    end

    MaxCols=max(cellfun(@(x) size(x,2),TraceCells));
    NumRows=sum(cellfun(@height,TraceCells));
    TraceArray=nan(NumRows,MaxCols);
    MetadataPool=cell(NumRows,5);

    counter=1;
    for recordingIdx=1:size(TraceCells,1)
        RowIdx=counter:counter+size(TraceCells{recordingIdx},1)-1;
        TraceArray(RowIdx,1:size(TraceCells{recordingIdx},2))=TraceCells{recordingIdx};
        MetadataPool(RowIdx,1)=repmat(Metadata(recordingIdx,1),numel(RowIdx),1);
        MetadataPool(RowIdx,2)=repmat(Metadata(recordingIdx,2),numel(RowIdx),1);
        MetadataPool(RowIdx,3)=repmat(Metadata(recordingIdx,3),numel(RowIdx),1);
        MetadataPool(RowIdx,4)=repmat(Metadata(recordingIdx,4),numel(RowIdx),1);
        MetadataPool(RowIdx,5)=repmat(filtersROIsAndEvents(3,groupIdx),numel(RowIdx),1);
        counter=counter+size(TraceCells{recordingIdx},1);
    end

    ExportreadySinksalligned{2,groupIdx}=cell2table([MetadataPool,num2cell(TraceArray)]);
end
end
