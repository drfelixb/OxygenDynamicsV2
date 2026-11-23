function L = createLegacyOxygenComparisonEnvelope(R,Output)
% Copy native tracked support restricted to legacy event bounds, preserving origin.
% Restore sink crop coordinates explicitly. No TIFF reconstruction or area matching.
L=struct('Detector',"legacy",'DetectorVersion',"V2-8cf3f036",'Events',table(), ...
    'EventFrameMasks',table(strings(0,1),zeros(0,1),cell(0,1),'VariableNames',{'EventID','Frame','PixelIdxList'}));
L.Events=table(strings(0,1),strings(0,1),zeros(0,1),zeros(0,1),'VariableNames',{'EventID','EventType','IntervalStartSec','IntervalEndSec'});
shape=[size(R.Intensity,1) size(R.Intensity,2)];
for kind=["sink","surge"]
    if kind=="sink"
        E=Output.Table_OxygenSinkEvents_Out; lists=Output.Overall_OxygenSinks_Pxllist; siteField='SinkID'; crop=Output.Pixel_frame;
    else
        E=Output.Table_OxygenSurgeEvents_Out; lists=Output.Overall_OxygenSurges_Pxllist; siteField='SurgeID'; crop=0;
    end
    for k=1:height(E)
        id=string(R.RecordingID)+"/legacy/"+kind+"/"+string(k);
        L.Events(end+1,:)={id,kind,(E.StartFrame(k)-1)/R.fs,E.EndFrame(k)/R.fs};
        for t=max(1,E.StartFrame(k)):min(R.NFrames,E.EndFrame(k))
            p=lists{E.(siteField)(k),t};
            if isempty(p), continue; end
            [y,x]=ind2sub(shape-2*crop,double(p));
            p=uint32(sub2ind(shape,y+crop,x+crop));
            L.EventFrameMasks(end+1,:)={id,t,{p(:)}};
        end
    end
end
L.GeometryDefinition="native legacy tracked site support clipped to legacy event bounds; no inference from TIFF masks";
L.TimingDefinition="comparison adapter uses exposure intervals; original legacy tables retained without timing edits";
L.OriginalSinkEvents=Output.Table_OxygenSinkEvents_Out; L.OriginalSurgeEvents=Output.Table_OxygenSurgeEvents_Out;
end
