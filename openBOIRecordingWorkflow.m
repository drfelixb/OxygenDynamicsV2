function [Fig,UI]=openBOIRecordingWorkflow(InitialOptions,StageObserver)
%OPENBOIRECORDINGWORKFLOW Focused single-recording route, shared with batch.
% Optional options prefill controls; nothing runs or becomes confirmed on open.
% Optional StageObserver(Fig,Status) permits bounded presentation verification.
setupOxygenDynamicsPath;
if nargin<1,InitialOptions=struct();end
if nargin<2,StageObserver=[];end
assert(isempty(StageObserver)||isa(StageObserver,'function_handle'), ...
    'OxygenDynamics:InvalidRunRequest','StageObserver must be a function handle.');
State=struct('Request',[],'SelectedRun',[],'Status','idle','Busy',false, ...
    'ProgressHistory',{{}},'LastRunStage','','FailedRunFolder','');
Fig=uifigure('Name','BOI recording workflow','Position',[80 70 1120 830]);
g=uigridlayout(Fig,[10 4]);g.ColumnWidth={175,'1x',175,'1x'};
g.RowHeight={32,36,36,36,36,36,'1x',36,32,36};
titleLabel=uilabel(g,'Text','One BOI recording — analysis and saved-result review','FontSize',18,'FontWeight','bold');
titleLabel.Layout.Row=1;titleLabel.Layout.Column=[1 3];
entry=uigridlayout(g,[1 2]);entry.Padding=[0 0 0 0];place(entry,1,4);
newButton=uibutton(entry,'Text','New analysis','ButtonPushedFcn',@newAnalysis);
reopen=uibutton(entry,'Text','Open saved run','ButtonPushedFcn',@chooseRun);
choose=uibutton(g,'Text','Select recording folder','ButtonPushedFcn',@chooseRecording);place(choose,2,1);
source=uieditfield(g,'text','ValueChangedFcn',@invalidate);place(source,2,[2 4]);
outButton=uibutton(g,'Text','Choose output parent','ButtonPushedFcn',@chooseOutput);place(outButton,3,1);
output=uieditfield(g,'text','ValueChangedFcn',@invalidate);place(output,3,[2 4]);
a=uilabel(g,'Text','Sampling rate (Hz)');place(a,4,1);
fs=uieditfield(g,'text','ValueChangedFcn',@invalidate,'Tooltip','Supply the acquisition-controlled rate. Embedded recording timestamps are not used to infer it.');place(fs,4,2);
a=uilabel(g,'Text','Pixel size (µm/pixel)');place(a,4,3);
px=uieditfield(g,'text','ValueChangedFcn',@invalidate);place(px,4,4);
a=uilabel(g,'Text','Detection support');place(a,5,1);
profile=uidropdown(g,'Items',{'Choose explicitly','Reviewed craniotomy ROI','Legacy whole image'}, ...
    'ItemsData',{'','craniotomy-roi-1','whole-image'},'Value','','ValueChangedFcn',@invalidate);place(profile,5,2);
a=uilabel(g,'Text','Mouse / condition');place(a,5,3);
identity=uigridlayout(g,[1 2]);identity.Padding=[0 0 0 0];place(identity,5,4);
mouse=uieditfield(identity,'text','Placeholder','Mouse (optional)','ValueChangedFcn',@invalidate);
condition=uieditfield(identity,'text','Placeholder','Condition (optional)','ValueChangedFcn',@invalidate);
a=uilabel(g,'Text','Other labels (optional)');place(a,6,1);
labels=uigridlayout(g,[1 3]);labels.Padding=[0 0 0 0];place(labels,6,[2 4]);
drug=uieditfield(labels,'text','Placeholder','Drug ID','ValueChangedFcn',@invalidate);
genotype=uieditfield(labels,'text','Placeholder','Genotype','ValueChangedFcn',@invalidate);
promoter=uieditfield(labels,'text','Placeholder','Promoter','ValueChangedFcn',@invalidate);
preview=uigridlayout(g,[1 2]);preview.ColumnWidth={'1x',340};place(preview,7,[1 4]);
details=uitextarea(preview,'Editable','off','Value',{'Select a recording, new output directory, rate, calibration and support profile.','Analysis uses the established detector and measurement definitions.','Reopen saved run reads a completed BOIRun.mat; it does not run analysis.'});
ax=uiaxes(preview);title(ax,'Reviewed tissue support');
preflight=uibutton(g,'Text','Review settings','ButtonPushedFcn',@preflightCallback);place(preflight,8,1);
confirm=uicheckbox(g,'Text','I checked these settings and tissue support','Enable','off','ValueChangedFcn',@confirmation);place(confirm,8,[2 3]);
runButton=uibutton(g,'Text','Run recording','Enable','off','ButtonPushedFcn',@runCallback);place(runButton,8,4);
status=uilabel(g,'Text','Choose New analysis or Open saved run.','WordWrap','on','Interpreter','none');place(status,9,[1 4]);
eventButton=uibutton(g,'Text','Inspect event traces','Enable','off','ButtonPushedFcn',@eventCallback);place(eventButton,10,[1 2]);
windowButton=uibutton(g,'Text','Inspect recording results','Enable','off','ButtonPushedFcn',@windowCallback);place(windowButton,10,3);
workbookButton=uibutton(g,'Text','Open saved workbook','Enable','off','ButtonPushedFcn',@workbookCallback);place(workbookButton,10,4);
controls={source,output,fs,px,profile,mouse,condition,drug,genotype,promoter,choose,outButton,newButton,reopen,preflight};
UI=struct('Prepare',@prepare,'Run',@execute,'OpenRun',@selectRun,'OpenLatest',@openLatest, ...
    'ListRuns',@listRuns,'NewAnalysis',@newAnalysis,'SelectedTargets',@selectedTargets,'OpenEvents',@openEvents, ...
    'OpenWindows',@openWindows,'State',@getState,'Confirm',confirm,'RunButton',runButton, ...
    'NewButton',newButton,'ReopenButton',reopen,'EventButton',eventButton, ...
    'WindowButton',windowButton,'WorkbookButton',workbookButton,'Details',details,'Status',status, ...
    'Source',source,'Output',output,'SampleHz',fs,'PixelSizeUm',px,'SupportProfile',profile);
for initialField=fieldnames(InitialOptions)'
    value=InitialOptions.(initialField{1});
    switch initialField{1}
        case 'RecordingFolder',source.Value=char(value);
        case 'OutputFolder',output.Value=char(value);
        case 'SampleHz',fs.Value=num2str(value,17);
        case 'PixelSizeUm',px.Value=num2str(value,17);
        case 'SupportProfile',profile.Value=char(value);
        case 'Mouse',mouse.Value=char(value);
        case 'Condition',condition.Value=char(value);
        case 'DrugID',drug.Value=char(value);
        case 'Genotype',genotype.Value=char(value);
        case 'Promoter',promoter.Value=char(value);
        otherwise,error('OxygenDynamics:InvalidRunRequest','Unsupported initial field %s.',initialField{1});
    end
end
    function s=getState()
        s=State;
    end
    function newAnalysis(~,~)
        assert(~State.Busy,'OxygenDynamics:RunBusy','Wait for the current operation.');
        source.Value='';output.Value='';fs.Value='';px.Value='';profile.Value='';
        for control=[mouse condition drug genotype promoter],control.Value='';end
        invalidate([],[]);State.Status='idle';
        status.Text='New analysis: choose one recording and a new output location, then review settings.';
        details.Value={'New analysis uses the established BOI detector and measurements.', ...
            'A recording run starts only after preflight and explicit confirmation.'};
    end
    function invalidate(~,~)
        State.Request=[];State.SelectedRun=[];State.Status='unconfirmed';
        State.ProgressHistory={};State.LastRunStage='';State.FailedRunFolder='';
        confirm.Value=false;confirm.Enable='off';runButton.Enable='off';
        eventButton.Enable='off';windowButton.Enable='off';workbookButton.Enable='off';
        status.Text='Inputs changed. Review and confirm the current settings before running.';
        details.Value={'Settings have changed; previous preflight/result is no longer selected.'};cla(ax);
    end
    function o=options()
        o=struct('RecordingFolder',source.Value,'OutputFolder',output.Value,'SampleHz',str2double(fs.Value), ...
            'PixelSizeUm',str2double(px.Value),'SupportProfile',profile.Value);
        names={'Mouse','Condition','DrugID','Genotype','Promoter'};values={mouse.Value,condition.Value,drug.Value,genotype.Value,promoter.Value};
        for k=1:numel(names),if ~isempty(strtrim(values{k})),o.(names{k})=values{k};end,end
    end
    function request=prepare()
        assert(~State.Busy,'OxygenDynamics:RunBusy','Wait for the current operation.');invalidate([],[]);
        try
            request=prepareBOIRecordingRequest(options());State.Request=request;State.Status='prepared';
            details.Value=formatBOIWorkflowPreflight(request);
            showTissue(request.InputReview);
            confirm.Enable='on';status.Text='Preflight passed. Check settings and tissue support, then confirm to enable Run.';
        catch err
            State.Status='failed';status.Text=['Preflight failed: ' err.message];
            details.Value={'REQUIRED CORRECTION BEFORE RUN',err.message, ...
                'No analysis was started. Correct the input/settings, then review again.'};
            rethrow(err);
        end
    end
    function confirmation(~,~)
        runButton.Enable='off';if confirm.Value&&~isempty(State.Request),runButton.Enable='on';end
    end
    function result=execute()
        assert(~State.Busy&&confirm.Value&&~isempty(State.Request), ...
            'OxygenDynamics:RunNotConfirmed','Review and confirm this recording before running.');
        State.SelectedRun=[];State.Status='running';State.ProgressHistory={};
        State.LastRunStage='';State.FailedRunFolder='';setBusy(true);cleanup=onCleanup(@()setBusy(false));
        status.Text='Checking the confirmed request before claiming a new output directory.';drawnow;
        try
            current=prepareBOIRecordingRequest(options());
            assert(isequaln(current.Options,State.Request.Options),'OxygenDynamics:RunRequestChanged','Settings changed; review them again.');
            result=runBOIRecordingWorkflow(State.Request,@onRunProgress);
            State.SelectedRun=result;State.Status='complete';showResult();
        catch err
            State.Status='failed';State.Request=[];confirm.Value=false;
            if isempty(State.FailedRunFolder)
                status.Text=['Run could not start; no completed result selected. ' err.message];
                details.Value={'RUN DID NOT START',err.message,'No new run folder was claimed by this workflow.'};
            else
                failure=struct('Stage',State.LastRunStage,'ErrorID',err.identifier,'ErrorMessage',err.message);
                [status.Text,details.Value]=formatBOIRunFailure(failure,State.FailedRunFolder);
            end
            rethrow(err);
        end
    end
    function onRunProgress(runStatus,statusPath)
        State.LastRunStage=runStatus.Stage;
        State.ProgressHistory{end+1}=runStatus;
        State.FailedRunFolder=fileparts(statusPath);
        if isvalid(Fig)
            if strcmp(runStatus.Status,'failed')
                [status.Text,details.Value]=formatBOIRunFailure(runStatus,State.FailedRunFolder);
            elseif strcmp(runStatus.Status,'complete')
                status.Text='Complete. Checking and opening the saved result.';
            else
                status.Text=sprintf('Running — %s | %s',runStatus.Stage,State.FailedRunFolder);
            end
            drawnow;
            if ~isempty(StageObserver)
                try,StageObserver(Fig,runStatus);
                catch observerError
                    warning('OxygenDynamics:StageObserverFailed','Stage observer failed: %s',observerError.message);
                end
            end
        end
    end
    function selectRun(path)
        assert(~State.Busy,'OxygenDynamics:RunBusy','Wait for the current operation.');invalidate([],[]);
        try
            State.SelectedRun=loadBOIRecordingRun(path);State.Status='complete';showResult();
        catch err
            State.Status='failed';
            [failedFolder,failedStatus]=readBOIFailedStatus(path);
            if ~isempty(failedStatus)
                State.LastRunStage=failedStatus.Stage;State.FailedRunFolder=failedFolder;
                [status.Text,details.Value]=formatBOIRunFailure(failedStatus,failedFolder);
            else
                selectedFolder=char(path);if ~isfolder(selectedFolder),selectedFolder=fileparts(selectedFolder);end
                status.Text=['Cannot reopen run: ' err.message];
                details.Value={'SAVED RUN CANNOT BE OPENED', ...
                    ['Selected folder: ' selectedFolder], ...
                    ['Exact error ID: ' err.identifier],['Exact error: ' err.message], ...
                    'Keep this folder unchanged. Choose another completed run, or report this folder and error ID for repair.'};
            end
            rethrow(err);
        end
    end
    function showResult()
        r=State.SelectedRun;
        % Display the selected run's settings, not a previously edited input.
        savedOptions=r.Request.Options;
        textFields={'RecordingFolder','OutputFolder','Mouse','Condition','DrugID','Genotype','Promoter'};
        textControls={source,output,mouse,condition,drug,genotype,promoter};
        for fieldIndex=1:numel(textFields)
            textControls{fieldIndex}.Value=char(savedOptions.(textFields{fieldIndex}));
        end
        fs.Value=num2str(savedOptions.SampleHz,17);px.Value=num2str(savedOptions.PixelSizeUm,17);
        profile.Value=savedOptions.SupportProfile;
        showTissue(r.Request.InputReview);
        confirm.Enable='off';confirm.Value=false;runButton.Enable='off';
        eventButton.Enable=onoff(r.EventCount>0);windowButton.Enable='on';workbookButton.Enable='on';
        status.Text=sprintf('Selected completed run | %d automatic events | saved traces: %s',r.EventCount,r.CorrectedTraceStatus);
        details.Value={['Selected run: ' r.ManifestPath],['Recording: ' savedOptions.RecordingFolder], ...
            sprintf('Support: %s | %.9g Hz | %.9g µm/pixel',r.SupportProfile,savedOptions.SampleHz,savedOptions.PixelSizeUm), ...
            ['Output folder: ' r.Directory],['Workbook target: ' r.Paths.Workbook], ...
            ['Event evidence target: ' r.Paths.EventAudit],['Recording results target: ' r.Paths.DataOutput], ...
            'Inspect event traces: choose an automatic sink or surge event, then view corrected intensity and supporting score.', ...
            'Inspect recording results: switch signs, select a window, and export its saved evidence to a new folder.', ...
            'Open saved workbook uses the indexed workbook for this selected run.', ...
            'Automatic detections are preserved. Human review revisions remain separate files.', ...
            'A saved evidence export is not a full review session.'};
    end
    function showTissue(review)
        mask=resolveBOITissueSupport(review.TissueSnapshot, ...
            [review.Files.RawTiffInfo.Height review.Files.RawTiffInfo.Width],review.RawSHA256);
        if ~isempty(mask)
            imagesc(ax,mask,[0 1]);axis(ax,'image');colormap(ax,gray);
            title(ax,'Declared tissue support (dark interior retained)');
        else
            cla(ax);title(ax,'No declared tissue mask; legacy support selected');
        end
    end
    function [fig,ui]=openEvents()
        r=selected();[fig,ui]=openBOIEventReview(r.Paths.EventAudit,[],true);
        ui.AttachReferenceSources(r.Paths.SinkMaster,r.Paths.SurgeMaster);
    end
    function [fig,ui]=openWindows()
        r=selected();[fig,ui]=openBOIWindowReview(r.Paths.DataOutput,r);
        if ~isempty(ui.Events.Data),ui.ConnectAudit(r.Paths.EventAudit);
        elseif ui.Review.HasSurgeWindows
            ui.SelectSign('surge');if ~isempty(ui.Events.Data),ui.ConnectAudit(r.Paths.EventAudit);end
        end
    end
    function r=selected()
        assert(strcmp(State.Status,'complete')&&~isempty(State.SelectedRun), ...
            'OxygenDynamics:IncompleteRun','Select a completed saved run first.');
        r=loadBOIRecordingRun(State.SelectedRun.ManifestPath);
    end
    function targets=selectedTargets()
        r=selected();targets=struct('Run',r.ManifestPath,'SourceSHA256',r.SourceSHA256, ...
            'EventAudit',r.Paths.EventAudit,'DataOutput',r.Paths.DataOutput, ...
            'Workbook',r.Paths.Workbook,'OutputFolder',r.Directory);
    end
    function paths=listRuns(parent)
        assert(isfolder(parent),'OxygenDynamics:RunFolderMissing','Choose an existing results folder.');
        entries=dir(parent);folders={parent};paths={};dates=[];
        for k=1:numel(entries)
            if entries(k).isdir&&~ismember(entries(k).name,{'.','..'})
                folders{end+1}=fullfile(parent,entries(k).name); %#ok<AGROW>
            end
        end
        for k=1:numel(folders)
            folder=folders{k};
            index=fullfile(folder,'BOIRun.mat');statusFile=fullfile(folder,'RunStatus.json');
            if ~isfile(index)||~isfile(statusFile),continue;end
            try
                statusData=jsondecode(fileread(statusFile));
                if ~isfield(statusData,'Status')||~strcmp(statusData.Status,'complete'),continue;end
                saved=load(index,'Run');
                if ~isfield(saved,'Run')||~isstruct(saved.Run)||~isscalar(saved.Run)|| ...
                        ~all(isfield(saved.Run,{'Schema','Status'}))|| ...
                        ~strcmp(saved.Run.Schema,'boi-recording-run-1')|| ...
                        ~strcmp(saved.Run.Status,'complete'),continue;end
                paths{end+1}=index;info=dir(statusFile);dates(end+1)=info.datenum; %#ok<AGROW>
            catch
                % A malformed or partial candidate is not a completed run.
            end
        end
        [~,order]=sort(dates,'descend');paths=paths(order);
    end
    function openLatest(parent)
        paths=listRuns(parent);
        assert(~isempty(paths),'OxygenDynamics:NoCompletedRun','No completed BOIRun.mat was found in that folder or its immediate subfolders.');
        selectRun(paths{1});
    end
    function setBusy(value)
        State.Busy=value;
        for k=1:numel(controls),controls{k}.Enable=onoff(~value);end
        confirm.Enable='off';runButton.Enable='off';eventButton.Enable='off';windowButton.Enable='off';workbookButton.Enable='off';
        if ~value&&strcmp(State.Status,'complete'),showResult();end
        drawnow;
    end
    function chooseRecording(~,~)
        path=uigetdir(pwd,'Select one BOI recording folder');if isequal(path,0),return;end
        source.Value=path;invalidate([],[]);
    end
    function chooseOutput(~,~)
        path=uigetdir(pwd,'Choose parent for a new run folder');if isequal(path,0),return;end
        [~,name]=fileparts(tempname(path));output.Value=fullfile(path,['BOIRun_' name]);invalidate([],[]);
    end
    function chooseRun(~,~)
        choice=uiconfirm(Fig,'Find the latest completed run in a results folder, or choose a BOIRun.mat file.', ...
            'Open saved run','Options',{'Find in results folder','Choose BOIRun.mat','Cancel'}, ...
            'DefaultOption',1,'CancelOption',3);
        if strcmp(choice,'Cancel'),return;end
        try
            if strcmp(choice,'Find in results folder')
                parent=uigetdir(pwd,'Choose results folder (run folder or its parent)');if isequal(parent,0),return;end
                paths=listRuns(parent);
                assert(~isempty(paths),'OxygenDynamics:NoCompletedRun','No completed BOIRun.mat was found here. Choose a run folder or its parent.');
                if isscalar(paths),selectRun(paths{1});return;end
                [~,names]=cellfun(@fileparts,cellfun(@fileparts,paths,'UniformOutput',false),'UniformOutput',false);
                [selection,okay]=listdlg('PromptString','Choose a completed saved run:', ...
                    'ListString',names,'SelectionMode','single','InitialValue',1);
                if okay,selectRun(paths{selection});end
            else
                [file,path]=uigetfile('BOIRun.mat','Choose a completed BOIRun.mat');
                if ~isequal(file,0),selectRun(fullfile(path,file));end
            end
        catch err
            uialert(Fig,err.message,'Cannot reopen run');
        end
    end
    function workbookCallback(~,~)
        try
            targets=selectedTargets();open(targets.Workbook);
            status.Text=['Opened saved workbook: ' targets.Workbook];
        catch err
            uialert(Fig,err.message,'Cannot open workbook');
        end
    end
    function preflightCallback(~,~)
        try
            prepare();
        catch err
            uialert(Fig,err.message,'Preflight failed');
        end
    end
    function runCallback(~,~)
        try
            execute();
        catch err
            uialert(Fig,err.message,'Run failed');
        end
    end
    function eventCallback(~,~)
        try
            openEvents();
        catch err
            uialert(Fig,err.message,'Cannot inspect events');
        end
    end
    function windowCallback(~,~)
        try
            openWindows();
        catch err
            uialert(Fig,err.message,'Cannot inspect recording');
        end
    end
end
function place(control,row,column)
control.Layout.Row=row;control.Layout.Column=column;
end
function value=onoff(yes)
value='off';if yes,value='on';end
end
function [summary,lines]=formatBOIRunFailure(failure,folder)
stage=char(string(failure.Stage));errorID=char(string(failure.ErrorID));
errorMessage=char(string(failure.ErrorMessage));
sourceMissing=strcmp(stage,'staging')&&strcmpi(errorID,'MATLAB:COPYFILE:FileNotFound');
summary=sprintf('Run failed during %s; no completed result selected.',stage);
lines={['FAILED STAGE: ' stage]};
if sourceMissing
    summary='Run failed during staging: a required source file became unavailable. No completed result selected.';
    lines{end+1}='A required source file became unavailable.';
    lines{end+1}='Check the recording folder, choose a new output directory, then run Review settings again.';
else
    lines{end+1}='Retain this incomplete folder and report the exact error ID below before retrying.';
    lines{end+1}='After the cause is addressed, choose a new output directory and run Review settings again.';
end
lines=[lines,{['Exact error ID: ' errorID],['Exact error: ' errorMessage], ...
    ['Incomplete run folder retained: ' folder], ...
    'Inspect RunStatus.json there; do not reopen this folder as a completed run.'}];
end
function [folder,failed]=readBOIFailedStatus(path)
if isfolder(path),folder=char(path);else,folder=fileparts(char(path));end
failed=[];file=fullfile(folder,'RunStatus.json');
if ~isfile(file),return;end
try
    candidate=jsondecode(fileread(file));
    if isstruct(candidate)&&all(isfield(candidate,{'Status','Stage','ErrorID','ErrorMessage'}))&& ...
            strcmp(candidate.Status,'failed')
        failed=candidate;
    end
catch
    % Malformed status remains a normal incomplete-run error.
end
end
