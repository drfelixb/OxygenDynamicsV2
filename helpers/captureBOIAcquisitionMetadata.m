function [Snapshot,Resolved,QC] = captureBOIAcquisitionMetadata(RecordingFolder,NFrames,SampleHz,RawSHA256,RequireCompatible)
%CAPTUREBOIACQUISITIONMETADATA Snapshot optional declarations before detection.
% No live metadata file is retroactively applied to an existing master output.
if nargin<5,RequireCompatible=true;end
file=fullfile(RecordingFolder,'BOIInputMetadata.json');
Snapshot=struct('State','not_supplied','FileName','BOIInputMetadata.json','RawJSON','','SHA256','');
if isfile(file)
    Snapshot.State='captured';Snapshot.RawJSON=fileread(file);Snapshot.SHA256=oxygenFileSHA256(file);
end
[Resolved,QC]=resolveBOIAcquisitionMetadata(Snapshot,NFrames,SampleHz,RawSHA256);
if RequireCompatible && ~Resolved.InputCompatible
    holds=QC(QC.Disposition=="hold_recording",:);
    error('OxygenDynamics:UnsupportedBOIInput','BOI input held: %s Action: %s', ...
        strjoin(holds.Message,' '),strjoin(holds.Action,' '));
end
end
