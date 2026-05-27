function [Paths,Postures,Pupils,Puffs,Mice,Genotypes,Conditions,DrugIDs,Promoters,SampleFs,Pixelsizes] = unpackWrapperInputTable(InputD)
%UNPACKWRAPPERINPUTTABLE Convert wrapper metadata table columns to cell arrays.

Paths = table2cell(InputD(:,{'Paths'}));
Postures = table2cell(InputD(:,{'PostureFile'}));
Pupils = table2cell(InputD(:,{'PupilFile'}));
Puffs = table2cell(InputD(:,{'PuffsFile'}));
Mice = table2cell(InputD(:,{'Mouse'}));
Genotypes = table2cell(InputD(:,{'Genotype'}));
Conditions = table2cell(InputD(:,{'Condition'}));
DrugIDs = table2cell(InputD(:,{'DrugID'}));
Promoters = table2cell(InputD(:,{'Promoter'}));
SampleFs = table2cell(InputD(:,{'SampleF'}));
Pixelsizes = table2cell(InputD(:,{'Pixelsize'}));

end
