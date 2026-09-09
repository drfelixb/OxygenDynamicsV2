function RecordingMetadata = createStatsRecordingMetadata(DatafileID,Mouse,Condition,DrugID,Genotype,Promoter,Puff,PixelSize,RecordingIndex)
%CREATESTATSRECORDINGMETADATA Build normalized per-recording stats metadata.

if nargin < 8
    PixelSize = NaN;
end
if nargin < 9
    RecordingIndex = NaN;
end

if ~ischar(Mouse)
    Mouse = num2str(Mouse);
end

RecordingMetadata = struct('DatafileID',DatafileID,'Mouse',Mouse,'Condition',Condition, ...
    'DrugID',DrugID,'Genotype',Genotype,'Promoter',Promoter, ...
    'RecordingID',char(string(DatafileID)), 'PuffStim',hasPuffStimulus(Puff),'PixelSize',PixelSize,'RecordingIndex',RecordingIndex);
end

function HasPuffStimulus = hasPuffStimulus(Puff)
if isempty(Puff)
    HasPuffStimulus = false;
elseif isnumeric(Puff)
    HasPuffStimulus = all(~isnan(Puff));
elseif isstring(Puff)
    HasPuffStimulus = all(strlength(Puff)>0 & ~ismissing(Puff));
elseif ischar(Puff)
    HasPuffStimulus = ~isempty(Puff);
else
    HasPuffStimulus = true;
end
end
