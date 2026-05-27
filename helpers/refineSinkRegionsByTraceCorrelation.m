function [Overall_OxygenSinks_Pxllist,Overall_OxySinks_logical,Trace_PotentialNoise] = ...
    refineSinkRegionsByTraceCorrelation(Overall_OxygenSinks_Pxllist,Overall_OxySinks_logical, ...
    Mean_OxySink_Trace_Convo,correlationThreshold,noiseCorrelationPercentile,overlapFractionThreshold)
%REFINESINKREGIONSBYTRACECORRELATION Merge overlapping sink regions with correlated traces.

Trace_Convo_CrossCor = safeCorrMatrix(Mean_OxySink_Trace_Convo');
Trace_Convo_CrossCor_High_sum = sum(Trace_Convo_CrossCor>correlationThreshold,2);
Trace_PotentialNoise = ~(Trace_Convo_CrossCor_High_sum > ...
    prctile(Trace_Convo_CrossCor_High_sum,noiseCorrelationPercentile));

OxySink_Pxls_Currated = cell(size(Overall_OxygenSinks_Pxllist));
for i = 1:size(Trace_Convo_CrossCor,1)
    NumCorrelatedTraces = sum(Trace_Convo_CrossCor(i,:)>correlationThreshold);
    if NumCorrelatedTraces > 1 && Trace_PotentialNoise(i)
        CombinedIndx = find(Trace_Convo_CrossCor(i,:)>correlationThreshold)';
        Corrs = Trace_Convo_CrossCor(i,Trace_Convo_CrossCor(i,:)>correlationThreshold);
        [~,IndxSort] = sort(Corrs,'descend');
        SeedRow = CombinedIndx(IndxSort(1));

        Trace_Convo_CrossCor(SeedRow,:) = nan;
        OxySink_Pxls_Currated(i,:) = Overall_OxygenSinks_Pxllist(SeedRow,:);
        Overall_OxygenSinks_Pxllist(SeedRow,:) = {[]};
        Pxls_seed = uniqueTrackedPixels(OxySink_Pxls_Currated(i,Overall_OxySinks_logical(SeedRow,:)));

        for j = 2:length(IndxSort)
            TestRow = CombinedIndx(IndxSort(j));
            Pxls_test = uniqueTrackedPixels(Overall_OxygenSinks_Pxllist(TestRow, ...
                Overall_OxySinks_logical(TestRow,:)));
            if hasSufficientOverlap(Pxls_seed,Pxls_test,overlapFractionThreshold)
                for k = 1:size(OxySink_Pxls_Currated,2)
                    OxySink_Pxls_Currated{i,k} = unique(vertcat( ...
                        OxySink_Pxls_Currated{i,k},Overall_OxygenSinks_Pxllist{TestRow,k}));
                    Trace_Convo_CrossCor(TestRow,:) = nan;
                    Overall_OxygenSinks_Pxllist(TestRow,:) = {[]};
                end
            end
        end
    elseif NumCorrelatedTraces == 1
        OxySink_Pxls_Currated(i,:) = Overall_OxygenSinks_Pxllist(i,:);
        Overall_OxygenSinks_Pxllist(i,:) = {[]};
    end
end

Anypoc = any(~cellfun(@isempty,OxySink_Pxls_Currated),2);
Overall_OxygenSinks_Pxllist = OxySink_Pxls_Currated(Anypoc,:);
Overall_OxySinks_logical = ~cellfun(@isempty,Overall_OxygenSinks_Pxllist);

end

function Pixels = uniqueTrackedPixels(PixelCells)

if isempty(PixelCells)
    Pixels = [];
    return
end

PixelCells = cellfun(@transpose,PixelCells,'UniformOutput',false);
Pixels = [PixelCells{:}];
Pixels = unique(Pixels)';

end

function HasOverlap = hasSufficientOverlap(seedPixels,testPixels,overlapFractionThreshold)

if isempty(seedPixels) || isempty(testPixels)
    HasOverlap = false;
    return
end

IntersectionCount = length(intersect(seedPixels,testPixels));
HasOverlap = IntersectionCount > length(testPixels)*overlapFractionThreshold || ...
    IntersectionCount > length(seedPixels)*overlapFractionThreshold;

end
