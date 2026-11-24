function View=openBOIAreaComparison(Fig,Review)
% Read-only temporal comparison of the already cached single-pocket images.
% Review remains the owner of every unsaved/saved scientific frame decision.
id='OxygenDynamics:AreaComparison';D=Review.Current();C=D.Context;
Cache=getappdata(Fig,'BOIAreaReviewCache');
assert(~isempty(Cache)&&strcmp(Cache.ContextSHA256,D.ContextSHA256),id,'Open the matching cached area reviewer first.');
previous=getappdata(Fig,'BOIAreaComparisonUI');
if isstruct(previous)&&isfield(previous,'Tab')&&isgraphics(previous.Tab)
    previous.StopPlayback();previous.Tab.Parent.SelectedTab=previous.Tab;View=previous;return;
end
assert(all(ismember([C.ReferenceFrames(:);C.Frames(:);C.RecoveredFrames(:)],Cache.Frames)),id,'Required comparison frames are not cached.');
% Add the entry to a reviewer already open before this display feature existed.
buttons=findall(Review.Tab,'Type','uibutton');
if ~any(strcmp({buttons.Text},'Compare / playback'))
    labels=findall(Review.Tab,'-isa','matlab.ui.control.Label');heading=[];
    for headingIndex=1:numel(labels)
        if startsWith(string(labels(headingIndex).Text),'Reviewed area -'),heading=labels(headingIndex);break;end
    end
    assert(isscalar(heading),id,'Cannot locate the area-review heading.');
    parent=heading.Parent;rowHeights=parent.RowHeight;
    top=uigridlayout(parent,[1 2]);top.Layout.Row=1;top.Layout.Column=1;top.Padding=[0 0 0 0];top.ColumnWidth={'1x',180};
    heading.Parent=top;heading.Layout.Row=1;heading.Layout.Column=1;
    uibutton(top,'Text','Compare / playback','ButtonPushedFcn',@(~,~)openBOIAreaComparison(Fig,Review));
    parent.RowHeight=rowHeights;
end
sz=C.FrameSize(:)';currentFrame=Review.Frame.Value;mode='stopped';phase=false;step=0;span=[];ticks=0;
Tab=uitab(Review.Tab.Parent,'Title','Baseline and playback');G=uigridlayout(Tab,[6 1]);
G.RowHeight={32,38,36,'1x',54,44};
uilabel(G,'Text',sprintf('Baseline and playback - site %d / event %d',C.SiteID,C.EventID),'FontSize',15,'FontWeight','bold');
controls=uigridlayout(G,[1 10]);controls.Padding=[0 0 0 0];
controls.ColumnWidth={70,90,150,195,105,65,90,155,130,'1x'};
uilabel(controls,'Text','Frame');
frame=uidropdown(controls,'Items',cellstr(string(Cache.Frames(:)')),'ItemsData',num2cell(Cache.Frames(:)'), ...
    'Value',currentFrame,'ValueChangedFcn',@selectFrame);
source=uidropdown(controls,'Items',{'Denoised input','Original raw'},'ItemsData',{'denoised','raw'}, ...
    'Value',Review.Source.Value,'ValueChangedFcn',@refresh);
spanLabels={sprintf('Episode %d-%d',C.Frames(1),C.Frames(end)),sprintf('Reference %d-%d',C.ReferenceFrames(1),C.ReferenceFrames(end)), ...
    sprintf('Recovered %d-%d',C.RecoveredFrames(1),C.RecoveredFrames(end)),sprintf('All cached %d-%d',Cache.Frames(1),Cache.Frames(end))};
period=uidropdown(controls,'Items',spanLabels, ...
    'ItemsData',{'episode','reference','recovered','all'},'Value','episode','ValueChangedFcn',@refresh);
playButton=uibutton(controls,'Text','Play span','ButtonPushedFcn',@(~,~)play());
stopButton=uibutton(controls,'Text','Stop','ButtonPushedFcn',@(~,~)stopPlayback());
speed=uidropdown(controls,'Items',{'1 frame/s','2 frames/s','4 frames/s'},'ItemsData',{1,2,4},'Value',4,'ValueChangedFcn',@refresh);
flickerButton=uibutton(controls,'Text','Flicker reference','ButtonPushedFcn',@(~,~)flicker());
reviewButton=uibutton(controls,'Text','Review this frame','ButtonPushedFcn',@(~,~)reviewFrame());
uilabel(controls,'Text',sprintf('Acquisition: %.3g Hz',C.SampleHz),'WordWrap','on');
options=uigridlayout(G,[1 4]);options.Padding=[0 0 0 0];options.ColumnWidth={180,170,180,'1x'};
overlays=uicheckbox(options,'Text','Show current outlines','Value',true,'ValueChangedFcn',@refresh);
uibutton(options,'Text','Previous frame','ButtonPushedFcn',@(~,~)move(-1));
uibutton(options,'Text','Next frame','ButtonPushedFcn',@(~,~)move(1));
uilabel(options,'Text','Cyan: accepted footprint. Magenta: saved suggestion. Green: current reviewed/draft area.','WordWrap','on');
plots=uigridlayout(G,[1 3]);plots.Padding=[0 0 0 0];plots.BackgroundColor=[1 1 1];
baselineAx=uiaxes(plots);currentAx=uiaxes(plots);changeAx=uiaxes(plots);
z=zeros(numel(Cache.Rows),numel(Cache.Columns));
baselineImage=imagesc(baselineAx,Cache.Columns,Cache.Rows,z);currentImage=imagesc(currentAx,Cache.Columns,Cache.Rows,z);
changeImage=imagesc(changeAx,Cache.Columns,Cache.Rows,z,[-15 15]);
colormap(baselineAx,gray(256));colormap(currentAx,gray(256));
cmap=[linspace(.1,1,128)' linspace(.25,1,128)' linspace(.8,1,128)';linspace(1,.8,128)' linspace(1,.15,128)' linspace(1,.1,128)'];
colormap(changeAx,cmap);cb=colorbar(changeAx);cb.Color=[.15 .15 .15];
axesList=[baselineAx currentAx changeAx];lines=cell(1,3);
for ax=axesList
    axis(ax,'image');ax.YDir='reverse';xlim(ax,Cache.Columns([1 end]));ylim(ax,Cache.Rows([1 end]));
    xlabel(ax,'Column (pixel)');ylabel(ax,'Row (pixel)');ax.Color=[1 1 1];ax.XColor=[.15 .15 .15];ax.YColor=[.15 .15 .15];
    ax.Title.Color=[.15 .15 .15];ax.XLabel.Color=[.15 .15 .15];ax.YLabel.Color=[.15 .15 .15];
end
status=uilabel(G,'Text','','WordWrap','on');
uilabel(G,'Text',['Display only: no frame is accepted, no mask is edited and no burden is calculated here. ' ...
    'Blue = lower intensity than the accepted reference; red = higher. Use Review this frame to make a judgment in the area editor.'],'WordWrap','on');
clock=timer('ExecutionMode','fixedSpacing','BusyMode','drop','Period',.25,'TimerFcn',@tick);
Tab.DeleteFcn=@dispose;
View=struct('Tab',Tab,'Frame',frame,'Source',source,'Span',period,'Speed',speed,'Overlays',overlays, ...
    'Play',playButton,'Flicker',flickerButton,'Stop',stopButton,'ReviewFrame',reviewButton, ...
    'StopPlayback',@stopPlayback,'IsPlaying',@isPlaying,'Mode',@currentMode, ...
    'BaselineImage',baselineImage,'CurrentImage',currentImage,'ChangeImage',changeImage, ...
    'BaselineAxes',baselineAx,'CurrentAxes',currentAx,'ChangeAxes',changeAx,'Status',status);
setappdata(Fig,'BOIAreaComparisonUI',View);Tab.Parent.SelectedTab=Tab;render();figure(Fig);drawnow;
    function active=isPlaying()
        active=~strcmp(mode,'stopped');
    end
    function value=currentMode()
        value=mode;
    end
    function selectFrame(~,~)
        selected=frame.Value;stopPlayback();currentFrame=selected;render();
    end
    function refresh(~,~)
        stopPlayback();render();
    end
    function move(delta)
        stopPlayback();j=find(Cache.Frames==currentFrame);j=max(1,min(numel(Cache.Frames),j+delta));
        currentFrame=Cache.Frames(j);render();
    end
    function play()
        stopPlayback();
        switch period.Value
            case 'episode',span=C.Frames(:)';
            case 'reference',span=C.ReferenceFrames(:)';
            case 'recovered',span=C.RecoveredFrames(:)';
            case 'all',span=Cache.Frames(:)';
        end
        assert(~isempty(span)&&all(ismember(span,Cache.Frames)),id,'Selected span is not cached.');
        mode='playback';phase=false;step=1;ticks=0;currentFrame=span(1);clock.Period=1/speed.Value;
        render();start(clock);
    end
    function flicker()
        stopPlayback();mode='flicker';phase=false;ticks=0;clock.Period=.5;render();start(clock);
    end
    function tick(~,~)
        try
            if ~isgraphics(Tab)||Tab.Parent.SelectedTab~=Tab,stopPlayback();return;end
            ticks=ticks+1;
            if strcmp(mode,'playback')
                if step>=numel(span),stopPlayback();return;end
                step=step+1;currentFrame=span(step);
            elseif strcmp(mode,'flicker')
                if ticks>=40,stopPlayback();return;end % Bounded 20-second comparison.
                phase=~phase;
            else,return;
            end
            render();drawnow limitrate;
        catch err
            stopPlayback();if isgraphics(status),status.Text=['Playback stopped: ' err.message];end
        end
    end
    function stopPlayback()
        if isvalid(clock)&&strcmp(clock.Running,'on'),stop(clock);end
        mode='stopped';phase=false;
        if isgraphics(Tab),render();end
    end
    function reviewFrame()
        stopPlayback();assert(ismember(currentFrame,C.Frames),id,'Choose an episode frame for area review.');
        Review.Frame.Value=currentFrame;Review.Frame.ValueChangedFcn(Review.Frame,[]);
        Tab.Parent.SelectedTab=Review.Tab;
    end
    function render()
        if ~isgraphics(Tab),return;end
        live=Review.Current();assert(strcmp(live.ContextSHA256,D.ContextSHA256),id,'The area review source changed.');
        raw=strcmp(source.Value,'raw');images=Cache.Denoised;background=Cache.DenoisedBackground;lim=Cache.GrayLimits(2,:);
        if raw,images=Cache.Raw;background=Cache.RawBackground;lim=Cache.GrayLimits(1,:);end
        j=find(Cache.Frames==currentFrame);assert(isscalar(j),id,'Frame is not cached.');
        plane=double(images(:,:,j));map=100*(plane-background)./background;map(background<=0)=NaN;
        baselineImage.CData=background;currentImage.CData=plane;changeImage.CData=map;changeImage.AlphaData=isfinite(map);
        baselineAx.CLim=lim;currentAx.CLim=lim;changeAx.CLim=[-15 15];
        title(baselineAx,sprintf('Reference mean %d-%d',C.ReferenceFrames(1),C.ReferenceFrames(end)));
        title(currentAx,sprintf('%s frame %d',source.Value,currentFrame));
        if strcmp(mode,'flicker')&&phase
            currentImage.CData=background;title(currentAx,'Reference phase (same contrast)');
        end
        title(changeAx,'Change from reference (%)');frame.Value=currentFrame;
        episodeIndex=find(C.Frames==currentFrame);suggestion=[];reviewed=[];state='context only';
        if ~isempty(episodeIndex)
            suggestion=Cache.Suggestions{episodeIndex};reviewed=live.FrameDecisions(episodeIndex).Pixels;
            state=live.FrameDecisions(episodeIndex).Status;
        end
        reviewButton.Enable='off';if ~isempty(episodeIndex),reviewButton.Enable='on';end
        for n=1:3
            if ~isempty(lines{n}),delete(lines{n}(isgraphics(lines{n})));end;lines{n}=gobjects(0);
            if ~overlays.Value,continue;end
            sets={C.FixedFootprint};colors={[0 .85 1]};
            if n>1,sets={C.FixedFootprint,suggestion,reviewed};colors={[0 .85 1],[1 .15 .8],[.1 .8 .2]};end
            hold(axesList(n),'on');
            for maskIndex=1:numel(sets)
                mask=false(sz);mask(sets{maskIndex})=true;crop=mask(Cache.Rows,Cache.Columns);
                if any(crop(:))
                    [~,h]=contour(axesList(n),Cache.Columns,Cache.Rows,double(crop),[.5 .5],'Color',colors{maskIndex},'LineWidth',1.3);
                    lines{n}(end+1)=h;
                end
            end
            hold(axesList(n),'off');
        end
        status.Text=sprintf('Frame %d | %s | area review: %s | fixed contrast across the cached sequence. Main review draft is retained.',currentFrame,mode,state);
    end
    function dispose(~,~)
        mode='stopped';if isvalid(clock),stop(clock);delete(clock);end
    end
end
