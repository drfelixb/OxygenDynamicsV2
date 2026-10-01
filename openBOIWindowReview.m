function [Fig,UI]=openBOIWindowReview(Path,RunContext)
%OPENBOIWINDOWREVIEW Inspect saved recording/window calculation ingredients.
setupOxygenDynamicsPath;
if nargin<2,RunContext=[];end
if nargin<1
    [file,folder]=uigetfile('*.mat','Choose saved BOI DataOutput.mat');
    if isequal(file,0),Fig=[];UI=[];return;end
    Path=fullfile(folder,file);
end
R=loadBOIWindowReview(Path);W=R.RecordingWindowMetrics;Index=[];kind='sink';EventIndex=[];
auditPaths=containers.Map('KeyType','char','ValueType','char');
Fig=uifigure('Name','BOI recording and window review','Position',[60 50 1280 930]);
layout=uigridlayout(Fig,[2 1]);layout.RowHeight={42,'1x'};
uilabel(layout,'Text',['Saved results: ' R.Path ' | Scientific eligibility is not established.'], ...
    'Interpreter','none','WordWrap','on');
tabs=uitabgroup(layout);
main=uitab(tabs,'Title','Window calculation');frameTab=uitab(tabs,'Title','Frame ingredients');
eventTab=uitab(tabs,'Title','Event timing');supportTab=uitab(tabs,'Title','Saved tissue support');
definitionTab=uitab(tabs,'Title','Measurement definitions');definitions=createBOIMeasurementPanel(definitionTab);
mainGrid=uigridlayout(main,[6 1]);mainGrid.RowHeight={90,35,110,32,'1x',170};
windows=uitable(mainGrid,'Data',W(:,{'RecordingID','WindowID','StartSec','EndSec','OccupancyStatus'}), ...
    'SelectionType','row','Multiselect','off','RowName',{},'CellSelectionCallback',@chooseRow);
status=uilabel(mainGrid,'Text','Select a saved window.','WordWrap','on');
metrics=uitable(mainGrid,'Data',table(),'RowName',{});
actions=uigridlayout(mainGrid,[1 2]);actions.ColumnWidth={230,'1x'};actions.Padding=[0 0 0 0];
exportButton=uibutton(actions,'Text','Export selected window evidence','Enable','off','ButtonPushedFcn',@exportSelected);
signItems={'sink'};if R.HasSurgeWindows,signItems={'sink','surge'};end
signControl=uidropdown(actions,'Items',signItems,'Value','sink','ValueChangedFcn',@changeSign, ...
    'Tooltip','Each sign uses its own saved tissue support. Older exports have no surge window outcomes; unavailable is not zero.');
plots=uigridlayout(mainGrid,[1 2]);plots.Padding=[0 0 0 0];areaAxes=uiaxes(plots);timeAxes=uiaxes(plots);
detail=uitextarea(mainGrid,'Editable','off','Value',{'No saved windows; no biological zero is inferred.'});
frameGrid=uigridlayout(frameTab,[2 1]);frameGrid.RowHeight={140,'1x'};
checks=uitable(frameGrid,'Data',table(),'RowName',{});frames=uitable(frameGrid,'Data',table(),'RowName',{});
eventGrid=uigridlayout(eventTab,[3 1]);eventGrid.RowHeight={36,48,'1x'};
eventActions=uigridlayout(eventGrid,[1 3]);eventActions.Padding=[0 0 0 0];eventActions.ColumnWidth={200,190,'1x'};
attachButton=uibutton(eventActions,'Text','Choose saved event audit','ButtonPushedFcn',@chooseAudit,'Enable','off');
openEventButton=uibutton(eventActions,'Text','Open selected event evidence','ButtonPushedFcn',@openEventCallback,'Enable','off');
uilabel(eventActions,'Text','Choose a row to follow its trace, baseline and source image.','WordWrap','on');
eventStatus=uilabel(eventGrid,'Text','Select an event. Missing audit evidence is unavailable, not zero.','WordWrap','on','Interpreter','none');
events=uitable(eventGrid,'Data',table(),'RowName',{},'SelectionType','row','Multiselect','off','CellSelectionCallback',@chooseEvent);
supportGrid=uigridlayout(supportTab,[2 2]);supportGrid.RowHeight={55,'1x'};
supportNote=uilabel(supportGrid,'Text','Saved static support; dynamic validity is not established.','WordWrap','on');supportNote.Layout.Column=[1 2];
sinkAxes=uiaxes(supportGrid);surgeAxes=uiaxes(supportGrid);
for t=[windows metrics checks frames events]
    t.ForegroundColor=[.1 .1 .1];t.BackgroundColor=[1 1 1;.94 .96 .98];
end
UI=struct('Review',R,'Select',@selectWindow,'Windows',windows,'Metrics',metrics,'Checks',checks,'Frames',frames, ...
    'Sign',signControl,'SelectSign',@selectSign,'Events',events,'Detail',detail,'Status',status,'Definitions',definitions,'SupportNote',supportNote, ...
    'SinkAxes',sinkAxes,'SurgeAxes',surgeAxes,'ExportButton',exportButton, ...
    'SelectEvent',@selectEvent,'ConnectAudit',@connectAudit,'OpenEvent',@openEvent, ...
    'EventStatus',eventStatus,'OpenEventButton',openEventButton);
if height(W)>0,selectWindow(1);end
    function chooseRow(~,event)
        if ~isempty(event.Indices),selectWindow(event.Indices(1,1));end
    end
    function changeSign(~,~)
        selectSign(signControl.Value);
    end
    function selectSign(value)
        assert(ismember(value,signItems),'OxygenDynamics:WindowReviewMissingEvidence','Selected sign has no saved window evidence.');
        selected=table();if ~isempty(Index),selected=W(Index,{'RecordingID','WindowID'});end
        kind=value;signControl.Value=value;
        W=R.RecordingWindowMetrics;if strcmp(kind,'surge'),W=R.SurgeRecordingWindowMetrics;end
        windows.Data=W(:,{'RecordingID','WindowID','StartSec','EndSec','OccupancyStatus'});
        if ~isempty(selected),Index=find(ismember(W(:,{'RecordingID','WindowID'}),selected,'rows'));end
        if ~isempty(Index),selectWindow(Index);elseif height(W)>0,selectWindow(1);end
    end
    function selectWindow(index)
        D=buildBOIWindowReviewData(R,index,kind);Index=index;
        windows.Selection=index;scroll(windows,'row',index);
        metrics.Data=D.Metrics;checks.Data=D.Checks;frames.Data=D.Frames;events.Data=D.Events;detail.Value=D.Details;
        EventIndex=[];openEventButton.Enable='off';attachButton.Enable='off';
        eventStatus.Text='Select an event; saved audits can be created from BOI Measurements in the main window.';
        if height(D.Events)>0,selectEvent(1);else,eventStatus.Text='No detected events in this recording. No event evidence is inferred.';end
        failures=sum(D.Checks.Status=="mismatch")+sum(D.Metrics.ArithmeticStatus=="mismatch");
        status.Text=sprintf('%s | %s / %s | %d arithmetic/context mismatches; %d unavailable outcomes. Scientific eligibility remains open.', ...
            upper(kind),string(D.Window.RecordingID),string(D.Window.WindowID),failures,sum(D.Metrics.ArithmeticStatus=="unavailable"));
        exportButton.Enable='on';
        F=D.Frames;cla(areaAxes);plot(areaAxes,F.ModeledStartSec,F.OccupiedArea_um2,'LineWidth',1.3);
        title(areaAxes,['Saved native ' kind ' union inside tissue']);ylabel(areaAxes,'Covered area (µm²)');xlabel(areaAxes,'Modeled recording time (s)');grid(areaAxes,'on');
        cla(timeAxes);plot(timeAxes,F.ModeledStartSec,F.AnalyzedTissueTime_um2_sec,'LineWidth',1.3);
        finiteTime=F.AnalyzedTissueTime_um2_sec(isfinite(F.AnalyzedTissueTime_um2_sec));
        if ~isempty(finiteTime)&&all(finiteTime>=0),ylim(timeAxes,[0 max(1,1.05*max(finiteTime))]);end
        title(timeAxes,'Denominator contribution per frame');ylabel(timeAxes,'Analyzed tissue-time (µm²·s)');xlabel(timeAxes,'Modeled recording time (s)');grid(timeAxes,'on');
        C=D.Contract;supportNote.Text=sprintf('%s | %.6g µm/pixel as supplied. Masks show saved analysis support; anatomical accuracy and dynamic validity are not established.',C.TissueValidityStatus,C.PixelSizeUm);
        for k=1:2
            ax=sinkAxes;name='Sink';if k==2,ax=surgeAxes;name='Surge';end
            mask=false(C.FrameSize);p=C.([name 'EligibleTissuePixels']);mask(p)=true;
            imagesc(ax,mask,[0 1]);colormap(ax,gray);axis(ax,'image');
            title(ax,sprintf('%s saved support: %d pixels',name,numel(p)));xlabel(ax,'Column (pixel)');ylabel(ax,'Row (pixel)');
        end
    end
    function chooseEvent(~,event)
        if ~isempty(event.Indices),selectEvent(event.Indices(1,1));end
    end
    function selectEvent(index)
        assert(index>=1&&index<=height(events.Data)&&index==fix(index));EventIndex=index;events.Selection=index;
        attachButton.Enable='on';openEventButton.Enable='off';key=char(W.RecordingID(Index));
        if isKey(auditPaths,key)
            openEventButton.Enable='on';eventStatus.Text=['Selected audit: ' auditPaths(key) '. Source and event association will be rechecked when opening.'];
        else
            eventStatus.Text='Choose a saved event-amplitude-audit.mat for this recording. The connection checks source, mapping, support, timing and measurements.';
        end
    end
    function connectAudit(path)
        key=char(W.RecordingID(Index));
        if isKey(auditPaths,key),remove(auditPaths,key);end
        openEventButton.Enable='off';eventStatus.Text='Checking the selected saved audit...';drawnow;
        [linked,~]=linkBOIWindowEventReview(R,Index,EventIndex,path,kind);
        auditPaths(key)=linked.AuditPath;selectEvent(EventIndex);
        eventStatus.Text=['Checked source/event connection: ' linked.AuditPath];
    end
    function chooseAudit(~,~)
        [file,folder]=uigetfile('*.mat','Choose event-amplitude-audit.mat for the selected recording');if isequal(file,0),return;end
        try,connectAudit(fullfile(folder,file));catch err,eventStatus.Text=['Audit not connected: ' err.message];end
    end
    function [eventFigure,eventUI]=openEvent()
        key=char(W.RecordingID(Index));assert(isKey(auditPaths,key),'OxygenDynamics:WindowEventIdentity','Choose a saved event audit first.');
        context=struct('Review',R,'WindowIndex',Index,'EventIndex',EventIndex,'Kind',kind,'ParentFigure',Fig);
        [eventFigure,eventUI]=openBOIEventReview(auditPaths(key),context);
        if ~isempty(RunContext)
            eventUI.AttachReferenceSources(RunContext.Paths.SinkMaster,RunContext.Paths.SurgeMaster);
            eventUI.Tabs.SelectedTab=eventUI.TimingTab;
        end
        selected=definitions.SelectedPath();if ~isempty(selected),eventUI.Definitions.Load(selected);end
    end
    function openEventCallback(~,~)
        try,openEvent();catch err,eventStatus.Text=['Event evidence unavailable: ' err.message];end
    end
    function exportSelected(~,~)
        parent=uigetdir(fileparts(R.Path),'Choose parent folder for a NEW window review');if isequal(parent,0),return;end
        [~,uniqueName]=fileparts(tempname(parent));folder=fullfile(parent,['BOIWindowReview_' uniqueName]);
        try
            exportBOIWindowReview(R,Index,folder,definitions.SelectedPath(),kind);status.Text=['Exported: ' folder];
        catch err,uialert(Fig,err.message,'Window export failed');end
    end
end
