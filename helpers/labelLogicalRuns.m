function Labels = labelLogicalRuns(LogicalVector)
%LABELLOGICALRUNS Label contiguous true runs in a logical vector.

LogicalVector = logical(LogicalVector(:));
Labels = zeros(size(LogicalVector));
Transitions = diff([false;LogicalVector;false]);
RunStarts = find(Transitions==1);
RunEnds = find(Transitions==-1)-1;

for RunIdx = 1:numel(RunStarts)
    Labels(RunStarts(RunIdx):RunEnds(RunIdx)) = RunIdx;
end

end
