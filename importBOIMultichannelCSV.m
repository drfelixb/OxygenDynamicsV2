function pairs=importBOIMultichannelCSV(file,defaultMode)
% Import a paired working list or the lab's two-channel-rows-per-folder CSV.
if nargin<2, defaultMode="dual-bli"; end
setupOxygenDynamicsPath;
defaultMode=checkMode(defaultMode);
file=string(java.io.File(char(file)).getCanonicalPath());
base=fileparts(file);
opts=detectImportOptions(file,'FileType','text','Delimiter',',','VariableNamingRule','preserve');
opts=setvartype(opts,opts.VariableNames,'string');
t=readtable(file,opts);
for name=string(t.Properties.VariableNames)
    t.(name)=strtrim(fillmissing(t.(name),'constant',""));
end
has=@(name)ismember(name,string(t.Properties.VariableNames));
assert(height(t)>0,'BOIPair:CSV','The recording list is empty.');
if all(has(["RecordingID","RawA","RawB"])) && (~has("Paths") || has("SampleHz"))
    pairs=cell(height(t),1);
    need(["SensorA","SensorB","PromoterA","PromoterB","SampleHz","PixelSizeUm"]);
    for i=1:height(t)
        o=baseRow(i); o.RecordingID=t.RecordingID(i);
        o.RawFiles=[resolve(t.RawA(i),base),resolve(t.RawB(i),base)];
        o.DenoisedFiles=[resolve(value('DenoisedA',i),base),resolve(value('DenoisedB',i),base)];
        o.Sensors=[t.SensorA(i),t.SensorB(i)]; o.Promoters=[t.PromoterA(i),t.PromoterB(i)];
        o.SampleHz=str2double(t.SampleHz(i)); o.PixelSizeUm=str2double(t.PixelSizeUm(i));
        flag=lower(value('Include',i));
        assert(ismember(flag,["","0","1","true","false"]),'BOIPair:CSV','Invalid Include value on row %d.',i);
        o.Include=~ismember(flag,["0","false"]); o.Status=value('Status',i);
        o.ResultFolder=resolve(value('ResultFolder',i),base); o.Message=value('Message',i);
        if value('SourceCSV',i)~="", o.SourceCSV=value('SourceCSV',i); end
        o.SourceCSVPath=value('SourceCSVPath',i); o.SourceFolder=resolve(value('SourceFolder',i),base);
        pairs{i}=o;
    end
    return
end
need("Paths");
paths=regexprep(replace(t.Paths,"\","/"),'/+$','');
assert(all(paths~=""),'BOIPair:CSV','Each channel row needs a recording path.');
groups=unique(paths,'stable'); pairs=cell(numel(groups),1);
folderLayout=numel(groups)==height(t);
if ~folderLayout, need(["Sensor_Promoter","SampleF","Pixelsize"]); end
for i=1:numel(groups)
    idx=find(paths==groups(i));
    assert(folderLayout || numel(idx)==2,'BOIPair:CSV','Expected two channel rows for %s.',groups(i));
    o=baseRow(idx); [~,name]=fileparts(groups(i)); o.RecordingID=name;
    if o.Mouse=="", o.Mouse=name; end
    folder=resolve(groups(i),base);
    if ~isfolder(folder), folder=fullfile(base,name); end
    if strcmpi(name,'FB25047_49') && any(strcmpi(o.Mouse,{'FB25047_49','FB25049'}))
        o.RecordingID="FB25049"; o.Mouse=o.RecordingID;
        if ~isfolder(folder), folder=fullfile(base,'FB25047_2'); end
    end
    [guess,den]=findBOIPairedMovies(folder);
    [~,stems]=fileparts(guess);
    if folderLayout
        if value('RecordingID',idx)~="", o.RecordingID=value('RecordingID',idx); end
        o.Sensors=[value('SensorA',idx),value('SensorB',idx)];
        o.Promoters=[value('PromoterA',idx),value('PromoterB',idx)];
        o.Promoters(o.Promoters=="")="unspecified";
        if o.Mode=="dual-bli"
            defaults=["GeNL","Antares"];
            for c=1:2
                if o.Sensors(c)=="" && nnz(contains(stems,defaults(c),'IgnoreCase',true))==1
                    o.Sensors(c)=defaults(c);
                end
            end
        elseif o.Sensors(1)==""
            known=["GeNL","Antares"];
            seen=arrayfun(@(s)any(contains(stems,s,'IgnoreCase',true)),known);
            if nnz(seen)==1, o.Sensors(1)=known(seen); end
        end
        o.SampleHz=str2double(value('SampleF',idx)); o.PixelSizeUm=str2double(value('Pixelsize',idx));
    else
        labels=regexp(t.Sensor_Promoter(idx),'^(.+?)[-_]([^-_]+)$','tokens','once');
        assert(all(~cellfun(@isempty,labels)),'BOIPair:CSV','Expected promoter-sensor names in %s.',groups(i));
        sensors=reshape(string(cellfun(@(v)v{2},labels,'UniformOutput',false)),1,[]);
        promoters=reshape(string(cellfun(@(v)v{1},labels,'UniformOutput',false)),1,[]);
        if has("Channel") && any(t.Channel(idx)~="")
            role=upper(t.Channel(idx));
            assert(isequal(sort(role),["A";"B"]),'BOIPair:CSV','Use one Channel A and one B in %s.',groups(i));
            [~,order]=sort(role);
        elseif o.Mode=="dual-bli" && nnz(strcmpi(sensors,'GeNL'))==1 && nnz(strcmpi(sensors,'Antares'))==1
            order=[find(strcmpi(sensors,'GeNL')),find(strcmpi(sensors,'Antares'))];
        elseif o.Mode=="bli-fluorescence" && nnz(ismember(lower(sensors),["genl","antares"]))==1
            oxygen=ismember(lower(sensors),["genl","antares"]); order=[find(oxygen),find(~oxygen)];
        else
            error('BOIPair:CSV','Specify Channel A and B for %s. In fluorescence mode A is oxygen.',groups(i));
        end
        o.Sensors=sensors(order); o.Promoters=promoters(order);
        o.SampleHz=str2double(value('SampleF',idx)); o.PixelSizeUm=str2double(value('Pixelsize',idx));
        assert(all(isfinite([o.SampleHz o.PixelSizeUm])) && all([o.SampleHz o.PixelSizeUm]>0), ...
            'BOIPair:CSV','Invalid calibration in %s.',groups(i));
    end
    o.RawFiles=["",""]; o.DenoisedFiles=["",""];
    camera=boiPairSensorOrder(guess,o.Sensors);
    if ~isempty(camera)
        o.RawFiles=guess(camera); o.DenoisedFiles=den(camera);
    end
    if o.Mode=="bli-fluorescence", o.DenoisedFiles(2)=""; end
    for c=1:2
        if folderLayout
            letters='AB'; raw=value(['Raw' letters(c)],idx); detection=value(['Denoised' letters(c)],idx);
        else
            row=idx(order(c)); raw=value('RawFile',row); detection=value('DenoisedFile',row);
        end
        if raw~=""
            chosen=resolve(raw,folder);
            if chosen~=o.RawFiles(c), o.DenoisedFiles(c)=""; end
            o.RawFiles(c)=chosen;
        end
        if detection~="", o.DenoisedFiles(c)=resolve(detection,folder); end
    end
    o.SourceFolder=folder; o.SourceCSVPath=groups(i); pairs{i}=o;
end
    function need(names)
        missing=names(~has(names));
        assert(isempty(missing),'BOIPair:CSV','Missing CSV columns: %s',strjoin(missing,', '));
    end
    function v=value(key,rows)
        v=""; if ~has(string(key)), return; end
        values=unique(t.(key)(rows));
        if ~isscalar(values) && ismember(string(key),["Condition","Genotype","Group_Treatment","DrugID"]), return; end
        assert(isscalar(values),'BOIPair:CSV','Channel rows disagree on %s (CSV data rows %s).',key,mat2str(rows'));
        v=values;
    end
    function o=baseRow(rows)
        mode=value('Mode',rows); if mode=="", mode=defaultMode; end
        o=struct('SourceCSV',file,'SourceCSVPath',"",'SourceFolder',"",'Mode',checkMode(mode), ...
            'AlignedAndSynchronized',false,'Include',true,'Status',"",'ResultFolder',"",'Message',"");
        for key=["Mouse","Condition","Genotype","DrugID"]
            o.(key)=value(key,rows);
        end
        if o.DrugID=="", o.DrugID=value('Group_Treatment',rows); end
    end
end
function mode=checkMode(mode)
mode=lower(strtrim(string(mode)));
assert(isscalar(mode) && ismember(mode,["dual-bli","bli-fluorescence"]), ...
    'BOIPair:CSV','Mode must be dual-bli or bli-fluorescence.');
end
function path=resolve(path,base)
if path=="", return; end
path=replace(path,"\","/");
if ~java.io.File(char(path)).isAbsolute()
    if ~isempty(regexp(path,'^[A-Za-z]:/','once')), return; end
    path=fullfile(base,path);
end
path=string(java.io.File(char(path)).getCanonicalPath());
end
