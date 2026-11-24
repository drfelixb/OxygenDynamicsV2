function [Fig,UI]=openBOIBatchEditor(InitialBatch)
%OPENBOIBATCHEDITOR Prepare and run explicitly confirmed recording queues.
% InitialBatch may be a batch struct, an input table or a CSV path. Opening a
% CSV never starts analysis. A saved working CSV is required for run outcomes.
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
    'CheckProgress',[],'StatsPlan',[],'StatsConfirmed',false,'StatsResult',[],'StatsHandoff',[]);
checkDialog=[];
importActive=false;importConverted=0;importPathSummary=[];importLastPaths=strings(0,1);
acquisition={'SampleF','Pixelsize','BOISupportProfile'};
importSettings=acquisition(1:2);
importLabels={'Sampling rate (Hz)','Pixel size (µm/pixel)'};
essential={'Paths','InputStatus','AnalysisStatus','ResultCheck',acquisition{:}};
optional={'Mouse','Condition','DrugID','Genotype','Promoter','RecordingLabel', ...
    'RecordingDate','Session','Sex','AgeDays','BrainRegion','Project','Operator','Notes'};
reserved={'BatchRowID','InputStatus','AnalysisStatus','ResultCheck','ReviewStatus', ...
    'RunID','RunFolder','StartedUTC','CompletedUTC','SoftwareVersion','BOIBatchSourceCommit','BOIBatchSourceState','Stage', ...
    'ElapsedSeconds','Message','AttemptHistory'};
Fig=uifigure('Name','Batch recordings','Position',[70 70 1120 800]);
Fig.CloseRequestFcn=@closeWindow;
imaging=uimenu(Fig,'Text','Imaging mode');
uimenu(imaging,'Text','Multichannel batch from CSV…','MenuSelectedFcn',@(~,~)openBOIMultichannelBatch());
g=uigridlayout(Fig,[7 1]);g.Padding=[10 10 10 10];g.RowSpacing=7;
g.RowHeight={34,24,76,32,'1x','2x',28};
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
settings=uipanel(g,'Title','Shared settings');
sg=uigridlayout(settings,[2 6]);sg.Padding=[8 3 8 3];sg.RowSpacing=3;
sg.RowHeight={23,25};sg.ColumnWidth={110,90,140,90,108,'1x'};
uilabel(sg,'Text','Sampling rate (Hz)');
sample=uieditfield(sg,'text','ValueChangedFcn',@sharedChanged);
uilabel(sg,'Text','Pixel size (µm/pixel)');
pixels=uieditfield(sg,'text','ValueChangedFcn',@sharedChanged);
uilabel(sg,'Text','Detection support');
support=uidropdown(sg,'Items',{'Automatic tissue estimate','Reviewed craniotomy ROI'}, ...
    'ItemsData',{'whole-image','craniotomy-roi-1'},'Value','whole-image', ...
    'ValueChangedFcn',@sharedChanged);
support.Tooltip=sprintf(['Automatic tissue estimate uses image intensity. Review the estimated edge visually.\n' ...
    'Detections can extend beyond the estimated tissue edge; inspect the estimate after analysis.\n' ...
    'Reviewed craniotomy ROI uses a matching source-bound reviewed tissue mask.']);
confirmation=uicheckbox(sg,'Text','Confirm shared overrides', ...
    'ValueChangedFcn',@sharedConfirmed);place(confirmation,2,[1 2]);
settingsHint=uilabel(sg,'Text','Overrides fill blank cells. Detection support defaults to Automatic tissue estimate.', ...
    'WordWrap','on');place(settingsHint,2,[3 6]);
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
rowsTable.Tooltip=sprintf(['Blank cells inherit confirmed shared settings. Detection support otherwise uses the automatic estimate.\n' ...
    'Choose the displayed default or shared support option to clear a row override.']);
tabs=uitabgroup(g);
detailsTab=uitab(tabs,'Title','Recording details');
dg=uigridlayout(detailsTab,[2 3]);dg.RowHeight={28,'1x'};
dg.ColumnWidth={155,160,'1x'};dg.Padding=[5 5 5 5];dg.RowSpacing=4;
attachButton=uibutton(dg,'Text','Attach saved run…','ButtonPushedFcn',@attachCallback);
openRunButton=uibutton(dg,'Text','Open saved run','Enable','off','ButtonPushedFcn',@openRunCallback);
openRunButton.Tooltip='Checks this recording and its saved artifacts before opening; unrelated rows are not checked.';
runHint=uilabel(dg,'Text','Attach an existing run to inspect its saved results.','WordWrap','on');
details=uitextarea(dg,'Editable','off','Value',{'Add a recording folder, enter acquisition settings, then Check rows.'});
place(details,2,[1 3]);
metadataTab=uitab(tabs,'Title','Metadata');
mg=uigridlayout(metadataTab,[3 4]);mg.Padding=[8 6 8 6];mg.RowHeight={28,28,'1x'};
mg.ColumnWidth={170,'1x',140,140};
fieldChoice=uidropdown(mg,'Items',optional,'Value','Mouse');
fieldValue=uieditfield(mg,'text','Placeholder','Value to apply; blank clears the selected cells');
applyButton=uibutton(mg,'Text','Apply to selection','ButtonPushedFcn',@applyCallback);
showFieldButton=uibutton(mg,'Text','Show / add field','ButtonPushedFcn',@showFieldCallback);
customName=uieditfield(mg,'text','Placeholder','New custom field name');place(customName,2,[1 2]);
customButton=uibutton(mg,'Text','Add custom field','ButtonPushedFcn',@customCallback);place(customButton,2,3);
hideButton=uibutton(mg,'Text','Hide selected field','ButtonPushedFcn',@hideFieldCallback);place(hideButton,2,4);
metadataHint=uilabel(mg,'Text','Select recordings above to apply optional metadata. Use days for age and YYYY-MM-DD for dates.', ...
    'WordWrap','on','VerticalAlignment','top');place(metadataHint,3,[1 4]);
queueTab=uitab(tabs,'Title','Run');
qg=uigridlayout(queueTab,[8 4]);qg.Padding=[6 6 6 6];qg.RowSpacing=5;qg.Scrollable='on';
qg.ColumnWidth={185,205,'1x',180};qg.RowHeight={30,30,28,40,32,34,0,'1x'};
outputButton=uibutton(qg,'Text','Choose output parent…','ButtonPushedFcn',@outputCallback);
outputParent=uieditfield(qg,'text','Placeholder','Existing parent folder for fresh recording attempts', ...
    'ValueChangedFcn',@outputChanged);place(outputParent,1,[2 4]);
runAgain=uicheckbox(qg,'Text','Run again in new folders, including verified results','ValueChangedFcn',@queueOptionsChanged);place(runAgain,2,[1 2]);
reviewQueueButton=uibutton(qg,'Text','Review selected queue','ButtonPushedFcn',@reviewQueueCallback);place(reviewQueueButton,2,4);
queuePreview=uilabel(qg,'Text','No queue reviewed','FontWeight','bold','FontSize',15, ...
    'WordWrap','on','Interpreter','none');place(queuePreview,3,[1 4]);
queueEstimate=uilabel(qg,'Text','Select recordings, choose an output folder and review the queue.', ...
    'WordWrap','on','Interpreter','none');place(queueEstimate,4,[1 4]);
runQueueButton=uibutton(qg,'Text','Start recordings','FontWeight','bold','Enable','off','ButtonPushedFcn',@runQueueCallback);place(runQueueButton,5,1);
stopButton=uibutton(qg,'Text','Stop after current recording','Enable','off','ButtonPushedFcn',@stopCallback);place(stopButton,5,2);
queueDetailsButton=uibutton(qg,'Text','Show details','Enable','off','ButtonPushedFcn',@toggleQueueDetails);place(queueDetailsButton,5,4);
queueStatus=uilabel(qg,'Text','','WordWrap','on','Interpreter','none');place(queueStatus,6,[1 4]);
queueDetails=uitextarea(qg,'Editable','off','Visible','off');place(queueDetails,7,[1 4]);
statsTab=uitab(tabs,'Title','Automatic export');
eg=uigridlayout(statsTab,[8 4]);eg.Padding=[8 8 8 8];eg.RowSpacing=4;
eg.RowHeight={30,30,27,32,26,30,55,'1x'};eg.ColumnWidth={175,175,'1x',180};
statsParentButton=uibutton(eg,'Text','Choose export parent…','ButtonPushedFcn',@statsParentCallback);
statsParent=uieditfield(eg,'text','Placeholder','Existing parent for a new combined stats/export folder', ...
    'ValueChangedFcn',@statsOptionsChanged);place(statsParent,1,[2 4]);
statsScope=uidropdown(eg,'Items',{'All completed recordings','Selected recording rows'}, ...
    'ValueChangedFcn',@statsOptionsChanged);place(statsScope,2,[1 2]);
reviewStatsButton=uibutton(eg,'Text','Review combined export','ButtonPushedFcn',@reviewStatsCallback);place(reviewStatsButton,2,4);
statsPreview=uilabel(eg,'Text','Choose an export folder, then review the selection.', ...
    'WordWrap','on','Interpreter','none','FontWeight','bold');place(statsPreview,3,[1 4]);
exportStatsButton=uibutton(eg,'Text','Export workbook','FontWeight','bold','Enable','off','ButtonPushedFcn',@exportStatsCallback);place(exportStatsButton,4,1);
statsDetailsButton=uibutton(eg,'Text','Show details','Enable','off','ButtonPushedFcn',@toggleStatsDetails);place(statsDetailsButton,4,2);
reopenStatsButton=uibutton(eg,'Text','Open existing export…','ButtonPushedFcn',@reopenStatsCallback);place(reopenStatsButton,4,4);
reopenStatsButton.Tooltip='Choose a completed combined-export folder. Reads its receipts and tables without rerunning statistics or reading original movies.';
statsOutcome=uilabel(eg,'Text','','WordWrap','on','Interpreter','none');place(statsOutcome,5,[1 4]);
openStatsButton=uibutton(eg,'Text','Open workbook','Enable','off','ButtonPushedFcn',@openStatsCallback);place(openStatsButton,6,1);
pocketButton=uibutton(eg,'Text','Pocket traces','Enable','off','ButtonPushedFcn',@pocketTracesCallback);place(pocketButton,6,2);
pocketButton.Tooltip='Preview original TIFFs and export automatic pocket and nearby-tissue traces for each condition.';
statsSummary=uilabel(eg,'Text','No completed workbook loaded.','WordWrap','on');place(statsSummary,6,[3 4]);
statsFolder=createBOIExportFolderPanel(eg);place(statsFolder.Grid,7,[1 4]);
statsDestination=statsFolder.Path;statsDestination.Value={'The completed combined export folder will be shown here.'};
openStatsFolderButton=statsFolder.OpenButton;copyStatsPathButton=statsFolder.CopyButton;
statsDetails=uitextarea(eg,'Editable','off','Visible','off');place(statsDetails,8,[1 4]);
reviewedTab=uitab(tabs,'Title','Reviewed export');
reviewedExport=createBOIReviewedExportPanel(reviewedTab,struct('AssertIdle',@assertIdle, ...
    'Begin',@beginReviewedExport,'End',@finishReviewedExport,'AutomaticMAT',@automaticMAT));
compactTab=uitab(tabs,'Title','Compact workbook');
compactExport=createBOICompactExportPanel(compactTab,struct('AssertIdle',@assertIdle, ...
    'Begin',@beginCompactExport,'End',@finishCompactExport,'AutomaticSource',@automaticCompactSource,'BatchContext',@compactBatchContext));
historyTab=uitab(tabs,'Title','History');
hg=uigridlayout(historyTab,[2 3]);hg.Padding=[5 5 5 5];hg.RowHeight={28,'1x'};
hg.ColumnWidth={145,170,'1x'};
historyButton=uibutton(hg,'Text','Load selected history','ButtonPushedFcn',@historyCallback);
openAttemptButton=uibutton(hg,'Text','Open selected saved run','Enable','off','ButtonPushedFcn',@openAttemptCallback);
historyStatus=uilabel(hg,'Text','Select one recording row to view its attempts.','WordWrap','on');
historyTable=uitable(hg,'Data',cell(0,0),'CellSelectionCallback',@historySelection);place(historyTable,2,[1 3]);
HistoryRows=table();SelectedHistoryRow=[];HistoryRowID="";
importTab=uitab(tabs,'Title','CSV setup');
ig=uigridlayout(importTab,[9 3]);ig.Padding=[10 8 10 8];ig.Scrollable='on';
ig.ColumnWidth={230,'1x',180};ig.RowHeight={34,32,32,30,38,28,42,32,'1x'};
importSummary=uilabel(ig,'Text','Open a CSV to check its paths and required settings.', ...
    'WordWrap','on','Interpreter','none');place(importSummary,1,[1 3]);
importFields=cell(size(importSettings));importCounts=cell(size(importSettings));
for k=1:numel(importSettings)
    fieldLabel=uilabel(ig,'Text',importLabels{k});place(fieldLabel,k+1,1);
    importFields{k}=uieditfield(ig,'text','Placeholder','Enter the confirmed value');
    place(importFields{k},k+1,2);
    importCounts{k}=uilabel(ig,'Text','','WordWrap','on');place(importCounts{k},k+1,3);
end
supportHelp=uilabel(ig,'Text','Detection support defaults to Automatic tissue estimate. Set a shared or row override to use a reviewed mask.', ...
    'WordWrap','on');place(supportHelp,4,[1 3]);
importFeedback=uilabel(ig,'Text','','WordWrap','on','Interpreter','none');place(importFeedback,5,[1 2]);
applyImportButton=uibutton(ig,'Text','Apply to missing rows','ButtonPushedFcn',@applyImportCallback);place(applyImportButton,5,3);
pathSummary=uilabel(ig,'Text','','WordWrap','on','Interpreter','none');place(pathSummary,6,[1 3]);
pathExample=uilabel(ig,'Text','','WordWrap','on','Interpreter','none');place(pathExample,7,[1 3]);
prefixLabel=uilabel(ig,'Text','Original folder prefix');place(prefixLabel,8,1);
importPrefix=uieditfield(ig,'text','Placeholder','Beginning of the original paths');place(importPrefix,8,2);
mapImportButton=uibutton(ig,'Text','Choose local folder…','ButtonPushedFcn',@mapImportCallback);place(mapImportButton,8,3);
status=uilabel(g,'Text','Prepare and check rows, then review a selected queue before starting analysis.', ...
    'Interpreter','none','WordWrap','on');
lockedControls={newButton,openButton,saveButton,saveAsButton,checkButton,queueButton, ...
    sample,pixels,support,confirmation,addButton,pasteButton,deleteButton,upButton,downButton, ...
    resetButton,selectReadyButton,rowsTable,attachButton,openRunButton,fieldChoice,fieldValue, ...
    applyButton,showFieldButton,customName,customButton,hideButton,outputButton,outputParent, ...
    runAgain,reviewQueueButton,historyButton,openAttemptButton,historyTable, ...
    statsButton,statsParentButton,statsParent,statsScope,reviewStatsButton,statsDetailsButton,exportStatsButton, ...
    openStatsButton,pocketButton,reopenStatsButton,openStatsFolderButton,copyStatsPathButton,reviewedExport.Controls{:},compactExport.Controls{:}, ...
    importFields{:},applyImportButton,importPrefix,mapImportButton};
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
    'RunQueue',@runQueue,'StartReviewedQueue',@startReviewedQueue,'RequestStop',@requestStop,'StopAfterCurrent',@requestStop, ...
    'History',@getHistory,'OpenAttempt',@openAttempt,'OutputParent',outputParent, ...
    'QueueTab',queueTab,'QueuePreview',queuePreview,'QueueEstimate',queueEstimate,'QueueDetails',queueDetails,'QueueDetailsButton',queueDetailsButton, ...
    'RunQueueButton',runQueueButton,'StopButton',stopButton,'ReviewQueueButton',reviewQueueButton, ...
    'SelectReadyButton',selectReadyButton,'RunAgain',runAgain,'QueueStatus',queueStatus, ...
    'CheckDialog',@getCheckDialog, ...
    'HistoryTable',historyTable,'HistoryTab',historyTab,'OpenAttemptButton',openAttemptButton, ...
    'StatsTab',statsTab,'StatsButton',statsButton,'StatsOutputParent',statsParent,'StatsScope',statsScope, ...
    'ReviewStats',@reviewStats,'ConfirmStats',@confirmStats,'RunStats',@runStatsExport,'StartReviewedStats',@startReviewedStats,'ReopenStats',@reopenStats, ...
    'ReviewStatsButton',reviewStatsButton,'ExportStatsButton',exportStatsButton,'StatsPreview',statsPreview, ...
    'StatsDetails',statsDetails,'StatsDetailsButton',statsDetailsButton,'StatsSummary',statsSummary,'StatsOutcome',statsOutcome,'StatsDestination',statsDestination, ...
    'OpenStatsButton',openStatsButton,'PocketTracesButton',pocketButton,'ReopenStatsButton',reopenStatsButton,'OpenStatsFolderButton',openStatsFolderButton,'CopyStatsPathButton',copyStatsPathButton, ...
    'StatsExportFolder',statsFolder,'ReviewedExport',reviewedExport,'ReviewedExportTab',reviewedTab,'CompactExport',compactExport,'CompactExportTab',compactTab);
UI.ImportTab=importTab;UI.ImportSummary=importSummary;UI.ImportFeedback=importFeedback;
UI.ImportRate=importFields{1};UI.ImportPixelSize=importFields{2};
UI.ApplyImportSettingsButton=applyImportButton;UI.MapImportPaths=@mapImportPaths;UI.ImportPrefix=importPrefix;
if ismember('Mouse',Batch.Rows.Properties.VariableNames),State.VisibleMetadata={'Mouse'};end
if isfield(Batch,'OutputParent'),outputParent.Value=char(string(Batch.OutputParent));end
syncShared();invalidate([]);State.Dirty=false;refresh();
if isfield(Batch,'PathImport'),startImport();end

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
        importActive=false;importConverted=0;importPathSummary=[];importLastPaths=strings(0,1);
        tabs.SelectedTab=detailsTab;
        State.Batch=b;State.SelectedRows=[];State.Report=table();State.Requests={};
        State.VisibleMetadata={};State.Outcome=[];runAgain.Value=false;
        if ismember('Mouse',b.Rows.Properties.VariableNames),State.VisibleMetadata={'Mouse'};end
        if isfield(b,'OutputParent'),outputParent.Value=char(string(b.OutputParent));else,outputParent.Value='';end
        clearHistory();
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
        startImport();
    end
    function startImport()
        importActive=true;
        importConverted=State.Batch.PathImport.ChangedCount;
        importPathSummary=State.Batch.PathImport;
        importLastPaths=State.Batch.Rows.Paths;
        for k=1:numel(importFields),importFields{k}.Value='';end
        importPrefix.Value='';importFeedback.Text='';
        State.Dirty=State.Dirty||importConverted>0;
        refresh();
        if any(missingImportSettings(),'all')||~isempty(importPathSummary.NeedsMapping)
            tabs.SelectedTab=importTab;
            status.Text='Finish CSV setup, then Check rows.';
        elseif importConverted>0
            status.Text=sprintf('Updated path format for %d recordings. Check rows to verify the folders.',importConverted);
        end
    end
    function missing=missingImportSettings()
        b=State.Batch;
        missing=false(height(b.Rows),numel(importSettings));
        for k=1:numel(importSettings)
            name=importSettings{k};
            if ~b.SharedConfirmed||strlength(strtrim(string(b.Shared.(name))))==0
                missing(:,k)=strlength(strtrim(b.Rows.(name)))==0;
            end
        end
    end
    function refreshImport()
        missing=false(0,numel(importSettings));
        needsMapping=table();
        pathSummary.Text='';pathExample.Text='';
        if importActive
            missing=missingImportSettings();
            n=nnz(any(missing,2));
            if n>0
                importSummary.Text=sprintf('%d recordings need settings. Enter a value once for each field that needs it.',n);
            else
                importSummary.Text='All recordings have the required settings. Click Check rows to verify inputs.';
            end
            current=State.Batch.Rows.Paths;
            if ~isequal(current,importLastPaths)
                [~,importPathSummary]=prepareBOIBatchImportPaths(current,State.Batch.BaseFolder);
                importLastPaths=current;
            end
            needsMapping=importPathSummary.NeedsMapping;
            if importConverted>0
                pathSummary.Text=sprintf('Updated Windows/macOS path format for %d recordings.',importConverted);
            end
            if ~isempty(needsMapping)
                pathSummary.Text=sprintf('%d recording paths need a local folder on this computer.',height(needsMapping));
                pathExample.Text=sprintf('Example: %s\nChoose the local folder corresponding to the original prefix below. You can edit that prefix.', ...
                    char(needsMapping.Path(1)));
                if isempty(importPrefix.Value),importPrefix.Value=char(importPathSummary.SuggestedPrefix);end
            end
        else
            importSummary.Text='Open a CSV to check its paths and required settings.';
            importFeedback.Text='';
        end
        for k=1:numel(importFields)
            count=nnz(missing(:,k));
            importFields{k}.Enable=onoff(count>0&&~State.Busy);
            if count>0,importCounts{k}.Text=sprintf('%d missing',count);
            elseif importActive,importCounts{k}.Text='Already supplied';
            else,importCounts{k}.Text='';end
        end
        applyImportButton.Enable=onoff(any(missing,'all')&&~State.Busy);
        prefixLabel.Visible=onoff(~isempty(needsMapping));importPrefix.Visible=prefixLabel.Visible;
        mapImportButton.Visible=prefixLabel.Visible;
        importPrefix.Enable=onoff(~isempty(needsMapping)&&~State.Busy);
        mapImportButton.Enable=importPrefix.Enable;
    end
    function applyImportCallback(~,~)
        assertIdle();
        missing=missingImportSettings();values=strings(size(importSettings));
        for k=1:numel(importSettings)
            if ~any(missing(:,k)),continue;end
            values(k)=strtrim(string(importFields{k}.Value));
            if values(k)=="",continue;end
            value=str2double(values(k));
            if ~isreal(value)||~isfinite(value)||value<=0
                importFeedback.Text=[importLabels{k} ' must be a positive number.'];
                return;
            end
        end
        targets=missing&(values~="");
        if ~any(targets,'all')
            importFeedback.Text='Enter or choose a value to apply to the recordings that need it.';
            return;
        end
        for k=1:numel(importSettings)
            if ~any(targets(:,k)),continue;end
            State.Batch.Rows.(importSettings{k})(targets(:,k))=values(k);
            importFields{k}.Value='';
        end
        affected=any(targets,2);invalidate(find(affected));refresh();
        importFeedback.Text=sprintf('Applied settings to %d recordings. Save to keep these choices.',nnz(affected));
    end
    function mapImportCallback(~,~)
        assertIdle();
        folder=uigetdir(State.Batch.BaseFolder,'Choose the local folder matching the original prefix');
        if isequal(folder,0),return;end
        try,mapImportPaths(importPrefix.Value,folder);
        catch err,importFeedback.Text=err.message;end
    end
    function mapImportPaths(prefix,folder)
        assertIdle();
        assert(importActive,'OxygenDynamics:BatchPathMapping','Open a CSV before mapping its paths.');
        before=State.Batch.Rows.Paths;
        [paths,info]=prepareBOIBatchImportPaths(before,State.Batch.BaseFolder,prefix,folder);
        assert(info.MappedCount>0,'OxygenDynamics:BatchPathMapping','No paths match that folder prefix. Check the example path.');
        State.Batch.Rows.Paths=paths;importLastPaths=paths;importPathSummary=info;
        importPrefix.Value='';invalidate(find(paths~=before));refresh();
        importFeedback.Text=sprintf('Mapped %d recording paths. Use Check rows to verify the folders.',info.MappedCount);
    end
    function value=hasWorkingCSV()
        value=~isempty(char(State.Batch.FilePath))&& ...
            (~isfield(State.Batch,'WorkingCSV')||isequal(State.Batch.WorkingCSV,true));
    end
    function requireWorkingCSV()
        assert(hasWorkingCSV(),'OxygenDynamics:BatchWorkingCSVRequired', ...
            'Use Save as… to create a working CSV, then review the queue before starting recordings.');
    end
    function [b,backup]=saveBatch(path)
        assert(~State.Busy,'OxygenDynamics:BatchBusy','Wait for the current check.');
        if nargin<1||isempty(path),path=State.Batch.FilePath;end
        assert(~isempty(path),'OxygenDynamics:BatchPathRequired','Choose a CSV filename with Save as.');
        [b,backup]=writeBOIBatchCSV(State.Batch,path);State.Batch=b;State.Dirty=false;invalidateQueue();
        refresh();status.Text=['Working CSV saved: ' char(b.FilePath)];
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
        status.Text=sprintf('Checked %d rows: %d ready; %d need attention.', ...
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
        State.SelectedRows=indices;syncHistorySelection();showDetails();
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
        reviewedExport.SetBusy(busy);compactExport.SetBusy(busy);
        stopButton.Enable=onoff(busy&&running&&~State.StopRequested);
        syncQueueStart();
        syncStatsControls();
        if ~busy
            showDetails();openAttemptButton.Enable='off';
            if historyMatchesSelection()&&~isempty(SelectedHistoryRow)&&SelectedHistoryRow<=height(HistoryRows)&& ...
                    string(HistoryRows.Status(SelectedHistoryRow))=="Complete"&&HistoryRows.Verified(SelectedHistoryRow)
                openAttemptButton.Enable='on';
            end
            refreshImport();
        end
    end
    function invalidateQueue()
        invalidateStats();
        State.QueuePlan=[];State.QueueConfirmed=false;
        syncQueueStart();
        queuePreview.Text='No queue reviewed';
        queueEstimate.Text='Select recordings, choose an output folder and review the queue.';
        queueEstimate.Tooltip='';
        queueStatus.Text='';
        if ~hasWorkingCSV()
            queueStatus.Text='Use Save as… to create a working CSV for the run.';
        end
        queueDetails.Value={''};
        setQueueDetailsExpanded(false);queueDetailsButton.Enable='off';
    end
    function syncQueueStart()
        count=0;
        if ~isempty(State.QueuePlan),count=State.QueuePlan.Counts.Run;end
        runQueueButton.Text='Start recordings';
        if count==1,runQueueButton.Text='Start 1 recording';
        elseif count>1,runQueueButton.Text=sprintf('Start %d recordings',count);end
        runQueueButton.Enable=onoff(~State.Busy&&count>0&&hasWorkingCSV());
    end
    function toggleQueueDetails(~,~)
        setQueueDetailsExpanded(strcmp(queueDetails.Visible,'off'));
    end
    function setQueueDetailsExpanded(expanded)
        heights=qg.RowHeight;heights{7}=0;
        queueDetailsButton.Text='Show details';
        if expanded,heights{7}=94;queueDetailsButton.Text='Hide details';end
        qg.RowHeight=heights;queueDetails.Visible=onoff(expanded);
    end
    function invalidateStats()
        State.StatsPlan=[];State.StatsConfirmed=false;
        if isempty(strtrim(statsParent.Value))
            statsPreview.Text='Choose an export folder, then review the selection.';
        else
            statsPreview.Text='Review the selection to prepare a new export.';
        end
        statsPreview.Tooltip='';
        if isempty(State.StatsResult)
            statsDetails.Value={''};
        else
            statsDetails.Value=State.StatsHandoff.Handoff;
        end
        setStatsDetailsExpanded(false);syncStatsControls();
    end
    function syncStatsControls()
        ready=~State.Busy&&~isempty(State.StatsPlan)&&State.StatsPlan.Counts.Included>0;
        exportStatsButton.Enable=onoff(ready);
        hasStats=~isempty(State.StatsResult)&&isfile(State.StatsResult.Workbook);
        openResult=~State.Busy&&hasStats;
        pocketButton.Enable=onoff(openResult);openStatsButton.Enable=onoff(openResult);openStatsFolderButton.Enable=onoff(openResult);copyStatsPathButton.Enable=onoff(openResult);
        statsDetailsButton.Enable=onoff(~State.Busy&&(~isempty(State.StatsPlan)||hasStats));
    end
    function toggleStatsDetails(~,~)
        setStatsDetailsExpanded(strcmp(statsDetails.Visible,'off'));
    end
    function setStatsDetailsExpanded(expanded)
        statsDetails.Visible=onoff(expanded);
        if expanded
            statsDetailsButton.Text='Hide details';
        elseif isempty(State.StatsPlan)&&~isempty(State.StatsResult)
            statsDetailsButton.Text='Show export guide';
        else
            statsDetailsButton.Text='Show details';
        end
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
        lines={['New combined output: ' plan.OutputFolder]};
        if ~isempty(plan.Excluded)
            lines=[lines,{'','Excluded recordings'}];
            for si=1:height(plan.Excluded)
                r=plan.Excluded(si,:);lines{end+1}=sprintf('%s | %s',r.Mouse,r.Reason); %#ok<AGROW>
            end
        end
        lines=[lines,{'','Included recordings'}];
        for si=1:height(plan.Included)
            r=plan.Included(si,:);lines{end+1}=sprintf('%s | %s | %s | %s',r.Mouse,r.Condition,r.RunFolder,r.MetadataStatus); %#ok<AGROW>
        end
        lines=[lines,{'','The export uses saved automatic measurements. Burden values can be unavailable.', ...
            'Labels come from each saved run. Current optional metadata is retained in BatchSourceRows.csv.'}];
        statsDetails.Value=lines;
        parent=fileparts(plan.OutputFolder);
        [~,name,extension]=fileparts(parent);displayParent=[name extension];
        if isempty(displayParent),displayParent=parent;end
        statsPreview.Text=sprintf('%d included · %d excluded · Output: %s', ...
            plan.Counts.Included,plan.Counts.Excluded,displayParent);
        statsPreview.Tooltip=plan.OutputFolder;
        setStatsDetailsExpanded(false);
        tabs.SelectedTab=statsTab;
        status.Text='Check the preview, then click Export workbook to confirm and start.';
        clear cleanup
    end
    function confirmStats(value)
        assertIdle();assert(~isempty(State.StatsPlan),'OxygenDynamics:BatchStatsNotReviewed','Review combined export first.');
        assert(islogical(value)&&isscalar(value),'OxygenDynamics:BatchStatsConfirmation','Confirm with a single logical value.');
        State.StatsConfirmed=value;
    end
    function result=startReviewedStats(varargin)
        confirmStats(true);result=runStatsExport(varargin{:});
    end
    function result=runStatsExport(executor)
        assertIdle();assert(State.StatsConfirmed&&~isempty(State.StatsPlan), ...
            'OxygenDynamics:BatchStatsNotConfirmed','Review and confirm the combined export first.');
        setBusy(true,false);cleanup=onCleanup(@()finishStats());
        checkDialog=uiprogressdlg(Fig,'Title','Combined stats / export','Message','Rechecking reviewed saved recordings. No detection is running.', ...
            'Indeterminate','on','Cancelable','off');drawnow;
        if nargin<1,executor=[];end
        try
            bundle=statsFolder.ExportTo(@(folder)runStatsBundle(folder,executor),State.StatsPlan.OutputFolder);
        catch err
            if isempty(State.StatsResult),statsOutcome.Text='Export failed.';
            else,statsOutcome.Text='Export failed; previous export retained.';end
            status.Text='Automatic export failed. Retained partial output is not a completed result.';
            rethrow(err);
        end
        result=bundle.Result;presentStats(bundle,'Export completed');
        clear cleanup
    end
    function bundle=runStatsBundle(~,executor)
        result=runBOIBatchStats(State.Batch,State.StatsPlan,@statsProgress,executor);
        statsProgress(struct('Stage','opening-result','Index',1,'Count',1,'Mouse',''));
        bundle=readStatsBundle(result.Directory);
    end
    function bundle=readStatsBundle(path)
        [bundle.Result,bundle.Info]=loadBOIBatchStatsResult(path);
    end
    function result=reopenStats(path)
        assertIdle();setBusy(true,false);cleanup=onCleanup(@()finishCheck());
        checkDialog=uiprogressdlg(Fig,'Title','Open completed automatic export', ...
            'Message','Reading saved receipts and result tables. No statistics or original-movie reading.', ...
            'Indeterminate','on','Cancelable','off');drawnow;
        folder=char(java.io.File(char(string(path))).getCanonicalPath());
        if isfile(folder),folder=fileparts(folder);end
        try
            bundle=statsFolder.LoadExisting(@(~)readStatsBundle(path),folder);
        catch err
            statsOutcome.Text='Saved export not opened; previous selection retained.';
            status.Text='Saved export could not be opened. No analysis or export was started.';
            rethrow(err);
        end
        invalidateStats();result=bundle.Result;presentStats(bundle,'Saved export opened');
        clear cleanup
    end
    function presentStats(bundle,message)
        State.StatsResult=bundle.Result;State.StatsHandoff=bundle.Info;
        compactExport.OfferOpenedSource(automaticCompactSource());
        statsDetails.Value=bundle.Info.Handoff;statsOutcome.Text=message;
        showStatsAvailability();
        setStatsDetailsExpanded(false);
        tabs.SelectedTab=statsTab;
        status.Text=[message '. Open the workbook, folder or export guide.'];
    end
    function showStatsAvailability()
        a=State.StatsHandoff.Burden;
        if a.Known
            statsSummary.Text=sprintf('%d / %d normalized burdens available',a.AvailableNormalizedRecordings,a.Recordings);
        else
            statsSummary.Text='Burden availability not recorded';
        end
    end
    function value=automaticCompactSource()
        assert(~isempty(State.StatsResult),'OxygenDynamics:CompactSource','Open a completed automatic export first.');
        value=struct('DataOutput',State.StatsResult.DataOutput,'Workbook',State.StatsResult.Workbook, ...
            'UseWorkbookBurdenTables',true);
    end
    function b=compactBatchContext(source)
        b=struct('FilePath',State.Batch.FilePath,'Metadata',table());
        if isempty(State.StatsResult)||~isfield(State.StatsResult,'Included'),return;end
        opened=automaticCompactSource();
        if isstruct(source)
            if ~isequaln(source,opened),return;end
        elseif ~any(string(source)==[string(opened.Workbook),string(opened.DataOutput)]),return;
        end
        I=State.StatsResult.Included;rows=State.Batch.Rows;
        if ~all(ismember({'RecordingID','BatchRowID'},I.Properties.VariableNames)),return;end
        [m,ix]=ismember(string(I.BatchRowID),string(rows.BatchRowID));
        if ~all(m),b.FilePath='';return;end
        allowed={'Mouse','Experiment','SessionID','Session','Condition','DrugID','Genotype','Promoter','PuffStim','FieldOfViewID','ControlRecordingID', ...
            'RecordingLabel','RecordingDate','Sex','AgeDays','BrainRegion','Project','Operator','Notes','Camera','ExposureTime_ms','Gain','Binning', ...
            'Treatment','Dose','DoseUnit','Route','TreatmentTime','TimeSinceTreatment_min'};
        names=intersect(allowed,rows.Properties.VariableNames,'stable');b.Metadata=rows(ix,names);b.Metadata.RecordingID=string(I.RecordingID);
        if ismember('Session',b.Metadata.Properties.VariableNames)&&~ismember('SessionID',b.Metadata.Properties.VariableNames)
            b.Metadata.SessionID=b.Metadata.Session;b.Metadata.Session=[];
        end
    end
    function beginCompactExport(message)
        assertIdle();setBusy(true,false);
        checkDialog=uiprogressdlg(Fig,'Title','Compact workbook','Message',message,'Indeterminate','on','Cancelable','off');drawnow;
    end
    function finishCompactExport()
        finishCheck();status.Text='Compact workbook operation finished. See the compact tab for source and export status.';
    end
    function path=automaticMAT()
        assertIdle();assert(~isempty(State.StatsResult)&&isfile(State.StatsResult.DataOutput), ...
            'OxygenDynamics:ReviewedExportSource','Open a completed automatic export first, or choose its DataOutput.mat directly.');
        path=State.StatsResult.DataOutput;
    end
    function beginReviewedExport(message)
        assertIdle();setBusy(true,false);
        checkDialog=uiprogressdlg(Fig,'Title','Reviewed burden-only export','Message',message, ...
            'Indeterminate','on','Cancelable','off');drawnow;
    end
    function finishReviewedExport()
        finishCheck();status.Text='Reviewed burden operation finished. See its preview/export status; automatic results are preserved.';
    end
    function finishStats()
        invalidateStats();finishCheck();
    end
    function statsProgress(event)
        State.CheckProgress=event;
        checkDialog.Title=sprintf('Automatic export — %d recordings',State.StatsPlan.Counts.Included);
        switch event.Stage
            case 'verifying',message=sprintf('Checking saved recording %d of %d: %s',event.Index,event.Count,event.Mouse);
            case 'verifying-sources',message=sprintf('Checking saved inputs for recording %d of %d: %s',event.Index,event.Count,event.Mouse);
            case 'preparing',message='Preparing a new export folder';
            case 'loading',message=sprintf('Loading saved recording %d of %d: %s',event.Index,event.Count,event.Mouse);
            case 'combining',message='Combining saved measurements';
            case 'exporting',message='Writing the workbook and companion files';
            case 'verifying-output',message=sprintf('Checking export output %d of %d: %s',event.Index,event.Count,event.Item);
            case 'reverifying-runs'
                if isfield(event,'Item')&&strcmp(event.Item,'Batch CSV'),message='Checking the batch CSV for changes';
                else,message=sprintf('Final check of saved run %d of %d: %s',event.Index,event.Count-1,event.Mouse);end
            case 'saving-receipt',message='Saving the completed export receipt';
            case 'complete',message='Export files verified and saved';
            case 'opening-result',message='Opening the saved export summary';
            otherwise,message='Preparing the automatic export';
        end
        checkDialog.Message=[message newline 'No detector or new recording analysis is running.'];
        status.Text=message;drawnow;
    end
    function statsTabCallback(~,~)
        tabs.SelectedTab=statsTab;
    end
    function statsParentCallback(~,~)
        parent=uigetdir(pwd,'Choose an existing parent for a fresh combined stats/export folder');
        if isequal(parent,0),return;end
        statsParent.Value=parent;invalidateStats();
    end
    function statsOptionsChanged(~,~),invalidateStats();end
    function reviewStatsCallback(~,~),guarded(@()reviewStats());end
    function exportStatsCallback(~,~),guarded(@startReviewedStats);end
    function reopenStatsCallback(~,~)
        assertIdle();initial=statsFolder.Folder();if isempty(initial),initial=pwd;end
        folder=uigetdir(initial,'Choose a COMPLETED combined-export folder (contains BatchStatsResult.mat)');
        if ~isequal(folder,0),guarded(@()reopenStats(folder));end
    end
    function pocketTracesCallback(~,~)
        assertIdle();
        if ~isempty(State.StatsResult)
            guarded(@()openPocketTracePreview(State.StatsResult.Directory));
        end
    end
    function openStatsCallback(~,~)
        assertIdle();
        if ~isempty(State.StatsResult)
            guarded(@()statsFolder.OpenFile(State.StatsResult.Workbook));
        end
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
        assert(~isempty(State.Batch.FilePath),'OxygenDynamics:BatchPathRequired', ...
            'Use Save as… to create a working CSV before reviewing an unsaved batch.');
        invalidateQueue();setBusy(true,false);cleanup=onCleanup(@()finishCheck());
        status.Text='Reviewing selected sources, settings and destinations. Analysis has not started.';beginCheck();
        [plan,checked]=prepareBOIBatchQueue(State.Batch,outputParent.Value,string(selectedIDs),logical(retry),@checkProgress);
        State.Batch=checked;State.Report=plan.Report;State.Requests={};
        State.QueuePlan=plan;State.QueueConfirmed=false;State.Dirty=true;refresh();
        queuePreview.Text=sprintf('%d to start · %d skipped · %d excluded', ...
            plan.Counts.Run,plan.Counts.Skipped,plan.Counts.Excluded);
        [~,folder,extension]=fileparts(plan.OutputParent);
        destination=[char(folder) char(extension)];
        if isempty(destination),destination=char(plan.OutputParent);end
        copyGiB=plan.SourceCopyBytes/1024^3;
        copyEstimate=sprintf('%.1f GiB',copyGiB);
        if copyGiB>0&&copyGiB<0.1,copyEstimate='<0.1 GiB';end
        queueEstimate.Text=sprintf('Output: %s\nSource copies: %s, plus results and temporary files.', ...
            destination,copyEstimate);
        queueEstimate.Tooltip=char(plan.OutputParent);
        queueDetails.Value=formatQueue(plan);queueDetailsButton.Enable='on';
        tabs.SelectedTab=queueTab;
        if plan.Counts.Run==0
            queueStatus.Text='No selected recordings need to start.';
            status.Text='Open details to see why the selected recordings will be skipped or excluded.';
        elseif ~hasWorkingCSV()
            queueStatus.Text='Use Save as… to create a working CSV, then review again to start recordings.';
            status.Text='Queue preview ready. The run will record outcomes in the working CSV.';
        else
            queueStatus.Text='';
            status.Text='Review the preview. The Start button confirms and starts this queue.';
        end
        clear cleanup
    end
    function confirmQueue(value)
        assertIdle();assert(~isempty(State.QueuePlan),'OxygenDynamics:BatchQueueNotReviewed','Review the current selected queue first.');
        assert(islogical(value)&&isscalar(value),'OxygenDynamics:BatchQueueConfirmation','Confirm with a single logical value.');
        if value,requireWorkingCSV();end
        State.QueueConfirmed=value;
    end
    function outcome=startReviewedQueue(varargin)
        confirmQueue(true);
        reset=onCleanup(@()clearQueueConfirmation());
        outcome=runQueue(varargin{:});
        clear reset
    end
    function clearQueueConfirmation()
        State.QueueConfirmed=false;
    end
    function outcome=runQueue(executor)
        assertIdle();assert(State.QueueConfirmed&&~isempty(State.QueuePlan), ...
            'OxygenDynamics:BatchQueueNotConfirmed','Review and confirm the selected queue before starting analysis.');
        requireWorkingCSV();
        assert(State.QueuePlan.Counts.Run>0,'OxygenDynamics:BatchQueueEmpty','No selected rows need a new analysis attempt.');
        if nargin>=1,assert(isempty(executor)||isa(executor,'function_handle'),'OxygenDynamics:BatchExecutor','Supply a test executor function handle.');end
        State.StopRequested=false;State.Outcome=[];setBusy(true,true);
        cleanup=onCleanup(@()finishQueue());tabs.SelectedTab=queueTab;
        queuePreview.Text='Analysis running';
        queueStatus.Text=sprintf('0 of %d completed · Starting',State.QueuePlan.Counts.Run);
        status.Text='Starting the confirmed queue. Stop after current recording does not cancel the current calculation.';drawnow;
        try
            if nargin<1||isempty(executor)
                [b,outcome]=runBOIBatchQueue(State.Batch,State.QueuePlan,@queueProgress,@shouldStop);
            else
                [b,outcome]=runBOIBatchQueue(State.Batch,State.QueuePlan,@queueProgress,@shouldStop,executor);
            end
            State.Batch=b;State.Outcome=outcome;State.Dirty=false;State.Report=reportFromBatch(b);
            refresh();
            queuePreview.Text=['Queue ' char(outcome.Status)];
            queueStatus.Text=sprintf('%d completed · %d pending', ...
                numel(outcome.CompletedRowIDs),numel(outcome.PendingRowIDs));
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
            queuePreview.Text='Queue stopped';
            queueStatus.Text='Open details for the error.';
            queueDetails.Value=[{status.Text};cellstr(string(queueDetails.Value(:)))];rethrow(err);
        end
    end
    function finishQueue()
        clearQueueConfirmation();State.QueuePlan=[];
        setBusy(false,false);
    end
    function queueProgress(b,event)
        State.Batch=b;State.Report=reportFromBatch(b);State.Requests={};State.Dirty=false;refresh();
        % Refresh updates row details; controls remain locked throughout drawnow.
        setBusy(true,true);
        if ~State.StopRequested
            completed=event.Index-double(~strcmp(event.Status,'Complete'));
            stage=event.Stage;
            switch stage
                case 'staging',stage='Copying source files';
                case 'analysis',stage='Analyzing';
                case 'statistics',stage='Calculating statistics';
                case 'complete',stage='Complete';
            end
            queueStatus.Text=sprintf('%d of %d completed · %s — %s',max(0,completed),event.Count, ...
                rowLabel(find(b.Rows.BatchRowID==string(event.RowID)),false),stage);
        end
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
    function label=rowLabel(row,includePath)
        if nargin<2,includePath=true;end
        label='Unknown row';if ~isscalar(row),return;end
        label=char(State.Batch.Rows.Paths(row));
        if ~includePath
            [~,name,extension]=fileparts(label);label=[name extension];
        end
        if ismember('Mouse',State.Batch.Rows.Properties.VariableNames)&&strlength(State.Batch.Rows.Mouse(row))>0
            label=char(State.Batch.Rows.Mouse(row));
            if includePath,label=[label ' | ' char(State.Batch.Rows.Paths(row))];end
        end
    end
    function history=getHistory(row)
        assertIdle();if nargin<1,row=State.SelectedRows;end
        requireSelection(row);assert(isscalar(row),'OxygenDynamics:BatchSelection','Select one recording row for attempt history.');
        rowID=State.Batch.Rows.BatchRowID(row);
        history=loadBOIBatchHistory(State.Batch,rowID);
        if ~isequal(State.SelectedRows,row),return;end
        HistoryRowID=rowID;
        HistoryRows=history;SelectedHistoryRow=[];historyTable.Data=history;
        historyTable.ColumnName=history.Properties.VariableNames;openAttemptButton.Enable='off';
        historyStatus.Text=sprintf('%d recorded attempts for %s',height(history),rowLabel(row));
    end
    function matches=historyMatchesSelection()
        matches=isscalar(State.SelectedRows)&&strlength(HistoryRowID)>0&& ...
            State.Batch.Rows.BatchRowID(State.SelectedRows)==HistoryRowID;
    end
    function clearHistory()
        HistoryRowID="";HistoryRows=table();SelectedHistoryRow=[];
        historyTable.Data=cell(0,0);openAttemptButton.Enable='off';
        historyStatus.Text='Select one recording row to view its attempts.';
    end
    function syncHistorySelection()
        if strlength(HistoryRowID)>0&&~historyMatchesSelection(),clearHistory();end
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
        labels={'Automatic tissue estimate','Reviewed craniotomy ROI'};
        profiles={'whole-image','craniotomy-roi-1'};
        if isempty(strtrim(p)),p='whole-image';end
        if ~ismember(p,profiles)
            labels{end+1}=['Imported setting: ' p];profiles{end+1}=p;
        end
        if ~isequal(support.ItemsData,profiles)
            support.ItemsData={};support.Items=labels;support.ItemsData=profiles;
        end
        support.Value=p;
        confirmation.Value=logical(State.Batch.SharedConfirmed);
    end
    function label=blankSupportLabel()
        label="Automatic (default)";
        shared=string(State.Batch.Shared.BOISupportProfile);
        if ~State.Batch.SharedConfirmed||strlength(strtrim(shared))==0,return;end
        switch shared
            case "whole-image",label="Automatic (shared)";
            case "craniotomy-roi-1",label="Reviewed ROI (shared)";
            otherwise,label="Use shared setting";
        end
    end
    function refresh()
        names=State.Batch.Rows.Properties.VariableNames;
        State.VisibleMetadata=State.VisibleMetadata(ismember(State.VisibleMetadata,names));
        columns=displayColumns();data=State.Batch.Rows(:,columns);
        blankSupport=blankSupportLabel();
        data.BOISupportProfile(strlength(strtrim(data.BOISupportProfile))==0)=blankSupport;
        data.BOISupportProfile(data.BOISupportProfile=="whole-image")="Automatic tissue estimate";
        data.BOISupportProfile(data.BOISupportProfile=="craniotomy-roi-1")="Reviewed craniotomy ROI";
        % Editable CSV completion cells are never accepted as verification.
        unverified=true(height(State.Batch.Rows),1);
        if ~isempty(State.Report),unverified=State.Report.AnalysisStatus=="Unchecked";end
        linked=strlength(State.Batch.Rows.RunFolder)>0;
        data.AnalysisStatus(linked&unverified)="Check saved run";
        data.AnalysisStatus(~linked&unverified)="Not analyzed";
        rowsTable.Data=cellstrTable(data);rowsTable.ColumnName=columnLabels(columns);
        rowsTable.ColumnEditable=~ismember(columns,reserved);
        formats=repmat({'char'},1,numel(columns));
        supportChoices={char(blankSupport),'Automatic tissue estimate','Reviewed craniotomy ROI'};
        % Keep invalid imported values visible for correction; never replace
        % their underlying text with a valid scientific choice.
        imported=cellstr(unique(data.BOISupportProfile,'stable'))';
        formats{strcmp(columns,'BOISupportProfile')}=unique([supportChoices imported],'stable');
        rowsTable.ColumnFormat=formats;
        widths=repmat({140},1,numel(columns));
        baseWidths={235,105,115,108,85,110,176};
        for wi=1:numel(essential),widths{strcmp(columns,essential{wi})}=baseWidths{wi};end
        if ismember('Mouse',columns),widths{1}=108;end
        rowsTable.ColumnWidth=widths;
        choices=unique([optional metadataNames(names)],'stable');previous=fieldChoice.Value;
        fieldChoice.Items=choices;
        if ismember(previous,choices),fieldChoice.Value=previous;else,fieldChoice.Value=choices{1};end
        file=char(string(State.Batch.FilePath));
        if isempty(file)
            caption='New batch (not saved)';
        else
            [~,stem,extension]=fileparts(file);
            role='Imported CSV';
            if hasWorkingCSV(),role='Working CSV';end
            caption=[role ': ' stem extension];
        end
        if State.Dirty,caption=['Unsaved changes | ' caption];end
        fileLabel.Text=caption;fileLabel.Tooltip=file;
        State.SelectedRows=State.SelectedRows(State.SelectedRows<=height(State.Batch.Rows));
        syncHistorySelection();showDetails();refreshImport();
    end
    function showDetails()
        selected=State.SelectedRows;n=numel(selected);
        selectionLabel.Text=sprintf('%d of %d selected',n,height(State.Batch.Rows));
        openRunButton.Enable='off';attachButton.Enable=onoff(n==1&&~State.Busy);
        runHint.Text='Attach an existing run to inspect its saved results.';
        if n==0
            details.Value={'Select table cells to select their recording rows. Use Shift/Cmd/Ctrl to select more than one.', ...
                'Enter only a recording folder per row; use shared acquisition settings or row overrides.', ...
                'Automatic tissue estimate is the default. Inspect the estimated tissue edge after analysis.', ...
                'Click Check rows, then select ready recordings and open Run.'};return;
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
        usesAutomatic=false;
        try
            [resolved,origins]=resolveBOIBatch(b);
            usesAutomatic=resolved.BOISupportProfile(row)=="whole-image";
            if ismember('Paths',resolved.Properties.VariableNames),lines{end+1}=['Resolved source: ' char(resolved.Paths(row))];end
            for k=1:numel(acquisition)
                name=acquisition{k};value=resolved.(name)(row);
                if strlength(value)==0,value="missing";end
                if strcmp(name,'BOISupportProfile')
                    switch value
                        case "whole-image",value="Automatic tissue estimate";
                        case "craniotomy-roi-1",value="Reviewed craniotomy ROI";
                    end
                end
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
        if usesAutomatic
            lines{end+1}='Review the estimated tissue edge visually. Detections can extend past the estimate.';
        end
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
            case 'InputStatus',label='Input status';
            case 'AnalysisStatus',label='Analysis status';
            case 'ResultCheck',label='Result check';
            case 'SampleF',label='Rate (Hz)';
            case 'Pixelsize',label='Pixel (µm/px)';
            case 'BOISupportProfile',label='Detection support';
            case 'Mouse',label='Mouse ID';
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
    function sharedChanged(control,~)
        shared=struct('SampleF',sample.Value,'Pixelsize',pixels.Value);
        if isequal(control,support),shared.BOISupportProfile=support.Value;end
        setShared(shared,false);
    end
    function sharedConfirmed(~,~)
        setShared(struct('SampleF',sample.Value,'Pixelsize',pixels.Value),confirmation.Value);
    end
    function tableSelection(~,event)
        if isempty(event.Indices),selectRows([]);else,selectRows(unique(event.Indices(:,1),'stable'));end
    end
    function tableEdit(~,event)
        columns=displayColumns();
        name=columns{event.Indices(2)};value=event.NewData;
        if strcmp(name,'BOISupportProfile')
            switch string(value)
                case blankSupportLabel(),value='';
                case "Automatic tissue estimate",value='whole-image';
                case "Reviewed craniotomy ROI",value='craniotomy-roi-1';
            end
        end
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
                    'Save your changes after reviewing the copied rows.'], ...
                    'Create new identities for copied rows?', ...
                    'Options',{'Create new identities','Cancel'},'DefaultOption',2,'CancelOption',2);
                if strcmp(choice,'Create new identities'),guarded(@()openBatch(selectedPath,'new-copies'));end
            else
                showError(err);
            end
        end
    end
    function saveCallback(~,~)
        if hasWorkingCSV(),guarded(@saveBatch);else,chooseSave();end
    end
    function saveAsCallback(~,~)
        chooseSave();
    end
    function saved=chooseSave()
        saved=false;initial='BOI_batch.csv';
        if ~isempty(char(State.Batch.FilePath))
            [folder,stem]=fileparts(char(State.Batch.FilePath));
            suffix='_working';if hasWorkingCSV(),suffix='_copy';end
            stem=[stem suffix];initial=fullfile(folder,[stem '.csv']);
            k=2;
            while isfile(initial)||isfolder(initial)
                initial=fullfile(folder,sprintf('%s_%d.csv',stem,k));k=k+1;
            end
        end
        [name,path]=uiputfile('*.csv','Save working CSV',initial);if isequal(name,0),return;end
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
        assertIdle();tabs.SelectedTab=queueTab;
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
        guarded(@reviewQueue);
    end
    function runQueueCallback(~,~)
        guarded(@startReviewedQueue);
    end
    function stopCallback(~,~)
        guarded(@requestStop);
    end
    function historyCallback(~,~)
        guarded(@getHistory);
    end
    function historySelection(~,event)
        SelectedHistoryRow=[];openAttemptButton.Enable='off';
        if State.Busy||isempty(event.Indices)||~historyMatchesSelection(),return;end
        row=event.Indices(1,1);if row>height(HistoryRows),return;end
        SelectedHistoryRow=row;
        if string(HistoryRows.Status(row))=="Complete"&&logical(HistoryRows.Verified(row))
            openAttemptButton.Enable='on';
        end
    end
    function openAttemptCallback(~,~)
        assertIdle();if isempty(SelectedHistoryRow)||~historyMatchesSelection()||strcmp(openAttemptButton.Enable,'off'),return;end
        guarded(@()openAttempt(char(HistoryRows.RunFolder(SelectedHistoryRow))));
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
        saveOption='Save as…';if hasWorkingCSV(),saveOption='Save';end
        choice=uiconfirm(Fig,'Save changes to the batch before continuing?', ...
            'Unsaved batch changes','Options',{saveOption,'Discard','Cancel'}, ...
            'DefaultOption',1,'CancelOption',3);
        switch choice
            case 'Save'
                try,saveBatch();catch err,showError(err);proceed=false;end
            case 'Save as…',proceed=chooseSave();
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
