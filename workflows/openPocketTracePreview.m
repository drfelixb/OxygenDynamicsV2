function fig = openPocketTracePreview(exportFolder)
%OPENPOCKETTRACEPREVIEW Resolve label conflicts and unavailable original TIFFs.
setupOxygenDynamicsPath;
fig = uifigure('Name','Pocket traces | Automatic','Position',[100 100 1120 500]);
g = uigridlayout(fig,[4 5]);
g.RowHeight = {46,'1x',36,56};
g.ColumnWidth = {150,150,100,'1x',180};
help = uilabel(g,'Text','Checking the saved recording sources…','WordWrap','on');
help.Layout.Column = [1 5];
grid = uitable(g,'RowName',[],'ColumnEditable',false,'CellSelectionCallback',@select);
grid.Layout.Row = 2; grid.Layout.Column = [1 5];
mouse = uibutton(g,'Text','Confirm mouse ID…','ButtonPushedFcn',@identify);
locate = uibutton(g,'Text','Locate TIFF…','ButtonPushedFcn',@chooseFile);
retry = uibutton(g,'Text','Retry sources','ButtonPushedFcn',@retrySources);
run = uibutton(g,'Text','Export pocket traces','FontWeight','bold','ButtonPushedFcn',@extract);
run.Layout.Row = 3; run.Layout.Column = 5;
status = uitextarea(g,'Editable','off','Value',{'Checking original TIFFs by SHA-256…'});
status.Layout.Row = 4; status.Layout.Column = [1 5];
chosen = []; plan = []; result = "";
setBusy(true); drawnow;
try
    plan = preparePocketNearbyTissue(exportFolder,exportFolder,@showProgress);
    refresh();
catch err
    delete(fig); rethrow(err)
end

    function showProgress(message)
        if isvalid(status)
            status.Value={char(message)};
            drawnow limitrate nocallbacks
        end
    end
    function select(~,event)
        if isempty(event.Indices), chosen=[]; else, chosen=event.Indices(1,1); end
        buttons();
    end
    function buttons()
        mouse.Enable=~isempty(chosen);
        locate.Enable=~isempty(chosen);
    end
    function setBusy(busy)
        for h=[mouse locate retry run], h.Enable=~busy; end
        if busy, grid.Enable='off'; else, grid.Enable='on'; end
        if ~busy, buttons(); end
    end
    function refresh()
        r=plan.Rows;
        grid.Data=r(:,{'BatchMouse','Mouse','Condition','Group','SourceStatus','SourcePath','RecordingFolder','VerifiedRawFile','SourceSHA256'});
        grid.ColumnName={'Saved mouse','Confirmed mouse','Condition','Sensor','TIFF status','Saved source path','Recording folder','Verified TIFF','SHA-256'};
        grid.ColumnWidth={100,110,100,85,155,260,260,260,160};
        help.Text='Select a row to confirm a mouse ID or locate its original TIFF. Rows with the same SHA-256 share one movie. Each condition will be summarized separately.';
        status.Value={sprintf('%d selected rows, %d distinct movies, %d unavailable TIFFs, %d unresolved mouse identities.', ...
            height(r),numel(unique(r.SourceSHA256)),numel(unique(r.SourceSHA256(r.VerifiedRawFile==""))), ...
            numel(unique(r.SourceSHA256(r.Mouse==""))))};
        setBusy(false);
    end
    function identify(~,~)
        if isempty(chosen), return; end
        r=plan.Rows; same=r.SourceSHA256==r.SourceSHA256(chosen);
        answer=inputdlg("Saved labels: "+strjoin(unique(r.BatchMouse(same)),", ")+newline+"Confirmed mouse ID", ...
            'Confirm mouse ID',[1 60],{char(r.Mouse(chosen))});
        if isempty(answer) || strlength(strip(string(answer{1})))==0, return; end
        plan.Rows.Mouse(same)=strip(string(answer{1})); refresh();
    end
    function chooseFile(~,~)
        if isempty(chosen), return; end
        [name,path]=uigetfile({'*.tif;*.tiff','TIFF movies';'*.*','All files'},'Locate original TIFF');
        if isequal(name,0), return; end
        hash=plan.Rows.SourceSHA256(chosen); file=string(fullfile(path,name));
        setBusy(true); drawnow;
        try
            assert(strcmpi(oxygenFileSHA256(file),hash),'Selected file does not match the saved SHA-256.');
            same=plan.Rows.SourceSHA256==hash;
            plan.Rows.VerifiedRawFile(same)=file; plan.Rows.SourceStatus(same)="TIFF verified";
            refresh();
        catch err
            setBusy(false); uialert(fig,err.message,'TIFF verification');
        end
    end
    function retrySources(~,~)
        setBusy(true); drawnow;
        try
            fresh=preparePocketNearbyTissue(exportFolder,exportFolder,@showProgress);
            assert(isequal(fresh.Rows.SourceSHA256,plan.Rows.SourceSHA256),'Export selection changed. Reopen the preview.');
            for k=1:height(fresh.Rows)
                if plan.Rows.Mouse(k)~="", fresh.Rows.Mouse(k)=plan.Rows.Mouse(k); end
                file=plan.Rows.VerifiedRawFile(k);
                if fresh.Rows.VerifiedRawFile(k)=="" && isfile(file) && strcmpi(oxygenFileSHA256(file),fresh.Rows.SourceSHA256(k))
                    fresh.Rows.VerifiedRawFile(k)=file; fresh.Rows.SourceStatus(k)="TIFF verified";
                end
            end
            plan=fresh; refresh();
        catch err
            setBusy(false); uialert(fig,err.message,'Source check');
        end
    end
    function extract(~,~)
        if result~=""
            openFolder(result);
            return
        end
        r=plan.Rows; unavailable=r.VerifiedRawFile=="";
        if all(unavailable)
            uialert(fig,'Locate at least one original TIFF before exporting.','TIFFs unavailable'); return
        end
        if any(r.Mouse(~unavailable)=="")
            uialert(fig,'Select each conflicting source and confirm its mouse ID.','Mouse identity'); return
        end
        if any(unavailable)
            omitted=r(unavailable,:);
            list=strjoin(omitted.BatchMouse+" | "+omitted.Condition+" | "+omitted.SourcePath,newline);
            answer=uiconfirm(fig,"Omit these rows from this export?"+newline+list, ...
                'Confirm partial export','Options',{'Cancel','Omit listed rows'},'DefaultOption',1,'CancelOption',1);
            if ~strcmp(answer,'Omit listed rows'), return; end
        end
        setBusy(true); status.Value={'Extracting raw traces and making figures…'}; drawnow;
        try
            result=exportAutomaticPocketTraces(plan,plan.ExportFolder,table(),unique(r.SourceSHA256(unavailable)),true,@showProgress);
            status.Value={char("Completed Automatic pocket traces: "+result)};
            run.Text='Open results folder'; run.Enable='on';
        catch err
            setBusy(false); status.Value={err.message}; uialert(fig,err.message,'Pocket traces');
        end
    end
end

function openFolder(folder)
java.awt.Desktop.getDesktop().open(java.io.File(char(folder)));
end
