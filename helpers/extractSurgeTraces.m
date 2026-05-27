function [Mean_OxySurge_TraceZ,OxySurge_Pxls_all,OxySurge_Map] = extractSurgeTraces( ...
    Overall_OxygenSurges_Pxllist,Overall_OxySurges_logical,IM_Zframetime,IM_Zframetime_smoothed)
%EXTRACTSURGETRACES Extract mean surge traces from the z-scored stack.

OxySurge_Map = false(size(IM_Zframetime_smoothed(:,:,1)));
OxySurge_Pxls_all = cell(size(Overall_OxygenSurges_Pxllist,1),1);
Mean_OxySurge_TraceZ = NaN(size(Overall_OxygenSurges_Pxllist,1),size(IM_Zframetime,3));
TraceStackZ = reshape(IM_Zframetime,[],size(IM_Zframetime,3));

for i = 1:size(Overall_OxygenSurges_Pxllist,1)
    Pxls = Overall_OxygenSurges_Pxllist(i,Overall_OxySurges_logical(i,:));
    if isempty(Pxls)
        continue
    end

    Pxls_Unique = cellfun(@transpose,Pxls,'UniformOutput',false);
    Pxls_Unique = [Pxls_Unique{:}];
    Pxls_Unique = unique(Pxls_Unique)';

    OxySurge_Pxls_all{i} = Pxls_Unique;
    OxySurge_Map(Pxls_Unique) = true;
    Mean_OxySurge_TraceZ(i,:) = mean(TraceStackZ(Pxls_Unique,:),1);
end
end
