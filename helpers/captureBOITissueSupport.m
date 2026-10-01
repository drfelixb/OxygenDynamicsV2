function [Snapshot,Mask,Declaration] = captureBOITissueSupport(Folder,FrameSize,RawSHA256)
%CAPTUREBOITISSUESUPPORT Capture an optional decision before the BOI master.
file=fullfile(Folder,'BOITissueSupport.json');
Snapshot=struct('State','not_supplied','FileName','BOITissueSupport.json','RawJSON','','SHA256','');
if isfile(file)
    Snapshot.State='captured';Snapshot.RawJSON=fileread(file);Snapshot.SHA256=oxygenFileSHA256(file);
end
[Mask,Declaration]=resolveBOITissueSupport(Snapshot,FrameSize,RawSHA256);
end
