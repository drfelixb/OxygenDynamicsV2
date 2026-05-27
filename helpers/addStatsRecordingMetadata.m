function DataTable = addStatsRecordingMetadata(DataTable,Metadata,BeforeVariable)
%ADDSTATSRECORDINGMETADATA Add recording metadata columns to a stats table.

NumRows = height(DataTable);
Experiment = repmat({Metadata.DatafileID},NumRows,1);
Mouse = repmat({Metadata.Mouse},NumRows,1);
Condition = repmat({Metadata.Condition},NumRows,1);
DrugID = repmat({Metadata.DrugID},NumRows,1);
PuffStim = repmat(logical(Metadata.PuffStim),NumRows,1);
Genotype = repmat({Metadata.Genotype},NumRows,1);
Promoter = repmat({Metadata.Promoter},NumRows,1);

DataTable = addvars(DataTable,Experiment,Mouse,Condition,DrugID,PuffStim,Genotype,Promoter, ...
    'Before',BeforeVariable);

end
