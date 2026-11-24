function Info = getOxygenPipelineVersion()
%GETOXYGENPIPELINEVERSION Identify the software actually running.
Info.Version = '4.0.0-dev';
Info.BuildTimestamp = '2026-11-24 15:51:20 +01:00';
Info.DisplayName = ['Oxygen Dynamics Pipeline v',Info.Version];
Info.SourceCommit = 'unknown';
Info.SourceState = 'unknown';

root = fileparts(fileparts(mfilename('fullpath')));
marker = fullfile(root,'.git');
if ~isfolder(marker) && ~isfile(marker)
    return
end

% Reuse the native repository handle, but always read live HEAD and status.
% A later acquisition in this session may follow an edit or branch switch.
persistent repo
if exist('gitrepo','file')
    try
        if isempty(repo)
            repo = gitrepo(root);
        end
        Info.SourceCommit = char(repo.LastCommit.ID);
        changes = status(repo);
        if isempty(changes)
            Info.SourceState = 'clean';
        else
            Info.SourceState = 'modified';
        end
        return
    catch
        repo = [];
    end
end

% Older MATLAB releases or repository layouts unsupported by the native API.
% Pass arguments directly so shell syntax in a checkout path is harmless.
try
    [ok,commit] = readGit(root,{'rev-parse','--verify','HEAD'});
    if ok && ~isempty(regexp(commit,'^([0-9a-f]{40}|[0-9a-f]{64})$','once'))
        Info.SourceCommit = commit;
        [ok,changes] = readGit(root,{'status','--porcelain','--untracked-files=normal'});
        if ok && isempty(changes)
            Info.SourceState = 'clean';
        elseif ok
            Info.SourceState = 'modified';
        end
    end
catch
    % Git metadata is optional, including on installations without Git.
end
end

function [ok,output] = readGit(root,args)
command = java.util.ArrayList();
for word = [{'git','--no-optional-locks','-C',root},args]
    command.add(java.lang.String(word{1}));
end
builder = java.lang.ProcessBuilder(command);
builder.redirectErrorStream(true);
process = builder.start();
reader = java.util.Scanner(process.getInputStream(),'UTF-8');
cleanup = onCleanup(@()reader.close());
reader.useDelimiter('\A');
output = '';
if reader.hasNext(), output = strtrim(char(reader.next())); end
ok = process.waitFor()==0;
end
