function [Resolved,Origins,PathImport]=resolveBOIBatch(Batch)
%RESOLVEBOIBATCH Resolve row/shared values and batch detection support.
% Shared values apply only after explicit confirmation. Detection support
% defaults to the existing automatic tissue estimate. Returned paths are
% canonical absolute paths, relative to the document's BaseFolder. Foreign
% recording paths are retained until explicitly mapped to local folders.
% Rows in Batch retain the user's overrides and blanks for continued editing.
assert(isstruct(Batch)&&isscalar(Batch)&&isfield(Batch,'Schema')&&strcmp(Batch.Schema,'boi-batch-1')&& ...
    all(isfield(Batch,{'Rows','BaseFolder','Shared','SharedConfirmed'})), ...
    'OxygenDynamics:InvalidBatch','Supply a boi-batch-1 document.');
checked=createBOIBatch(Batch.Rows,Batch.BaseFolder);
Resolved=checked.Rows;
fields={'SampleF','Pixelsize','BOISupportProfile'};
assert(isstruct(Batch.Shared)&&isscalar(Batch.Shared)&&all(isfield(Batch.Shared,fields)), ...
    'OxygenDynamics:InvalidBatch','Shared settings must include SampleF, Pixelsize and BOISupportProfile.');
assert(islogical(Batch.SharedConfirmed)&&isscalar(Batch.SharedConfirmed), ...
    'OxygenDynamics:InvalidBatch','Explicitly confirm shared settings with a logical SharedConfirmed value.');
Origins=table();
for k=1:numel(fields)
    name=fields{k};shared=Batch.Shared.(name);
    assert((ischar(shared)&&(isrow(shared)||isempty(shared)))|| ...
        (isstring(shared)&&isscalar(shared)&&~ismissing(shared)), ...
        'OxygenDynamics:InvalidBatch','Shared %s must be text.',name);
    Origins.(name)=repmat("row",height(Resolved),1);
    missing=strlength(strtrim(Resolved.(name)))==0;
    Origins.(name)(missing)="missing";
    if Batch.SharedConfirmed&&strlength(strtrim(string(shared)))>0
        Resolved.(name)(missing)=string(shared);
        Origins.(name)(missing)="shared";
    end
end
defaultSupport=Origins.BOISupportProfile=="missing";
Resolved.BOISupportProfile(defaultSupport)="whole-image";
Origins.BOISupportProfile(defaultSupport)="default";
[Resolved.Paths,PathImport]=prepareBOIBatchImportPaths(Resolved.Paths,checked.BaseFolder);
foreign=false(height(Resolved),1);
foreign(PathImport.NeedsMapping.RowIndex)=true;
for name={'Paths','RunFolder'}
    for row=1:height(Resolved)
        if strcmp(name{1},'Paths')&&foreign(row),continue;end
        value=Resolved.(name{1})(row);
        if strlength(strtrim(value))==0,continue;end
        file=java.io.File(char(value));
        if ~file.isAbsolute(),file=java.io.File(fullfile(checked.BaseFolder,char(value)));end
        Resolved.(name{1})(row)=string(char(file.getCanonicalPath()));
    end
end
end
