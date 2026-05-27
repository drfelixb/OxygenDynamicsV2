function Metadata = createRecordingMetadata(mouseId,condition,drugId,genotype,promoter)
%CREATERECORDINGMETADATA Build metadata struct shared by wrapper preflight.

Metadata = struct();
Metadata.Mouse = mouseId;
Metadata.Condition = condition;
Metadata.DrugID = drugId;
Metadata.Genotype = genotype;
Metadata.Promoter = promoter;

end
