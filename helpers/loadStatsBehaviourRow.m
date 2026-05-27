function BehaviourRow = loadStatsBehaviourRow(BehaviourRow,BehaviourFolder,RecordingFolder,RecordingId,Inputs,RecordingDuration,BehFs)
%LOADSTATSBEHAVIOURROW Load all configured behaviour traces for one recording.

BehaviourRow = loadStatsBehaviourMatRow(BehaviourRow,BehaviourFolder,RecordingId,Inputs);
BehaviourRow = loadStatsWhiskingRow(BehaviourRow,Inputs.Whisking,BehaviourFolder,RecordingFolder, ...
    RecordingId,RecordingDuration,BehFs);
end
