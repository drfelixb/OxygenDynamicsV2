function D=getBOIReviewedOpticalDefinition(folder,version)
%GETBOIREVIEWEDOPTICALDEFINITION Bind this implementation to its exact draft.
if nargin<1||isempty(folder),folder=fullfile(fileparts(fileparts(mfilename('fullpath'))),'definitions');end
if nargin<2,version='0.1.0-draft';end
switch string(version)
    case "0.1.0-draft"
        expectedContract='569961f5ce65a0d6d38625f1ef9f1c3480ffcb672bda78a2a0612ce26b5f6308';
        expectedDictionary='093b0095b3acb73ebad8820703203d99d1bdf69709c7158eef2aa8182b7d6ebb';
    case "0.2.0-offset"
        expectedContract='708cab6f7b4607d8b2f9eb61fd3008302774964cb8b5f04d2f26581919918a58';
        expectedDictionary='7779d378976002813e9864bc7f77d964211cb49fd122fc563facf53a656347dd';
    otherwise
        error('OxygenDynamics:ReviewedOpticalDefinitionChanged','Unknown saved reviewed optical version.');
end
contract=fullfile(folder,['boi-reviewed-optical-contract-' char(version) '.json']);
dictionary=fullfile(folder,['boi-reviewed-optical-dictionary-' char(version) '.json']);
ch=oxygenFileSHA256(contract);dh=oxygenFileSHA256(dictionary);
assert(strcmp(ch,expectedContract)&&strcmp(dh,expectedDictionary), ...
    'OxygenDynamics:ReviewedOpticalDefinitionChanged','Reviewed definition changed. Version and verify its implementation before calculation.');
[~,document]=getBOIMeasurementDictionary(dictionary);
D=struct('ID',['boi-reviewed-optical-' char(version)],'ContractPath',contract,'ContractSHA256',ch, ...
    'Contract',jsondecode(fileread(contract)),'DictionaryPath',dictionary,'DictionarySHA256',dh,'Dictionary',document, ...
    'ImplementationStatus','implemented_read_only_exploratory','ScientificAdoption',false);
end
