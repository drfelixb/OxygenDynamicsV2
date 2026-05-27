function RecordingInput = createStatsRecordingInput(PathValue,Mouse,Condition,Genotype,Promoter,DrugID,Posture,Pupil,Puff,Whisking,PixelSize)
%CREATESTATSRECORDINGINPUT Bundle one metadata CSV row for stats loading.

if nargin < 11
    PixelSize = NaN;
end

RecordingInput = struct();
RecordingInput.Path = PathValue;
RecordingInput.Mouse = Mouse;
RecordingInput.Condition = Condition;
RecordingInput.Genotype = Genotype;
RecordingInput.Promoter = Promoter;
RecordingInput.DrugID = DrugID;
RecordingInput.Posture = Posture;
RecordingInput.Pupil = Pupil;
RecordingInput.Puff = Puff;
RecordingInput.Whisking = Whisking;
RecordingInput.PixelSize = PixelSize;
end
