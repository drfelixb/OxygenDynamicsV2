function plotOxygenEventAudit(A,T,I,folder)
% Diagnostic panels use original units and explicit event/site support.
selected=find(A.WrongDirection);
control=contains(lower(A.Condition),'mneon')|contains(lower(A.Condition),'fluorescen');
for kind=["sink","surge"]
    rows=find(control&A.EventType==kind);
    if ~isempty(rows),selected=union(selected,rows(unique(round(linspace(1,numel(rows),min(3,numel(rows)))))));end
end
fs=I.AnalysisParams.fs;
for e=reshape(selected,1,[])
    t=T{e};first=A.StartFrame(e);last=A.EndFrame(e);
    frames=max(1,first-round(40*fs)):min(numel(t.Raw),last+round(40*fs));
    time=((1:numel(t.Raw))-first)/fs;
    f=figure('Visible','off','Color','w','Position',[100 100 1150 1050]);
    cleaner=onCleanup(@()close(f));layout=tiledlayout(f,4,1,'TileSpacing','compact');
    ax=nexttile(layout);plot(ax,time(frames),t.Raw(frames),'k','LineWidth',1);hold(ax,'on');
    plot(ax,time(frames),t.RawCubicTrend(frames),'Color',[.7 .4 0]);
    b=t.CleanBaselineFrames;scatter(ax,time(b),t.Raw(b),12,[0 .5 .2],'filled');
    if isfinite(A.RecomputedBaseline(e)),yline(ax,A.RecomputedBaseline(e),'--','Pre-event mean');end
    ylabel(ax,'Preserved input (a.u.)');legend(ax,{'Event footprint','Full-record cubic fit','Clean baseline samples'},'Location','best','AutoUpdate','off');
    mark(ax,A(e,:),fs);
    ax=nexttile(layout);plot(ax,time(frames),t.DetectionDetrended(frames),'Color',[.2 .3 .7]);
    ylabel(ax,'Detrended detection input (a.u.)');mark(ax,A(e,:),fs);
    ax=nexttile(layout);plot(ax,time(frames),t.Normalized(frames),'k');hold(ax,'on');
    plot(ax,time(frames),t.Filtered(frames),'Color',[0 .5 .7],'LineWidth',1.2);
    ylabel(ax,'Normalized score');xlabel(ax,'Seconds from refined event start');
    legend(ax,{'Event footprint: normalized','Event footprint: filtered'},'Location','best','AutoUpdate','off');mark(ax,A(e,:),fs);
    ax=nexttile(layout);plot(ax,time(frames),t.TimingTrace(frames),'Color',[.3 .3 .3]);hold(ax,'on');
    plot(ax,time(frames),t.TimingTrend(frames),'Color',[.7 .4 0]);
    ylabel(ax,'Whole-site score');xlabel(ax,'Seconds from refined event start');
    if A.EventType(e)=="sink"
        legend(ax,{'Filtered + fifth-order detrended','Seventh-order timing trend'},'Location','best','AutoUpdate','off');
    else
        legend(ax,{'Normalized site trace (no timing refinement)'},'Location','best','AutoUpdate','off');
    end
    mark(ax,A(e,:),fs);
    title(layout,sprintf('%s | site %d, event %d | amplitude %.3g%% | %s', ...
        A.EventType(e),A.SiteID(e),A.EventID(e),100*A.RecomputedAmplitude(e),A.RecomputedStatus(e)), ...
        'Interpreter','none');
    subtitle(layout,'Dashed bounds: measurement window. Dotted bounds: native detection.');
    if isfield(t,'SpatialNormalized')
        % Stage diagnostics are also retained numerically in the MAT/CSV outputs.
        ax2=figure('Visible','off','Color','w','Position',[100 100 1100 400]);
        cleanup2=onCleanup(@()close(ax2));
        plot(time(frames),t.SpatialNormalized(frames),'Color',[.5 .2 .6]);
        xlabel('Seconds from refined event start');ylabel('Spatial z score: event footprint');
        title(sprintf('%s site %d event %d: after frame-wise normalization',A.EventType(e),A.SiteID(e),A.EventID(e)));
        mark(gca,A(e,:),fs);
        drawnow;
        exportgraphics(ax2,fullfile(folder,sprintf('%s-site%d-event%d-spatial.png',A.EventType(e),A.SiteID(e),A.EventID(e))),'Resolution',120);
        clear cleanup2
    end
    drawnow;
    exportgraphics(f,fullfile(folder,sprintf('%s-site%d-event%d.png',A.EventType(e),A.SiteID(e),A.EventID(e))),'Resolution',120);
    clear cleaner
end
end
function mark(ax,r,fs)
xline(ax,0,'k--','HandleVisibility','off');
xline(ax,(r.EndFrame-r.StartFrame+1)/fs,'k--','HandleVisibility','off');
xline(ax,(r.DetectedStartFrame-r.StartFrame)/fs,':','HandleVisibility','off');
xline(ax,(r.DetectedEndFrame-r.StartFrame+1)/fs,':','HandleVisibility','off');grid(ax,'on');
end
