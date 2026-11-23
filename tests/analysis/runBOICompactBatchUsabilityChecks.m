function runBOICompactBatchUsabilityChecks(out,mode)
if nargin<2,mode='initial';end
setupOxygenDynamicsPath;repo=fileparts(fileparts(fileparts(mfilename('fullpath'))));
p=fullfile(out,'scope.json');scope=jsondecode(fileread(p));assert(scope.ExecutionApproved);
setenv('BOI_CEX_BATCH_OUT',out);previous=pwd;guards=fullfile(tempdir,'guards');mkdir(guards);
for n=string(scope.NoScientificCalculators)'
    f=fopen(fullfile(guards,n+'.m'),'w');fprintf(f,'function varargout=%s(varargin)\nerror(''OxygenDynamics:ForbiddenCompactCalculation'',''Scientific calculator called: %s'');\nend\n',n,n);fclose(f);
end
% Frozen reference is old reporting code only, never a scientific calculator.
s=fileread(fullfile(out,'before','createBOICompactWorkbookData.m'));s=strrep(s,'function D=createBOICompactWorkbookData(S)','function D=beforeCompactWorkbookData(S)');
f=fopen(fullfile(guards,'beforeCompactWorkbookData.m'),'w');fwrite(f,s,'char');fclose(f);
addpath(guards,'-begin');cd(guards);cleanup=onCleanup(@()cd(previous)); %#ok<NASGU>
for n=string(scope.NoScientificCalculators)',assert(startsWith(which(n),guards));end
suite=matlab.unittest.TestSuite.fromFile(fullfile(repo,scope.TestFile));names=string(scope.FrozenTests);
[found,ix]=ismember(names,extractAfter(string({suite.Name}),'/'));assert(all(found)&&numel(suite)==3);suite=reshape(suite(ix),1,[]);
if strcmp(mode,'memory')
    assert(scope.MemoryCorrection.Approved&&scope.Counters.Repairs==2&&~scope.NoFurtherExecutionAuthorized);
    suite=suite(string({suite.Name})==string(scope.MemoryCorrection.SelectedTest));assert(numel(suite)==1);
    setenv('BOI_CEX_BULK_SUFFIX','MemoryChecked');
elseif strcmp(mode,'repair'),assert(scope.Counters.Repairs==1);suite=suite(ismember(string({suite.Name}),string(scope.RepairTests)));else,assert(strcmp(mode,'initial'));end
runner=matlab.unittest.TestRunner.withTextOutput;entries=struct('Name',{},'Passed',{},'Failed',{},'Incomplete',{},'Duration',{});
for k=1:numel(suite)
    scope=jsondecode(fileread(p));assert(scope.Counters.Evaluations<scope.Limits.Evaluations);
    scope.Counters.Evaluations=scope.Counters.Evaluations+1;scope.LastTest=suite(k).Name;writeBOIRunJSON(p,scope);
    r=runner.run(suite(k));entries(end+1)=struct('Name',r.Name,'Passed',r.Passed,'Failed',r.Failed,'Incomplete',r.Incomplete,'Duration',r.Duration); %#ok<AGROW>
    writeBOIRunJSON(fullfile(out,[mode '-test-results.json']),struct('Tests',entries,'Passed',all([entries.Passed])));
end
assert(all([entries.Passed]),'OxygenDynamics:CompactChecks','Frozen checks failed; preserve bounded checkpoint.');
end
