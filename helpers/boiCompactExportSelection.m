function Value=boiCompactExportSelection(Action,BatchPath,AutomaticSHA256,ReviewPaths)
%BOICOMPACTEXPORTSELECTION Separate UI sidecar; never edits batch/scientific data.
Value=struct('ReviewPaths',{{}},'Restored',false);
if isempty(BatchPath),return;end
path=[char(BatchPath) '.compact-selection.json'];
switch char(Action)
    case 'load'
        if ~isfile(path),return;end
        try
            V=jsondecode(fileread(path));
            if ~strcmp(V.Schema,'boi-compact-selection-1')||~strcmp(V.AutomaticSHA256,AutomaticSHA256)||~strcmp(V.BatchSHA256,oxygenFileSHA256(BatchPath)),return;end
            reviews=cellstr(string(V.ReviewPaths));hash=cellstr(string(V.ReviewSHA256));
            for i=1:numel(reviews)
                if ~isfile(reviews{i})||~strcmp(oxygenFileSHA256(reviews{i}),hash{i}),return;end
            end
            Value.ReviewPaths=reviews;Value.Restored=true;
        catch
            % Stale/corrupt UI preferences never govern scientific membership.
        end
    case 'save'
        assert(isfile(BatchPath),'OxygenDynamics:CompactSelection','Save the batch before remembering review choices.');
        reviews=cellstr(string(ReviewPaths));hash=cell(size(reviews));
        for i=1:numel(reviews),hash{i}=oxygenFileSHA256(reviews{i});end
        V=struct('Schema','boi-compact-selection-1','BatchSHA256',oxygenFileSHA256(BatchPath), ...
            'AutomaticSHA256',char(AutomaticSHA256),'ReviewPaths',{reviews},'ReviewSHA256',{hash});
        tmp=[tempname(fileparts(path)) '.json'];c=onCleanup(@()removeTemp(tmp));
        writeBOIRunJSON(tmp,V);movefile(tmp,path,'f');Value.ReviewPaths=reviews;Value.Restored=true;
    otherwise,error('OxygenDynamics:CompactSelection','Unknown selection action.');
end
end
function removeTemp(p),if isfile(p),delete(p);end,end
