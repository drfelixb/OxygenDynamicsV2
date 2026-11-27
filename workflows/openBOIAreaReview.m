function Panel=openBOIAreaReview(Fig,UI,MeasurementFolder,OutputRoot,RecoveredFrames)
% Explicit single-event frame-area review, attached to the existing viewer.
if nargin<5,RecoveredFrames=[];end
R=UI.CurrentReview();D=createBOIAreaReview(R,UI.CurrentIndex(),MeasurementFolder,RecoveredFrames);
OutputRoot=char(java.io.File(OutputRoot).getCanonicalPath());if ~isfolder(OutputRoot),mkdir(OutputRoot);end
previousPanel=getappdata(Fig,'BOIAreaReviewUI');
if isstruct(previousPanel)&&isfield(previousPanel,'HasDrafts')
    assert(~previousPanel.HasDrafts(),'OxygenDynamics:AreaReviewDraft','Save the existing area draft before reopening.');
    if isgraphics(previousPanel.Tab),delete(previousPanel.Tab);end
end
Cache=getappdata(Fig,'BOIAreaReviewCache');
if isempty(Cache),Cache=prepareBOIAreaImages(D,R,OutputRoot);setappdata(Fig,'BOIAreaReviewCache',Cache);end
assert(strcmp(Cache.ContextSHA256,D.ContextSHA256),'OxygenDynamics:AreaReviewSource','Cached images belong to another measurement.');
initial=fullfile(OutputRoot,'AreaReview_0001_initial');
if ~isfolder(initial)
    D.Reviewer='System (unreviewed initialization)';D.Reason='All frames are unreviewed. Saved detections are suggestions only.';
    Previous=saveBOIAreaReview(D,initial);
else
    Previous=loadBOIAreaReview(fullfile(initial,'AreaReview.json'));
end
latest=fullfile(OutputRoot,'LatestRevision.json');
if isfile(latest)
    pointer=jsondecode(fileread(latest));candidate=loadBOIAreaReview(pointer.Path);
    assert(strcmp(candidate.SHA256,pointer.SHA256)&&strcmp(candidate.Document.ContextSHA256,D.ContextSHA256), ...
        'OxygenDynamics:AreaReviewSource','Latest revision changed or belongs to another measurement.');
    Previous=candidate;
end
D=Previous.Document;C=D.Context;sz=C.FrameSize(:)';index=1;dirty=false;closingDiscard=false;cancelActiveDrawing=[];undo=cell(numel(C.Frames),1);
Tab=uitab(UI.Tabs,'Title','Reviewed frame areas');G=uigridlayout(Tab,[8 1]);G.RowHeight={34,48,34,34,'1x',74,112,64};
heading=uigridlayout(G,[1 2]);heading.Padding=[0 0 0 0];heading.ColumnWidth={'1x',180};
uilabel(heading,'Text',sprintf('Reviewed area - sink site %d / event %d - %d frames',C.SiteID,C.EventID,numel(C.Frames)),'FontSize',15,'FontWeight','bold');
uibutton(heading,'Text','Compare / playback','ButtonPushedFcn',@(~,~)guard(@compare));
summary=uilabel(G,'Text','','WordWrap','on');
nav=uigridlayout(G,[1 8]);nav.Padding=[0 0 0 0];nav.ColumnWidth={55,105,65,150,150,140,160,'1x'};
uibutton(nav,'Text','Prev','ButtonPushedFcn',@(~,~)move(-1));
frame=uidropdown(nav,'Items',cellstr(string(C.Frames(:)')),'ItemsData',num2cell(C.Frames(:)'),'Value',C.Frames(1),'ValueChangedFcn',@chooseFrame);
uibutton(nav,'Text','Next','ButtonPushedFcn',@(~,~)move(1));
source=uidropdown(nav,'Items',{'Denoised input','Original raw'},'ItemsData',{'denoised','raw'},'Value','denoised','ValueChangedFcn',@(~,~)render());
uibutton(nav,'Text','Next unreviewed','ButtonPushedFcn',@(~,~)nextUnreviewed());
uibutton(nav,'Text','Save revision','ButtonPushedFcn',@(~,~)guard(@saveCurrent));
uibutton(nav,'Text','Reopen revision','ButtonPushedFcn',@(~,~)guard(@reopen));
savedLabel=uilabel(nav,'Text','Saved initial revision; 0 accepted','WordWrap','on');
who=uigridlayout(G,[1 6]);who.Padding=[0 0 0 0];who.ColumnWidth={65,130,55,'1x',65,'1x'};
reviewerName='Felix';reviewReason='Per-frame area review of the approved longer pocket';
if D.Revision>1&&~startsWith(D.Reviewer,'Software verification'),reviewerName=D.Reviewer;reviewReason=D.Reason;end
uilabel(who,'Text','Reviewer');reviewer=uieditfield(who,'text','Value',reviewerName,'ValueChangedFcn',@markDirty);
uilabel(who,'Text','Reason');reason=uieditfield(who,'text','Value',reviewReason,'ValueChangedFcn',@markDirty);
uilabel(who,'Text','Frame note');note=uieditfield(who,'text','ValueChangedFcn',@editNote);
cleanReviewer=reviewer.Value;cleanReason=reason.Value;
plots=uigridlayout(G,[1 2]);plots.Padding=[0 0 0 0];plots.BackgroundColor=[1 1 1];imageAx=uiaxes(plots);changeAx=uiaxes(plots);
actions=uigridlayout(G,[2 5]);actions.Padding=[0 0 0 0];actions.RowHeight={30,30};
acceptSaved=uibutton(actions,'Text','Accept saved mask','ButtonPushedFcn',@(~,~)acceptSuggestion());
acceptDrawn=uibutton(actions,'Text','Accept drawn area','ButtonPushedFcn',@(~,~)acceptCurrent());
uibutton(actions,'Text','No pocket area','ButtonPushedFcn',@(~,~)decide('empty'));
uibutton(actions,'Text','Uncertain','ButtonPushedFcn',@(~,~)decide('uncertain'));
uibutton(actions,'Text','Reset to unreviewed','ButtonPushedFcn',@(~,~)resetFrame());
uibutton(actions,'Text','Draw / replace','ButtonPushedFcn',@(~,~)drawRegion('replace'));
uibutton(actions,'Text','Add region','ButtonPushedFcn',@(~,~)drawRegion('add'));
uibutton(actions,'Text','Erase region / hole','ButtonPushedFcn',@(~,~)drawRegion('erase'));
undoButton=uibutton(actions,'Text','Undo frame change','ButtonPushedFcn',@(~,~)undoFrame());
useSaved=uibutton(actions,'Text','Use saved as draft','ButtonPushedFcn',@(~,~)draftSuggestion());
tableView=uitable(G,'ColumnName',{'Frame','Status','Area pixels','Outside cyan'},'ColumnWidth',{65,120,110,'auto'},'RowName',{},'CellSelectionCallback',@chooseRow);
message=uilabel(G,'Text','','WordWrap','on');
oldClose=Fig.CloseRequestFcn;Fig.CloseRequestFcn=@closeWithArea;
Panel=struct('Tab',Tab,'HasDrafts',@hasDrafts,'Current',@current,'LastSaved',@lastSaved, ...
    'Save',@saveCurrent,'Frame',frame,'Source',source,'Table',tableView,'Summary',summary);
setappdata(Fig,'BOIAreaReviewUI',Panel);UI.Tabs.SelectedTab=Tab;render();figure(Fig);drawnow;
    function yes=hasDrafts(),yes=dirty&&~closingDiscard;end
    function value=current(),value=D;end
    function value=lastSaved(),value=Previous;end
    function compare(),openBOIAreaComparison(Fig,Panel);end
    function markDirty(~,~),dirty=true;render();end
    function editNote(~,~),remember();D.FrameDecisions(index).Note=note.Value;dirty=true;render();end
    function remember(),undo{index}=D.FrameDecisions(index);end
    function chooseFrame(~,~),index=find(C.Frames==frame.Value);render();end
    function chooseRow(~,e),if ~isempty(e.Indices),index=e.Indices(1,1);render();end,end
    function move(delta),index=max(1,min(numel(C.Frames),index+delta));render();end
    function nextUnreviewed()
        s=string({D.FrameDecisions.Status});j=find(s=="unreviewed"|s=="uncertain",1);if ~isempty(j),index=j;end;render();
    end
    function advance()
        if index<numel(C.Frames),index=index+1;end;render();
    end
    function acceptSuggestion()
        p=Cache.Suggestions{index};if isempty(p),return;end
        if isempty(strtrim(reviewer.Value)),uialert(Fig,'Enter the reviewer name before accepting a frame.','Reviewer required');return;end
        remember();D.FrameDecisions(index).Pixels=p;D.FrameDecisions(index).Origin='researcher_accepted_saved_detection';
        decide('accepted',false);
    end
    function draftSuggestion()
        p=Cache.Suggestions{index};if isempty(p),return;end
        remember();F=D.FrameDecisions(index);F.Pixels=p;F.Status='unreviewed';
        F.Origin='saved_detection_draft';F.Reviewer='';F.DecidedUTC='';
        D.FrameDecisions(index)=F;dirty=true;render();
    end
    function acceptCurrent()
        if isempty(D.FrameDecisions(index).Pixels),uialert(Fig,'Draw an area, or explicitly choose No pocket area.','No area selected');return;end
        decide('accepted');
    end
    function decide(status,keepUndo)
        if nargin<2,keepUndo=true;end
        if isempty(strtrim(reviewer.Value)),uialert(Fig,'Enter the reviewer name before accepting a frame.','Reviewer required');return;end
        if keepUndo,remember();end
        F=D.FrameDecisions(index);F.Status=status;
        if strcmp(status,'empty'),F.Pixels=[];F.Origin='researcher_confirmed_empty';end
        F.Reviewer=strtrim(reviewer.Value);F.DecidedUTC=char(datetime('now','TimeZone','UTC','Format','yyyy-MM-dd''T''HH:mm:ss''Z'''));
        D.FrameDecisions(index)=F;dirty=true;advance();
    end
    function resetFrame()
        remember();D.FrameDecisions(index).Status='unreviewed';D.FrameDecisions(index).Pixels=[];
        D.FrameDecisions(index).Origin='none';D.FrameDecisions(index).Reviewer='';D.FrameDecisions(index).DecidedUTC='';dirty=true;render();
    end
    function undoFrame()
        if isempty(undo{index}),return;end
        old=D.FrameDecisions(index);D.FrameDecisions(index)=undo{index};undo{index}=old;dirty=true;render();
    end
    function drawRegion(mode)
        % Keep placement nonblocking so Cancel and close remain responsive.
        points=zeros(0,2);dragging=false;outside=false;restored=false;roi=[];
        oldDown=Fig.WindowButtonDownFcn;oldMotion=Fig.WindowButtonMotionFcn;oldUp=Fig.WindowButtonUpFcn;
        drawing=[num2cell(findall(nav,'-property','Enable'));num2cell(findall(actions,'-property','Enable'));{reviewer;reason;note;tableView}];
        drawing=drawing(:)';
        for disableIndex=1:numel(drawing),drawing{disableIndex}.Enable='off';end
        undoButton.Enable='on';undoButton.Text='Cancel drawing';undoButton.ButtonPushedFcn=@(~,~)cancelDrawing();
        message.Text='Drag an outline on the left image and release to finish, or choose Cancel drawing.';
        cancelActiveDrawing=@cancelDrawing;
        try
            roi=images.roi.Freehand(imageAx,'Color',[.1 .8 .2],'InteractionsAllowed','none');
            Fig.WindowButtonDownFcn=@startStroke;Fig.WindowButtonMotionFcn=@moveStroke;Fig.WindowButtonUpFcn=@finishStroke;
        catch err
            restoreControls();uialert(Fig,err.message,'Area drawing');
        end
        function startStroke(~,~)
            point=imageAx.CurrentPoint(1,1:2);
            if ~insideCrop(point),return;end
            points=point;dragging=true;
        end
        function moveStroke(~,~)
            if ~dragging,return;end
            point=imageAx.CurrentPoint(1,1:2);
            if ~insideCrop(point),outside=true;return;end
            points(end+1,:)=point;
            if size(points,1)>=3&&isvalid(roi),roi.Position=points;end
        end
        function finishStroke(~,~)
            if ~dragging,return;end
            try
                moveStroke([],[]);dragging=false;
                if ~outside&&size(points,1)>=3
                    [x,y]=meshgrid(Cache.Columns,Cache.Rows);inside=inpolygon(x,y,points(:,1),points(:,2));
                    p=sort(sub2ind(sz,y(inside),x(inside)));
                    if ~isempty(p)
                        remember();F=D.FrameDecisions(index);
                        switch mode
                            case 'replace',F.Pixels=p;
                            case 'add',F.Pixels=union(F.Pixels,p);
                            case 'erase',F.Pixels=setdiff(F.Pixels,p);
                        end
                        F.Status='unreviewed';F.Origin='researcher_drawn_or_edited';F.Reviewer='';F.DecidedUTC='';
                        D.FrameDecisions(index)=F;
                    end
                end
                restoreControls();
            catch err
                restoreControls();uialert(Fig,err.message,'Area drawing');
            end
        end
        function yes=insideCrop(point)
            yes=all(isfinite(point))&&point(1)>=Cache.Columns(1)&&point(1)<=Cache.Columns(end)&& ...
                point(2)>=Cache.Rows(1)&&point(2)<=Cache.Rows(end);
        end
        function cancelDrawing()
            restoreControls();
        end
        function restoreControls()
            if restored,return;end
            restored=true;cancelActiveDrawing=[];
            if ~isempty(roi)&&isvalid(roi),delete(roi);end
            Fig.WindowButtonDownFcn=oldDown;Fig.WindowButtonMotionFcn=oldMotion;Fig.WindowButtonUpFcn=oldUp;
            for restoreIndex=1:numel(drawing)
                if isvalid(drawing{restoreIndex}),drawing{restoreIndex}.Enable='on';end
            end
            undoButton.Text='Undo frame change';undoButton.ButtonPushedFcn=@(~,~)undoFrame();render();
        end
    end
    function store=saveCurrent()
        D.Reviewer=strtrim(reviewer.Value);D.Reason=strtrim(reason.Value);
        name=['AreaReview_' char(java.util.UUID.randomUUID())];store=saveBOIAreaReview(D,fullfile(OutputRoot,name),Previous);
        Previous=store;D=store.Document;cleanReviewer=reviewer.Value;cleanReason=reason.Value;dirty=false;savedLabel.Text=sprintf('Saved revision %d',D.Revision);render();
        writeBOIRunJSON(fullfile(OutputRoot,'LatestRevision.json'),struct('Path',store.Path,'SHA256',store.SHA256,'AreaStatus',store.Measures.Status));
    end
    function reopen()
        if dirty,error('OxygenDynamics:AreaReviewDraft','Save the current progress before reopening another revision.');end
        [name,path]=uigetfile('AreaReview.json','Reopen a saved area revision',OutputRoot);if isequal(name,0),return;end
        store=loadBOIAreaReview(fullfile(path,name));assert(strcmp(store.Document.ContextSHA256,D.ContextSHA256),'OxygenDynamics:AreaReviewSource','This revision belongs to another measurement.');
        Previous=store;D=store.Document;reviewer.Value=D.Reviewer;reason.Value=D.Reason;cleanReviewer=reviewer.Value;cleanReason=reason.Value;dirty=false;undo=cell(numel(C.Frames),1);render();
    end
    function guard(action)
        try,action();catch err,uialert(Fig,err.message,'Area revision');end
    end
    function closeWithArea(~,~)
        if isa(cancelActiveDrawing,'function_handle'),cancelActiveDrawing();end
        if dirty
            choice=uiconfirm(Fig,'Save an area revision to retain your frame decisions.','Unsaved area review', ...
                'Options',{'Keep reviewing','Save and close','Discard drafts and close'},'DefaultOption',1,'CancelOption',1);
            if strcmp(choice,'Keep reviewing'),return;end
            if strcmp(choice,'Save and close'),try,saveCurrent();catch err,uialert(Fig,err.message,'Area revision not saved');return;end,end
        end
        closingDiscard=true;
        if isa(oldClose,'function_handle'),oldClose(Fig,[]);else,delete(Fig);end
        closingDiscard=false;
    end
    function render()
        dirty=~isequaln(D,Previous.Document)||~strcmp(reviewer.Value,cleanReviewer)||~strcmp(reason.Value,cleanReason);
        Q=computeBOIReviewedArea(D);F=D.FrameDecisions(index);frame.Value=C.Frames(index);note.Value=F.Note;
        summary.Text=sprintf('%d/%d frames accepted | current frame %d: %s | mean area and burden: %s', ...
            Q.ReviewedFrames,Q.RequiredFrames,F.Frame,F.Status,Q.Status);
        if Q.Complete,summary.Text=sprintf('%d/%d reviewed | mean area %.6g um^2 | event burden %.6g | normalized %.6g', ...
                Q.ReviewedFrames,Q.RequiredFrames,Q.MeanAreaUm2,Q.Contribution,Q.NormalizedContribution);end
        savedLabel.Text=sprintf('Saved revision %d',Previous.Document.Revision);
        if dirty,savedLabel.Text=sprintf('Unsaved changes; saved revision %d',Previous.Document.Revision);end
        raw=strcmp(source.Value,'raw');images=Cache.Denoised;background=Cache.DenoisedBackground;lim=Cache.GrayLimits(2,:);
        if raw,images=Cache.Raw;background=Cache.RawBackground;lim=Cache.GrayLimits(1,:);end
        j=find(Cache.Frames==F.Frame);plane=double(images(:,:,j));denominator=boiIntensityDenominator(background,boiCameraOffset(C));
        denominator(denominator<=0)=NaN;map=100*(plane-background)./denominator;
        cla(imageAx);imagesc(imageAx,Cache.Columns,Cache.Rows,plane,lim);colormap(imageAx,gray(256));
        title(imageAx,sprintf('%s frame %d - draw here',source.Value,F.Frame));finish(imageAx);
        cla(changeAx);h=imagesc(changeAx,Cache.Columns,Cache.Rows,map,[-15 15]);h.AlphaData=isfinite(map);
        cmap=[linspace(.1,1,128)' linspace(.25,1,128)' linspace(.8,1,128)';linspace(1,.8,128)' linspace(1,.15,128)' linspace(1,.1,128)'];
        colormap(changeAx,cmap);cb=colorbar(changeAx);cb.Color=[.15 .15 .15];title(changeAx,sprintf('Change vs accepted baseline %d-%d (%%)',C.ReferenceFrames(1),C.ReferenceFrames(end)));finish(changeAx);
        tableView.Data=table(C.Frames(:),string({D.FrameDecisions.Status})',Q.FramePixels,Q.OutsideFootprintPixels, ...
            'VariableNames',{'Frame','Status','AreaPixels','OutsideCyan'});
        acceptSaved.Enable='off';if ~isempty(Cache.Suggestions{index}),acceptSaved.Enable='on';end
        useSaved.Enable=acceptSaved.Enable;
        acceptDrawn.Enable='off';if ~isempty(F.Pixels),acceptDrawn.Enable='on';end
        message.Text=['Cyan: accepted trace footprint. Magenta: unaccepted saved suggestion. Green: your current area. ' ...
            'Each frame needs explicit acceptance or No pocket area. Unreviewed/uncertain frames and area outside cyan withhold the complete result. ' ...
            'Use saved as draft to edit a suggestion. Drag an outline and release to finish; Add/Erase preserve separate regions and holes. Save revision retains progress.'];
        if ~isempty(Q.SpatialMismatchFrames),message.Text=['SPATIAL MISMATCH: area extends outside the accepted cyan footprint; final quantification is withheld. ' message.Text];end
    end
    function finish(ax)
        hold(ax,'on');sets={C.FixedFootprint,Cache.Suggestions{index},D.FrameDecisions(index).Pixels};colors={[0 .85 1],[1 .15 .8],[.1 .8 .2]};
        for k=1:3
            mask=false(sz);mask(sets{k})=true;crop=mask(Cache.Rows,Cache.Columns);
            if any(crop(:)),contour(ax,Cache.Columns,Cache.Rows,double(crop),[.5 .5],'Color',colors{k},'LineWidth',1.3);end
        end
        axis(ax,'image');ax.YDir='reverse';xlim(ax,Cache.Columns([1 end]));ylim(ax,Cache.Rows([1 end]));
        xlabel(ax,'Column (pixel)');ylabel(ax,'Row (pixel)');ax.Color=[1 1 1];ax.XColor=[.15 .15 .15];ax.YColor=[.15 .15 .15];
        ax.Title.Color=[.15 .15 .15];ax.XLabel.Color=[.15 .15 .15];ax.YLabel.Color=[.15 .15 .15];hold(ax,'off');
    end
end
