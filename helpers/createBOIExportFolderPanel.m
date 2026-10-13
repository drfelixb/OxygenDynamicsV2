function Panel=createBOIExportFolderPanel(Parent)
%CREATEBOIEXPORTFOLDERPANEL Keep the last completed export easy to find.
Grid=uigridlayout(Parent,[2 3]);Grid.Padding=[0 0 0 0];
Grid.RowHeight={24,'1x'};Grid.ColumnWidth={'1x',105,90};
Message=uilabel(Grid,'Text','Last completed export folder: none yet.','WordWrap','on','Interpreter','none');
Message.Layout.Row=1;Message.Layout.Column=[1 3];
Path=uitextarea(Grid,'Editable','off','Value',{'Export evidence to show its full folder path here.'});
Path.Layout.Row=2;Path.Layout.Column=1;
OpenButton=uibutton(Grid,'Text','Open folder','Enable','off','ButtonPushedFcn',@openCallback);
OpenButton.Layout.Row=2;OpenButton.Layout.Column=2;
CopyButton=uibutton(Grid,'Text','Copy path','Enable','off','ButtonPushedFcn',@copyCallback);
CopyButton.Layout.Row=2;CopyButton.Layout.Column=3;
LastFolder='';
Panel=struct('Grid',Grid,'Path',Path,'Message',Message,'OpenButton',OpenButton, ...
    'CopyButton',CopyButton,'ExportTo',@exportTo,'ChooseAndExport',@chooseAndExport, ...
    'Folder',@getFolder,'Open',@openFolder,'Copy',@copyPath);
    function Folder=getFolder()
        Folder=LastFolder;
    end
    function Receipt=exportTo(Writer,Folder)
        try
            Receipt=Writer(Folder);
            assert(isfolder(Folder),'OxygenDynamics:ExportFolderMissing','The completed export folder is missing.');
        catch err
            Message.Text='Export failed. The last completed export folder is unchanged.';
            rethrow(err);
        end
        LastFolder=char(Folder);Path.Value={LastFolder};Path.Tooltip=LastFolder;
        OpenButton.Enable='on';CopyButton.Enable='on';
        Message.Text='Last completed export folder — select the text, Open folder or Copy path.';
    end
    function Receipt=chooseAndExport(Writer,StartFolder,Prefix,varargin)
        % Optional parent lets focused checks exercise the same cancellation path.
        if isempty(varargin)
            parent=uigetdir(StartFolder,'Choose parent folder for a NEW evidence export');
        else
            parent=varargin{1};
        end
        Receipt=[];
        if isequal(parent,0)
            Message.Text='Export cancelled. The last completed export folder is unchanged.';
            return
        end
        [~,name]=fileparts(tempname(parent));
        Receipt=exportTo(Writer,fullfile(parent,[Prefix name]));
    end
    function Folder=openFolder()
        Folder=completedFolder();
        if ispc
            winopen(Folder);
        else
            executable='xdg-open';if ismac,executable='/usr/bin/open';end
            % Separate arguments preserve spaces/quotes without a shell.
            args=javaArray('java.lang.String',2);
            args(1)=java.lang.String(executable);args(2)=java.lang.String(Folder);
            builder=java.lang.ProcessBuilder(args);process=builder.start();
            code=process.waitFor();
            assert(code==0,'OxygenDynamics:OpenExportFolderFailed', ...
                'The file manager could not open the folder. Select or copy the displayed path instead.');
        end
        Message.Text='Opened the last completed export folder in your file manager.';
    end
    function Folder=copyPath()
        Folder=completedFolder();clipboard('copy',Folder);
        Message.Text='Copied the last completed export folder path.';
    end
    function Folder=completedFolder()
        assert(~isempty(LastFolder)&&isfolder(LastFolder),'OxygenDynamics:ExportFolderMissing', ...
            'No completed export folder is available. Export evidence first, or locate the retained folder.');
        Folder=LastFolder;
    end
    function openCallback(~,~)
        try,openFolder();catch err,showError(err);end
    end
    function copyCallback(~,~)
        try,copyPath();catch err,showError(err);end
    end
    function showError(err)
        Message.Text=err.message;uialert(ancestor(Grid,'figure'),err.message,'Export folder unavailable');
    end
end
