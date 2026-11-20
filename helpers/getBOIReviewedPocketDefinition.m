function D=getBOIReviewedPocketDefinition
%GETBOIREVIEWEDPOCKETDEFINITION Version-bound, separately selected reviewed rule.
p=fullfile(fileparts(fileparts(mfilename('fullpath'))),'docs','planning','boi-reviewed-pocket-contract-0.2.0-exploratory.json');
h=oxygenFileSHA256(p);
assert(strcmp(h,'1e54fc7265e5275db3f78f82105ce25c9e1603d566bf7a198e958c88d9e8cbb9'),'OxygenDynamics:PocketDefinitionChanged','Reviewed pocket definition changed without a verified version.');
D=jsondecode(fileread(p));D.FileSHA256=h;
end
