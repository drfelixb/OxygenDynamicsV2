function fig=openBOIMultichannelBatch(initialFile,defaultMode)
% Review a CSV queue. Import, edits and input checks never start detection.
setupOxygenDynamicsPath;
if nargin<2, defaultMode='dual-bli'; end
rows=boiPairQueueTable({}); busy=false; stop=false; cellIndex=[];
if nargin>=1 && strlength(string(initialFile))>0
    rows=boiPairQueueTable(importBOIMultichannelCSV(initialFile,defaultMode));
end
fig=uifigure('Name','Multichannel batch recordings','Position',[65 65 1160 640],'CloseRequestFcn',@closeWindow);
grid=uigridlayout(fig,[7 1]); grid.RowHeight={36,32,'1x',32,28,42,30};
inputs=uigridlayout(grid,[1 5]); inputs.Padding=[0 0 0 0]; inputs.ColumnWidth={125,230,145,145,'1x'};
uilabel(inputs,'Text','CSV imaging mode');
mode=uidropdown(inputs,'Items',{'Two bioluminescent channels','Oxygen plus fluorescence'}, ...
    'ItemsData',{'dual-bli','bli-fluorescence'},'Value',char(defaultMode));
mode.Tooltip='Default for CSV rows with no Mode column. Each row shows its analysis mode below.';
add=uibutton(inputs,'Text','Add CSV files…','ButtonPushedFcn',@addFiles);
save=uibutton(inputs,'Text','Save list as CSV…','ButtonPushedFcn',@saveList);
count=uilabel(inputs,'Text','','HorizontalAlignment','right');
uilabel(grid,'Text','A is oxygen. B is a second oxygen sensor or fluorescence. Scroll right to review movie paths and metadata.');
sheet=uitable(grid,'Tag','PairBatchRows','SelectionType','cell','Multiselect','off', ...
    'CellEditCallback',@editCell,'CellSelectionCallback',@pickCell);
names=rows.Properties.VariableNames;
names=[names(1:2),{'Status'},names(3:13),names(15:end)];
editable=~ismember(names,{'Status','ResultFolder','Message','SourceCSV','SourceCSVPath','SourceFolder'});
sheet.ColumnEditable=editable;
sheet.ColumnName={'Include','Recording ID','Status','Mode','A sensor','B sensor','A promoter','B promoter', ...
    'Hz','µm/pixel','A preserved TIFF','B preserved TIFF','A denoised TIFF','B denoised TIFF', ...
    'Details','Result folder','Mouse','Condition','Genotype','Treatment','Source CSV','CSV path','Source folder','A offset (counts)','B offset (counts)'};
sheet.ColumnWidth={55,115,90,135,95,95,85,85,50,70,220,220,180,180,250,240,110,110,110,110,220,220,220,100,100};
actions=uigridlayout(grid,[1 5]); actions.Padding=[0 0 0 0]; actions.ColumnWidth={135,145,155,170,'1x'};
choose=uibutton(actions,'Text','Choose TIFF for cell…','Enable','off','ButtonPushedFcn',@chooseMovie);
check=uibutton(actions,'Text','Check included rows','ButtonPushedFcn',@checkRows);
open=uibutton(actions,'Text','Open selected result','Enable','off','ButtonPushedFcn',@openResult);
combine=uibutton(actions,'Text','Combine saved results…','ButtonPushedFcn',@combineResults);
sync=uicheckbox(grid,'Text','I confirm that both movies in every included row share an aligned grid and corresponding frames.', ...
    'ValueChangedFcn',@(~,~)updateButtons());
stage=uilabel(grid,'Text','Review the channel assignments, then choose Run included recordings.','Interpreter','none', ...
    'FontWeight','bold','WordWrap','on','Tag','PairBatchStage');
footer=uigridlayout(grid,[1 3]); footer.Padding=[0 0 0 0]; footer.ColumnWidth={'1x',180,205};
destination=uilabel(footer,'Text','','Interpreter','none');
halt=uibutton(footer,'Text','Stop after this recording','Enable','off','ButtonPushedFcn',@requestStop);
go=uibutton(footer,'Text','Run included recordings…','ButtonPushedFcn',@startBatch);
refresh();
    function refresh()
        displayRows=rows;
        missing=displayRows.Status=="" & (displayRows.RawA=="" | displayRows.RawB=="");
        displayRows.Status(missing)="Choose TIFFs";
        displayRows.Mode=categorical(displayRows.Mode,["dual-bli","bli-fluorescence"]);
        sheet.Data=displayRows(:,names); updateButtons();
    end
    function updateButtons()
        count.Text=sprintf('%d of %d included',nnz(rows.Include),height(rows));
        check.Enable=~busy && any(rows.Include); save.Enable=~busy && ~isempty(rows);
        go.Enable=~busy && any(rows.Include) && sync.Value;
        valid=~isempty(cellIndex) && cellIndex(1)<=height(rows);
        choose.Enable=~busy && valid && ismember(names{cellIndex(2)},{'RawA','RawB','DenoisedA','DenoisedB'});
        open.Enable=~busy && valid && rows.Status(cellIndex(1))=="Complete" && rows.ResultFolder(cellIndex(1))~="";
    end
    function addFiles(~,~)
        [files,parent]=uigetfile('*.csv','Add paired recording lists','MultiSelect','on');
        if isequal(files,0), return; end
        try
            new=boiPairQueueTable({});
            for f=reshape(string(files),1,[])
                new=[new;boiPairQueueTable(importBOIMultichannelCSV(fullfile(parent,f),mode.Value))]; %#ok<AGROW>
            end
            rows=[rows;new]; sync.Value=false; cellIndex=[]; refresh();
            stage.Text='Review the included rows, imaging modes, channel assignments and movie paths.';
        catch err, report(err); end
    end
    function saveList(~,~)
        [f,p]=uiputfile('*.csv','Save a new paired recording list','Paired_recordings.csv');
        if isequal(f,0), return; end
        try
            target=fullfile(p,f); assert(~isfile(target),'BOIPair:Destination','Choose a new CSV filename.');
            temp=[tempname(p) '.csv']; clean=onCleanup(@()removeTemp(temp));
            writetable(rows,temp,'Encoding','UTF-8');
            java.nio.file.Files.move(java.io.File(temp).toPath(),java.io.File(target).toPath(),javaArray('java.nio.file.CopyOption',0));
            stage.Text=['Saved ' target];
        catch err, report(err); end
    end
    function pickCell(~,event)
        cellIndex=event.Indices;
        if ~isempty(cellIndex), cellIndex=cellIndex(1,:); end
        updateButtons();
    end
    function editCell(~,event)
        if busy || ~isempty(event.Error), refresh(); return; end
        i=event.Indices(1); col=event.Indices(2); key=names{col};
        v=sheet.Data.(key)(i); if strcmp(key,'Mode'), v=string(v); end
        if isstring(v) && ismissing(v), v=""; end
        change(i,key,v);
    end
    function chooseMovie(~,~)
        i=cellIndex(1); key=names{cellIndex(2)};
        [f,p]=uigetfile({'*.tif;*.tiff','TIFF movies'},['Select ' key]);
        if isequal(f,0), return; end
        change(i,key,string(fullfile(p,f)));
    end
    function change(i,key,v)
        if isequaln(rows.(key)(i),v), return; end
        if strcmp(key,'Mode')
            rows.RawB(i)=""; rows.DenoisedB(i)="";rows.CameraOffsetCountsB(i)=""; rows.SensorB(i)=""; rows.PromoterB(i)="unspecified";
            stage.Text='Channel B changed role. Select its preserved movie and enter its sensor and promoter.';
        elseif ismember(key,{'RawA','RawB'})
            rows.(['Denoised' key(end)])(i)="";
        end
        if ismember(key,{'RawA','RawB','DenoisedA','DenoisedB'}) && v~="" && ~java.io.File(char(v)).isAbsolute()
            v=string(java.io.File(fullfile(fileparts(char(rows.SourceCSV(i))),char(v))).getCanonicalPath());
        end
        rows.(key)(i)=v;
        if ~strcmp(key,'Include')
            rows.Status(i)=""; rows.ResultFolder(i)=""; rows.Message(i)="";
        end
        sync.Value=false; refresh();
    end
    function checkRows(~,~)
        setBusy(true); restore=onCleanup(@()setBusy(false));
        selected=find(rows.Include); ids=strtrim(rows.RecordingID(selected)); issues=0;
        for i=selected'
            stage.Text=char("Checking TIFF headers  ·  "+rows.RecordingID(i)); drawnow nocallbacks
            try
                assert(nnz(ids==strtrim(rows.RecordingID(i)))==1,'BOIPair:Identity','Duplicate included recording ID.');
                candidate=rows(i,:);
                assigned=[candidate.RawA candidate.RawB];
                blank=assigned=="";
                if any(blank)
                    folder=candidate.SourceFolder;
                    if folder=="" && nnz(blank)==1, folder=fileparts(assigned(~blank)); end
                    assert(folder~="" && isfolder(folder),'BOIPair:Source','Choose a TIFF for the blank channel or supply its recording folder.');
                    raw=findBOIPairedMovies(folder,assigned);
                    camera=boiPairSensorOrder(raw,[candidate.SensorA candidate.SensorB]);
                    assert(~isempty(camera) && all(raw(camera(~blank))==assigned(~blank)), ...
                        'BOIPair:Source','No unique sensor-matched TIFF pair compatible with this row in %s. Check the files or choose the TIFFs.',folder);
                    candidate.RawA=raw(camera(1)); candidate.RawB=raw(camera(2));
                end
                prepareBOIMultichannel(boiPairQueueOptions(candidate,tempname,true));
                rows.Message(i)="Input check passed";
                if any(blank)
                    rows.RawA(i)=candidate.RawA; rows.RawB(i)=candidate.RawB;
                    sync.Value=false;
                    rows.Message(i)="Input check passed. Found preserved TIFFs in "+folder;
                end
            catch err
                rows.Message(i)=string(err.message); issues=issues+1;
            end
        end
        refresh(); stage.Text=sprintf('%d checked, %d with input issues. See Details for each row.',numel(selected),issues);
    end
    function startBatch(~,~)
        if busy || ~sync.Value || ~any(rows.Include), return; end
        p=uigetdir(pwd,'Choose an output parent for the included recordings'); if isequal(p,0), return; end
        [~,suffix]=fileparts(tempname(p)); out=fullfile(p,['Multichannel_batch_' suffix]);
        setBusy(true); restore=onCleanup(@()setBusy(false)); stop=false; halt.Text='Stop after this recording'; halt.Enable='on';
        destination.Text=out; destination.Tooltip=out; selected=find(rows.Include);
        try
            [rows,book,why]=runBOIMultichannelBatch(rows,out,true,@progress,@shouldStop);
            statuses=rows.Status(selected);
            stage.Text=sprintf('%d complete, %d failed, %d queued.',nnz(statuses=="Complete"),nnz(statuses=="Failed"),nnz(statuses=="Queued"));
            if book~="", stage.Text=[stage.Text '  Combined workbook: Paired_recordings.xlsx']; end
            if why~="", uialert(fig,char(why),'Combined export failed'); end
            sync.Value=false; refresh();
        catch err, report(err); end
    end
    function progress(~,msg,current)
        if ~isequal(rows.Status,current.Status) || ~isequal(rows.Include,current.Include)
            rows=current; refresh();
        end
        stage.Text=char(msg); drawnow
    end
    function setBusy(value)
        busy=value; mode.Enable=~busy; add.Enable=~busy;
        if busy, sheet.Enable='inactive'; else, sheet.Enable='on'; end
        combine.Enable=~busy; sync.Enable=~busy; halt.Enable='off'; updateButtons();
    end
    function yes=shouldStop()
        yes=stop;
    end
    function requestStop(~,~)
        stop=true; halt.Enable='off'; halt.Text='Stop requested';
    end
    function openResult(~,~)
        try, viewBOIMultichannel(rows.ResultFolder(cellIndex(1))); catch err, report(err); end
    end
    function combineResults(~,~)
        try, exportBOIMultichannelComparison(); catch err, report(err); end
    end
    function closeWindow(~,~)
        if busy, return; end
        delete(fig);
    end
    function report(err)
        stage.Text=err.message; uialert(fig,err.message,'Multichannel batch');
    end
end
function removeTemp(file)
if isfile(file), delete(file); end
end
