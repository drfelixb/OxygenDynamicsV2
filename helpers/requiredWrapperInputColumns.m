function RequiredInputColumns = requiredWrapperInputColumns()
%REQUIREDWRAPPERINPUTCOLUMNS Metadata columns needed by batch wrappers.

RequiredInputColumns = {'Paths','PostureFile','PupilFile','PuffsFile','Mouse','Genotype', ...
    'Condition','DrugID','Promoter','SampleF','Pixelsize'};

end
