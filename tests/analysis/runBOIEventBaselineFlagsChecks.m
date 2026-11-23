function runBOIEventBaselineFlagsChecks(out,mode)
% Finite execution driver. Scope freezes names before the first MATLAB start.
if nargin<2,mode='initial';end
setupOxygenDynamicsPath;root=fileparts(fileparts(fileparts(mfilename('fullpath'))));
scope=jsondecode(fileread(fullfile(out,'scope.json')));
runner=matlab.unittest.TestRunner.withTextOutput;
constructed=matlab.unittest.TestSuite.fromFile(fullfile(root,'tests','analysis','testBOIEventBaselineFlags.m'));
assert(isequal(sort(extractAfter(string({constructed.Name}),'/'))',sort(string(scope.ConstructedTests))));
existing=constructed([]); % Preserve the concrete Test class returned by R2025a.
files=fieldnames(scope.FrozenExistingTests);
for i=1:numel(files)
    suite=matlab.unittest.TestSuite.fromFile(fullfile(root,'tests','analysis',[files{i} '.m']));
    assert(isequal(sort(extractAfter(string({suite.Name}),'/'))',sort(string(scope.FrozenExistingTests.(files{i})))));
    existing=[existing suite]; %#ok<AGROW>
end
if strcmp(mode,'repair')
    before=jsondecode(fileread(fullfile(out,'initial-test-results.json')));
    failed=string({before.Tests([before.Tests.Failed]|[before.Tests.Incomplete]).Name});
    constructed=constructed(ismember(string({constructed.Name}),failed));
    existing=existing(ismember(string({existing.Name}),failed));
    assert(numel(existing)<=3&&numel(constructed)<=12,'Repair must fit the frozen total evaluation limits.');
else
    assert(strcmp(mode,'initial')&&numel(constructed)==12&&numel(existing)==45);
end
allResults=runner.run([constructed existing]);
entries=struct('Name',{},'Passed',{},'Failed',{},'Incomplete',{},'Duration',{});
for i=1:numel(allResults)
    r=allResults(i);entries(i)=struct('Name',r.Name,'Passed',r.Passed,'Failed',r.Failed,'Incomplete',r.Incomplete,'Duration',r.Duration);
end
report=struct('Mode',mode,'ConstructedExecutions',numel(constructed),'ExistingExecutions',numel(existing), ...
    'Tests',entries,'Passed',all([entries.Passed]));
writeJSON(fullfile(out,[mode '-test-results.json']),report);
comparisonPath=fullfile(out,'saved-example-results.json');
if strcmp(mode,'initial')||~isfile(comparisonPath)
    writeJSON(fullfile(out,['saved-comparison-started-' mode '.json']),struct('Mode',mode,'Cases',3));
    compareSavedExamples(out,scope.Fixture.Path);
end
assert(report.Passed,'OxygenDynamics:BaselineFlagChecks','One or more frozen checks failed; retain this report for the one permitted repair.');
fprintf('Completed %d constructed and %d existing evaluations; saved three-example comparison complete.\n',numel(constructed),numel(existing));
end

function compareSavedExamples(out,path)
S=load(path,'result');old=S.result;assert(numel(old.Cases)==3&&old.SampleF==1&&old.RequiredBaselineFrames==20);
rows=table();
for i=1:3
    C=old.Cases(i);a=C.Current.StartFrame;b=C.Current.EndFrame;
    E=table("FB2412",C.SiteID,C.EventID,a,b,'VariableNames',{'RecordingID','SinkID','EventID','StartFrame','EndFrame'});
    T=struct('Raw',C.RawEventTrace,'Footprint',[],'DetectedFrames',C.NativeStartFrame:C.NativeEndFrame, ...
        'FootprintSource','archived_fixed_event_footprint_mean_pixel_indices_not_in_fixture', ...
        'OverlapAssessedFrames',C.LegacyBaselineOnCurrentBoundsFrames,'OverlappingReferenceFrames',C.LegacyBaselineOverlapFrames);
    D=deriveBOIEventReferences(E,{T},{},old.SampleF,20,'named_saved_comparison_trace');
    expected=C.BaselineOnly.AmplitudePercent;
    assert(abs(D.EventAmplitudePercent-expected)<=1e-10*max(1,abs(expected)),'Saved original temporal-rule comparison differs.');
    assert(abs(D.EventReferenceValue-C.BaselineOnly.BaselineValue)<=1e-10*max(1,abs(C.BaselineOnly.BaselineValue)));
    assert(D.EventReferenceOverlapFrames==numel(C.LegacyBaselineOverlapFrames));
    row=D(:,{'RecordingID','SinkID','EventID','StartFrame','EndFrame','EventAmplitudePercent', ...
        'EventReferenceKind','EventReferenceStartFrame','EventReferenceEndFrame','EventReferenceValue', ...
        'EventReferenceObservedSamples','EventReferenceOverlapFrames','EventReferenceNeedsReview', ...
        'EventReferenceRecoveryUnverified','RecordingReferenceStatus','AboveRecordingReference','EventReferenceFootprintSource'});
    row.StrictSavedAmplitudePercent=C.Current.AmplitudePercent;
    row.OriginalTemporalRuleOnSameTracePercent=expected;
    rows=[rows;row]; %#ok<AGROW>
end
writeJSON(fullfile(out,'saved-example-results.json'),struct('Schema','boi-event-baseline-flags-saved-check-1', ...
    'Cases',table2struct(rows),'RawMoviesRead',0,'OriginalResultsChanged',false,'NewBurdenTotalsComputed',false, ...
    'Limitation','Only archived event means and known reference-overlap lists are available. No full recording native inventory/pixel identities: earlier-reference overlap is not assessable; no missing evidence is invented.'));
writetable(rows,fullfile(out,'saved-example-results.csv'));
end
function writeJSON(path,value)
fid=fopen(path,'w');assert(fid>=0);c=onCleanup(@()fclose(fid));fprintf(fid,'%s\n',jsonencode(value,'PrettyPrint',true));
end
