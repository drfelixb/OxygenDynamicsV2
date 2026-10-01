function D=getBOIReviewedOpticalDefinition(folder)
%GETBOIREVIEWEDOPTICALDEFINITION Bind this implementation to its exact draft.
if nargin<1,folder=fullfile(fileparts(fileparts(mfilename('fullpath'))),'docs','planning');end
contract=fullfile(folder,'boi-reviewed-optical-contract-0.1.0-draft.json');
dictionary=fullfile(folder,'boi-reviewed-optical-dictionary-0.1.0-draft.json');
ch=oxygenFileSHA256(contract);dh=oxygenFileSHA256(dictionary);
assert(strcmp(ch,'dcf0fa405a4f9d768133e8210d8c7dfa3104fc586994f09416f477e3557e0e63')&& ...
    strcmp(dh,'093b0095b3acb73ebad8820703203d99d1bdf69709c7158eef2aa8182b7d6ebb'), ...
    'OxygenDynamics:ReviewedOpticalDefinitionChanged','Reviewed definition changed. Version and verify its implementation before calculation.');
[~,document]=getBOIMeasurementDictionary(dictionary);
D=struct('ID','boi-reviewed-optical-0.1.0-draft','ContractPath',contract,'ContractSHA256',ch, ...
    'Contract',jsondecode(fileread(contract)),'DictionaryPath',dictionary,'DictionarySHA256',dh,'Dictionary',document, ...
    'ImplementationStatus','implemented_read_only_exploratory','ScientificAdoption',false);
end
