function Identity = oxygenEventFirstCodeIdentity(root)
% Content identity includes dirty and new MATLAB sources, not just HEAD.
files=dir(fullfile(root,'**','*.m')); paths=strings(numel(files),1); hashes=paths;
for k=1:numel(files)
    path=fullfile(files(k).folder,files(k).name);
    paths(k)=extractAfter(string(path),strlength(string(root))+1);
    hashes(k)=oxygenEventFirstSHA256(path);
end
Identity=table(paths,hashes,'VariableNames',{'RepositoryRelativePath','SHA256'});
end
