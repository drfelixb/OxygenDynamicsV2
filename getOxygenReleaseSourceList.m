function Plan = getOxygenReleaseSourceList(ProjectRoot,IncludeSmokeTest,ExpectedPlan)
%GETOXYGENRELEASESOURCELIST Validate the exact shared release source policy.
% No output directory or package is created here. ExpectedPlan rechecks the
% same paths and bytes immediately before the caller creates a directory.
if nargin<2,IncludeSmokeTest=true;end
if nargin<3,ExpectedPlan=[];end
assert(islogical(IncludeSmokeTest)&&isscalar(IncludeSmokeTest), ...
    'OxygenDynamics:ReleaseOption','includeSmokeTest must be a scalar logical.');
ProjectRoot=char(java.io.File(char(ProjectRoot)).getCanonicalPath());
policyName='OxygenReleaseSourcePolicy.json';
checkSourcePath(ProjectRoot,policyName);
policyPath=fullfile(ProjectRoot,policyName);
Policy=jsondecode(fileread(policyPath));
assert(isstruct(Policy)&&isscalar(Policy)&&all(isfield(Policy, ...
    {'schema','required_sources','optional_smoke_source','retained_unverified_assets', ...
    'forbidden_extensions','forbidden_segments','forbidden_path_patterns', ...
    'forbidden_exact_paths','dynamic_edges'}))&&strcmp(Policy.schema,'oxygen-release-source-policy-1'), ...
    'OxygenDynamics:ReleasePolicy','Missing or unsupported release source policy.');
Sources=cellstr(string(Policy.required_sources(:)));
if IncludeSmokeTest,Sources{end+1,1}=char(Policy.optional_smoke_source);end
Assets=cellstr(string(Policy.retained_unverified_assets(:)));
Files=[Sources;Assets];
assert(numel(unique(lower(string(Files))))==numel(Files), ...
    'OxygenDynamics:ReleasePolicy','Duplicate or case-colliding release destinations.');
for k=1:numel(Policy.dynamic_edges)
    edge=Policy.dynamic_edges(k);
    assert(all(ismember({edge.from,edge.via,edge.to},Sources)), ...
        'OxygenDynamics:ReleasePolicy','A declared dynamic source edge is incomplete.');
end
Hashes=cell(size(Files));
for k=1:numel(Files)
    name=Files{k};
    assert(~isempty(name)&&isempty(regexp(name,'(^/|\\|:|(^|/)\.\.?(/|$)|//|/$)','once')), ...
        'OxygenDynamics:ReleasePath','Unsafe release path: %s.',name);
    [~,~,extension]=fileparts(name);
    assert(~any(strcmpi(extension,Policy.forbidden_extensions))&& ...
        ~any(ismember(lower(string(strsplit(name,'/'))),lower(string(Policy.forbidden_segments))))&& ...
        ~any(strcmpi(name,Policy.forbidden_exact_paths)), ...
        'OxygenDynamics:ReleaseExcluded','Excluded release path: %s.',name);
    for j=1:numel(Policy.forbidden_path_patterns)
        assert(isempty(regexpi(name,Policy.forbidden_path_patterns{j},'once')), ...
            'OxygenDynamics:ReleaseExcluded','Excluded release path: %s.',name);
    end
    checkSourcePath(ProjectRoot,name);
    Hashes{k}=oxygenFileSHA256(fullfile(ProjectRoot,name));
end
Plan=struct('Schema',Policy.schema,'PolicySHA256',oxygenFileSHA256(policyPath), ...
    'RelativePaths',{Files},'SHA256',{Hashes}, ...
    'UnverifiedAssets',{Assets},'ReleaseReady',false);
if ~isempty(ExpectedPlan)
    assert(isequaln(Plan,ExpectedPlan),'OxygenDynamics:ReleaseSourceChanged', ...
        'Release policy, source list or file bytes changed after validation. No package was started.');
end
end

function checkSourcePath(root,name)
% Check each path component, so a symlinked source folder is not followed.
parts=strsplit(name,'/');current=root;
for k=1:numel(parts)
    current=fullfile(current,parts{k});
    file=java.io.File(current);
    assert(~javaMethod('isSymbolicLink','java.nio.file.Files',file.toPath()), ...
        'OxygenDynamics:ReleasePath','Symlink excluded: %s.',name);
end
canonical=char(java.io.File(current).getCanonicalPath());
assert(startsWith(canonical,[root filesep])&&isfile(current), ...
    'OxygenDynamics:ReleaseRequiredFileMissing','Missing or outside-root required file: %s.',name);
end
