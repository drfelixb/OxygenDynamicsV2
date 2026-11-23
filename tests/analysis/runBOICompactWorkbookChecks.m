function runBOICompactWorkbookChecks(out,mode)
% Eight frozen families, counted individually; no scientific calculator calls.
if nargin<2,mode='initial';end
setupOxygenDynamicsPath;repo=fileparts(fileparts(fileparts(mfilename('fullpath'))));
scopePath=fullfile(out,'scope.json');scope=jsondecode(fileread(scopePath));
assert(scope.ExecutionApproved&&scope.BudgetAllocated,'Approved compact scope required.');
setenv('BOI_CEX_EVIDENCE_DIR',out);oldpwd=pwd;guards=fullfile(tempdir,'calculator-guards');mkdir(guards);
for n=string(scope.NoCalculatorTestGuards)'
    p=fullfile(guards,n+'.m');f=fopen(p,'w');fprintf(f,'function varargout=%s(varargin)\nerror(''OxygenDynamics:ForbiddenCompactCalculation'',''Scientific calculator was called: %s'');\nend\n',n,n);fclose(f);
end
addpath(guards,'-begin');cd(guards);c=onCleanup(@()cd(oldpwd)); %#ok<NASGU>
for n=string(scope.NoCalculatorTestGuards)',assert(startsWith(which(n),guards),'Calculator guard missing.');end
suite=matlab.unittest.TestSuite.fromFile(fullfile(repo,scope.TestSuitePlanned));
names=string({scope.FrozenScenarioFunctions.Name});[found,ix]=ismember(names,extractAfter(string({suite.Name}),'/'));
assert(all(found)&&numel(suite)==8,'Exactly eight frozen functions required.');suite=reshape(suite(ix),1,[]);
if strcmp(mode,'repair')
    assert(scope.Counters.RepairCycles>=1&&scope.Counters.RepairCycles<=scope.ProposedLimits.RoutineRepairs);
    selected=string(scope.RepairTests);suite=suite(ismember(string({suite.Name}),selected));
    assert(numel(suite)==numel(selected),'Repair names must be frozen functions.');
else,assert(strcmp(mode,'initial'));end
runner=matlab.unittest.TestRunner.withTextOutput;entries=struct('Name',{},'Passed',{},'Failed',{},'Incomplete',{},'Duration',{});
for i=1:numel(suite)
    scope=jsondecode(fileread(scopePath));assert(scope.Counters.TestEvaluations<scope.ProposedLimits.ConstructedExecutionsTotalIncludingRetries,'24 total evaluations exhausted.');
    scope.Counters.TestEvaluations=scope.Counters.TestEvaluations+1;scope.LastTest=suite(i).Name;writeBOIRunJSON(scopePath,scope);
    result=runner.run(suite(i));r=result(1);entries(end+1)=struct('Name',r.Name,'Passed',r.Passed,'Failed',r.Failed,'Incomplete',r.Incomplete,'Duration',r.Duration); %#ok<AGROW>
    writeBOIRunJSON(fullfile(out,[mode '-test-results.json']),struct('Mode',mode,'Tests',entries,'Passed',all([entries.Passed])));
end
assert(all([entries.Passed]),'OxygenDynamics:CompactChecks','Frozen checks failed. Preserve checkpoint; only approved bounded repairs may follow.');
fprintf('Compact workbook: %d frozen evaluations passed. Zero real recording inputs and zero calculator calls.\n',numel(entries));
end
