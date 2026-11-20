function nearbyFigures(out,condition)
read=@(f)readPocketTable(fullfile(out,f));
c=read('Aligned_by_group.csv');w=read('Windows_by_mouse.csv');ev=read('Pocket_index.csv');
c=c(c.Analysis=="Primary" & c.Alignment=="Offset",:); late=w(w.Analysis=="Primary" & w.Start_s==31,:);
if ~isempty(c)
    f=figure('Visible','off','Color','white','Position',[50 50 1150 680]);guard=onCleanup(@()close(f));
    tl=tiledlayout(f,2,2,'TileSpacing','compact','Padding','compact');a=nexttile(tl,1);hold(a,'on');
    combined=c(c.Group=="All",:);plot(a,combined.Seconds,combined.PocketPct,'Color',[0 .36 .42],'LineWidth',2,'DisplayName','Former pocket');
    plot(a,combined.Seconds,combined.RingPct,'--','Color',[.32 .36 .39],'LineWidth',1.7,'DisplayName','Nearby tissue');
    xline(a,0,':','HandleVisibility','off');yline(a,0,':','HandleVisibility','off');grid(a,'on');legend(a,'Location','northwest');
    shadeLate(a);ylabel(a,'Change from pre-onset baseline (%)');xlabel(a,'Seconds from measurement offset');title(a,'Mouse-weighted signal');
    a=nexttile(tl,3);hold(a,'on');groups=unique(c.Group(c.Group~="All"));groups=[intersect(["GFAP";"hSyn";"ECS"],groups,'stable');setdiff(groups,["GFAP";"hSyn";"ECS"])];
    for g=groups'
        z=c(c.Group==g,:);h=plot(a,z.Seconds,z.ExcessPP,'LineWidth',1.8,'DisplayName',g);
        switch g
            case "GFAP",h.Color=[.60 .29 .14];
            case "hSyn",h.Color=[.34 .27 .55];
            case "ECS",h.Color=[.06 .49 .44];
        end
    end
    xline(a,0,':','HandleVisibility','off');yline(a,0,':','HandleVisibility','off');grid(a,'on');legend(a,'Location','northwest');
    shadeLate(a);xlabel(a,'Seconds from measurement offset');ylabel(a,'Pocket minus nearby (percentage points)');title(a,'Local difference by group');
    a=nexttile(tl,2,[2 1]);hold(a,'on');y=0;labels=strings(0,1);
    for g=groups'
        z=sortrows(late(late.Group==g,:),'Mouse');
        for i=1:height(z)
            y=y+1;plot(a,[z.RingPct(i),z.PocketPct(i)],[y y],'-','Color',[.66 .72 .73],'HandleVisibility','off');
            plot(a,z.RingPct(i),y,'o','Color',[.35 .38 .39],'MarkerFaceColor','white','HandleVisibility','off');
            plot(a,z.PocketPct(i),y,'o','Color',[0 .36 .42],'MarkerFaceColor',[0 .36 .42],'HandleVisibility','off');
            labels(y,1)=g+"  "+z.Mouse(i);
        end
    end
    plot(a,NaN,NaN,'o','Color',[.35 .38 .39],'DisplayName','Nearby tissue');plot(a,NaN,NaN,'o','Color',[0 .36 .42],'MarkerFaceColor',[0 .36 .42],'DisplayName','Former pocket');
    legend(a,'Location','southoutside','Orientation','horizontal');
    xline(a,0,':','HandleVisibility','off');a.YTick=1:y;a.YTickLabel=labels;a.YDir='reverse';ylim(a,[.4 max(1,y)+.6]);
    grid(a,'on');xlabel(a,'Change from pre-onset baseline (%)');title(a,'Each mouse at +31 to +60 s from measurement offset');
    title(tl,"Automatic pockets and nearby tissue | "+condition,'Interpreter','none');
    exportgraphics(f,fullfile(out,'Post_offset_signal_by_mouse.png'),'Resolution',160);
end
% Select by available follow-up, never by the measured signal.
full=ev.StartFrame>round(20*ev.SampleF) & ev.PostOffsetSecondsAvailable>=60-1e-9;
i=find(full,1);
if isempty(i),i=1;end
e=ev(i,:);fig=showPocketNearbyTissue(out,e.Mouse,e.SinkID,e.EventID,e.SourceSHA256,"off");
exampleGuard=onCleanup(@()close(fig));
exportgraphics(fig,fullfile(out,'Example_pocket_and_ring.png'),'Resolution',150);
end

function shadeLate(ax)
x=xlim(ax);left=max(31,x(1));right=min(60,x(2));
if left>=right,return;end
y=ylim(ax);
h=patch(ax,[left right right left],[y(1) y(1) y(2) y(2)],[.88 .93 .94], ...
    'EdgeColor','none','FaceAlpha',.5,'HandleVisibility','off');
uistack(h,'bottom');xlim(ax,x);ylim(ax,y);
end
