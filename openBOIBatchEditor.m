function [Fig,UI]=openBOIBatchEditor(InitialBatch)
%OPENBOIBATCHEDITOR Prepare and run explicitly confirmed recording queues.
% InitialBatch may be a batch struct, an input table or a CSV path. Opening a
% CSV never starts analysis. Run uses the reviewed queue and shared service.
setupOxygenDynamicsPath;
if nargin<1||isempty(InitialBatch)
    Batch=createBOIBatch();
elseif ischar(InitialBatch)||isstring(InitialBatch)
    Batch=readBOIBatchCSV(InitialBatch);
elseif istable(InitialBatch)
    Batch=createBOIBatch(InitialBatch);
else
    Batch=InitialBatch;
end
State=struct('Batch',Batch,'Report',table(),'Requests',{{}}, ...
    'SelectedRows',[],'VisibleMetadata',{{}},'Dirty',false,'Busy',false, ...
    'Running',false,'StopRequested',false,'QueuePlan',[],'QueueConfirmed',false,'Outcome',[], ...
    'CheckProgress',[],'StatsPlan',[],'StatsConfirmed',false,'StatsResult',[]);
checkDialog=[];
acquisition={'SampleF','Pixelsize','BOISupportProfile'};
essential={'Paths','InputStatus','AnalysisStatus','ResultCheck',acquisition{:}};
optional={'Mouse','Condition','DrugID','Genotype','Promoter','RecordingLabel', ...
    'RecordingDate','Session','Sex','AgeDays','BrainRegion','Project','Operator','Notes'};
reserved={'BatchRowID','InputStatus','AnalysisStatus','ResultCheck','ReviewStatus', ...
    'RunID','RunFolder','StartedUTC','CompletedUTC','SoftwareVersion','Stage', ...
    'ElapsedSeconds','Message','AttemptHistory'};
Fig=uifigure('Name','Batch recordings','Position',[70 70 1120 800]);
Fig.CloseRequestFcn=@closeWindow;
g=uigridlayout(Fig,[7 1]);g.Padding=[10 10 10 10];g.RowSpacing=7;
g.RowHeight={34,24,114,32,'1x',136,28};
top=uigridlayout(g,[1 8]);top.Padding=[0 0 0 0];
top.ColumnWidth={'1x',65,80,65,80,100,115,125};
titleLabel=uilabel(top,'Text','Batch recordings','FontSize',18,'FontWeight','bold');
newButton=uibutton(top,'Text','New','ButtonPushedFcn',@newCallback);
openButton=uibutton(top,'Text','Open CSV','ButtonPushedFcn',@openCallback);
saveButton=uibutton(top,'Text','Save','ButtonPushedFcn',@saveCallback);
saveAsButton=uibutton(top,'Text','Save as…','ButtonPushedFcn',@saveAsCallback);
checkButton=uibutton(top,'Text','Check rows','ButtonPushedFcn',@checkCallback);
queueButton=uibutton(top,'Text','Run selected…','ButtonPushedFcn',@queueCallback);
statsButton=uibutton(top,'Text','Stats / export…','ButtonPushedFcn',@statsTabCallback);
fileLabel=uilabel(g,'Text','','Interpreter','none','WordWrap','on');
settings=uipanel(g,'Title','Shared acquisition settings — row overrides stay editable in the table');
sg=uigridlayout(settings,[3 6]);sg.Padding=[8 5 8 5];sg.RowSpacing=4;
sg.RowHeight={23,25,20};sg.ColumnWidth={110,90,140,90,108,'1x'};
uilabel(sg,'Text','Sampling rate (Hz)');
sample=uieditfield(sg,'text','ValueChangedFcn',@sharedChanged);
uilabel(sg,'Text','Pixel size (µm/pixel)');
pixels=uieditfield(sg,'text','ValueChangedFcn',@sharedChanged);
uilabel(sg,'Text','Detection support');
support=uidropdown(sg,'Items',{'Choose explicitly','Reviewed craniotomy ROI','Automatic tissue estimate (legacy)'}, ...
    'ItemsData',{'','craniotomy-roi-1','whole-image'},'Value','', ...
    'ValueChangedFcn',@sharedChanged);
support.Tooltip=sprintf(['Automatic tissue estimate (legacy): estimates tissue from image intensity; no preset ROI is needed. Review the estimated edge visually.\n' ...
    'Detections can extend beyond the estimated tissue edge; inspect the estimate after analysis.\n' ...
    'Reviewed craniotomy ROI uses a matching source-bound reviewed tissue mask.']);
confirmation=uicheckbox(sg,'Text','I confirm these shared acquisition and tissue-support settings', ...
    'ValueChangedFcn',@sharedConfirmed);place(confirmation,2,[1 6]);
settingsHint=uilabel(sg,'Text','Blank rows inherit confirmed settings. Automatic tissue estimate needs no preset ROI; review it visually.', ...
    'WordWrap','on');place(settingsHint,3,[1 6]);
actions=uigridlayout(g,[1 8]);actions.Padding=[0 0 0 0];
actions.ColumnWidth={100,100,85,75,85,150,100,'1x'};
addButton=uibutton(actions,'Text','Add folder…','ButtonPushedFcn',@addFolderCallback);
pasteButton=uibutton(actions,'Text','Paste paths…','ButtonPushedFcn',@pasteCallback);
deleteButton=uibutton(actions,'Text','Delete rows','ButtonPushedFcn',@deleteCallback);
upButton=uibutton(actions,'Text','Move up','ButtonPushedFcn',@upCallback);
downButton=uibutton(actions,'Text','Move down','ButtonPushedFcn',@downCallback);
resetButton=uibutton(actions,'Text','Use shared for selection','ButtonPushedFcn',@resetCallback);
selectReadyButton=uibutton(actions,'Text','Select ready','ButtonPushedFcn',@selectReadyCallback);
selectionLabel=uilabel(actions,'Text','No rows selected','Interpreter','none');
rowsTable=uitable(g,'Data',cell(0,numel(essential)),'RowName','numbered', ...
    'CellSelectionCallback',@tableSelection,'CellEditCallback',@tableEdit);
rowsTable.Tooltip=sprintf(['Blank acquisition cells inherit confirmed shared settings. Choose Use shared to clear a support override.\n' ...
    'Support override: whole-image = Automatic tissue estimate (legacy); craniotomy-roi-1 = Reviewed craniotomy ROI.\n' ...
    'The automatic estimate needs no preset ROI; inspect the estimated edge after analysis.']);
tabs=uitabgroup(g);
detailsTab=uitab(tabs,'Title','Selected recording / check details');
dg=uigridlayout(detailsTab,[2 3]);dg.RowHeight={28,'1x'};
dg.ColumnWidth={155,160,'1x'};dg.Padding=[5 5 5 5];dg.RowSpacing=4;
attachButton=uibutton(dg,'Text','Attach saved run…','ButtonPushedFcn',@attachCallback);
openRunButton=uibutton(dg,'Text','Open saved run','Enable','off','ButtonPushedFcn',@openRunCallback);
openRunButton.Tooltip='Checks this recording and its saved artifacts before opening; unrelated rows are not checked.';
runHint=uilabel(dg,'Text','Attach an existing run to inspect its saved results.','WordWrap','on');
details=uitextarea(dg,'Editable','off','Value',{'Add a recording folder, enter acquisition settings, then Check rows.'});
place(details,2,[1 3]);
metadataTab=uitab(tabs,'Title','Optional / custom fields');
mg=uigridlayout(metadataTab,[3 4]);mg.Padding=[8 6 8 6];mg.RowHeight={28,28,'1x'};
mg.ColumnWidth={170,'1x',140,140};
fieldChoice=uidropdown(mg,'Items',optional,'Value','Mouse');
fieldValue=uieditfield(mg,'text','Placeholder','Value to apply; blank clears the selected cells');
applyButton=uibutton(mg,'Text','Apply to selection','ButtonPushedFcn',@applyCallback);
showFieldButton=uibutton(mg,'Text','Show / add field','ButtonPushedFcn',@showFieldCallback);
customName=uieditfield(mg,'text','Placeholder','New custom field name');place(customName,2,[1 2]);
customButton=uibutton(mg,'Text','Add custom field','ButtonPushedFcn',@customCallback);place(customButton,2,3);
hideButton=uibutton(mg,'Text','Hide selected field','ButtonPushedFcn',@hideFieldCallback);place(hideButton,2,4);
metadataHint=uilabel(mg,'Text','All labels are optional. Subject ID uses Mouse; age is in days and dates use YYYY-MM-DD. Custom text and blanks are preserved. Hiding a field keeps its data.', ...
    'WordWrap','on');place(metadataHint,3,[1 4]);
queueTab=uitab(tabs,'Title','Review queue / run');
qg=uigridlayout(queueTab,[5 4]);qg.Padding=[6 6 6 6];qg.RowSpacing=5;
qg.ColumnWidth={165,'1x',160,150};qg.RowHeight={30,30,'1x',30,32};
outputButton=uibutton(qg,'Text','Choose output parent…','ButtonPushedFcn',@outputCallback);
outputParent=uieditfield(qg,'text','Placeholder','Existing parent folder for fresh recording attempts', ...
    'ValueChangedFcn',@outputChanged);place(outputParent,1,[2 4]);
runAgain=uicheckbox(qg,'Text','Run again in new folders, including verified results','ValueChangedFcn',@queueOptionsChanged);place(runAgain,2,[1 2]);
reviewQueueButton=uibutton(qg,'Text','Review selected queue','ButtonPushedFcn',@reviewQueueCallback);place(reviewQueueButton,2,3);
chooseRowsButton=uibutton(qg,'Text','Back to recording rows','ButtonPushedFcn',@chooseRowsCallback);place(chooseRowsButton,2,4);
queueDetails=uitextarea(qg,'Editable','off','Value',{'Select ready rows, choose an output parent, then review the selected queue.', ...
    'Verified matching results are skipped unless Run again is selected. Held rows are excluded.', ...
    'Each new attempt copies its source movies. Result and temporary storage are additional.'});place(queueDetails,3,[1 4]);
queueConfirm=uicheckbox(qg,'Text','I checked the selected recordings, settings, destinations and source-copy storage', ...
    'Enable','off','ValueChangedFcn',@queueConfirmationChanged);place(queueConfirm,4,[1 4]);
runQueueButton=uibutton(qg,'Text','Run reviewed queue','Enable','off','ButtonPushedFcn',@runQueueCallback);place(runQueueButton,5,1);
stopButton=uibutton(qg,'Text','Stop after current recording','Enable','off','ButtonPushedFcn',@stopCallback);place(stopButton,5,2);
queueStatus=uilabel(qg,'Text','No reviewed queue','WordWrap','on','Interpreter','none');place(queueStatus,5,[3 4]);
statsTab=uitab(tabs,'Title','Combined stats / export');
eg=uigridlayout(statsTab,[7 4]);eg.Padding=[8 8 8 8];eg.RowHeight={30,30,'1x',30,32,45,55};
eg.ColumnWidth={155,160,165,'1x'};
statsParentButton=uibutton(eg,'Text','Choose export parent…','ButtonPushedFcn',@statsParentCallback);
statsParent=uieditfield(eg,'text','Placeholder','Existing parent for a new combined stats/export folder', ...
    'ValueChangedFcn',@statsOptionsChanged);place(statsParent,1,[2 4]);
statsScope=uidropdown(eg,'Items',{'All completed recordings','Selected recording rows'}, ...
    'ValueChangedFcn',@statsOptionsChanged);place(statsScope,2,[1 2]);
reviewStatsButton=uibutton(eg,'Text','Review combined export','ButtonPushedFcn',@reviewStatsCallback);place(reviewStatsButton,2,3);
statsSummary=uilabel(eg,'Text','Review required','WordWrap','on');place(statsSummary,2,4);
statsDetails=uitextarea(eg,'Editable','off','Value',{'Collect completed saved recordings with the existing stats/export workflow.', ...
    'Uses the exact saved sink/surge files and their original labels. No detector or new recording run.', ...
    'Keeps the existing workbook, event, grouped metric and trace formats. Stimulation remains descriptive metadata.'});place(statsDetails,3,[1 4]);
statsConfirm=uicheckbox(eg,'Text','I checked the included/excluded recordings and new export destination', ...
    'Enable','off','ValueChangedFcn',@statsConfirmationChanged);place(statsConfirm,4,[1 4]);
exportStatsButton=uibutton(eg,'Text','Run stats / export','Enable','off','ButtonPushedFcn',@exportStatsCallback);place(exportStatsButton,5,1);
openStatsButton=uibutton(eg,'Text','Open workbook','Enable','off','ButtonPushedFcn',@openStatsCallback);place(openStatsButton,5,2);
statsOutcome=uilabel(eg,'Text','No combined export completed in this window.','WordWrap','on','Interpreter','none');place(statsOutcome,5,[3 4]);
statsFolder=createBOIExportFolderPanel(eg);place(statsFolder.Grid,[6 7],[1 4]);
statsDestination=statsFolder.Path;statsDestination.Value={'The completed combined export folder will be shown here.'};
openStatsFolderButton=statsFolder.OpenButton;copyStatsPathButton=statsFolder.CopyButton;
historyTab=uitab(tabs,'Title','Attempt history');
hg=uigridlayout(historyTab,[2 3]);hg.Padding=[5 5 5 5];hg.RowHeight={28,'1x'};
hg.ColumnWidth={145,170,'1x'};
historyButton=uibutton(hg,'Text','Load selected history','ButtonPushedFcn',@historyCallback);
openAttemptButton=uibutton(hg,'Text','Open selected saved run','Enable','off','ButtonPushedFcn',@openAttemptCallback);
historyStatus=uilabel(hg,'Text','Select one recording row to view its attempts.','WordWrap','on');
historyTable=uitable(hg,'Data',cell(0,0),'CellSelectionCallback',@historySelection);place(historyTable,2,[1 3]);
HistoryRows=table();SelectedHistoryRow=[];
tabs.SelectionChangedFcn=@tabChanged;
status=uilabel(g,'Text','Prepare and check rows, then review a selected queue before starting analysis.', ...
    'Interpreter','none','WordWrap','on');
lockedControls={newButton,openButton,saveButton,saveAsButton,checkButton,queueButton, ...
    sample,pixels,support,confirmation,addButton,pasteButton,deleteButton,upButton,downButton, ...
    resetButton,selectReadyButton,rowsTable,attachButton,openRunButton,fieldChoice,fieldValue, ...
    applyButton,showFieldButton,customName,customButton,hideButton,outputButton,outputParent, ...
    runAgain,reviewQueueButton,chooseRowsButton,historyButton,openAttemptButton,historyTable, ...
    statsButton,statsParentButton,statsParent,statsScope,reviewStatsButton,statsConfirm,exportStatsButton, ...
    openStatsButton,openStatsFolderButton,copyStatsPathButton};
UI=struct('State',@getState,'GetBatch',@getBatch,'SetBatch',@setBatch, ...
    'Check',@checkRows,'Save',@saveBatch,'Open',@openBatch,'AddPaths',@addPaths, ...
    'SelectRows',@selectRows,'Edit',@editCell,'SetShared',@setShared, ...
    'AddColumn',@addColumn,'ApplyMetadata',@applyMetadata,'ResetToShared',@resetToShared, ...
    'DeleteRows',@deleteRows,'MoveRows',@moveRows,'SortRows',@sortRows, ...
    'AttachRun',@attachRun,'OpenRun',@openRun,'Table',rowsTable,'Details',details, ...
    'Status',status,'FileLabel',fileLabel,'SampleF',sample,'Pixelsize',pixels, ...
    'SupportProfile',support,'SharedConfirmed',confirmation,'CheckButton',checkButton, ...
    'OpenRunButton',openRunButton,'AttachButton',attachButton, ...
    'FieldChoice',fieldChoice,'FieldValue',fieldValue,'Tabs',tabs, ...
    'NewButton',newButton,'OpenButton',openButton,'SaveButton',saveButton, ...
    'SaveAsButton',saveAsButton,'AddButton',addButton,'PasteButton',pasteButton, ...
    'DeleteButton',deleteButton,'ResetButton',resetButton,'ApplyButton',applyButton, ...
    'SetOutputParent',@setOutputParent,'SelectReady',@selectReady, ...
    'ReviewQueue',@reviewQueue,'PrepareQueue',@reviewQueue,'ConfirmQueue',@confirmQueue, ...
    'RunQueue',@runQueue,'RequestStop',@requestStop,'StopAfterCurrent',@requestStop, ...
    'History',@getHistory,'OpenAttempt',@openAttempt,'OutputParent',outputParent, ...
    'QueueTab',queueTab,'QueueDetails',queueDetails,'QueueConfirm',queueConfirm, ...
    'RunQueueButton',runQueueButton,'StopButton',stopButton,'ReviewQueueButton',reviewQueueButton, ...
    'SelectReadyButton',selectReadyButton,'RunAgain',runAgain,'QueueStatus',queueStatus, ...
    'CheckDialog',@getCheckDialog, ...
    'HistoryTable',historyTable,'HistoryTab',historyTab, ...
    'StatsTab',statsTab,'StatsButton',statsButton,'StatsOutputParent',statsParent,'StatsScope',statsScope, ...
    'ReviewStats',@reviewStats,'ConfirmStats',@confirmStats,'RunStats',@runStatsExport, ...
    'StatsConfirm',statsConfirm,'ReviewStatsButton',reviewStatsButton,'ExportStatsButton',exportStatsButton, ...
    'StatsDetails',statsDetails,'StatsSummary',statsSummary,'StatsOutcome',statsOutcome,'StatsDestination',statsDestination, ...
    'OpenStatsButton',openStatsButton,'OpenStatsFolderButton',openStatsFolderButton,'CopyStatsPathButton',copyStatsPathButton, ...
    'StatsExportFolder',statsFolder);
if ismember('Mouse',Batch.Rows.Properties.VariableNames),State.VisibleMetadata={'Mouse'};end
if isfield(Batch,'OutputParent'),outputParent.Value=char(string(Batch.OutputParent));end
syncShared();invalidate([]);State.Dirty=false;refresh();

    function s=getState()
        s=State;
    end
    function b=getBatch()
        b=State.Batch;
    end
    function setBatch(b)
        assert(~State.Busy,'OxygenDynamics:BatchBusy','Wait for the current check.');
        if istable(b),b=createBOIBatch(b);end
        assert(isstruct(b)&&isfield(b,'Rows'),'OxygenDynamics:InvalidBatch','Supply a BOI batch or input table.');
        State.Batch=b;State.SelectedRows=[];State.Report=table();State.Requests={};
        State.VisibleMetadata={};State.Outcome=[];runAgain.Value=false;
        if ismember('Mouse',b.Rows.Properties.VariableNames),State.VisibleMetadata={'Mouse'};end
        if isfield(b,'OutputParent'),outputParent.Value=char(string(b.OutputParent));else,outputParent.Value='';end
        HistoryRows=table();SelectedHistoryRow=[];historyTable.Data=cell(0,0);
        syncShared();invalidate([]);State.Dirty=false;refresh();
    end
    function openBatch(path,duplicatePolicy)
        assertIdle();
        if nargin<2
            b=readBOIBatchCSV(path);
        else
            b=readBOIBatchCSV(path,duplicatePolicy);
        end
        setBatch(b);
        if nargin>=2&&strcmp(duplicatePolicy,'new-copies')
            State.Dirty=true;refresh();
            status.Text='Copied rows have new identities and cleared saved-run links. Check rows and save deliberately; the original CSV is unchanged.';
        else
            status.Text='CSV opened as an unchecked draft. Check rows to verify current inputs and saved results.';
        end
    end
    function [b,backup]=saveBatch(path)
        assert(~State.Busy,'OxygenDynamics:BatchBusy','Wait for the current check.');
        if nargin<1||isempty(path),path=State.Batch.FilePath;end
        assert(~isempty(path),'OxygenDynamics:BatchPathRequired','Choose a CSV filename with Save as.');
        [b,backup]=writeBOIBatchCSV(State.Batch,path);State.Batch=b;State.Dirty=false;invalidateQueue();
        refresh();status.Text=['Saved CSV: ' char(b.FilePath)];
        if ~isempty(backup),status.Text=[status.Text ' | Prior copy: ' char(backup)];end
    end
    function report=checkRows(rowIDs)
        assert(~State.Busy,'OxygenDynamics:BatchBusy','Wait for the current check.');
        if nargin<1||isempty(rowIDs),rowIDs=State.Batch.Rows.BatchRowID;end
        selected=ismember(State.Batch.Rows.BatchRowID,string(rowIDs));
        invalidateQueue();setBusy(true,false);status.Text='Checking sources, settings and saved results. No analysis is started.';
        cleanup=onCleanup(@()finishCheck());beginCheck();
        [b,report,requests]=checkBOIBatch(State.Batch,rowIDs,@checkProgress);
        State.Batch=b;
        if isempty(State.Report),State.Report=report;else,State.Report(selected,:)=report(selected,:);end
        if numel(State.Requests)~=height(State.Batch.Rows),State.Requests=cell(height(State.Batch.Rows),1);end
        State.Requests(selected)=requests(selected);State.Dirty=true;
        refresh();ready=sum(report.InputStatus(selected)=="Ready");
        status.Text=sprintf('Checked %d rows: %d ready; %d need attention. Save to keep the current status view.', ...
            nnz(selected),ready,nnz(selected)-ready);
        clear cleanup
    end
    function finishCheck()
        if ~isempty(checkDialog)&&isvalid(checkDialog),close(checkDialog);end
        checkDialog=[];
        setBusy(false,false);
    end
    function dialog=getCheckDialog()
        dialog=checkDialog;
    end
    function beginCheck()
        State.CheckProgress=[];
        checkDialog=uiprogressdlg(Fig,'Title','Checking recordings', ...
            'Message','Preparing source and saved-result checks. No analysis is running.', ...
            'Value',0,'Cancelable','off');
        drawnow;
    end
    function checkProgress(event)
        State.CheckProgress=event;
        switch event.Stage
            case 'source',stage='Checking source files and acquisition settings';
            case 'attempt-history',stage='Verifying saved attempt history';
            case 'saved-result',stage='Verifying saved result artifacts and source/settings match';
            otherwise,stage=sprintf('Checked: %s | %s',event.InputStatus,event.AnalysisStatus);
        end
        title=sprintf('Checking recording %d of %d',event.CheckIndex,event.CheckCount);
        checkDialog.Title=title;
        checkDialog.Message=sprintf('%s\n%s\nNo analysis is running. Reading large movie files can take time.',event.Label,stage);
        checkDialog.Value=(event.CheckIndex-1+event.Fraction)/event.CheckCount;
        status.Text=sprintf('%s | %s | %s. No analysis is running.',title,event.Label,stage);
        drawnow;
    end
    function addPaths(paths)
        assert(~State.Busy,'OxygenDynamics:BatchBusy','Wait for the current check.');
        if ischar(paths)||(isstring(paths)&&isscalar(paths)),paths=splitlines(string(paths));end
        paths=string(paths(:));paths=strtrim(paths);paths=paths(~ismissing(paths)&strlength(paths)>0);
        for k=1:numel(paths)
            if startsWith(paths(k),'"')&&endsWith(paths(k),'"')
                quoted=char(paths(k));paths(k)=string(quoted(2:end-1));
            end
        end
        paths=paths(strlength(paths)>0);
        if isempty(paths),return;end
        added=createBOIBatch(table(paths,'VariableNames',{'Paths'}),State.Batch.BaseFolder);
        oldNames=State.Batch.Rows.Properties.VariableNames;
        addedNames=added.Rows.Properties.VariableNames;
        for k=1:numel(addedNames)
            name=addedNames{k};if ~ismember(name,oldNames),State.Batch.Rows.(name)=repmat("",height(State.Batch.Rows),1);end
        end
        allNames=State.Batch.Rows.Properties.VariableNames;
        for k=1:numel(allNames)
            name=allNames{k};if ~ismember(name,addedNames),added.Rows.(name)=repmat("",height(added.Rows),1);end
        end
        n=height(State.Batch.Rows);State.Batch.Rows=[State.Batch.Rows;added.Rows(:,allNames)];
        State.SelectedRows=n+(1:numel(paths));invalidate([]);refresh();
        status.Text=sprintf('Added %d recording folders. Check rows after entering the acquisition settings.',numel(paths));
    end
    function selectRows(indices)
        assertIdle();invalidateQueue();
        indices=unique(double(indices(:)'),'stable');
        assert(all(isfinite(indices)&indices==fix(indices)&indices>=1&indices<=height(State.Batch.Rows)), ...
            'OxygenDynamics:BatchSelection','Select existing row numbers.');
        State.SelectedRows=indices;showDetails();
    end
    function editCell(row,name,value)
        assert(~State.Busy,'OxygenDynamics:BatchBusy','Wait for the current check.');
        name=char(string(name));assertEditable(name);
        assert(isscalar(row)&&row>=1&&row<=height(State.Batch.Rows)&&row==fix(row), ...
            'OxygenDynamics:BatchSelection','Select one existing row.');
        value=string(value);assert(isscalar(value)&&~ismissing(value), ...
            'OxygenDynamics:BatchValue','Enter a single text value; use an empty string for blank.');
        if ~ismember(name,State.Batch.Rows.Properties.VariableNames),addColumn(name);end
        State.Batch.Rows.(name)(row)=value;invalidate(row);refresh();
    end
    function setShared(shared,confirmed)
        assert(~State.Busy,'OxygenDynamics:BatchBusy','Wait for the current check.');
        if nargin<2,confirmed=false;end
        for k=1:numel(acquisition)
            name=acquisition{k};if isfield(shared,name),State.Batch.Shared.(name)=char(string(shared.(name)));end
        end
        State.Batch.SharedConfirmed=logical(confirmed);syncShared();invalidate([]);refresh();
    end
    function addColumn(name)
        assertIdle();
        name=char(strtrim(string(name)));assertEditable(name);
        assert(~isempty(name),'OxygenDynamics:BatchColumn','Enter a nonblank column name.');
        names=State.Batch.Rows.Properties.VariableNames;
        collision=find(strcmpi(names,name),1);
        assert(isempty(collision)||strcmp(names{collision},name),'OxygenDynamics:BatchColumnCollision', ...
            'The name conflicts with existing column %s. Use its exact name.',name);
        if ~ismember(name,names)
            State.Batch.Rows.(name)=repmat("",height(State.Batch.Rows),1);invalidate([]);
        end
        if ~ismember(name,essential)&&~ismember(name,State.VisibleMetadata)
            State.VisibleMetadata{end+1}=name;
        end
        refresh();
    end
    function applyMetadata(name,value,indices)
        assertIdle();
        name=char(string(name));assert(~ismember(name,[{'Paths'} acquisition]), ...
            'OxygenDynamics:BatchMetadata','Edit acquisition values per row or use shared settings.');
        if nargin<3,indices=State.SelectedRows;end
        requireSelection(indices);addColumn(name);
        for row=indices(:)',State.Batch.Rows.(name)(row)=string(value);end
        invalidate(indices);refresh();
    end
    function resetToShared(indices)
        assertIdle();
        if nargin<1,indices=State.SelectedRows;end
        requireSelection(indices);
        for k=1:numel(acquisition),State.Batch.Rows.(acquisition{k})(indices)="";end
        invalidate(indices);refresh();
        status.Text='Selected row overrides cleared. Confirm the shared settings, then Check rows.';
    end
    function deleteRows(indices)
        assertIdle();
        if nargin<1,indices=State.SelectedRows;end
        requireSelection(indices);State.Batch.Rows(indices,:)=[];State.SelectedRows=[];
        invalidate([]);refresh();
    end
    function moveRows(direction)
        assertIdle();
        requireSelection(State.SelectedRows);
        assert(isscalar(direction)&&ismember(direction,[-1 1]), ...
            'OxygenDynamics:BatchOrder','Direction must be -1 (up) or 1 (down).');
        n=height(State.Batch.Rows);order=1:n;selected=false(1,n);selected(State.SelectedRows)=true;
        if direction<0
            for k=2:n
                if selected(k)&&~selected(k-1)
                    order([k-1 k])=order([k k-1]);selected([k-1 k])=selected([k k-1]);
                end
            end
        else
            for k=n-1:-1:1
                if selected(k)&&~selected(k+1)
                    order([k k+1])=order([k+1 k]);selected([k k+1])=selected([k+1 k]);
                end
            end
        end
        reorder(order);State.SelectedRows=find(selected);refresh();
    end
    function sortRows(name,direction)
        assertIdle();
        if nargin<2,direction='ascend';end
        [~,order]=sort(State.Batch.Rows.(char(name)),direction);reorder(order);refresh();
    end
    function reorder(order)
        assertIdle();invalidateQueue();
        ids=State.Batch.Rows.BatchRowID(State.SelectedRows);
        State.Batch.Rows=State.Batch.Rows(order,:);
        if ~isempty(State.Report),State.Report=State.Report(order,:);end
        if numel(State.Requests)==numel(order),State.Requests=State.Requests(order);end
        State.SelectedRows=find(ismember(State.Batch.Rows.BatchRowID,ids))';State.Dirty=true;
    end
    function attachRun(row,path)
        assertIdle();
        requireSelection(row);assert(isscalar(row),'OxygenDynamics:BatchSelection','Attach a saved run to one selected row.');
        path=char(string(path));assert(isfolder(path)||isfile(path), ...
            'OxygenDynamics:BatchRunMissing','Choose the exact saved run folder or BOIRun.mat.');
        if isfile(path),path=fileparts(path);end
        assert(isfile(fullfile(path,'BOIRun.mat'))||isfile(fullfile(path,'RunStatus.json')), ...
            'OxygenDynamics:BatchRunMissing','The selected folder has no BOIRun.mat or RunStatus.json.');
        State.Batch.Rows.RunFolder(row)=string(path);invalidate(row);refresh();
        status.Text='Saved run linked by explicit selection. Check rows to verify its source, settings and result artifacts.';
    end
    function [runFig,runUI]=openRun()
        assertIdle();
        requireSelection(State.SelectedRows);assert(isscalar(State.SelectedRows), ...
            'OxygenDynamics:BatchSelection','Select one completed recording.');
        selectedID=State.Batch.Rows.BatchRowID(State.SelectedRows);checkRows(selectedID);
        row=find(State.Batch.Rows.BatchRowID==selectedID);
        assert(isscalar(row)&&State.Report.AnalysisStatus(row)=="Complete"&&State.Report.ResultCheck(row)=="Matches", ...
            'OxygenDynamics:BatchRunUnverified','Check this row and select a complete saved run whose inputs and artifacts match.');
        [runFig,runUI]=openBOIRecordingWorkflow();
        try,runUI.OpenRun(char(State.Batch.Rows.RunFolder(row)));
        catch err,delete(runFig);rethrow(err);end
    end
    function invalidate(indices)
        invalidateQueue();
        if isempty(indices),indices=1:height(State.Batch.Rows);end
        % Duplicate checks and report/request ordering are batch-wide. Preserve
        % exact saved-run links; old completion claims are masked until check.
        State.Report=table();State.Requests={};
        State.Batch.Rows.InputStatus(:)="Unchecked";
        State.Batch.Rows.ResultCheck(:)="Unchecked";
        if ~isempty(indices),State.Batch.Rows.Message(indices)="";end
        State.Dirty=true;status.Text='Inputs changed. Check rows to verify current readiness and saved results.';
    end
    function assertIdle()
        assert(~State.Busy,'OxygenDynamics:BatchBusy', ...
            'Wait for the current operation. During analysis, Stop after current recording preserves the running attempt.');
    end
    function setBusy(busy,running)
        State.Busy=logical(busy);State.Running=logical(running);
        for ci=1:numel(lockedControls)
            if isvalid(lockedControls{ci}),lockedControls{ci}.Enable=onoff(~busy);end
        end
        stopButton.Enable=onoff(busy&&running&&~State.StopRequested);
        queueConfirm.Enable=onoff(~busy&&~isempty(State.QueuePlan));
        runQueueButton.Enable=onoff(~busy&&State.QueueConfirmed&&~isempty(State.QueuePlan)&&State.QueuePlan.Counts.Run>0);
        if ~busy
            statsConfirm.Enable=onoff(~isempty(State.StatsPlan));
            exportStatsButton.Enable=onoff(State.StatsConfirmed&&~isempty(State.StatsPlan));
            hasStats=~isempty(State.StatsResult)&&isfile(State.StatsResult.Workbook);
            openStatsButton.Enable=onoff(hasStats);openStatsFolderButton.Enable=onoff(hasStats);copyStatsPathButton.Enable=onoff(hasStats);
            showDetails();openAttemptButton.Enable='off';
            if ~isempty(SelectedHistoryRow)&&SelectedHistoryRow<=height(HistoryRows)&& ...
                    string(HistoryRows.Status(SelectedHistoryRow))=="Complete"&&HistoryRows.Verified(SelectedHistoryRow)
                openAttemptButton.Enable='on';
            end
        end
    end
    function invalidateQueue()
        invalidateStats();
        State.QueuePlan=[];State.QueueConfirmed=false;
        queueConfirm.Value=false;queueConfirm.Enable='off';runQueueButton.Enable='off';
        queueStatus.Text='Review required';
    end
    function invalidateStats()
        State.StatsPlan=[];State.StatsConfirmed=false;
        statsConfirm.Value=false;statsConfirm.Enable='off';exportStatsButton.Enable='off';
        statsSummary.Text='Review required';
    end
    function plan=reviewStats(parent,ids)
        assertIdle();
        if nargin>=1&&~isempty(parent),statsParent.Value=char(string(parent));end
        if nargin<2
            ids=State.Batch.Rows.BatchRowID;
            if strcmp(statsScope.Value,'Selected recording rows'),ids=State.Batch.Rows.BatchRowID(State.SelectedRows);end
        end
        assert(~isempty(ids),'OxygenDynamics:BatchStatsSelection','Select recording rows, or choose All completed recordings.');
        invalidateQueue();setBusy(true,false);cleanup=onCleanup(@()finishCheck());beginCheck();
        [plan,checked]=prepareBOIBatchStats(State.Batch,statsParent.Value,ids,@checkProgress);
        State.Batch=checked;State.Report=plan.Report;State.Requests={};State.Dirty=true;
        State.StatsPlan=plan;refresh();
        lines={sprintf('%d verified completed recordings included; %d excluded.',plan.Counts.Included,plan.Counts.Excluded), ...
            'Uses the existing stats exporter and its workbook/event/metric/trace formats.', ...
            'Labels come from each saved run. Current optional metadata is retained in BatchSourceRows.csv.', ...
            'Stimulation remains metadata; no behaviour/protocol reconstruction. No detection is run.', ...
            ['New combined output: ' plan.OutputFolder], '', 'Included:'};
        for si=1:height(plan.Included)
            r=plan.Included(si,:);lines{end+1}=sprintf('%s | %s | %s | %s',r.Mouse,r.Condition,r.RunFolder,r.MetadataStatus); %#ok<AGROW>
        end
        lines{end+1}='';lines{end+1}='Excluded:';
        for si=1:height(plan.Excluded)
            r=plan.Excluded(si,:);lines{end+1}=sprintf('%s | %s',r.Mouse,r.Reason); %#ok<AGROW>
        end
        statsDetails.Value=lines;
        statsSummary.Text=sprintf('%d included | %d excluded',plan.Counts.Included,plan.Counts.Excluded);
        tabs.SelectedTab=statsTab;tabChanged([],[]);
        status.Text='Review included/excluded saved recordings and the destination, then confirm combined stats/export.';
        clear cleanup
    end
    function confirmStats(value)
        assertIdle();assert(~isempty(State.StatsPlan),'OxygenDynamics:BatchStatsNotReviewed','Review combined export first.');
        assert(islogical(value)&&isscalar(value),'OxygenDynamics:BatchStatsConfirmation','Confirm with a single logical value.');
        State.StatsConfirmed=value;statsConfirm.Value=value;exportStatsButton.Enable=onoff(value);
    end
    function result=runStatsExport(executor)
        assertIdle();assert(State.StatsConfirmed&&~isempty(State.StatsPlan), ...
            'OxygenDynamics:BatchStatsNotConfirmed','Review and confirm the combined export first.');
        setBusy(true,false);cleanup=onCleanup(@()finishStats());
        checkDialog=uiprogressdlg(Fig,'Title','Combined stats / export','Message','Rechecking reviewed saved recordings. No detection is running.', ...
            'Value',0,'Cancelable','off');drawnow;
        if nargin<1,executor=[];end
        result=statsFolder.ExportTo(@(~)runBOIBatchStats(State.Batch,State.StatsPlan,@statsProgress,executor),State.StatsPlan.OutputFolder);
        State.StatsResult=result;
        statsOutcome.Text=sprintf('Completed combined export: %d recordings. Existing formats and calculations retained.',height(result.Included));
        status.Text='Combined stats/export completed. Open the workbook or export folder for postprocessing.';
        clear cleanup
    end
    function finishStats()
        invalidateStats();finishCheck();
    end
    function statsProgress(event)
        State.CheckProgress=event;
        checkDialog.Title=sprintf('Combined stats / export — %d recordings',event.Count);
        switch event.Stage
            case 'verifying',message=sprintf('Verifying saved recording %d of %d: %s',event.Index,event.Count,event.Mouse);value=0;
            case 'loading',message=sprintf('Loading saved recording %d of %d: %s',event.Index,event.Count,event.Mouse);value=.1+.6*(event.Index-1)/max(1,event.Count);
            case 'combining',message='Combining saved measurements using the existing stats workflow';value=.75;
            case 'exporting',message='Writing the existing workbook, event tables, metrics and trace exports';value=.85;
            otherwise,message='Checking the completed combined export';value=.95;
        end
        checkDialog.Message=[message newline 'No detector or new recording analysis is running.'];
        checkDialog.Value=value;status.Text=message;drawnow;
    end
    function statsTabCallback(~,~)
        tabs.SelectedTab=statsTab;tabChanged([],[]);
    end
    function statsParentCallback(~,~)
        parent=uigetdir(pwd,'Choose an existing parent for a fresh combined stats/export folder');
        if isequal(parent,0),return;end
        statsParent.Value=parent;invalidateStats();
    end
    function statsOptionsChanged(~,~),invalidateStats();end
    function reviewStatsCallback(~,~),guarded(@()reviewStats());end
    function statsConfirmationChanged(~,~),guarded(@()confirmStats(logical(statsConfirm.Value)));end
    function exportStatsCallback(~,~),guarded(@()runStatsExport());end
    function openStatsCallback(~,~)
        assertIdle();if ~isempty(State.StatsResult),open(State.StatsResult.Workbook);end
    end
    function setOutputParent(path)
        assertIdle();outputParent.Value=char(string(path));State.Batch.OutputParent=outputParent.Value;
        invalidateQueue();
    end
    function indices=selectReady()
        assertIdle();
        if isempty(State.Report)||any(State.Report.InputStatus=="Unchecked"),checkRows();end
        indices=find(State.Report.InputStatus=="Ready")';selectRows(indices);
        status.Text=sprintf('%d ready rows selected; %d excluded. Review the queue to see verified skips and held rows.', ...
            numel(indices),height(State.Batch.Rows)-numel(indices));
    end
    function plan=reviewQueue(parent,selectedIDs,retry)
        assertIdle();
        if nargin>=1&&~isempty(parent),setOutputParent(parent);end
        if nargin<2,selectedIDs=State.Batch.Rows.BatchRowID(State.SelectedRows);end
        if nargin<3,retry=runAgain.Value;else,runAgain.Value=logical(retry);end
        assert(~isempty(selectedIDs),'OxygenDynamics:BatchSelection','Select recording rows before reviewing the queue.');
        assert(~isempty(State.Batch.FilePath),'OxygenDynamics:BatchPathRequired','Save the batch CSV before reviewing the execution queue.');
        if State.Dirty,saveBatch(State.Batch.FilePath);end
        invalidateQueue();setBusy(true,false);cleanup=onCleanup(@()finishCheck());
        status.Text='Reviewing selected sources, settings and destinations. Analysis has not started.';beginCheck();
        [plan,checked]=prepareBOIBatchQueue(State.Batch,outputParent.Value,string(selectedIDs),logical(retry),@checkProgress);
        State.Batch=checked;State.Report=plan.Report;State.Requests={};
        State.QueuePlan=plan;State.QueueConfirmed=false;State.Dirty=true;refresh();
        queueDetails.Value=formatQueue(plan);queueStatus.Text=sprintf('%d to run | %d skipped | %d excluded', ...
            plan.Counts.Run,plan.Counts.Skipped,plan.Counts.Excluded);
        tabs.SelectedTab=queueTab;tabChanged([],[]);
        status.Text='Review the queue, then confirm its recordings, settings, destinations and storage before Run.';
        clear cleanup
    end
    function confirmQueue(value)
        assertIdle();assert(~isempty(State.QueuePlan),'OxygenDynamics:BatchQueueNotReviewed','Review the current selected queue first.');
        assert(islogical(value)&&isscalar(value),'OxygenDynamics:BatchQueueConfirmation','Confirm with a single logical value.');
        State.QueueConfirmed=value;queueConfirm.Value=value;
        runQueueButton.Enable=onoff(value&&State.QueuePlan.Counts.Run>0);
    end
    function outcome=runQueue(executor)
        assertIdle();assert(State.QueueConfirmed&&~isempty(State.QueuePlan), ...
            'OxygenDynamics:BatchQueueNotConfirmed','Review and confirm the selected queue before starting analysis.');
        assert(State.QueuePlan.Counts.Run>0,'OxygenDynamics:BatchQueueEmpty','No selected rows need a new analysis attempt.');
        if nargin>=1,assert(isempty(executor)||isa(executor,'function_handle'),'OxygenDynamics:BatchExecutor','Supply a test executor function handle.');end
        State.StopRequested=false;State.Outcome=[];setBusy(true,true);
        cleanup=onCleanup(@()finishQueue());tabs.SelectedTab=queueTab;tabChanged([],[]);
        status.Text='Starting the confirmed queue. Stop after current recording does not cancel the current calculation.';drawnow;
        try
            if nargin<1||isempty(executor)
                [b,outcome]=runBOIBatchQueue(State.Batch,State.QueuePlan,@queueProgress,@shouldStop);
            else
                [b,outcome]=runBOIBatchQueue(State.Batch,State.QueuePlan,@queueProgress,@shouldStop,executor);
            end
            State.Batch=b;State.Outcome=outcome;State.Dirty=false;State.Report=reportFromBatch(b);
            refresh();queueStatus.Text=char(string(outcome.Status));
            lines={['Queue outcome: ' char(string(outcome.Status))],char(string(outcome.Message)), ...
                ['Queue records: ' char(string(outcome.QueueFolder))], ...
                sprintf('Completed: %d | Pending: %d',numel(outcome.CompletedRowIDs),numel(outcome.PendingRowIDs))};
            if strlength(string(outcome.RecoveryCSV))>0
                lines{end+1}=['Recovered CSV: ' char(string(outcome.RecoveryCSV))];
                lines{end+1}='Open the recovered CSV to review saved outcomes and reconcile edits before preparing another queue. The original working CSV is preserved.';
            end
            queueDetails.Value=[lines(:);{''};cellstr(string(queueDetails.Value(:)))];
            status.Text=sprintf('Queue %s. %d completed; %d pending. %s',outcome.Status, ...
                numel(outcome.CompletedRowIDs),numel(outcome.PendingRowIDs),outcome.Message);
        catch err
            status.Text=['Queue stopped before further dispatch: ' err.message];
            queueDetails.Value=[{status.Text};cellstr(string(queueDetails.Value(:)))];rethrow(err);
        end
    end
    function finishQueue()
        State.QueueConfirmed=false;State.QueuePlan=[];queueConfirm.Value=false;
        setBusy(false,false);
    end
    function queueProgress(b,event)
        State.Batch=b;State.Report=reportFromBatch(b);State.Requests={};State.Dirty=false;refresh();
        % Refresh updates row details; controls remain locked throughout drawnow.
        setBusy(true,true);
        queueStatus.Text=sprintf('%d / %d | %s',event.Index,event.Count,event.Stage);
        status.Text=sprintf('Recording %d of %d | %s | %s',event.Index,event.Count,event.Stage,event.Message);
        progressLine=sprintf('%s | row %s | %s | %s',event.Status,event.RowID,event.Stage,event.Message);
        queueDetails.Value=[{progressLine};cellstr(string(queueDetails.Value(:)))];drawnow;
    end
    function stop=shouldStop()
        drawnow;stop=State.StopRequested;
    end
    function requestStop()
        assert(State.Busy&&State.Running,'OxygenDynamics:BatchNotRunning','No recording queue is running.');
        State.StopRequested=true;stopButton.Enable='off';
        status.Text='Stop requested. The current recording will finish; pending recordings will remain queued.';
        queueStatus.Text='Stopping after current recording';
    end
    function report=reportFromBatch(b)
        r=b.Rows;resolved=resolveBOIBatch(b);
        report=table(r.BatchRowID,resolved.Paths,r.InputStatus,r.AnalysisStatus,r.ResultCheck,r.Message, ...
            repmat("Not checked",height(r),1),'VariableNames',{'BatchRowID','ResolvedPath','InputStatus', ...
            'AnalysisStatus','ResultCheck','Message','MetadataStatus'});
    end
    function lines=formatQueue(plan)
        c=plan.Counts;
        lines={sprintf('SELECTED %d of %d | RUN %d | VERIFIED SKIP %d | EXCLUDED %d | NOT SELECTED %d', ...
            c.Selected,c.Total,c.Run,c.Skipped,c.Excluded,c.NotSelected), ...
            sprintf('%d held or not ready across the batch are excluded from dispatch.',sum(plan.Report.InputStatus~="Ready")), ...
            ['Output parent: ' char(string(plan.OutputParent))], ...
            sprintf('Source movies copied for this queue: %.3f GiB (%.0f bytes).',plan.SourceCopyBytes/1024^3,plan.SourceCopyBytes), ...
            'Result files and temporary working space are additional; their storage and peak memory are unmeasured.', ...
            'One recording runs at a time. Stop after current recording finishes that attempt; mid-recording cancellation/resume is unavailable.', ...
            ['Queue records: ' char(string(plan.QueueFolder))],''};
        for qi=1:numel(plan.RunRowIDs)
            id=plan.RunRowIDs(qi);row=find(State.Batch.Rows.BatchRowID==id);request=plan.Requests{qi};o=request.Options;
            lines{end+1}=sprintf('RUN %d | %s | row %s',qi,rowLabel(row),id); %#ok<AGROW>
            lines{end+1}=['Source: ' char(o.RecordingFolder)]; %#ok<AGROW>
            lines{end+1}=sprintf('%.9g Hz | %.9g µm/pixel | %s',o.SampleHz,o.PixelSizeUm,o.SupportProfile); %#ok<AGROW>
            lines{end+1}=['Fresh destination: ' char(o.OutputFolder)]; %#ok<AGROW>
        end
        groups={plan.SkippedRowIDs,'VERIFIED SKIP';plan.ExcludedRowIDs,'EXCLUDED';plan.NotSelectedRowIDs,'NOT SELECTED'};
        for gi=1:size(groups,1)
            ids=groups{gi,1};
            for id=ids(:)'
                row=find(State.Batch.Rows.BatchRowID==id);line=sprintf('%s | %s | row %s',groups{gi,2},rowLabel(row),id);
                if ~isempty(row)&&strlength(plan.Report.Message(row))>0,line=[line ' | ' char(plan.Report.Message(row))];end
                lines{end+1}=line; %#ok<AGROW>
            end
        end
        lines=lines(:);
    end
    function label=rowLabel(row)
        label='Unknown row';if ~isscalar(row),return;end
        label=char(State.Batch.Rows.Paths(row));
        if ismember('Mouse',State.Batch.Rows.Properties.VariableNames)&&strlength(State.Batch.Rows.Mouse(row))>0
            label=[char(State.Batch.Rows.Mouse(row)) ' | ' label];
        end
    end
    function history=getHistory(row)
        assertIdle();if nargin<1,row=State.SelectedRows;end
        requireSelection(row);assert(isscalar(row),'OxygenDynamics:BatchSelection','Select one recording row for attempt history.');
        history=loadBOIBatchHistory(State.Batch,State.Batch.Rows.BatchRowID(row));
        HistoryRows=history;SelectedHistoryRow=[];historyTable.Data=history;
        historyTable.ColumnName=history.Properties.VariableNames;openAttemptButton.Enable='off';
        historyStatus.Text=sprintf('%d recorded attempts for %s',height(history),rowLabel(row));
    end
    function [runFig,runUI]=openAttempt(path)
        assertIdle();run=loadBOIRecordingRun(path);[runFig,runUI]=openBOIRecordingWorkflow();
        try,runUI.OpenRun(run.ManifestPath);catch err,delete(runFig);rethrow(err);end
    end
    function assertEditable(name)
        assert(~any(strcmpi(name,reserved))&&~startsWith(lower(string(name)),"boibatch"), ...
            'OxygenDynamics:BatchOwnedColumn','%s is maintained by the software and cannot be edited as metadata.',name);
        canonical=[{'Paths'} acquisition optional {'PostureFile','PupilFile','PuffsFile'}];
        match=find(strcmpi(name,canonical),1);
        assert(isempty(match)||strcmp(name,canonical{match}), ...
            'OxygenDynamics:BatchColumnCollision','Use the exact spelling of the reserved field %s.',name);
    end
    function requireSelection(indices)
        assert(~isempty(indices)&&all(isfinite(indices)&indices==fix(indices)&indices>=1&indices<=height(State.Batch.Rows)), ...
            'OxygenDynamics:BatchSelection','Select at least one existing row.');
    end
    function syncShared()
        sample.Value=char(string(State.Batch.Shared.SampleF));pixels.Value=char(string(State.Batch.Shared.Pixelsize));
        p=char(string(State.Batch.Shared.BOISupportProfile));
        if ismember(p,support.ItemsData),support.Value=p;else,support.Value='';end
        confirmation.Value=logical(State.Batch.SharedConfirmed);
    end
    function refresh()
        names=State.Batch.Rows.Properties.VariableNames;
        State.VisibleMetadata=State.VisibleMetadata(ismember(State.VisibleMetadata,names));
        columns=displayColumns();data=State.Batch.Rows(:,columns);
        data.BOISupportProfile(strlength(data.BOISupportProfile)==0)="Use shared";
        % Editable CSV completion cells are never accepted as verification.
        unverified=true(height(State.Batch.Rows),1);
        if ~isempty(State.Report),unverified=State.Report.AnalysisStatus=="Unchecked";end
        linked=strlength(State.Batch.Rows.RunFolder)>0;
        data.AnalysisStatus(linked&unverified)="Check saved run";
        data.AnalysisStatus(~linked&unverified)="Not analyzed";
        rowsTable.Data=cellstrTable(data);rowsTable.ColumnName=columnLabels(columns);
        rowsTable.ColumnEditable=~ismember(columns,reserved);
        formats=repmat({'char'},1,numel(columns));
        supportChoices={'Use shared','whole-image','craniotomy-roi-1'};
        % Keep invalid imported values visible for correction; never replace
        % their underlying text with a valid scientific choice.
        imported=cellstr(unique(data.BOISupportProfile,'stable'))';
        formats{strcmp(columns,'BOISupportProfile')}=unique([supportChoices imported],'stable');
        rowsTable.ColumnFormat=formats;
        widths=repmat({140},1,numel(columns));
        baseWidths={270,110,115,145,135,155,180};
        for wi=1:numel(essential),widths{strcmp(columns,essential{wi})}=baseWidths{wi};end
        rowsTable.ColumnWidth=widths;
        choices=unique([optional metadataNames(names)],'stable');previous=fieldChoice.Value;
        fieldChoice.Items=choices;
        if ismember(previous,choices),fieldChoice.Value=previous;else,fieldChoice.Value=choices{1};end
        file=char(string(State.Batch.FilePath));
        if isempty(file),caption='New batch (not saved)';else,[~,stem,extension]=fileparts(file);caption=['CSV: ' stem extension];end
        if State.Dirty,caption=['Unsaved changes | ' caption];end
        fileLabel.Text=caption;fileLabel.Tooltip=file;
        State.SelectedRows=State.SelectedRows(State.SelectedRows<=height(State.Batch.Rows));showDetails();
    end
    function showDetails()
        selected=State.SelectedRows;n=numel(selected);
        selectionLabel.Text=sprintf('%d of %d selected',n,height(State.Batch.Rows));
        openRunButton.Enable='off';attachButton.Enable=onoff(n==1&&~State.Busy);
        runHint.Text='Attach an existing run to inspect its saved results.';
        if n==0
            details.Value={'Select table cells to select their recording rows. Use Shift/Cmd/Ctrl to select more than one.', ...
                'Enter only a recording folder per row; use shared acquisition settings or row overrides.', ...
                'Automatic tissue estimate (legacy) uses image intensity and needs no preset ROI; review the estimated tissue edge visually.', ...
                'Detections can extend beyond the estimated tissue edge; inspect the estimate after analysis.', ...
                'Shared settings need explicit confirmation. Check rows verifies sources and linked results.', ...
                'Select ready rows, choose an output parent and review the queue before confirming Run.'};return;
        end
        row=selected(1);b=State.Batch;
        if n==1&&strlength(strtrim(b.Rows.RunFolder(row)))>0
            openRunButton.Enable=onoff(~State.Busy);
            runHint.Text='Opening checks this recording and its saved result; unrelated rows are not checked.';
        end
        lines={sprintf('Row %d | stable row ID: %s',row,char(b.Rows.BatchRowID(row))), ...
            ['Recording folder as entered: ' char(b.Rows.Paths(row))]};
        if ismember('Mouse',b.Rows.Properties.VariableNames)&&strlength(strtrim(b.Rows.Mouse(row)))>0
            lines=[{['Mouse: ' char(b.Rows.Mouse(row))]} lines];
        end
        if n>1,lines{end+1}=sprintf('%d rows selected. Details below describe the first selected row; metadata actions apply to every selected row.',n);end
        try
            [resolved,origins]=resolveBOIBatch(b);
            if ismember('Paths',resolved.Properties.VariableNames),lines{end+1}=['Resolved source: ' char(resolved.Paths(row))];end
            for k=1:numel(acquisition)
                name=acquisition{k};value=char(string(resolved.(name)(row)));
                if isempty(value),value='missing';end
                lines{end+1}=sprintf('%s: %s [%s]',displayName(name),value,char(origins.(name)(row))); %#ok<AGROW>
            end
        catch err,lines{end+1}=['Settings need attention: ' err.message];end
        if isempty(State.Report)||State.Report.InputStatus(row)=="Unchecked"
            lines{end+1}='Unchecked: Check rows verifies the batch. Open saved run verifies only this recording before opening.';
        else
            r=State.Report;
            lines{end+1}=sprintf('Input: %s | Analysis: %s | Result check: %s',r.InputStatus(row),r.AnalysisStatus(row),r.ResultCheck(row));
            if ismember('ResolvedPath',r.Properties.VariableNames),lines{end+1}=['Checked source: ' char(r.ResolvedPath(row))];end
            if ismember('MetadataStatus',r.Properties.VariableNames)&&strlength(r.MetadataStatus(row))>0
                lines{end+1}=['Metadata: ' char(r.MetadataStatus(row))];
            end
            if strlength(r.Message(row))>0,lines{end+1}=char(r.Message(row));end
            if numel(State.Requests)>=row&&~isempty(State.Requests{row})
                request=State.Requests{row};review=request.InputReview;
                lines{end+1}=sprintf('Source image series: %d frames | source SHA-256: %s',review.Files.RawTiffInfo.Frames,review.RawSHA256);
                lines{end+1}=['Tissue support check: ' strrep(review.TissueStatus,'_',' ')];
                lines{end+1}=['Sampling evidence: ' char(string(review.Acquisition.SamplingRateEvidence))];
                lines{end+1}=['Pixel calibration evidence: ' char(string(review.Acquisition.PixelSizeEvidence))];
                for qi=1:height(review.QC)
                    lines{end+1}=sprintf('Input %s: %s Action: %s', ...
                        review.QC.Disposition(qi),review.QC.Message(qi),review.QC.Action(qi)); %#ok<AGROW>
                end
            end
        end
        if strlength(b.Rows.RunFolder(row))>0,lines{end+1}=['Exact linked run folder: ' char(b.Rows.RunFolder(row))];end
        lines{end+1}=['Scientist review: ' char(b.Rows.ReviewStatus(row))];
        lines{end+1}='Support override choices: Use shared (blank in CSV) = confirmed shared setting; whole-image = Automatic tissue estimate (legacy); craniotomy-roi-1 = Reviewed craniotomy ROI.';
        lines{end+1}='Automatic tissue estimate (legacy) uses image intensity and needs no preset ROI; review the estimated tissue edge visually.';
        lines{end+1}='Detections can extend beyond the estimated tissue edge; inspect the estimate after analysis.';
        lines{end+1}='Automatic completion and scientist review are separate. A queue starts only after its settings and destinations are confirmed.';
        details.Value=lines;
    end
    function labels=columnLabels(columns)
        labels=cellfun(@displayName,columns,'UniformOutput',false);
    end
    function columns=displayColumns()
        metadata=State.VisibleMetadata;columns=essential;
        if ismember('Mouse',metadata)
            columns=[{'Mouse'} columns];metadata(strcmp(metadata,'Mouse'))=[];
        end
        columns=[columns metadata];
    end
    function label=displayName(name)
        switch name
            case 'Paths',label='Recording folder';
            case 'InputStatus',label='Input readiness';
            case 'AnalysisStatus',label='Analysis status';
            case 'ResultCheck',label='Saved result check';
            case 'SampleF',label='Rate override (Hz)';
            case 'Pixelsize',label='Pixel override (µm/pixel)';
            case 'BOISupportProfile',label='Support override';
            case 'Mouse',label='Subject ID (Mouse)';
            case 'AgeDays',label='Age (days)';
            case 'RecordingDate',label='Recording date (YYYY-MM-DD)';
            otherwise,label=name;
        end
    end
    function names=metadataNames(names)
        names=names(~ismember(names,[{'Paths'} acquisition reserved]));
        names=names(~startsWith(lower(string(names)),"boibatch"));
    end
    function cells=cellstrTable(t)
        cells=cell(height(t),width(t));
        for k=1:width(t),cells(:,k)=cellstr(t.(t.Properties.VariableNames{k}));end
    end
    function sharedChanged(~,~)
        shared=struct('SampleF',sample.Value,'Pixelsize',pixels.Value,'BOISupportProfile',support.Value);
        setShared(shared,false);
    end
    function sharedConfirmed(~,~)
        setShared(struct('SampleF',sample.Value,'Pixelsize',pixels.Value,'BOISupportProfile',support.Value),confirmation.Value);
    end
    function tableSelection(~,event)
        if isempty(event.Indices),selectRows([]);else,selectRows(unique(event.Indices(:,1),'stable'));end
    end
    function tableEdit(~,event)
        columns=displayColumns();
        name=columns{event.Indices(2)};value=event.NewData;
        if strcmp(name,'BOISupportProfile')&&strcmp(string(value),"Use shared"),value='';end
        try,editCell(event.Indices(1),name,value);
        catch err,refresh();showError(err);end
    end
    function newCallback(~,~)
        if ~mayDiscard(),return;end
        setBatch(createBOIBatch());status.Text='New batch. Add folders and enter acquisition settings.';
    end
    function openCallback(~,~)
        if ~mayDiscard(),return;end
        [name,path]=uigetfile('*.csv','Open batch CSV');if isequal(name,0),return;end
        selectedPath=fullfile(path,name);
        try
            openBatch(selectedPath);
        catch err
            if strcmp(err.identifier,'OxygenDynamics:BatchDuplicateRowID')
                choice=uiconfirm(Fig,[ ...
                    'Repeated BatchRowID values usually mean rows were copied. Keep the first identity and create new identities for its copies? ' ...
                    'Saved-run links and outcomes for copied rows will be cleared. Recording paths and metadata will be preserved. ' ...
                    'The original CSV is unchanged until you save.'], ...
                    'Create new identities for copied rows?', ...
                    'Options',{'Create new identities','Cancel'},'DefaultOption',2,'CancelOption',2);
                if strcmp(choice,'Create new identities'),guarded(@()openBatch(selectedPath,'new-copies'));end
            else
                showError(err);
            end
        end
    end
    function saveCallback(~,~)
        if isempty(State.Batch.FilePath),saveAsCallback([],[]);else,guarded(@()saveBatch(State.Batch.FilePath));end
    end
    function saveAsCallback(~,~)
        chooseSave();
    end
    function saved=chooseSave()
        saved=false;initial='BOI_batch.csv';if ~isempty(State.Batch.FilePath),initial=char(State.Batch.FilePath);end
        [name,path]=uiputfile('*.csv','Save batch CSV',initial);if isequal(name,0),return;end
        try,saveBatch(fullfile(path,name));saved=true;catch err,showError(err);end
    end
    function checkCallback(~,~)
        guarded(@checkRows);
    end
    function addFolderCallback(~,~)
        path=uigetdir(State.Batch.BaseFolder,'Choose a recording folder');
        if ~isequal(path,0),guarded(@()addPaths(path));end
    end
    function pasteCallback(~,~)
        dialog=uifigure('Name','Add recording folders','Position',[140 140 630 380],'WindowStyle','modal');
        pg=uigridlayout(dialog,[3 2]);pg.RowHeight={36,'1x',32};pg.ColumnWidth={'1x',110};
        hint=uilabel(pg,'Text','Paste one recording folder per line. Relative paths use the CSV folder.', 'WordWrap','on');place(hint,1,[1 2]);
        input=uitextarea(pg);place(input,2,[1 2]);
        uibutton(pg,'Text','Cancel','ButtonPushedFcn',@(~,~)delete(dialog));
        uibutton(pg,'Text','Add paths','ButtonPushedFcn',@pasteDone);
        function pasteDone(~,~)
            try,addPaths(string(input.Value));delete(dialog);catch err,showError(err);end
        end
    end
    function deleteCallback(~,~)
        guarded(@()deleteRows(State.SelectedRows));
    end
    function upCallback(~,~)
        guarded(@()moveRows(-1));
    end
    function downCallback(~,~)
        guarded(@()moveRows(1));
    end
    function resetCallback(~,~)
        guarded(@()resetToShared(State.SelectedRows));
    end
    function applyCallback(~,~)
        guarded(@()applyMetadata(fieldChoice.Value,fieldValue.Value,State.SelectedRows));
    end
    function showFieldCallback(~,~)
        guarded(@()addColumn(fieldChoice.Value));
    end
    function customCallback(~,~)
        guarded(@()addColumn(customName.Value));
    end
    function hideFieldCallback(~,~)
        assertIdle();
        State.VisibleMetadata(strcmp(State.VisibleMetadata,fieldChoice.Value))=[];refresh();
    end
    function attachCallback(~,~)
        if numel(State.SelectedRows)~=1,showError(MException('OxygenDynamics:BatchSelection','Select one recording row.'));return;end
        path=uigetdir(State.Batch.BaseFolder,'Choose the exact saved run folder');
        if ~isequal(path,0),guarded(@()attachRun(State.SelectedRows,path));end
    end
    function openRunCallback(~,~)
        guarded(@openRun);
    end
    function queueCallback(~,~)
        assertIdle();tabs.SelectedTab=queueTab;tabChanged([],[]);
    end
    function selectReadyCallback(~,~)
        guarded(@selectReady);
    end
    function outputCallback(~,~)
        assertIdle();initial=outputParent.Value;if isempty(initial),initial=State.Batch.BaseFolder;end
        path=uigetdir(initial,'Choose the existing parent for new recording attempts');
        if ~isequal(path,0),guarded(@()setOutputParent(path));end
    end
    function outputChanged(~,~)
        guarded(@()setOutputParent(outputParent.Value));
    end
    function queueOptionsChanged(~,~)
        assertIdle();invalidateQueue();
    end
    function reviewQueueCallback(~,~)
        assertIdle();
        if isempty(State.Batch.FilePath)&&~chooseSave(),return;end
        guarded(@reviewQueue);
    end
    function chooseRowsCallback(~,~)
        tabs.SelectedTab=detailsTab;tabChanged([],[]);
    end
    function queueConfirmationChanged(~,~)
        guarded(@()confirmQueue(queueConfirm.Value));
    end
    function runQueueCallback(~,~)
        guarded(@runQueue);
    end
    function stopCallback(~,~)
        guarded(@requestStop);
    end
    function historyCallback(~,~)
        guarded(@getHistory);
    end
    function historySelection(~,event)
        SelectedHistoryRow=[];openAttemptButton.Enable='off';
        if State.Busy||isempty(event.Indices),return;end
        row=event.Indices(1,1);if row>height(HistoryRows),return;end
        SelectedHistoryRow=row;
        if string(HistoryRows.Status(row))=="Complete"&&logical(HistoryRows.Verified(row))
            openAttemptButton.Enable='on';
        end
    end
    function openAttemptCallback(~,~)
        assertIdle();if isempty(SelectedHistoryRow),return;end
        guarded(@()openAttempt(char(HistoryRows.RunFolder(SelectedHistoryRow))));
    end
    function tabChanged(~,~)
        if tabs.SelectedTab==queueTab||tabs.SelectedTab==historyTab||tabs.SelectedTab==statsTab
            rowsTable.Visible='off';g.RowHeight={34,24,114,32,0,'1x',28};
        else
            rowsTable.Visible='on';g.RowHeight={34,24,114,32,'1x',136,28};
        end
    end
    function guarded(action)
        try,action();catch err,showError(err);end
    end
    function showError(err)
        status.Text=['Needs attention: ' err.message];
        uialert(Fig,sprintf('%s\n\n%s',err.message,err.identifier),'Batch needs attention','Icon','warning');
    end
    function proceed=mayDiscard()
        proceed=~State.Busy;if ~proceed||~State.Dirty,return;end
        choice=uiconfirm(Fig,'Save changes to the batch before continuing?', ...
            'Unsaved batch changes','Options',{'Save','Discard','Cancel'}, ...
            'DefaultOption',1,'CancelOption',3);
        switch choice
            case 'Save'
                if isempty(State.Batch.FilePath),proceed=chooseSave();
                else
                    try,saveBatch(State.Batch.FilePath);catch err,showError(err);proceed=false;end
                end
            case 'Discard',proceed=true;
            otherwise,proceed=false;
        end
    end
    function closeWindow(~,~)
        if State.Busy
            status.Text='The batch window stays open during the current operation. Use Stop after current recording to finish safely.';return;
        end
        if mayDiscard(),delete(Fig);end
    end
end

function place(control,row,column)
control.Layout.Row=row;control.Layout.Column=column;
end

function value=onoff(flag)
if flag,value='on';else,value='off';end
end
