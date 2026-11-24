function [rows,workbook,exportError]=runBOIMultichannelBatch(rows,output,confirmed,progress,stopRequested)
% Run checked pairs in order. Each attempt owns a new batch folder and queue CSV.
setupOxygenDynamicsPath;
if nargin<4, progress=@(~,message,~)fprintf('%s\n',message); end
if nargin<5, stopRequested=@()false; end
assert(isequal(confirmed,true),'BOIPair:Synchronization','Confirm alignment and corresponding frames for the included recordings.');
selected=find(rows.Include); assert(~isempty(selected),'BOIPair:Selection','Include at least one recording.');
ids=strtrim(rows.RecordingID(selected));
assert(all(~ismissing(ids) & ids~="") && numel(unique(ids))==numel(ids), ...
    'BOIPair:Identity','Each included row needs a distinct recording ID.');
output=char(java.io.File(char(output)).getCanonicalPath());
assert(isfolder(fileparts(output)) && ~isfolder(output) && ~isfile(output),'BOIPair:Destination','Select a new batch folder.');
paths=unique(rows{selected,{'RawA','RawB','DenoisedA','DenoisedB'}});
for path=reshape(paths(paths~="" & ~ismissing(paths)),1,[])
    if ~isfile(path), continue; end
    parent=string(fileparts(char(java.io.File(char(path)).getCanonicalPath())));
    assert(~startsWith(string(output)+filesep,parent+filesep),'BOIPair:Destination','Choose a batch destination outside the input movie folders.');
end
[ok,msg,id]=mkdir(output); assert(ok && isempty(id),'BOIPair:Destination','Could not claim batch folder: %s',msg);
rows.Status(selected)="Queued"; rows.Message(selected)=""; rows.ResultFolder(selected)="";
checkpoint();
workbook=""; exportError=""; done=strings(0,1);
for n=1:numel(selected)
    i=selected(n); name=regexprep(ids(n),'[^a-zA-Z0-9_-]','_');
    if stopRequested(), break; end
    rows.ResultFolder(i)=fullfile(string(output),compose('%04d_',i)+name);
    rows.Status(i)="Running"; checkpoint(); publish("Checking movie dimensions and timing");
    o=boiPairQueueOptions(rows(i,:),rows.ResultFolder(i),confirmed);
    try
        runBOIMultichannel(o,@publish);
        rows.Status(i)="Complete"; rows.Include(i)=false;
        done(end+1,1)=fullfile(rows.ResultFolder(i),'Multichannel.mat'); %#ok<AGROW>
    catch err
        rows.Status(i)="Failed"; rows.Message(i)=string(err.message);
    end
    checkpoint(); publish(rows.Status(i));
end
if ~isempty(done)
    progress(0,"Writing the combined workbook",rows);
    try
        target=fullfile(string(output),'Paired_recordings.xlsx');
        exportBOIMultichannelComparison(done,target); workbook=target;
    catch err
        exportError=string(err.message);
    end
end
    function publish(message)
        progress(i,compose('%d/%d',n,numel(selected))+"  ·  "+ids(n)+"  ·  "+message,rows);
    end
    function checkpoint()
        staging=[tempname(output) '.csv']; cleanup=onCleanup(@()discard(staging));
        writetable(rows,staging,'Encoding','UTF-8');
        [written,why]=movefile(staging,fullfile(output,'Queue.csv'),'f');
        assert(written,'BOIPair:Checkpoint','Could not save queue: %s',why);
    end
end
function discard(file)
if isfile(file), delete(file); end
end
