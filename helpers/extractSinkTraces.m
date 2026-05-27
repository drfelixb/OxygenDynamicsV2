function [Mean_OxySink_TraceZ,Mean_OxySink_Trace_Convo,Mean_OxySink_Trace_Raw,OxySink_Pxls_all,OxySink_Map] = ...
    extractSinkTraces(Overall_OxygenSinks_Pxllist,Overall_OxySinks_logical,IM_Zframetime, ...
    IM_Zframetime_smoothed,IM_Raw,Pixel_frame)
%EXTRACTSINKTRACES Extract mean sink traces from detection and optional raw stacks.

OxySink_Map = false(size(IM_Zframetime_smoothed(:,:,1)));
OxySink_Pxls_all = cell(size(Overall_OxygenSinks_Pxllist,1),1);
Mean_OxySink_TraceZ = NaN(size(Overall_OxygenSinks_Pxllist,1),size(IM_Zframetime,3));
Mean_OxySink_Trace_Convo = NaN(size(Overall_OxygenSinks_Pxllist,1),size(IM_Zframetime_smoothed,3));
Mean_OxySink_Trace_Raw = NaN(size(Overall_OxygenSinks_Pxllist,1),0);

ExtractRaw = ~isempty(IM_Raw);
if ExtractRaw
    Mean_OxySink_Trace_Raw = NaN(size(Overall_OxygenSinks_Pxllist,1),size(IM_Raw,3));
end

TraceStackZ = reshape(IM_Zframetime,[],size(IM_Zframetime,3));
TraceStackConvo = reshape(single(IM_Zframetime_smoothed),[],size(IM_Zframetime_smoothed,3));
if ExtractRaw
    TraceStackRaw = reshape(single(IM_Raw),[],size(IM_Raw,3));
end

for i = 1:size(Overall_OxygenSinks_Pxllist,1)
    Pxls = Overall_OxygenSinks_Pxllist(i,Overall_OxySinks_logical(i,:));
    Pxls_Unique = cellfun(@transpose,Pxls,'UniformOutput',false);
    Pxls_Unique = [Pxls_Unique{:}];
    Pxls_Unique = unique(Pxls_Unique)';

    idx_temp = zeros(numel(Pxls_Unique),2);
    [idx_temp(:,1),idx_temp(:,2)] = ind2sub(size(OxySink_Map)-2*Pixel_frame,Pxls_Unique);
    idx_temp = idx_temp+Pixel_frame;
    linIndx = sub2ind(size(OxySink_Map),idx_temp(:,1),idx_temp(:,2));

    OxySink_Pxls_all{i} = linIndx;
    OxySink_Map(linIndx) = true;

    Mean_OxySink_TraceZ(i,:) = mean(TraceStackZ(linIndx,:),1);
    Mean_OxySink_Trace_Convo(i,:) = mean(TraceStackConvo(linIndx,:),1);
    if ExtractRaw
        Mean_OxySink_Trace_Raw(i,:) = mean(TraceStackRaw(linIndx,:),1);
    end
end

end
