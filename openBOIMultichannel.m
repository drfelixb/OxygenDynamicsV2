function fig=openBOIMultichannel()
% Select and run one prealigned pair, or reopen an existing multichannel result.
setupOxygenDynamicsPath;
fig=uifigure('Name','Multichannel recordings','Position',[100 100 940 660]);
grid=uigridlayout(fig,[16 4]); grid.ColumnWidth={155,'1x','1x',105};
grid.RowHeight={36,30,28,28,28,28,28,28,28,28,28,30,32,30,'1x',36};
top=uigridlayout(grid,[1 4]); top.Layout.Row=1; top.Layout.Column=[1 4]; top.Padding=[0 0 0 0];
uibutton(top,'Text','Import recording CSV','ButtonPushedFcn',@importCSV);
uibutton(top,'Text','Find prepared TIFF pair','ButtonPushedFcn',@findFolder);
uibutton(top,'Text','Open saved paired result','ButtonPushedFcn',@reopen);
uibutton(top,'Text','Combine saved recordings','ButtonPushedFcn',@combine);
label('Imaging mode',2); mode=uidropdown(grid,'Items',{'Two bioluminescent channels','Oxygen plus fluorescence'}, ...
    'ItemsData',{'dual-bli','bli-fluorescence'},'ValueChangedFcn',@switchMode); place(mode,2,2,3);
label('Recording ID',3); identifier=field(3,2,3,'');
label('Channel',4); a=uilabel(grid,'Text','A · oxygen','FontWeight','bold'); place(a,4,2,2);
b=uilabel(grid,'Text','B · oxygen','FontWeight','bold'); place(b,4,3,3);
label('Sensor',5); sensors={field(5,2,2,'GeNL'),field(5,3,3,'Antares')};
label('Promoter',6); promoters={field(6,2,2,'unspecified'),field(6,3,3,'unspecified')};
raw={movieField('A preserved TIFF',7),movieField('B preserved TIFF',8)};
den={movieField('A denoised (optional)',9),movieField('B denoised (optional)',10)};
label('Frame rate (Hz)',11); hz=field(11,2,2,''); scale=field(12,2,2,''); label('Grid size (µm/pixel)',12);
sync=uicheckbox(grid,'Text','I confirm the movies share the aligned grid and corresponding frames.'); place(sync,13,1,4);
stage=uilabel(grid,'Text','Ready to set up a recording','FontWeight','bold','FontSize',15, ...
    'Interpreter','none','WordWrap','on','Tag','PairStage'); place(stage,14,1,4);
msg=uitextarea(grid,'Editable','off','Value',{'Select two preserved movies or import a paired recording CSV.'}); place(msg,15,1,4);
go=uibutton(grid,'Text','Run selected pair…','ButtonPushedFcn',@start); place(go,16,3,4);
batch=uibutton(grid,'Text','Multichannel batch from CSV…','ButtonPushedFcn',@(~,~)openBOIMultichannelBatch('',mode.Value)); place(batch,16,1,2);
imported=struct(); 
    function place(widget,row,left,right)
        widget.Layout.Row=row;
        if left==right, widget.Layout.Column=left; else, widget.Layout.Column=[left right]; end
    end
    function label(txt,row)
        w=uilabel(grid,'Text',txt); place(w,row,1,1);
    end
    function w=field(row,left,right,value)
        w=uieditfield(grid,'text','Value',value); place(w,row,left,right);
    end
    function w=movieField(txt,row)
        label(txt,row); w=field(row,2,3,'');
        button=uibutton(grid,'Text','Choose…','ButtonPushedFcn',@choose); place(button,row,4,4);
        w.UserData=button;
        function choose(~,~)
            [file,folder]=uigetfile({'*.tif;*.tiff','TIFF movies'},txt);
            if ~isequal(file,0), w.Value=fullfile(folder,file); sync.Value=false; end
        end
        w.ValueChangedFcn=@(~,~)resetSync();
    end
    function resetSync()
        sync.Value=false;
    end
    function switchMode(~,~)
        sync.Value=false; raw{2}.Value=''; den{2}.Value='';
        if strcmp(mode.Value,'bli-fluorescence')
            b.Text='B · fluorescence'; den{2}.Value=''; den{2}.Enable='off'; den{2}.UserData.Enable='off';
            if strcmp(sensors{2}.Value,'Antares'), sensors{2}.Value='Fluorescence'; end
        else
            b.Text='B · oxygen'; den{2}.Enable='on'; den{2}.UserData.Enable='on';
            if strcmp(sensors{2}.Value,'Fluorescence'), sensors{2}.Value='Antares'; end
        end
    end
    function findFolder(~,~)
        folder=uigetdir(pwd,'Choose recording folder'); if isequal(folder,0), return; end
        [r,d]=findBOIPairedMovies(folder);
        imported=struct(); [~,identifier.Value]=fileparts(folder); sync.Value=false;
        for c=1:2, raw{c}.Value=char(r(c)); den{c}.Value=char(d(c)); end
        msg.Value={'Check the sensor and promoter for each camera. Choose files manually if the suggestions are blank.'};
    end
    function importCSV(~,~)
        [f,p]=uigetfile('*.csv','Choose paired recording list'); if isequal(f,0), return; end
        try
            list=importBOIMultichannelCSV(fullfile(p,f),mode.Value);
            items=cellfun(@(v)char(v.RecordingID+"   "+strjoin(v.Promoters+"-"+v.Sensors," / ")),list,'UniformOutput',false);
            [k,ok]=listdlg('ListString',items,'SelectionMode','single','ListSize',[550 300], ...
                'PromptString','Select one recording'); if ~ok, return; end
            o=list{k}; imported=o; mode.Value=char(o.Mode); switchMode(); identifier.Value=char(o.RecordingID);
            for c=1:2
                raw{c}.Value=char(o.RawFiles(c)); den{c}.Value=char(o.DenoisedFiles(c));
                sensors{c}.Value=char(o.Sensors(c)); promoters{c}.Value=char(o.Promoters(c));
            end
            hz.Value=num2str(o.SampleHz); scale.Value=num2str(o.PixelSizeUm);
            msg.Value={char("CSV folder: "+o.SourceCSVPath),char("Resolved folder: "+o.SourceFolder), ...
                'Verify the selected TIFFs. Blank fields require manual selection.'};
        catch err, showError(err); end
    end
    function start(~,~)
        if ~sync.Value, uialert(fig,'Confirm frame correspondence and alignment.','Recording settings'); return; end
        parent=uigetdir(pwd,'Select output parent for a NEW paired result'); if isequal(parent,0), return; end
        o=imported; o.Mode=string(mode.Value); o.RecordingID=string(identifier.Value);
        o.RawFiles=string(cellfun(@(v)v.Value,raw,'UniformOutput',false));
        o.DenoisedFiles=string(cellfun(@(v)v.Value,den,'UniformOutput',false));
        o.Sensors=string(cellfun(@(v)v.Value,sensors,'UniformOutput',false));
        o.Promoters=string(cellfun(@(v)v.Value,promoters,'UniformOutput',false));
        o.SampleHz=str2double(hz.Value); o.PixelSizeUm=str2double(scale.Value); o.AlignedAndSynchronized=sync.Value;
        [~,suffix]=fileparts(tempname(parent));
        o.OutputFolder=fullfile(parent,['Multichannel_' regexprep(char(o.RecordingID),'[^a-zA-Z0-9_-]','_') '_' suffix]);
        go.Enable='off'; restore=onCleanup(@restoreButton); %#ok<NASGU>
        msg.Value={char("Output folder: "+string(o.OutputFolder))};
        try
            updateStage('Checking movie dimensions and timing');
            runBOIMultichannel(o,@updateStage);
        catch err
            if isvalid(stage)
                stage.Text=char("Failed  ·  "+string(stage.Text)); showError(err);
            end
            return
        end
        if isvalid(fig)
            try, viewBOIMultichannel(fullfile(o.OutputFolder,'Multichannel.mat')); catch err, showError(err); end
        end
        function updateStage(value)
            if isvalid(stage)
                stage.Text=char(o.RecordingID+"  ·  "+string(value));
                drawnow nocallbacks
            end
        end
        function restoreButton()
            if isvalid(go), go.Enable='on'; end
        end
    end
    function reopen(~,~)
        [f,p]=uigetfile('*.mat','Choose Multichannel.mat'); if isequal(f,0), return; end
        try, viewBOIMultichannel(fullfile(p,f)); catch err, showError(err); end
    end
    function combine(~,~)
        try, exportBOIMultichannelComparison(); catch err, showError(err); end
    end
    function showError(err)
        msg.Value={err.message}; uialert(fig,err.message,'Multichannel recordings');
    end
end
