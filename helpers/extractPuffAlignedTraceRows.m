function [AlignedTraces,MouseLabels] = extractPuffAlignedTraceRows(PuffLogical,SelectedPuffs,TraceSources,SampleFs,PuffsSFs,MouseLabel)
%EXTRACTPUFFALIGNEDTRACEROWS Extract trace windows around selected puff starts.

PreFrames = round(30*SampleFs);
PostFrames = round(60*SampleFs);
WindowLength = PreFrames+PostFrames+1;
PuffLabels = labelLogicalRuns(PuffLogical);
NumPuffs = max(PuffLabels);
NumMetrics = numel(TraceSources);

AlignedTraces = repmat({nan(NumPuffs,WindowLength)},1,NumMetrics);

for PuffIdx = 1:NumPuffs
    if ~ismember(PuffIdx,SelectedPuffs)
        continue
    end

    PuffStart = round((find(PuffLabels==PuffIdx,1,'first')-1)/PuffsSFs*SampleFs)+1;
    WindowStart = PuffStart-PreFrames;
    WindowEnd = PuffStart+PostFrames;

    for MetricIdx = 1:NumMetrics
        Trace = TraceSources{MetricIdx};
        SourceStart = max(1,WindowStart);
        SourceEnd = min(numel(Trace),WindowEnd);
        if SourceStart>SourceEnd
            continue
        end

        InsertStart = SourceStart-WindowStart+1;
        InsertEnd = InsertStart+(SourceEnd-SourceStart);
        AlignedTraces{MetricIdx}(PuffIdx,InsertStart:InsertEnd) = Trace(SourceStart:SourceEnd);
    end
end

SelectedPuffMask = ismember(1:NumPuffs,SelectedPuffs);
for MetricIdx = 1:NumMetrics
    AlignedTraces{MetricIdx} = AlignedTraces{MetricIdx}(SelectedPuffMask,:);
end
MouseLabels = repmat(string(MouseLabel),sum(SelectedPuffMask),1);

end
