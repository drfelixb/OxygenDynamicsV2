function OxygenDynamics_GUI()
%OXYGENDYNAMICS_GUI Stepwise launcher for the Oxygen Dynamics pipeline.

ProjectRoot = setupOxygenDynamicsPath();
PipelineVersion = '2026-05-27';
PipelineBuildTimestamp = '2026-05-27 11:00';

State = struct();
State.ProjectRoot = ProjectRoot;
State.InputCsv = '';
State.InputCsvName = '';
State.MasterFolder = '';
State.VerificationReport = [];
State.LastStatsResult = [];
State.LastVerificationFile = '';
State.LastWrapperRunInfoFile = '';
State.LastStatsWorkbook = '';
State.LastFiguresFolder = '';
State.LastRegressionBaseline = '';
State.LastRegressionBaselineWorkbook = '';
State.LastRegressionReport = '';
State.LastRegressionResult = [];
State.RegressionStatus = [];
State.SelectedRegressionStatsFolder = '';
State.FigureFiles = {};
State.FigureManifest = table();

Fig = uifigure('Name',sprintf('Oxygen Dynamics Pipeline %s',PipelineVersion), ...
    'Position',[100 100 1240 740]);
Grid = uigridlayout(Fig,[7 5]);
Grid.RowHeight = {38,38,44,'1x',120,120,34};
Grid.ColumnWidth = {170,'1x',150,150,150};
Grid.Padding = [12 12 12 12];
Grid.RowSpacing = 8;
Grid.ColumnSpacing = 8;

Title = uilabel(Grid,'Text',sprintf('Oxygen Dynamics Pipeline %s',PipelineVersion), ...
    'FontSize',20,'FontWeight','bold');
Title.Layout.Row = 1;
Title.Layout.Column = [1 2];

VersionLabel = uilabel(Grid,'Text',sprintf('Build: %s',PipelineBuildTimestamp), ...
    'HorizontalAlignment','right','FontColor',[0.35 0.35 0.35]);
VersionLabel.Layout.Row = 1;
VersionLabel.Layout.Column = 3;

ChooseCsvButton = uibutton(Grid,'Text','Choose CSV','ButtonPushedFcn',@chooseCsv);
ChooseCsvButton.Layout.Row = 1;
ChooseCsvButton.Layout.Column = 4;

OpenFolderButton = uibutton(Grid,'Text','Show Folder','Enable','off','ButtonPushedFcn',@showDatasetFolder);
OpenFolderButton.Layout.Row = 1;
OpenFolderButton.Layout.Column = 5;

CsvLabel = uilabel(Grid,'Text','No CSV selected','Interpreter','none');
CsvLabel.Layout.Row = 2;
CsvLabel.Layout.Column = [1 5];

ModeLabel = uilabel(Grid,'Text','Analysis mode');
ModeLabel.Layout.Row = 3;
ModeLabel.Layout.Column = 1;

ModeDropdown = uidropdown(Grid,'Items',{'All analysis','Only df/f tifs','Preflight only'}, ...
    'Value','All analysis');
ModeDropdown.Layout.Row = 3;
ModeDropdown.Layout.Column = 2;

ReanalyseCheck = uicheckbox(Grid,'Text','Reanalyse existing outputs','Value',true);
ReanalyseCheck.Layout.Row = 3;
ReanalyseCheck.Layout.Column = 3;

OverwriteCheck = uicheckbox(Grid,'Text','Overwrite outputs','Value',false);
OverwriteCheck.Layout.Row = 3;
OverwriteCheck.Layout.Column = [4 5];

MainTabs = uitabgroup(Grid);
MainTabs.Layout.Row = 4;
MainTabs.Layout.Column = [1 5];

VerificationTab = uitab(MainTabs,'Title','Verification');
VerificationGrid = uigridlayout(VerificationTab,[1 1]);
VerificationGrid.Padding = [8 8 8 8];

SummaryTable = uitable(VerificationGrid,'Data',cell(0,5), ...
    'ColumnName',{'Mouse','Status','IssueSummary','RecommendedAction','RecordingFolder'});

ResultsTab = uitab(MainTabs,'Title','Results Preview');
ResultsGrid = uigridlayout(ResultsTab,[1 2]);
ResultsGrid.ColumnWidth = {360,'1x'};
ResultsGrid.Padding = [8 8 8 8];
ResultsGrid.ColumnSpacing = 10;

ResultsLeftGrid = uigridlayout(ResultsGrid,[4 1]);
ResultsLeftGrid.RowHeight = {22,'1x',22,90};
ResultsLeftGrid.Padding = [0 0 0 0];
ResultsLeftGrid.RowSpacing = 6;
ResultsLeftGrid.Layout.Row = 1;
ResultsLeftGrid.Layout.Column = 1;

StatsPreviewLabel = uilabel(ResultsLeftGrid,'Text','Stats overview','FontWeight','bold');
StatsPreviewLabel.Layout.Row = 1;

StatsPreviewTable = uitable(ResultsLeftGrid,'Data',cell(0,2), ...
    'ColumnName',{'Item','Value'});
StatsPreviewTable.Layout.Row = 2;

FigureListLabel = uilabel(ResultsLeftGrid,'Text','Generated figures','FontWeight','bold');
FigureListLabel.Layout.Row = 3;

FigureListBox = uilistbox(ResultsLeftGrid,'Items',{},'ValueChangedFcn',@previewSelectedFigure);
FigureListBox.Layout.Row = 4;

FigurePreviewAxes = uiaxes(ResultsGrid);
FigurePreviewAxes.Layout.Row = 1;
FigurePreviewAxes.Layout.Column = 2;
title(FigurePreviewAxes,'Figure preview');
axis(FigurePreviewAxes,'off');

RegressionTab = uitab(MainTabs,'Title','Regression');
RegressionGrid = uigridlayout(RegressionTab,[5 1]);
RegressionGrid.RowHeight = {28,95,'1x',120,38};
RegressionGrid.Padding = [8 8 8 8];
RegressionGrid.RowSpacing = 8;

RegressionStatsLabel = uilabel(RegressionGrid,'Text','Stats output: latest/current','Interpreter','none');
RegressionStatsLabel.Layout.Row = 1;

RegressionStatusTable = uitable(RegressionGrid,'Data',cell(0,2), ...
    'ColumnName',{'Item','Value'});
RegressionStatusTable.Layout.Row = 2;

RegressionSummaryTable = uitable(RegressionGrid,'Data',cell(0,5), ...
    'ColumnName',{'Issue','Category','Status','Look At','Action'});
RegressionSummaryTable.Layout.Row = 3;

RegressionArchiveTable = uitable(RegressionGrid,'Data',cell(0,4), ...
    'ColumnName',{'Archive','BaselineCreated','Workbook','Source'});
RegressionArchiveTable.Layout.Row = 4;

RegressionActionGrid = uigridlayout(RegressionGrid,[1 9]);
RegressionActionGrid.ColumnWidth = repmat({'1x'},1,9);
RegressionActionGrid.Padding = [0 0 0 0];
RegressionActionGrid.ColumnSpacing = 8;
RegressionActionGrid.Layout.Row = 5;

RefreshRegressionButton = uibutton(RegressionActionGrid,'Text','Refresh Status', ...
    'Enable','off','ButtonPushedFcn',@refreshRegressionStatusButton);
RefreshRegressionButton.Layout.Row = 1;
RefreshRegressionButton.Layout.Column = 1;

CreateBaselineTabButton = uibutton(RegressionActionGrid,'Text','Create Baseline', ...
    'Enable','off','ButtonPushedFcn',@createRegressionBaseline);
CreateBaselineTabButton.Layout.Row = 1;
CreateBaselineTabButton.Layout.Column = 2;

ChooseStatsOutputButton = uibutton(RegressionActionGrid,'Text','Choose Stats', ...
    'Enable','off','ButtonPushedFcn',@chooseRegressionStatsOutput);
ChooseStatsOutputButton.Layout.Row = 1;
ChooseStatsOutputButton.Layout.Column = 3;

RunRegressionTabButton = uibutton(RegressionActionGrid,'Text','Run Regression', ...
    'Enable','off','ButtonPushedFcn',@runRegression);
RunRegressionTabButton.Layout.Row = 1;
RunRegressionTabButton.Layout.Column = 4;

OpenBaselineTabButton = uibutton(RegressionActionGrid,'Text','Open Baseline', ...
    'Enable','off','ButtonPushedFcn',@openRegressionBaseline);
OpenBaselineTabButton.Layout.Row = 1;
OpenBaselineTabButton.Layout.Column = 5;

OpenReportTabButton = uibutton(RegressionActionGrid,'Text','Open Report', ...
    'Enable','off','ButtonPushedFcn',@openRegressionReport);
OpenReportTabButton.Layout.Row = 1;
OpenReportTabButton.Layout.Column = 6;

OpenRegressionFolderButton = uibutton(RegressionActionGrid,'Text','Open Folder', ...
    'Enable','off','ButtonPushedFcn',@openRegressionFolder);
OpenRegressionFolderButton.Layout.Row = 1;
OpenRegressionFolderButton.Layout.Column = 7;

RestoreArchiveButton = uibutton(RegressionActionGrid,'Text','Restore Archive', ...
    'Enable','off','ButtonPushedFcn',@restoreRegressionArchive);
RestoreArchiveButton.Layout.Row = 1;
RestoreArchiveButton.Layout.Column = 8;

OpenArchiveFolderButton = uibutton(RegressionActionGrid,'Text','Open Archive', ...
    'Enable','off','ButtonPushedFcn',@openRegressionArchiveFolder);
OpenArchiveFolderButton.Layout.Row = 1;
OpenArchiveFolderButton.Layout.Column = 9;

OutputPanel = uipanel(Grid,'Title','Latest outputs');
OutputPanel.Layout.Row = 5;
OutputPanel.Layout.Column = [1 5];

OutputGrid = uigridlayout(OutputPanel,[3 5]);
OutputGrid.RowHeight = {24,30,30};
OutputGrid.ColumnWidth = {'1x','1x','1x','1x','1x'};
OutputGrid.Padding = [8 4 8 6];
OutputGrid.RowSpacing = 4;
OutputGrid.ColumnSpacing = 8;

VerificationOutputLabel = uilabel(OutputGrid,'Text','Verification: none','Interpreter','none');
VerificationOutputLabel.Layout.Row = 1;
VerificationOutputLabel.Layout.Column = 1;

WrapperOutputLabel = uilabel(OutputGrid,'Text','Wrapper: none','Interpreter','none');
WrapperOutputLabel.Layout.Row = 1;
WrapperOutputLabel.Layout.Column = 2;

StatsOutputLabel = uilabel(OutputGrid,'Text','Stats: none','Interpreter','none');
StatsOutputLabel.Layout.Row = 1;
StatsOutputLabel.Layout.Column = 3;

FiguresOutputLabel = uilabel(OutputGrid,'Text','Figures: none','Interpreter','none');
FiguresOutputLabel.Layout.Row = 1;
FiguresOutputLabel.Layout.Column = 4;

OpenVerificationButton = uibutton(OutputGrid,'Text','Open Verification','Enable','off', ...
    'ButtonPushedFcn',@openVerificationOutput);
OpenVerificationButton.Layout.Row = 2;
OpenVerificationButton.Layout.Column = 1;

OpenWrapperButton = uibutton(OutputGrid,'Text','Open Wrapper Log','Enable','off', ...
    'ButtonPushedFcn',@openWrapperOutput);
OpenWrapperButton.Layout.Row = 2;
OpenWrapperButton.Layout.Column = 2;

OpenStatsButton = uibutton(OutputGrid,'Text','Open Stats','Enable','off', ...
    'ButtonPushedFcn',@openStatsOutput);
OpenStatsButton.Layout.Row = 2;
OpenStatsButton.Layout.Column = 3;

OpenFiguresButton = uibutton(OutputGrid,'Text','Open Figures','Enable','off', ...
    'ButtonPushedFcn',@openFiguresOutput);
OpenFiguresButton.Layout.Row = 2;
OpenFiguresButton.Layout.Column = 4;

RegressionOutputLabel = uilabel(OutputGrid,'Text','Regression: none','Interpreter','none');
RegressionOutputLabel.Layout.Row = 1;
RegressionOutputLabel.Layout.Column = 5;

OpenRegressionButton = uibutton(OutputGrid,'Text','Open Regression','Enable','off', ...
    'ButtonPushedFcn',@openRegressionOutput);
OpenRegressionButton.Layout.Row = 2;
OpenRegressionButton.Layout.Column = 5;

OpenStatsAcceptanceButton = uibutton(OutputGrid,'Text','Open Acceptance','Enable','off', ...
    'ButtonPushedFcn',@openStatsAcceptanceOutput);
OpenStatsAcceptanceButton.Layout.Row = 3;
OpenStatsAcceptanceButton.Layout.Column = 3;

CreateBaselineButton = uibutton(OutputGrid,'Text','Create Baseline','Enable','off', ...
    'ButtonPushedFcn',@createRegressionBaseline);
CreateBaselineButton.Layout.Row = 3;
CreateBaselineButton.Layout.Column = 4;

RegressionButton = uibutton(OutputGrid,'Text','Run Regression','Enable','off', ...
    'ButtonPushedFcn',@runRegression);
RegressionButton.Layout.Row = 3;
RegressionButton.Layout.Column = 5;

LogArea = uitextarea(Grid,'Editable','off','Value',{ ...
    sprintf('Oxygen Dynamics Pipeline %s, build %s',PipelineVersion,PipelineBuildTimestamp); ...
    'Choose an input CSV to begin.'});
LogArea.Layout.Row = 6;
LogArea.Layout.Column = [1 5];

VerifyButton = uibutton(Grid,'Text','1. Run Verification','Enable','off','ButtonPushedFcn',@runVerification);
VerifyButton.Layout.Row = 7;
VerifyButton.Layout.Column = 1;

WrapperButton = uibutton(Grid,'Text','2. Run Wrapper','Enable','off','ButtonPushedFcn',@runWrapper);
WrapperButton.Layout.Row = 7;
WrapperButton.Layout.Column = 2;

StatsButton = uibutton(Grid,'Text','3. Run Stats','Enable','off','ButtonPushedFcn',@runStats);
StatsButton.Layout.Row = 7;
StatsButton.Layout.Column = 3;

FiguresButton = uibutton(Grid,'Text','4. Figures','Enable','off','ButtonPushedFcn',@runFigures);
FiguresButton.Layout.Row = 7;
FiguresButton.Layout.Column = 4;

ManualButton = uibutton(Grid,'Text','Manual','ButtonPushedFcn',@openManual);
ManualButton.Layout.Row = 7;
ManualButton.Layout.Column = 5;

    function chooseCsv(~,~)
        [FileName,FolderName] = uigetfile({'*.csv','CSV files (*.csv)'; '*.*','All files'}, ...
            'Choose input metadata CSV');
        if isequal(FileName,0)
            return
        end

        State.InputCsv = fullfile(FolderName,FileName);
        State.InputCsvName = FileName;
        State.MasterFolder = FolderName;
        State.VerificationReport = [];
        State.LastStatsResult = [];
        State.LastVerificationFile = '';
        State.LastWrapperRunInfoFile = '';
        State.LastStatsWorkbook = '';
        State.LastFiguresFolder = '';
        State.LastRegressionBaseline = defaultRegressionBaselinePath();
        State.LastRegressionBaselineWorkbook = defaultRegressionBaselineWorkbookPath();
        State.LastRegressionReport = '';
        State.LastRegressionResult = [];
        State.RegressionStatus = [];
        State.SelectedRegressionStatsFolder = '';
        State.FigureFiles = {};
        State.FigureManifest = table();

        CsvLabel.Text = sprintf('CSV: %s',State.InputCsv);
        VerifyButton.Enable = 'on';
        WrapperButton.Enable = 'off';
        StatsButton.Enable = 'off';
        FiguresButton.Enable = 'off';
        OpenFolderButton.Enable = 'on';
        SummaryTable.Data = cell(0,5);
        clearStatsPreview();
        clearRegressionTab();
        refreshFigureList();
        updateOutputLinks();
        appendLog(sprintf('Selected CSV: %s',State.InputCsv));
        appendLog(sprintf('Dataset folder: %s',State.MasterFolder));
        refreshRegressionStatus();
    end

    function runVerification(~,~)
        if ~hasCsv()
            return
        end

        setBusy(true,'Running verification...');
        try
            refreshVerificationReport();
        catch ME
            appendLog(['Verification failed: ',ME.message]);
            uialert(Fig,ME.message,'Verification failed');
        end
        setBusy(false,'');
    end

    function runWrapper(~,~)
        if ~canRunGatedStep('wrapper')
            return
        end

        setBusy(true,'Running wrapper analysis...');
        try
            State.LastWrapperRunInfoFile = '';
            State.LastWrapperRunInfo = runInProjectFolder(@() runWrapperWithSelectedConfig());
            if isfield(State.LastWrapperRunInfo,'RunInfoFile')
                State.LastWrapperRunInfoFile = State.LastWrapperRunInfo.RunInfoFile;
            end
            appendLog('Wrapper finished.');
            updateOutputLinks();
            appendLog('Refreshing verification after wrapper output changes...');
            refreshVerificationReport();
        catch ME
            appendLog(['Wrapper failed: ',ME.message]);
            uialert(Fig,ME.message,'Wrapper failed');
        end
        setBusy(false,'');
    end

    function runStats(~,~)
        if ~canRunGatedStep('stats')
            return
        end

        setBusy(true,'Running stats...');
        try
            StatsConfig = struct();
            StatsConfig.inputCsv = State.InputCsv;
            StatsConfig.masterFolder = State.MasterFolder;
            State.LastStatsResult = runInProjectFolder(@() runOxygenDynamicsStats(StatsConfig));
            appendLog('Stats finished.');
            if isfield(State.LastStatsResult,'OutputXlsx')
                State.LastStatsWorkbook = State.LastStatsResult.OutputXlsx;
                appendLog(sprintf('Stats workbook: %s',State.LastStatsResult.OutputXlsx));
            end
            updateStatsPreview();
            refreshRegressionStatus();
            MainTabs.SelectedTab = RegressionTab;
            updateOutputLinks();
            FiguresButton.Enable = 'on';
            CreateBaselineButton.Enable = 'on';
            RegressionButton.Enable = enabledIf(isfile(defaultRegressionBaselinePath()));
        catch ME
            appendLog(['Stats failed: ',ME.message]);
            uialert(Fig,ME.message,'Stats failed');
        end
        setBusy(false,'');
    end

    function createRegressionBaseline(~,~)
        StatsFolder = getCurrentStatsOutputFolder();
        if isempty(StatsFolder)
            uialert(Fig,'Run stats first or choose a dataset with an existing Stats_Output folder.', ...
                'Stats output required');
            return
        end

        BaselinePath = defaultRegressionBaselinePath();
        if ~confirmStatsAcceptanceForBaseline(StatsFolder)
            appendLog('Baseline creation cancelled because stats acceptance needs review.');
            return
        end
        if isfile(BaselinePath) && ~confirmBaselineOverwrite(BaselinePath)
            appendLog('Baseline creation cancelled.');
            return
        end

        setBusy(true,'Creating regression baseline...');
        try
            Baseline = runInProjectFolder(@() createOxygenRegressionBaseline(StatsFolder,BaselinePath));
            State.LastRegressionBaseline = BaselinePath;
            if isfield(Baseline,'BaselineWorkbook')
                State.LastRegressionBaselineWorkbook = Baseline.BaselineWorkbook;
            else
                State.LastRegressionBaselineWorkbook = defaultRegressionBaselineWorkbookPath();
            end
            State.LastRegressionReport = '';
            State.LastRegressionResult = [];
            appendLog(sprintf('Regression baseline saved: %s',BaselinePath));
            if isfile(State.LastRegressionBaselineWorkbook)
                appendLog(sprintf('Regression baseline workbook: %s',State.LastRegressionBaselineWorkbook));
            end
            refreshRegressionStatus();
            updateOutputLinks();
        catch ME
            appendLog(['Baseline creation failed: ',ME.message]);
            uialert(Fig,ME.message,'Baseline failed');
        end
        setBusy(false,'');
    end

    function runRegression(~,~)
        StatsFolder = getCurrentStatsOutputFolder();
        BaselinePath = defaultRegressionBaselinePath();
        if isempty(StatsFolder)
            uialert(Fig,'Run stats first or choose a dataset with an existing Stats_Output folder.', ...
                'Stats output required');
            return
        end
        if ~isfile(BaselinePath)
            uialert(Fig,'Create a regression baseline first.', ...
                'Baseline required');
            return
        end

        setBusy(true,'Running regression test...');
        try
            RegressionResult = runInProjectFolder(@() runOxygenRegressionTest(StatsFolder,BaselinePath, ...
                'ThrowOnFailure',false));
            State.LastRegressionResult = RegressionResult;
            if isfield(RegressionResult,'ReportPath')
                State.LastRegressionReport = RegressionResult.ReportPath;
                appendLog(sprintf('Regression report: %s',RegressionResult.ReportPath));
            end
            if RegressionResult.Passed
                appendLog('Regression passed.');
                uialert(Fig,'Regression passed.','Regression complete');
            else
                appendLog('Regression failed. Open the regression report for details.');
                uialert(Fig,'Regression failed. Open the regression report for details.', ...
                    'Regression failed');
            end
            updateStatsPreview();
            refreshRegressionStatus();
            MainTabs.SelectedTab = RegressionTab;
            updateOutputLinks();
        catch ME
            State.LastRegressionResult = [];
            State.LastRegressionReport = findLatestRegressionReport(StatsFolder);
            appendLog(['Regression failed: ',ME.message]);
            refreshRegressionStatus();
            MainTabs.SelectedTab = RegressionTab;
            updateOutputLinks();
            uialert(Fig,ME.message,'Regression failed');
        end
        setBusy(false,'');
    end

    function chooseRegressionStatsOutput(~,~)
        if ~hasCsv()
            return
        end
        StartFolder = fullfile(State.MasterFolder,'Stats_Runs');
        if ~isfolder(StartFolder)
            StartFolder = State.MasterFolder;
        end
        SelectedFolder = uigetdir(StartFolder,'Choose Stats_Output folder for regression');
        if isequal(SelectedFolder,0)
            return
        end
        DataOutputPath = fullfile(SelectedFolder,'DataOutput.mat');
        if ~isfile(DataOutputPath)
            uialert(Fig,'The selected folder does not contain DataOutput.mat.', ...
                'Invalid stats output');
            return
        end
        State.SelectedRegressionStatsFolder = SelectedFolder;
        State.LastStatsWorkbook = findStatsWorkbookInFolder(SelectedFolder);
        appendLog(sprintf('Selected regression stats output: %s',SelectedFolder));
        refreshRegressionStatus();
        MainTabs.SelectedTab = RegressionTab;
        updateOutputLinks();
    end

    function runFigures(~,~)
        if isempty(State.LastStatsResult)
            uialert(Fig,'Run stats first, or generate figures from MATLAB with runOxygenSummaryFigures(statsFolder).', ...
                'Stats required');
            return
        end

        setBusy(true,'Generating summary figures...');
        try
            FigureResult = runOxygenSummaryFigures(State.LastStatsResult);
            State.LastFiguresFolder = FigureResult.OutputFolder;
            State.FigureFiles = FigureResult.FigureFiles;
            if isfield(FigureResult,'FigureManifest') && istable(FigureResult.FigureManifest)
                State.FigureManifest = FigureResult.FigureManifest;
            else
                State.FigureManifest = table();
            end
            appendLog(sprintf('Summary figures saved: %s',FigureResult.OutputFolder));
            refreshFigureList();
            updateOutputLinks();
            MainTabs.SelectedTab = ResultsTab;
        catch ME
            appendLog(['Figure generation failed: ',ME.message]);
            uialert(Fig,ME.message,'Figure generation failed');
        end
        setBusy(false,'');
    end

    function WrapperRunInfo = runWrapperWithSelectedConfig()
        RunConfigOverride = struct();
        RunConfigOverride.inputCsv = State.InputCsv;
        RunConfigOverride.masterFolder = State.MasterFolder;
        RunConfigOverride.interactive = false;
        RunConfigOverride.reanalyseExisting = ReanalyseCheck.Value;
        RunConfigOverride.overwritePreviousAnalysis = OverwriteCheck.Value;
        RunConfigOverride.analysisMode = ModeDropdown.Value;
        RunConfigOverride.sendEmailAlerts = false;
        RunConfigOverride.runRawDenoisedQC = true;
        WrapperRunInfo = OxygenDynamics_Wrapper(RunConfigOverride);
    end

    function refreshVerificationReport()
        Report = runOxygenPipelineVerificationReport('inputCsv',State.InputCsv, ...
            'masterFolder',State.MasterFolder);
        State.VerificationReport = Report;
        updateSummaryTable(Report.SummaryTable);

        BlockedCount = sum(Report.SummaryTable.Status=="Blocked");
        PartialCount = sum(Report.SummaryTable.Status=="Partial");
        ReadyCount = sum(Report.SummaryTable.Status=="Ready");
        appendLog(sprintf('Verification complete. Ready: %d, Partial: %d, Blocked: %d', ...
            ReadyCount,PartialCount,BlockedCount));
        if isfield(Report,'OutputFiles') && isfield(Report.OutputFiles,'Xlsx')
            State.LastVerificationFile = Report.OutputFiles.Xlsx;
            appendLog(sprintf('Report: %s',Report.OutputFiles.Xlsx));
        end

        WrapperButton.Enable = enabledIf(BlockedCount==0);
        StatsButton.Enable = enabledIf(BlockedCount==0);
        updateOutputLinks();
    end

    function varargout = runInProjectFolder(functionHandle)
        OriginalFolder = pwd;
        RestoreFolder = onCleanup(@() cd(OriginalFolder));
        RestoreFolder; %#ok<VUNUS>
        cd(State.ProjectRoot);
        if nargout>0
            [varargout{1:nargout}] = functionHandle();
        else
            functionHandle();
        end
    end

    function tf = canRunGatedStep(stepName)
        tf = false;
        if ~hasCsv()
            return
        end
        if isempty(State.VerificationReport)
            uialert(Fig,'Run verification first.','Verification required');
            return
        end
        try
            assertNoBlockedVerificationRows(State.VerificationReport,stepName);
        catch ME
            uialert(Fig,ME.message,'Blocked recordings');
            appendLog(ME.message);
            return
        end
        tf = true;
    end

    function tf = hasCsv()
        tf = ~isempty(State.InputCsv) && isfile(State.InputCsv);
        if ~tf
            uialert(Fig,'Choose an input CSV first.','No CSV selected');
        end
    end

    function updateSummaryTable(TableData)
        DisplayColumns = {'Mouse','Status','IssueSummary','RecommendedAction','RecordingFolder'};
        DisplayColumns = DisplayColumns(ismember(DisplayColumns,TableData.Properties.VariableNames));
        SummaryTable.Data = TableData(:,DisplayColumns);
    end

    function updateStatsPreview()
        PreviewRows = buildOxygenStatsPreviewRows(State.LastStatsResult);
        PreviewRows = appendRegressionPreviewRows(PreviewRows);
        PreviewRows = prioritizeOxygenStatsPreviewRows(PreviewRows);
        StatsPreviewTable.Data = PreviewRows;
        styleStatsPreviewTable(PreviewRows);
        MainTabs.SelectedTab = ResultsTab;
    end

    function refreshRegressionStatusButton(~,~)
        if ~hasCsv()
            return
        end
        setBusy(true,'Refreshing regression status...');
        try
            refreshRegressionStatus();
            MainTabs.SelectedTab = RegressionTab;
        catch ME
            appendLog(['Regression status failed: ',ME.message]);
            uialert(Fig,ME.message,'Regression status failed');
        end
        setBusy(false,'');
    end

    function refreshRegressionStatus()
        if isempty(State.MasterFolder) || ~isfolder(State.MasterFolder)
            clearRegressionTab();
            return
        end

        StatsFolder = getCurrentStatsOutputFolder();
        updateRegressionStatsLabel(StatsFolder);
        BaselinePath = defaultRegressionBaselinePath();
        if isempty(StatsFolder)
            Status = getOxygenRegressionStatus('masterFolder',State.MasterFolder, ...
                'baselinePath',BaselinePath);
        else
            Status = getOxygenRegressionStatus('masterFolder',State.MasterFolder, ...
                'statsOutputPath',StatsFolder,'baselinePath',BaselinePath);
        end
        State.RegressionStatus = Status;
        State.LastRegressionBaseline = Status.BaselinePath;
        State.LastRegressionBaselineWorkbook = Status.BaselineWorkbook;
        if Status.HasRegressionReport
            State.LastRegressionReport = Status.LatestRegressionReport;
        end
        updateRegressionTables();
        updateOutputLinks();
    end

    function updateRegressionStatsLabel(StatsFolder)
        if isempty(StatsFolder)
            RegressionStatsLabel.Text = 'Stats output: none found';
        elseif ~isempty(State.SelectedRegressionStatsFolder) && strcmp(StatsFolder,State.SelectedRegressionStatsFolder)
            RegressionStatsLabel.Text = sprintf('Stats output: selected - %s',StatsFolder);
        else
            RegressionStatsLabel.Text = sprintf('Stats output: latest/current - %s',StatsFolder);
        end
    end

    function updateRegressionTables()
        GuiTables = buildOxygenRegressionGuiTables(State.RegressionStatus,State.LastRegressionResult);
        RegressionStatusTable.Data = GuiTables.StatusTable;
        RegressionSummaryTable.Data = GuiTables.SummaryTable;
        RegressionArchiveTable.Data = GuiTables.ArchiveTable;
    end

    function PreviewRows = appendRegressionPreviewRows(PreviewRows)
        if isempty(State.LastRegressionResult) || ~isstruct(State.LastRegressionResult)
            return
        end
        Result = State.LastRegressionResult;
        PreviewRows(end+1,:) = {'Regression',passFailLabel(Result.Passed)};
        if isfield(Result,'RegressionSummary') && istable(Result.RegressionSummary)
            SummaryRows = Result.RegressionSummary;
            MaxRows = min(height(SummaryRows),5);
            for RowIdx = 1:MaxRows
                Label = sprintf('Regression %s',char(SummaryRows.CheckType(RowIdx)));
                PreviewRows(end+1,:) = {Label,char(SummaryRows.Message(RowIdx))}; %#ok<AGROW>
            end
        end
    end

    function Confirmed = confirmStatsAcceptanceForBaseline(StatsFolder)
        Confirmed = true;
        AcceptanceStatus = getOxygenStatsAcceptanceStatus(StatsFolder);
        if AcceptanceStatus.Passed
            return
        end

        Message = createStatsAcceptanceConfirmationMessage(AcceptanceStatus);
        Choice = uiconfirm(Fig,Message,'Stats acceptance needs review', ...
            'Options',{'Continue','Cancel'},'DefaultOption','Cancel', ...
            'CancelOption','Cancel');
        Confirmed = strcmp(Choice,'Continue');
    end

    function Message = createStatsAcceptanceConfirmationMessage(AcceptanceStatus)
        Message = sprintf(['The selected stats output is marked %s.\n\n%s\n\n', ...
            'Review items: %d\n'], ...
            AcceptanceStatus.OverallStatus,AcceptanceStatus.Message, ...
            AcceptanceStatus.ReviewCount);
        ReviewRows = AcceptanceStatus.ReviewRows;
        MaxRows = min(height(ReviewRows),3);
        for RowIdx = 1:MaxRows
            Message = sprintf('%s\n- %s: %s\n  Look at: %s',Message, ...
                char(ReviewRows.Item(RowIdx)),char(ReviewRows.Message(RowIdx)), ...
                char(ReviewRows.WhereToLook(RowIdx)));
        end
        if height(ReviewRows)>MaxRows
            Message = sprintf('%s\n- ... %d more review rows',Message, ...
                height(ReviewRows)-MaxRows);
        end
        Message = sprintf('%s\n\nOnly continue if you have inspected and accepted these issues.',Message);
    end

    function styleStatsPreviewTable(PreviewRows)
        try
            removeStyle(StatsPreviewTable);
            for RowIdx = 1:size(PreviewRows,1)
                Value = string(PreviewRows{RowIdx,2});
                Item = string(PreviewRows{RowIdx,1});
                if startsWith(Value,"REVIEW") || startsWith(Value,"FAIL")
                    addStyle(StatsPreviewTable,uistyle('BackgroundColor',[1.00 0.88 0.86]), ...
                        'row',RowIdx);
                elseif startsWith(Value,"PASS") || (Item=="Stats acceptance" && startsWith(Value,"PASS"))
                    addStyle(StatsPreviewTable,uistyle('BackgroundColor',[0.88 0.96 0.88]), ...
                        'row',RowIdx);
                elseif startsWith(Value,"INFO")
                    addStyle(StatsPreviewTable,uistyle('BackgroundColor',[0.90 0.94 1.00]), ...
                        'row',RowIdx);
                end
            end
        catch
        end
    end

    function Label = passFailLabel(Passed)
        if Passed
            Label = 'PASS';
        else
            Label = 'FAIL';
        end
    end

    function clearStatsPreview()
        StatsPreviewTable.Data = cell(0,2);
        cla(FigurePreviewAxes);
        title(FigurePreviewAxes,'Figure preview');
        axis(FigurePreviewAxes,'off');
    end

    function clearRegressionTab()
        RegressionStatsLabel.Text = 'Stats output: none';
        RegressionStatusTable.Data = cell(0,2);
        RegressionSummaryTable.Data = cell(0,5);
        RegressionArchiveTable.Data = cell(0,4);
    end

    function refreshFigureList()
        FigureList = buildOxygenFigureListItems(State.FigureFiles, ...
            State.LastFiguresFolder,State.FigureManifest);
        State.FigureFiles = FigureList.Files;
        State.FigureManifest = FigureList.Manifest;
        FigureListBox.Items = FigureList.DisplayNames;
        FigureListBox.ItemsData = FigureList.Files;
        if isempty(FigureList.Files)
            FigureListBox.Value = {};
            cla(FigurePreviewAxes);
            title(FigurePreviewAxes,'Figure preview');
            axis(FigurePreviewAxes,'off');
        else
            FigureListBox.Value = FigureList.Files{1};
            previewFigureFile(FigureList.Files{1});
        end
    end

    function previewSelectedFigure(~,~)
        if isempty(FigureListBox.Value)
            return
        end
        previewFigureFile(FigureListBox.Value);
    end

    function previewFigureFile(FigureFile)
        if ~isfile(FigureFile)
            return
        end
        ImageData = imread(FigureFile);
        cla(FigurePreviewAxes);
        image(FigurePreviewAxes,ImageData);
        FigurePreviewAxes.XTick = [];
FigurePreviewAxes.YTick = [];
axis(FigurePreviewAxes,'image');
title(FigurePreviewAxes,getFileLabel(FigureFile),'Interpreter','none');
    end

    function LabelText = getFileLabel(FilePath)
        [~,Name,Ext] = fileparts(FilePath);
        LabelText = [Name,Ext];
    end

    function appendLog(Message)
        Existing = LogArea.Value;
        if ischar(Existing)
            Existing = {Existing};
        end
        LogArea.Value = [Existing; {sprintf('[%s] %s',char(datetime('now','Format','HH:mm:ss')),Message)}];
        drawnow;
    end

    function setBusy(IsBusy,Message)
        Buttons = [ChooseCsvButton,VerifyButton,WrapperButton,StatsButton,FiguresButton,ManualButton, ...
            OpenFolderButton,OpenVerificationButton,OpenWrapperButton,OpenStatsButton,OpenFiguresButton, ...
            OpenRegressionButton,OpenStatsAcceptanceButton,CreateBaselineButton,RegressionButton,RefreshRegressionButton, ...
            CreateBaselineTabButton,ChooseStatsOutputButton,RunRegressionTabButton, ...
            OpenBaselineTabButton,OpenReportTabButton,OpenRegressionFolderButton, ...
            RestoreArchiveButton,OpenArchiveFolderButton];
        if IsBusy
            set(Buttons,'Enable','off');
            if ~isempty(Message)
                appendLog(Message);
            end
        else
            ChooseCsvButton.Enable = 'on';
            ManualButton.Enable = 'on';
            OpenFolderButton.Enable = enabledIf(hasCsvNoAlert());
            VerifyButton.Enable = enabledIf(hasCsvNoAlert());
            HasValidReport = ~isempty(State.VerificationReport) && ...
                ~any(State.VerificationReport.SummaryTable.Status=="Blocked");
            WrapperButton.Enable = enabledIf(HasValidReport);
            StatsButton.Enable = enabledIf(HasValidReport);
            FiguresButton.Enable = enabledIf(~isempty(State.LastStatsResult));
            CreateBaselineButton.Enable = enabledIf(~isempty(getCurrentStatsOutputFolder()));
            RegressionButton.Enable = enabledIf(~isempty(getCurrentStatsOutputFolder()) && ...
                isfile(defaultRegressionBaselinePath()));
            RefreshRegressionButton.Enable = enabledIf(hasCsvNoAlert());
            CreateBaselineTabButton.Enable = enabledIf(~isempty(getCurrentStatsOutputFolder()));
            ChooseStatsOutputButton.Enable = enabledIf(hasCsvNoAlert());
            RunRegressionTabButton.Enable = enabledIf(~isempty(getCurrentStatsOutputFolder()) && ...
                isfile(defaultRegressionBaselinePath()));
            OpenBaselineTabButton.Enable = enabledIf(isOpenablePath(latestRegressionBaselineOutputPath()));
            OpenReportTabButton.Enable = enabledIf(isOpenablePath(State.LastRegressionReport));
            OpenRegressionFolderButton.Enable = enabledIf(isOpenablePath(regressionFolderPath()));
            RestoreArchiveButton.Enable = enabledIf(hasRegressionArchive());
            OpenArchiveFolderButton.Enable = enabledIf(isOpenablePath(regressionArchiveFolderPath()));
            updateOutputLinks();
        end
        drawnow;
    end

    function tf = hasCsvNoAlert()
        tf = ~isempty(State.InputCsv) && isfile(State.InputCsv);
    end

    function Value = enabledIf(condition)
        if condition
            Value = 'on';
        else
            Value = 'off';
        end
    end

    function showDatasetFolder(~,~)
        if hasCsvNoAlert()
            appendLog(sprintf('Dataset folder: %s',State.MasterFolder));
            openPath(State.MasterFolder);
        end
    end

    function updateOutputLinks()
        VerificationOutputLabel.Text = makeOutputLabel('Verification',State.LastVerificationFile);
        WrapperOutputLabel.Text = makeOutputLabel('Wrapper',State.LastWrapperRunInfoFile);
        StatsOutputLabel.Text = makeOutputLabel('Stats',State.LastStatsWorkbook);
        FiguresOutputLabel.Text = makeOutputLabel('Figures',State.LastFiguresFolder);
        RegressionOutputLabel.Text = makeOutputLabel('Regression',latestRegressionOutputPath());
        OpenVerificationButton.Enable = enabledIf(isOpenablePath(State.LastVerificationFile));
        OpenWrapperButton.Enable = enabledIf(isOpenablePath(State.LastWrapperRunInfoFile));
        OpenStatsButton.Enable = enabledIf(isOpenablePath(State.LastStatsWorkbook));
        OpenStatsAcceptanceButton.Enable = enabledIf(isOpenablePath(getStatsWorkbookForCurrentOutput()));
        OpenFiguresButton.Enable = enabledIf(isOpenablePath(State.LastFiguresFolder));
        OpenRegressionButton.Enable = enabledIf(isOpenablePath(latestRegressionOutputPath()));
        CreateBaselineButton.Enable = enabledIf(~isempty(getCurrentStatsOutputFolder()));
        RegressionButton.Enable = enabledIf(~isempty(getCurrentStatsOutputFolder()) && ...
            isfile(defaultRegressionBaselinePath()));
        RefreshRegressionButton.Enable = enabledIf(hasCsvNoAlert());
        CreateBaselineTabButton.Enable = enabledIf(~isempty(getCurrentStatsOutputFolder()));
        ChooseStatsOutputButton.Enable = enabledIf(hasCsvNoAlert());
        RunRegressionTabButton.Enable = enabledIf(~isempty(getCurrentStatsOutputFolder()) && ...
            isfile(defaultRegressionBaselinePath()));
        OpenBaselineTabButton.Enable = enabledIf(isOpenablePath(latestRegressionBaselineOutputPath()));
        OpenReportTabButton.Enable = enabledIf(isOpenablePath(State.LastRegressionReport));
        OpenRegressionFolderButton.Enable = enabledIf(isOpenablePath(regressionFolderPath()));
        RestoreArchiveButton.Enable = enabledIf(hasRegressionArchive());
        OpenArchiveFolderButton.Enable = enabledIf(isOpenablePath(regressionArchiveFolderPath()));
    end

    function LabelText = makeOutputLabel(LabelName,PathValue)
        if isempty(PathValue)
            LabelText = sprintf('%s: none',LabelName);
        else
            [~,Name,Ext] = fileparts(PathValue);
            LabelText = sprintf('%s: %s%s',LabelName,Name,Ext);
        end
    end

    function tf = isOpenablePath(PathValue)
        PathValue = asCharPath(PathValue);
        tf = ~isempty(PathValue) && (isfile(PathValue) || isfolder(PathValue));
    end

    function PathValue = asCharPath(PathValue)
        if iscell(PathValue)
            if isempty(PathValue)
                PathValue = '';
            else
                PathValue = PathValue{1};
            end
        end
        if isstring(PathValue)
            if isempty(PathValue) || ismissing(PathValue(1))
                PathValue = '';
            else
                PathValue = char(PathValue(1));
            end
        end
    end

    function openVerificationOutput(~,~)
        openPath(State.LastVerificationFile);
    end

    function openWrapperOutput(~,~)
        openPath(State.LastWrapperRunInfoFile);
    end

    function openStatsOutput(~,~)
        openPath(State.LastStatsWorkbook);
    end

    function openStatsAcceptanceOutput(~,~)
        WorkbookPath = getStatsWorkbookForCurrentOutput();
        if isempty(WorkbookPath) || ~isfile(WorkbookPath)
            uialert(Fig,'No stats workbook was found for the current stats output.', ...
                'Stats workbook missing');
            return
        end

        appendLog(sprintf('Opening stats workbook. Inspect sheet: StatsAcceptance. File: %s',WorkbookPath));
        if ~statsWorkbookHasAcceptanceSheet(WorkbookPath)
            appendLog('StatsAcceptance sheet was not found in this workbook. Rerun stats with the current code to create it.');
            uialert(Fig,['The workbook opened, but it does not appear to contain a ', ...
                'StatsAcceptance sheet. Rerun stats with the current code to create it.'], ...
                'StatsAcceptance missing');
        end
        openPath(WorkbookPath);
    end

    function openFiguresOutput(~,~)
        openPath(State.LastFiguresFolder);
    end

    function openRegressionOutput(~,~)
        openPath(latestRegressionOutputPath());
    end

    function openRegressionBaseline(~,~)
        openPath(latestRegressionBaselineOutputPath());
    end

    function openRegressionReport(~,~)
        openPath(State.LastRegressionReport);
    end

    function openRegressionFolder(~,~)
        openPath(regressionFolderPath());
    end

    function restoreRegressionArchive(~,~)
        if ~hasRegressionArchive()
            uialert(Fig,'No archived regression baselines were found.','No archive found');
            return
        end

        ArchiveFolder = regressionArchiveFolderPath();
        if isempty(ArchiveFolder)
            uialert(Fig,'The regression archive folder could not be found.', ...
                'Archive folder missing');
            return
        end
        [ArchiveFile,ArchivePath] = uigetfile(fullfile(ArchiveFolder,'*.mat'), ...
            'Choose archived regression baseline');
        if isequal(ArchiveFile,0)
            appendLog('Baseline restore cancelled.');
            return
        end
        ArchivedPath = fullfile(ArchivePath,ArchiveFile);

        Message = sprintf(['Restore this archived regression baseline?\n\n%s\n\n' ...
            'The current baseline will be archived before restore.'],ArchivedPath);
        Choice = uiconfirm(Fig,Message,'Restore regression baseline?', ...
            'Options',{'Restore','Cancel'},'DefaultOption','Cancel','CancelOption','Cancel');
        if ~strcmp(Choice,'Restore')
            appendLog('Baseline restore cancelled.');
            return
        end

        BaselinePath = defaultRegressionBaselinePath();
        setBusy(true,'Restoring archived regression baseline...');
        try
            RestoreResult = runInProjectFolder(@() restoreOxygenRegressionBaseline(ArchivedPath,BaselinePath));
            State.LastRegressionBaseline = RestoreResult.BaselinePath;
            State.LastRegressionBaselineWorkbook = RestoreResult.BaselineWorkbook;
            State.LastRegressionResult = [];
            State.LastRegressionReport = '';
            appendLog(sprintf('Restored regression baseline: %s',RestoreResult.BaselinePath));
            if isfield(RestoreResult,'BaselineWorkbook') && isfile(RestoreResult.BaselineWorkbook)
                appendLog(sprintf('Restored baseline workbook: %s',RestoreResult.BaselineWorkbook));
            end
            refreshRegressionStatus();
            MainTabs.SelectedTab = RegressionTab;
        catch ME
            appendLog(['Baseline restore failed: ',ME.message]);
            uialert(Fig,ME.message,'Restore failed');
        end
        setBusy(false,'');
    end

    function openRegressionArchiveFolder(~,~)
        openPath(regressionArchiveFolderPath());
    end

    function tf = confirmBaselineOverwrite(BaselinePath)
        Message = sprintf(['A regression baseline already exists:\n\n%s\n\n' ...
            'Overwrite it only after reviewing and accepting the current stats output.'],BaselinePath);
        Choice = uiconfirm(Fig,Message,'Overwrite regression baseline?', ...
            'Options',{'Overwrite','Cancel'},'DefaultOption','Cancel','CancelOption','Cancel');
        tf = strcmp(Choice,'Overwrite');
    end

    function StatsFolder = getCurrentStatsOutputFolder()
        StatsFolder = '';
        if ~isempty(State.SelectedRegressionStatsFolder) && isfolder(State.SelectedRegressionStatsFolder)
            StatsFolder = State.SelectedRegressionStatsFolder;
            return
        end
        if isstruct(State.LastStatsResult) && isfield(State.LastStatsResult,'DataOutputMat') && ...
                isfile(State.LastStatsResult.DataOutputMat)
            StatsFolder = fileparts(State.LastStatsResult.DataOutputMat);
            return
        end
        if ~isempty(State.LastStatsWorkbook) && isfile(State.LastStatsWorkbook)
            StatsFolder = fileparts(State.LastStatsWorkbook);
            return
        end
        if ~isempty(State.MasterFolder) && isfolder(State.MasterFolder)
            try
                StatsFolder = findLatestStatsOutputFolder(State.MasterFolder);
            catch
                StatsFolder = '';
            end
        end
    end

    function WorkbookPath = findStatsWorkbookInFolder(StatsFolder)
        WorkbookPath = '';
        if isempty(StatsFolder) || ~isfolder(StatsFolder)
            return
        end
        Preferred = dir(fullfile(StatsFolder,'FilteredData_*.xlsx'));
        if isempty(Preferred)
            Preferred = dir(fullfile(StatsFolder,'*.xlsx'));
        end
        if isempty(Preferred)
            return
        end
        [~,Idx] = max([Preferred.datenum]);
        WorkbookPath = fullfile(Preferred(Idx).folder,Preferred(Idx).name);
    end

    function WorkbookPath = getStatsWorkbookForCurrentOutput()
        WorkbookPath = '';
        if ~isempty(State.LastStatsWorkbook) && isfile(State.LastStatsWorkbook)
            WorkbookPath = State.LastStatsWorkbook;
            return
        end
        StatsFolder = getCurrentStatsOutputFolder();
        if ~isempty(StatsFolder)
            WorkbookPath = findStatsWorkbookInFolder(StatsFolder);
        end
    end

    function tf = statsWorkbookHasAcceptanceSheet(WorkbookPath)
        tf = false;
        if isempty(WorkbookPath) || ~isfile(WorkbookPath)
            return
        end
        try
            tf = any(sheetnames(WorkbookPath)=="StatsAcceptance");
        catch
            tf = false;
        end
    end

    function BaselinePath = defaultRegressionBaselinePath()
        if isempty(State.MasterFolder)
            BaselineRoot = State.ProjectRoot;
        else
            BaselineRoot = State.MasterFolder;
        end
        BaselinePath = fullfile(BaselineRoot,'Regression_Baselines','OxygenRegressionBaseline.mat');
    end

    function PathValue = latestRegressionOutputPath()
        if ~isempty(State.LastRegressionReport) && isfile(State.LastRegressionReport)
            PathValue = State.LastRegressionReport;
        elseif ~isempty(State.LastRegressionBaseline) && isfile(State.LastRegressionBaseline)
            if ~isempty(State.LastRegressionBaselineWorkbook) && isfile(State.LastRegressionBaselineWorkbook)
                PathValue = State.LastRegressionBaselineWorkbook;
            else
                PathValue = State.LastRegressionBaseline;
            end
        else
            PathValue = defaultRegressionBaselineWorkbookPath();
            if ~isfile(PathValue)
                PathValue = defaultRegressionBaselinePath();
                if ~isfile(PathValue)
                    PathValue = '';
                end
            end
        end
    end

    function PathValue = latestRegressionBaselineOutputPath()
        if ~isempty(State.LastRegressionBaselineWorkbook) && isfile(State.LastRegressionBaselineWorkbook)
            PathValue = State.LastRegressionBaselineWorkbook;
        elseif ~isempty(State.LastRegressionBaseline) && isfile(State.LastRegressionBaseline)
            PathValue = State.LastRegressionBaseline;
        else
            PathValue = defaultRegressionBaselineWorkbookPath();
            if ~isfile(PathValue)
                PathValue = defaultRegressionBaselinePath();
                if ~isfile(PathValue)
                    PathValue = '';
                end
            end
        end
    end

    function FolderPath = regressionFolderPath()
        if ~isempty(State.RegressionStatus) && isstruct(State.RegressionStatus) && ...
                isfield(State.RegressionStatus,'StatsOutputFolder') && ...
                isfolder(State.RegressionStatus.StatsOutputFolder)
            FolderPath = State.RegressionStatus.StatsOutputFolder;
        elseif ~isempty(State.LastRegressionReport) && isfile(State.LastRegressionReport)
            FolderPath = fileparts(State.LastRegressionReport);
        elseif ~isempty(State.LastRegressionBaseline) && isfile(State.LastRegressionBaseline)
            FolderPath = fileparts(State.LastRegressionBaseline);
        else
            FolderPath = '';
        end
    end

    function FolderPath = regressionArchiveFolderPath()
        if ~isempty(State.RegressionStatus) && isstruct(State.RegressionStatus) && ...
                isfield(State.RegressionStatus,'ArchiveFolder') && ...
                isfolder(State.RegressionStatus.ArchiveFolder)
            FolderPath = State.RegressionStatus.ArchiveFolder;
        else
            FolderPath = fullfile(fileparts(defaultRegressionBaselinePath()),'Archive');
            if ~isfolder(FolderPath)
                FolderPath = '';
            end
        end
    end

    function tf = hasRegressionArchive()
        tf = ~isempty(State.RegressionStatus) && isstruct(State.RegressionStatus) && ...
            isfield(State.RegressionStatus,'ArchivedBaselines') && ...
            istable(State.RegressionStatus.ArchivedBaselines) && ...
            height(State.RegressionStatus.ArchivedBaselines)>0;
    end

    function BaselineWorkbookPath = defaultRegressionBaselineWorkbookPath()
        [BaselineFolder,BaselineName] = fileparts(defaultRegressionBaselinePath());
        BaselineWorkbookPath = fullfile(BaselineFolder,[BaselineName '.xlsx']);
    end

    function ReportPath = findLatestRegressionReport(StatsFolder)
        ReportPath = '';
        ReportFolder = fullfile(StatsFolder,'Regression_Reports');
        if ~isfolder(ReportFolder)
            return
        end
        Reports = dir(fullfile(ReportFolder,'OxygenRegressionReport_*.xlsx'));
        if isempty(Reports)
            return
        end
        [~,Idx] = max([Reports.datenum]);
        ReportPath = fullfile(Reports(Idx).folder,Reports(Idx).name);
    end

    function openPath(PathValue)
        if ~isOpenablePath(PathValue)
            return
        end
        if ispc
            winopen(PathValue);
        else
            appendLog(PathValue);
        end
    end

    function openManual(~,~)
        ManualPath = fullfile(State.ProjectRoot,'USER_MANUAL.md');
        if isfile(ManualPath)
            edit(ManualPath);
        else
            uialert(Fig,'USER_MANUAL.md was not found.','Manual not found');
        end
    end

end
