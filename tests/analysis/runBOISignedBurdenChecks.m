function runBOISignedBurdenChecks(out,mode)
% Direct frozen synthetic suite. Never invokes saved-example drivers.
if nargin<2,mode='initial';end
setupOxygenDynamicsPath;
root=fileparts(fileparts(fileparts(mfilename('fullpath'))));
scopePath=fullfile(out,'scope.json');scope=jsondecode(fileread(scopePath));
assert(scope.ExecutionApproved&&scope.BudgetAllocated,'Approved revision-31 scope required.');
old=getenv('BOI_R31_EVIDENCE_DIR');setenv('BOI_R31_EVIDENCE_DIR',out);
cleanup=onCleanup(@()setenv('BOI_R31_EVIDENCE_DIR',old)); %#ok<NASGU>
fresh=matlab.unittest.TestSuite.fromFile(fullfile(root,scope.NewTestSuitePlanned));
names=string({scope.ConstructedFunctions.Name});
[found,idx]=ismember(names,extractAfter(string({fresh.Name}),'/'));
assert(all(found)&&numel(fresh)==12,'Constructed test list must match the frozen twelve.');
fresh=reshape(fresh(idx),1,[]);existing=fresh([]);
files=fieldnames(scope.FrozenExistingSyntheticFunctions);
for i=1:numel(files)
    suite=matlab.unittest.TestSuite.fromFile(fullfile(root,'tests','analysis',[files{i} '.m']));
    names=string(scope.FrozenExistingSyntheticFunctions.(files{i}));
    [found,idx]=ismember(names,extractAfter(string({suite.Name}),'/'));
    assert(all(found),'A frozen existing synthetic function is missing.');
    existing=[existing reshape(suite(idx),1,[])]; %#ok<AGROW>
end
assert(numel(existing)==24);
% Existing export test produces the artifact consumed by read-only S12.
suite=[existing fresh];
if strcmp(mode,'repair')
    assert(scope.Counters.RepairCycles==1,'One recorded repair required.');
    selected=string(scope.RepairTests);suite=suite(ismember(string({suite.Name}),selected));
    assert(numel(suite)==numel(selected),'Repair names must be in the frozen set.');
else
    assert(strcmp(mode,'initial'));
end
runner=matlab.unittest.TestRunner.withTextOutput;
entries=struct('Name',{},'Passed',{},'Failed',{},'Incomplete',{},'Duration',{});
for i=1:numel(suite)
    scope=jsondecode(fileread(scopePath));name=string(suite(i).Name);
    isNew=startsWith(name,'testBOISignedBurdenPolicy/');
    if isNew,key='ConstructedExecutions';limit=24;else,key='ExistingExecutions';limit=48;end
    assert(scope.Counters.(key)<limit,'Function execution limit reached.');
    writes=startsWith(name,'testBOIPortableAmplitude/')|| ...
        name=="testBOIBurdenCompleteness/testWorkbookAndCsvKeepTotalsUnavailable"|| ...
        name=="testBOIReviewedExport/testConfirmedExportKeepsFormatsValuesAndOriginals";
    if writes
        assert(scope.Counters.XLSXAttempts<8,'Eight workbook attempts exhausted; do not start another writer test.');
        scope.Counters.XLSXAttempts=scope.Counters.XLSXAttempts+1;
    end
    scope.Counters.(key)=scope.Counters.(key)+1;
    scope.LastTest=char(name);writeBOIRunJSON(scopePath,scope);
    result=runner.run(suite(i));r=result(1);
    entries(end+1)=struct('Name',r.Name,'Passed',r.Passed,'Failed',r.Failed,'Incomplete',r.Incomplete,'Duration',r.Duration); %#ok<AGROW>
    report=struct('Mode',mode,'Tests',entries,'Passed',all([entries.Passed]));
    writeBOIRunJSON(fullfile(out,[mode '-test-results.json']),report);
end
assert(all([entries.Passed]),'OxygenDynamics:Revision31Checks','Frozen checks failed; retain the report and use only the allowed repair.');
fprintf('Revision 31: %d frozen evaluations passed in this run. No real recording input.\n',numel(entries));
end
