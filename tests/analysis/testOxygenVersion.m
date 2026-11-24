function tests=testOxygenVersion
tests=functiontests(localfunctions);
end

function testCurrentVersionMatchesCheckout(t)
root=setupOxygenDynamicsPath();
info=getOxygenPipelineVersion();
assertMatches(t,root,info.Version);
end

function testDevelopmentCandidateAndRelease(t)
root=setupOxygenDynamicsPath();
copy=tempname;mkdir(copy);mkdir(fullfile(copy,'core'));mkdir(fullfile(copy,'tools'));
t.addTeardown(@()rmdir(copy,'s'));
for name={'core/getOxygenPipelineVersion.m','tools/setOxygenVersion.m', ...
        'README.md','CITATION.cff','INSTALLATION.md','DISTRIBUTION_STATUS.md','CHANGELOG.md'}
    copyfile(fullfile(root,name{1}),fullfile(copy,name{1}));
end
originalPath=path; t.addTeardown(@()restorePath(originalPath));
addpath(fullfile(copy,'core'),fullfile(copy,'tools'),'-begin');
clear getOxygenPipelineVersion setOxygenVersion
t.assertEqual(which('setOxygenVersion'),fullfile(copy,'tools','setOxygenVersion.m'));
history=fileread(fullfile(copy,'CHANGELOG.md'));
for label=["8.2.1-rc.1","8.2.1","8.2.2-dev"]
    setOxygenVersion(label);
    clear getOxygenPipelineVersion
    info=getOxygenPipelineVersion();
    t.verifyEqual(string(info.Version),label);t.verifyEqual(info.SourceCommit,'unknown');
    t.verifyEqual(info.SourceState,'unknown');
    assertMatches(t,copy,info.Version);
end
t.verifyEqual(fileread(fullfile(copy,'CHANGELOG.md')),history);
t.verifyTrue(contains(fileread(fullfile(copy,'README.md')),'RELEASE_NOTES_3.1.0_RC1.md'));
t.verifyError(@()setOxygenVersion('1.2-rc1'),'OxygenDynamics:VersionFormat');
% A broken target must be detected before the authoritative source changes.
before=fileread(fullfile(copy,'core','getOxygenPipelineVersion.m'));
writelines("No current version declaration",fullfile(copy,'INSTALLATION.md'));
t.verifyError(@()setOxygenVersion('8.3.0-dev'),'OxygenDynamics:VersionMarker');
t.verifyEqual(fileread(fullfile(copy,'core','getOxygenPipelineVersion.m')),before);
end

function assertMatches(t,root,v)
% These four live declarations must match for development, RC and final builds.
% Only release builds (including RCs) also carry a CITATION.cff release date.
declarations={'CITATION.cff','(?m)^version: "([^"]+)"$'; ...
    'README.md','(?m)^Checkout version: \*\*([^*]+)\*\*\.$'; ...
    'INSTALLATION.md','(?m)^The version should be `([^`]+)`\.'; ...
    'DISTRIBUTION_STATUS.md','(?m)^Checkout version: \*\*([^*]+)\*\*\.$'};
for k=1:size(declarations,1)
    names=regexp(fileread(fullfile(root,declarations{k,1})),declarations{k,2},'tokens');
    t.verifyEqual(names,{{v}},declarations{k,1});
end
t.verifyNotEmpty(regexp(v,'^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(-dev|-rc\.[1-9]\d*)?$','once'));
cff=fileread(fullfile(root,'CITATION.cff'));
if endsWith(v,'-dev')
    t.verifyEmpty(regexp(cff,'(?m)^date-released:','once'));
else
    t.verifyNotEmpty(regexp(cff,'(?m)^date-released: \d{4}-\d{2}-\d{2}$','once'));
end
end

function testHistoricalCreatorIsNeverInferred(t)
setupOxygenDynamicsPath;
legacy=struct('StatsInfo',struct('CalculationSoftware',struct('Version','1.01')));
p=createOxygenExportProvenance(legacy);
t.verifyEqual(p.OriginalCalculation.SoftwareVersion,'1.01');
t.verifyEqual(p.OriginalCalculation.SourceCommit,'unknown');
t.verifyEqual(p.OriginalCalculation.SourceState,'unknown');
info=getOxygenPipelineVersion();
t.verifyEqual(p.CurrentReaderExporter.SourceCommit,info.SourceCommit);
saved=struct('Version','synthetic','SourceCommit',repmat('c',1,40),'SourceState','modified');
p=createOxygenExportProvenance(struct('AnalysisInfo',struct('CalculationSoftware',saved)));
t.verifyEqual(p.OriginalCalculation.SourceCommit,saved.SourceCommit);
t.verifyEqual(p.OriginalCalculation.SourceState,'modified');
row=oxygenSoftwareProvenanceTable(legacy.StatsInfo,info);
t.verifyEqual(row.CalculationVersion,"1.01");t.verifyEqual(row.CalculationSourceCommit,"unknown");
end

function restorePath(originalPath)
path(originalPath);clear getOxygenPipelineVersion setOxygenVersion
end
