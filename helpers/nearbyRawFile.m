function path=nearbyRawFile(recorded,folder,original,hash)
% Accept a relocated or renamed source only if its full file digest agrees.
parts=split(replace(string(recorded),char(92),'/'),'/');name=parts(end);
paths=[fullfile(folder,name);string(recorded)];
if strlength(original)>0,paths(end+1,1)=fullfile(original,name);end
for root=[string(folder),string(original)]
    if strlength(root)==0 || ~isfolder(root),continue;end
    files=dir(fullfile(root,'*'));
    for k=1:numel(files)
        if ~files(k).isdir && endsWith(lower(files(k).name),{'.tif','.tiff'})
            paths(end+1,1)=fullfile(root,files(k).name); %#ok<AGROW>
        end
    end
end
paths=unique(paths,'stable');messages=strings(0,1);
for k=1:numel(paths)
    if ~isfile(paths(k)),continue;end
    try
        if strcmpi(oxygenFileSHA256(paths(k)),hash),path=paths(k);return;end
    catch ex
        messages(end+1)=string(ex.message); %#ok<AGROW>
    end
end
error('Nearby:RawSource','No readable raw TIFF matched %s. Checked %s. %s',hash,strjoin(cellstr(paths),' | '),strjoin(cellstr(messages),' | '));
end
