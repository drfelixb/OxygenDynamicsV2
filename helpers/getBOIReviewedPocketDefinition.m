function D=getBOIReviewedPocketDefinition(version)
%GETBOIREVIEWEDPOCKETDEFINITION Version-bound, separately selected reviewed rule.
if nargin<1,version='boi-reviewed-pocket-optical-0.2.0-exploratory';end
switch string(version)
    case "boi-reviewed-pocket-optical-0.2.0-exploratory"
        file='boi-reviewed-pocket-contract-0.2.0-exploratory.json';
        expected='1e54fc7265e5275db3f78f82105ce25c9e1603d566bf7a198e958c88d9e8cbb9';
    case "boi-reviewed-pocket-optical-0.3.0-offset"
        file='boi-reviewed-pocket-contract-0.3.0-offset.json';
        expected='b08a03b7fc07f1ee5ec54d156ff001a9ffb81d77fb60af05b40c04604be4ac1e';
    otherwise
        error('OxygenDynamics:PocketDefinitionChanged','Unknown reviewed pocket definition.');
end
p=fullfile(fileparts(fileparts(mfilename('fullpath'))),'definitions',file);
h=oxygenFileSHA256(p);
assert(strcmp(h,expected),'OxygenDynamics:PocketDefinitionChanged','Reviewed pocket definition changed without a verified version.');
D=jsondecode(fileread(p));D.FileSHA256=h;
end
