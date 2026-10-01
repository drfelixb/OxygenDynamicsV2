function [Fig,UI]=openBOIEventReview(AuditPath,WindowContext,StartOnEventList,HistoricalMetadataPath)
%OPENBOIEVENTREVIEW Inspect existing saved BOI audit evidence, without reruns.
setupOxygenDynamicsPath;
if nargin<1
    [file,folder]=uigetfile('*.mat','Choose saved event-amplitude-audit.mat');
    if isequal(file,0),Fig=[];UI=[];return;end
    AuditPath=fullfile(folder,file);
end
if nargin<3,StartOnEventList=false;end
initialIndex=1;
if nargin>=2&&~isempty(WindowContext)
    [Review,initialIndex]=linkBOIWindowEventReview(WindowContext.Review,WindowContext.WindowIndex, ...
        WindowContext.EventIndex,AuditPath,WindowContext.Kind);
else
    if nargin<4,HistoricalMetadataPath='';end
    Review=loadBOIEventReview(AuditPath,HistoricalMetadataPath);
end
A=Review.Audit;Index=[];
Fig=uifigure('Name','BOI saved event review','Position',[70 60 1280 900],'AutoResizeChildren','off');
Tabs=uitabgroup(Fig,'Position',[10 10 1260 880]);
Fig.SizeChangedFcn=@(~,~)set(Tabs,'Position',[10 10 Fig.Position(3)-20 Fig.Position(4)-20]);
EventTab=uitab(Tabs,'Title','Saved event evidence');
TimingTab=uitab(Tabs,'Title','Timing review');
TimingPanel=createBOITimingPanel(TimingTab,@()set(Tabs,'SelectedTab',EventTab),@selectTimingFrame);
ContextTab=uitab(Tabs,'Title','Optional context');
ContextPanel=createBOITemporalContextPanel(ContextTab,@chooseReferenceSources,@chooseReferenceJudgments);
BoundaryTab=uitab(Tabs,'Title','Researcher boundaries');
BoundaryPanel=createBOIBoundaryPanel(BoundaryTab,@()set(Tabs,'SelectedTab',TimingTab),@chooseBoundarySave,@chooseBoundaryLoad);
Fig.CloseRequestFcn=@closeReview;
BaselineTab=uitab(Tabs,'Title','Baseline diagnostic');
BaselinePanel=createBOIBaselinePanel(BaselineTab,@()set(Tabs,'SelectedTab',EventTab));
ReferenceTab=uitab(Tabs,'Title','Reviewed reference');
ReferencePanel=createBOIReviewedReferencePanel(ReferenceTab,@chooseReferenceSources,@()set(Tabs,'SelectedTab',TimingTab),@openReferenceContributor,@chooseReferenceJudgments);
OpticalTab=uitab(Tabs,'Title','Reviewed optical');
OpticalLayout=uigridlayout(OpticalTab,[1 1]);OpticalLayout.Padding=[0 0 0 0];OpticalModes=uitabgroup(OpticalLayout);
PocketTab=uitab(OpticalModes,'Title','Reviewed pocket (0.2.0)');
LegacyOpticalTab=uitab(OpticalModes,'Title','Legacy raw review (0.1.0)');
OpticalPanel=createBOIReviewedOpticalPanel(LegacyOpticalTab,@()set(Tabs,'SelectedTab',ReferenceTab),@()set(Tabs,'SelectedTab',TimingTab));
PocketPanel=createBOIReviewedPocketPanel(PocketTab,struct('Preview',@previewPocket,'Save',@choosePocketSave,'Load',@choosePocketLoad,'Export',@choosePocketExport));
DefinitionTab=uitab(Tabs,'Title','Measurement definitions');
Definitions=createBOIMeasurementPanel(DefinitionTab);
Grid=uigridlayout(EventTab,[6 1]);Grid.RowHeight={36,105,32,32,'1x',175};
heading=uigridlayout(Grid,[1 2]);heading.Padding=[0 0 0 0];heading.ColumnWidth={'1x',160};
Header=uilabel(heading,'Text',['Saved audit: ' Review.AuditPath ' | No scientific acceptance implied.'], ...
    'Interpreter','none','WordWrap','on');
back=uibutton(heading,'Text','Return to window','Enable','off','ButtonPushedFcn',@returnToWindow);
if nargin>=2&&~isempty(WindowContext)&&isfield(WindowContext,'ParentFigure')&&isgraphics(WindowContext.ParentFigure),back.Enable='on';end
baseline=string(A.RecomputedStatus);
for row=1:height(A)
    cleanCount=numel(Review.Traces{row}.CleanBaselineFrames);
    if cleanCount>0&&isfinite(A.RecomputedBaseline(row))
        baseline(row)=sprintf('Available (%d clean frames); %s',cleanCount,A.RecomputedStatus(row));
    else
        baseline(row)=sprintf('Unavailable (%d clean frames); %s',cleanCount,A.RecomputedStatus(row));
    end
end
Rows=table(string(A.EventType),A.SiteID,A.EventID,A.StartFrame,A.EndFrame, ...
    repmat("Automatic; not reviewed",height(A),1),baseline,100*A.StoredAmplitude, ...
    'VariableNames',{'Sign','Site','Event','StartFrame','EndFrame','ReviewStatus','BaselineAvailability','AmplitudePercent'});
List=uitable(Grid,'Data',Rows,'RowName',{},'CellSelectionCallback',@selectRow, ...
    'SelectionType','row','Multiselect','off','ForegroundColor',[.1 .1 .1], ...
    'BackgroundColor',[1 1 1;.94 .96 .98], ...
    'ColumnName',{'Sign','Site','Event','Start frame','End frame','Review status','Baseline availability','Amplitude (%)'});
Actions=uigridlayout(Grid,[1 4]);Actions.Padding=[0 0 0 0];Actions.ColumnWidth={180,150,210,'1x'};
Frame=uispinner(Actions,'Limits',[1 max(2,Review.AnalysisInfo.NFrames)],'Step',1,'Value',1,'ValueChangedFcn',@clearFrameView);
ImageButton=uibutton(Actions,'Text','Show source frame','ButtonPushedFcn',@showFrame,'Enable','off');
ExportButton=uibutton(Actions,'Text','Export selected evidence','ButtonPushedFcn',@exportSelected,'Enable','off');
ImageStatus=uilabel(Actions,'Text','Select an event.','Interpreter','none','WordWrap','on');
NativeActions=uigridlayout(Grid,[1 3]);NativeActions.Padding=[0 0 0 0];NativeActions.ColumnWidth={190,230,'1x'};
NativeButton=uibutton(NativeActions,'Text','Attach native masks','ButtonPushedFcn',@chooseNativeMaster,'Enable','off');
Overlay=uidropdown(NativeActions,'Items',{'Fixed amplitude footprint'},'ItemsData',{'fixed'},'ValueChangedFcn',@showFrame);
NativeStatus=uilabel(NativeActions,'Text','Native masks unavailable until a matching master is attached.','WordWrap','on');
Plots=uigridlayout(Grid,[1 2]);Plots.ColumnWidth={'1x','1x'};Plots.Padding=[0 0 0 0];
ImageAxes=uiaxes(Plots);axis(ImageAxes,'off');
TracePlots=uigridlayout(Plots,[2 1]);TracePlots.Padding=[0 0 0 0];
RawAxes=uiaxes(TracePlots);FractionAxes=uiaxes(TracePlots);
if height(A)==0
    initialDetail={'No saved events. This does not establish a valid biological zero.'};
else
    initialDetail={'Choose a sink or surge event in the list. Automatic detections are not biological judgments.', ...
        'The Timing review then shows corrected intensity first and detection score as supporting evidence. Raw/correction QA is optional.'};
end
Detail=uitextarea(Grid,'Editable','off','Value',initialDetail);
UI=struct('Review',Review,'Select',@selectEvent,'List',List,'Frame',Frame,'ImageButton',ImageButton, ...
    'ImageAxes',ImageAxes,'RawAxes',RawAxes,'FractionAxes',FractionAxes,'Detail',Detail, ...
    'ImageStatus',ImageStatus,'Definitions',Definitions,'ExportButton',ExportButton,'Header',Header, ...
    'AttachNative',@attachNative,'CurrentReview',@currentReview,'Overlay',Overlay,'NativeStatus',NativeStatus,'ReturnToWindow',back, ...
    'Context',ContextPanel,'ContextTab',ContextTab,'Baseline',BaselinePanel,'BaselineTab',BaselineTab,'Timing',TimingPanel,'TimingTab',TimingTab,'EventTab',EventTab,'Tabs',Tabs,'CurrentIndex',@currentIndex, ...
    'Boundaries',BoundaryPanel,'BoundaryTab',BoundaryTab,'SaveBoundaries',@saveBoundaries,'LoadBoundaries',@loadBoundaries, ...
    'Pocket',PocketPanel,'PocketTab',PocketTab,'OpticalModes',OpticalModes,'PreviewPocket',@previewPocket, ...
    'SavePocket',@savePocket,'LoadPocket',@loadPocket,'ExportPocket',@exportPocket,'ExportSelected',@exportSelectedTo, ...
    'Optical',OpticalPanel,'OpticalTab',OpticalTab,'Reference',ReferencePanel,'ReferenceTab',ReferenceTab,'AttachReferenceSources',@attachReferenceSources,'LoadReferenceJudgments',@loadReferenceJudgments);
if height(A)>0&&~StartOnEventList,selectEvent(initialIndex);end
    function result=currentIndex()
        result=Index;
    end
    function returnToWindow(~,~)
        if isgraphics(WindowContext.ParentFigure),figure(WindowContext.ParentFigure);else,back.Enable='off';end
    end
    function selectRow(~,event)
        if ~isempty(event.Indices),selectEvent(event.Indices(1,1));end
    end
    function selectEvent(index)
        Data=buildBOIEventReviewData(Review,index);Index=index;
        BaselinePanel.Update(Data);
        TimingPanel.Update(Data);
        ContextPanel.SetReview(Review,index);
        BoundaryPanel.Update(Review,index);
        ReferencePanel.Update(Review,index);OpticalPanel.Update(Review,index);PocketPanel.Update(Review,index);
        List.Selection=index;scroll(List,'row',index);
        Detail.Value=Data.Details;Frame.Value=A.DetectedStartFrame(Index);
        NativeButton.Enable='on';Overlay.ItemsData={};Overlay.Items={'Fixed amplitude footprint'};Overlay.ItemsData={'fixed'};Overlay.Value='fixed';
        NativeStatus.Text='Native masks unavailable until a matching master is attached.';
        if isfield(Review,'NativeMasks')&&~isempty(Review.NativeMasks{Index})
            Overlay.ItemsData={};Overlay.Items={'Fixed amplitude footprint','Native mask at this frame'};Overlay.ItemsData={'fixed','native'};
            NativeStatus.Text=Review.NativeMasks{Index}.Association;
        end
        ImageButton.Enable='on';ExportButton.Enable='on';cla(ImageAxes);axis(ImageAxes,'off');
        title(ImageAxes,'Source image not loaded');ImageStatus.Text='Show source frame to verify its checksum and view pixels.';
        F=Data.Frames;window=F.Frame>=max(1,A.StartFrame(Index)-40*Review.AnalysisInfo.AnalysisParams.fs)& ...
            F.Frame<=min(Review.AnalysisInfo.NFrames,A.EndFrame(Index)+40*Review.AnalysisInfo.AnalysisParams.fs);
        cla(RawAxes);plot(RawAxes,F.ModeledTimeSec(window),F.PreservedInputMean(window),'LineWidth',1.3);hold(RawAxes,'on');
        scatter(RawAxes,F.ModeledTimeSec(F.CleanBaseline),F.PreservedInputMean(F.CleanBaseline),15,[0 .6 .2],'filled');
        if isfinite(A.RecomputedBaseline(Index)),yline(RawAxes,A.RecomputedBaseline(Index),'--');end
        ylabel(RawAxes,'Preserved input (a.u.)');title(RawAxes,'Fixed-footprint trace; green = clean baseline');
        cla(FractionAxes);plot(FractionAxes,F.ModeledTimeSec(window),100*F.SignedFraction(window),'LineWidth',1.3);
        ylabel(FractionAxes,'Signed optical change (%)');xlabel(FractionAxes,'Modeled recording time (s)');
        title(FractionAxes,'Signed trace; no sign correction to match detection');
        for ax=[RawAxes FractionAxes]
            hold(ax,'on');fs=Review.AnalysisInfo.AnalysisParams.fs;
            xline(ax,(A.StartFrame(Index)-1)/fs,'r--');xline(ax,A.EndFrame(Index)/fs,'r--');
            xline(ax,(A.DetectedStartFrame(Index)-1)/fs,'b:');xline(ax,A.DetectedEndFrame(Index)/fs,'b:');
            grid(ax,'on');hold(ax,'off');
        end
    end
    function showFrame(~,~)
        TimingPanel.SetFrame(Frame.Value);
        cla(ImageAxes);axis(ImageAxes,'off');
        delete(findall(Fig,'Tag','BOIShownFrame'));
        Data=buildBOIEventReviewData(Review,Index);Detail.Value=Data.Details;
        try
            [plane,mask]=readBOIEventReviewFrame(Review,Index,Frame.Value,Overlay.Value);
            imagesc(ImageAxes,plane);colormap(ImageAxes,gray);axis(ImageAxes,'image');hold(ImageAxes,'on');
            color=[1 .45 0];label='FIXED amplitude footprint';
            if strcmp(Overlay.Value,'native'),color=[0 .9 .9];label=sprintf('NATIVE mask: %d pixels',nnz(mask));end
            if any(mask(:)),contour(ImageAxes,mask,[.5 .5],'Color',color,'LineWidth',1);end
            hold(ImageAxes,'off');title(ImageAxes,sprintf('Frame %d + %s',Frame.Value,label));
            xlabel(ImageAxes,'Image column (pixel)');ylabel(ImageAxes,'Image row (pixel)');
            for ax=[RawAxes FractionAxes]
                xline(ax,(Frame.Value-1)/Review.AnalysisInfo.AnalysisParams.fs,'-.', ...
                    'Color',[.6 .6 .6],'Tag','BOIShownFrame');
            end
            ImageStatus.Text='Source checksum matched. Orange = fixed union, not native mask.';
            if strcmp(Overlay.Value,'native')
                ImageStatus.Text=sprintf('Source/master checksums matched. Cyan = selected event at frame %d (%d pixels).',Frame.Value,nnz(mask));
                if ~any(mask(:)),ImageStatus.Text=[ImageStatus.Text ' Known empty outside its native run.'];end
            end
        catch err
            title(ImageAxes,'Source image unavailable');ImageStatus.Text=err.message;
            Detail.Value=[{['IMAGE UNAVAILABLE: ' err.message]};Data.Details];
        end
    end
    function clearFrameView(~,~)
        TimingPanel.SetFrame(Frame.Value);
        cla(ImageAxes);axis(ImageAxes,'off');title(ImageAxes,'Source image not loaded for selected frame');
        delete(findall(Fig,'Tag','BOIShownFrame'));
        ImageStatus.Text='Press Show source frame to view the selected frame.';
    end
    function selectTimingFrame(value)
        Frame.Value=value;clearFrameView([],[]);
    end
    function result=currentReview()
        result=Review;
    end
    function openReferenceContributor(row)
        selectEvent(row);Tabs.SelectedTab=TimingTab;
    end
    function loadReferenceJudgments(paths)
        if isfield(Review,'ReferenceJudgments'),Review=rmfield(Review,'ReferenceJudgments');end
        if ~isempty(Index),ReferencePanel.Update(Review,Index);OpticalPanel.Update(Review,Index);ContextPanel.SetReview(Review,Index);end
        Review=loadBOIReferenceJudgments(Review,paths);
        if ~isempty(Index),ReferencePanel.Update(Review,Index);OpticalPanel.Update(Review,Index);ContextPanel.SetReview(Review,Index);end
    end
    function chooseReferenceJudgments()
        [files,folder]=uigetfile('*.json','Choose saved reference judgments','MultiSelect','on');
        if isequal(files,0),return;end
        try,loadReferenceJudgments(fullfile(folder,cellstr(string(files))));catch err
            uialert(Fig,err.message,'Reference judgments not loaded');
        end
    end
    function attachReferenceSources(sinkPath,surgePath)
        if isfield(Review,'ReferenceSources'),Review=rmfield(Review,'ReferenceSources');end
        if ~isempty(Index),ReferencePanel.Update(Review,Index);OpticalPanel.Update(Review,Index);ContextPanel.SetReview(Review,Index);end
        Review=attachBOIReferenceSources(Review,sinkPath,surgePath);
        if ~isempty(Index),ReferencePanel.Update(Review,Index);OpticalPanel.Update(Review,Index);ContextPanel.SetReview(Review,Index);end
    end
    function chooseReferenceSources()
        [sink,folder]=uigetfile('*.mat','Choose matching SINK master for both-sign reference screening');
        if isequal(sink,0),return;end
        sinkPath=fullfile(folder,sink);
        [surge,folder]=uigetfile('*.mat','Choose matching SURGE master for both-sign reference screening');
        if isequal(surge,0),return;end
        try,attachReferenceSources(sinkPath,fullfile(folder,surge));catch err
            uialert(Fig,err.message,'Reference sources not attached');
        end
    end
    function attachNative(path)
        assert(~isempty(Index),'Select an event before attaching masks.');
        if isfield(Review,'NativeMasks'),Review.NativeMasks{Index}=[];end
        selectEvent(Index);
        Review=attachBOINativeMasks(Review,Index,path);selectEvent(Index);
        Overlay.Value='native';showFrame([],[]);
    end
    function chooseNativeMaster(~,~)
        [file,folder]=uigetfile('*.mat','Choose saved sink or surge master matching the selected event');
        if isequal(file,0),return;end
        try,attachNative(fullfile(folder,file));catch err
            NativeStatus.Text=['Native masks not attached: ' err.message];
            uialert(Fig,err.message,'Cannot attach native masks');
        end
    end
    function saveBoundaries(path)
        a=BoundaryPanel.ReadDraft();previous=[];
        if isfield(Review,'BoundaryReview'),previous=Review.BoundaryReview;end
        store=saveBOIBoundaryReview(Review,Index,a,path,previous);
        Review.BoundaryReview=store;BoundaryPanel.Saved();selectEvent(Index);
    end
    function loadBoundaries(path)
        store=loadBOIBoundaryReview(Review,path);Review.BoundaryReview=store;selectEvent(Index);
    end
    function chooseBoundarySave()
        try
            BoundaryPanel.ReadDraft(); % Validate before asking for a destination.
            [file,folder]=uiputfile('*.json','Save a NEW researcher review revision',fullfile(fileparts(Review.AuditPath),'BOI-researcher-review.json'));
            if isequal(file,0),return;end
            saveBoundaries(fullfile(folder,file));
        catch err,uialert(Fig,err.message,'Boundary revision not saved');end
    end
    function chooseBoundaryLoad()
        [file,folder]=uigetfile('*.json','Load researcher review for this audit');
        if isequal(file,0),return;end
        try,loadBoundaries(fullfile(folder,file));catch err,uialert(Fig,err.message,'Boundary review not loaded');end
    end
    function closeReview(~,~)
        if BoundaryPanel.HasDrafts()||PocketPanel.HasDrafts()
            choice=uiconfirm(Fig,'Unsaved researcher drafts will be lost. Save NEW revisions in Researcher boundaries or Reviewed optical to retain them.', ...
                'Unsaved researcher drafts','Options',{'Keep reviewing','Discard drafts and close'},'DefaultOption',1,'CancelOption',1);
            if strcmp(choice,'Keep reviewing'),return;end
        end
        delete(Fig);
    end
    function e=previewPocket()
        j=PocketPanel.ReadDraft();e=buildBOIReviewedPocketEvidence(Review,Index,j);PocketPanel.ShowPreview(e);
    end
    function store=savePocket(folder)
        e=PocketPanel.Current();
        assert(~isempty(e),'OxygenDynamics:PocketPreviewRequired','Preview the current draft before saving.');
        store=saveBOIReviewedPocketEvidence(e,folder);Review=attachBOIPocketEvidence(Review,Index,folder);PocketPanel.Update(Review,Index);
    end
    function store=loadPocket(folder)
        store=loadBOIReviewedPocketEvidence(folder);Review=attachBOIPocketEvidence(Review,Index,folder);PocketPanel.Update(Review,Index);
        Tabs.SelectedTab=OpticalTab;OpticalModes.SelectedTab=PocketTab;
    end
    function store=exportPocket(folder)
        assert(isfield(Review,'PocketEvidence')&&numel(Review.PocketEvidence)>=Index&&~isempty(Review.PocketEvidence{Index}), ...
            'OxygenDynamics:PocketSavedRequired','Save or reopen a revision before exporting. Unsaved drafts are excluded.');
        store=exportBOIReviewedPocketEvidence(Review.PocketEvidence{Index},folder);
    end
    function choosePocketSave()
        assert(~isempty(PocketPanel.Current()),'OxygenDynamics:PocketPreviewRequired','Preview the current draft before saving.');
        parent=uigetdir(fileparts(Review.AuditPath),'Choose PARENT folder; a NEW revision child will be created');if isequal(parent,0),return;end
        [~,name]=fileparts(tempname(parent));savePocket(fullfile(parent,['ReviewedPocket_' name]));
    end
    function choosePocketLoad()
        folder=uigetdir(fileparts(Review.AuditPath),'Choose the COMPLETED evidence folder itself for this event');if isequal(folder,0),return;end
        loadPocket(folder);
    end
    function choosePocketExport()
        parent=uigetdir(fileparts(Review.AuditPath),'Choose PARENT folder; a NEW export child will be created');if isequal(parent,0),return;end
        [~,name]=fileparts(tempname(parent));target=fullfile(parent,['ReviewedPocketExport_' name]);exportPocket(target);
        PocketPanel.State.Text='EXPORTED saved revision. Full folder path is at the top of the details.';
        PocketPanel.State.Tooltip=target;PocketPanel.Details.Value=[{['Exported folder: ' target]};PocketPanel.Details.Value];
    end
    function receipt=exportSelectedTo(folder)
        receipt=exportBOIEventReview(Review,Index,folder,Definitions.SelectedPath());
    end
    function exportSelected(~,~)
        parent=uigetdir(fileparts(Review.AuditPath),'Choose parent folder for a NEW event review');
        if isequal(parent,0),return;end
        [~,uniqueName]=fileparts(tempname(parent));folder=fullfile(parent,['BOIEventReview_' uniqueName]);
        try
            exportBOIEventReview(Review,Index,folder,Definitions.SelectedPath());
            ImageStatus.Text=['Exported: ' folder];
        catch err,uialert(Fig,err.message,'Evidence export failed');end
    end
end
