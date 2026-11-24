function exportFolder=exportPocketTraceFigures(results, outputParent, options)
%EXPORTPOCKETTRACEFIGURES Export plots and a combined CSV from saved MATLAB traces.
% Pass one condition folder from an Automatic pocket-trace export. This
% rebuilds the aligned CSVs and figures from its saved raw traces.
arguments
    results (1,1) string
    outputParent (1,1) string = ""
    options.MakeFigures (1,1) logical = true
    options.CombinedCSV (1,1) string = ""
    options.Condition (1,1) string = ""
end
if outputParent=="",outputParent=results;end
assert(isfolder(outputParent),'Choose an existing output parent directory.');
setupOxygenDynamicsPath;
read=@readPocketTable;
src=read(fullfile(results,'Recording_sources.csv'));
ev=read(fullfile(results,'Pocket_index.csv'));
ev.Mouse=string(ev.Mouse);ev.Group=string(ev.Group);
src=src(src.DistinctSource==1,:);
condition=unique(src.Condition);
assert(isscalar(condition),'Select the output folder for one condition to regenerate figures.');
if options.Condition~="", assert(condition==options.Condition); end
assert(~isempty(src) && numel(unique(src.SourceSHA256))==height(src),'Expected a manifest of distinct recordings.');
assert(numel(unique(ev.PocketKey))==height(ev),'Pocket keys must be unique within a result.');
stage=string(tempname(outputParent));
[ok,msg]=mkdir(stage);assert(ok,'%s',msg);guard=onCleanup(@()cleanStage(stage));
csvFile=options.CombinedCSV;
if csvFile=="", csvFile=fullfile(stage,'All_pocket_traces.csv'); end
pieces=cell(height(src),1);
for k=1:height(src)
    relative=replace(string(src.TraceFile(k)),char(92),'/');
    t=read(fullfile(results,relative));
    e=ev(string(ev.SourceSHA256)==src.SourceSHA256(k),:);
    [ok,ix]=ismember(t.PocketKey,e.PocketKey);
    assert(all(ok) && numel(unique(t.PocketKey))==height(e),'Trace keys do not match the recorded source.');
    id=e(ix,{'Mouse','Group','Condition','RecordingID','SinkID','EventID','SourceSHA256','StartFrame','EndFrame','NativeStartFrame','NativeEndFrame','PocketSet'});
    t=[id,t]; %#ok<AGROW>
    if ~isfile(csvFile)
        writetable(t,csvFile);
    elseif ~isempty(t)
        writetable(t,csvFile,'WriteMode','append','WriteVariableNames',false);
    end
    % A pocket signal can be valid even when its surrounding ring is empty.
    pieces{k}=t(isfinite(t.PocketPct),{'Group','Mouse','FromOnset_s','FromOffset_s','PocketPct'});
end
values=vertcat(pieces{:});
[pooled,mouse,sensor]=pocketCurves(values);
pooled.Condition=repmat(condition,height(pooled),1);
mouse.Condition=repmat(condition,height(mouse),1);
sensor.Condition=repmat(condition,height(sensor),1);
writetable(pooled,fullfile(stage,'Pocket_aligned_pooled.csv'));
writetable(mouse,fullfile(stage,'Pocket_aligned_by_mouse.csv'));
writetable(sensor,fullfile(stage,'Pocket_aligned_by_sensor.csv'));
if options.MakeFigures
    paired=read(fullfile(results,'Aligned_by_group.csv'));
    paired=paired(string(paired.Analysis)=="Primary" & string(paired.Alignment)=="Offset" & string(paired.Group)=="All",:);
    if ~isempty(pooled),plotPocketCurves(stage,pooled,mouse,sensor);end
    if ~isempty(paired),plotPaired(stage,paired);end
end
exportFolder=fullfile(outputParent,'Trace_exports');
from=java.io.File(char(stage)).toPath();
opts=javaArray('java.nio.file.CopyOption',0);
try
    java.nio.file.Files.move(from,java.io.File(char(exportFolder)).toPath(),opts);
catch ex
    if ~isfolder(exportFolder),rethrow(ex);end
    [~,token]=fileparts(stage);exportFolder=fullfile(outputParent,"Trace_exports_"+string(token));
    java.nio.file.Files.move(from,java.io.File(char(exportFolder)).toPath(),opts);
end
end

function cleanStage(folder)
if isfolder(folder),rmdir(folder,'s');end
end

function [pooled,mouse,sensor]=pocketCurves(values)
parts=cell(2,3);align=["Onset","Offset"];
for j=1:2
    time=round(values.("From"+align(j)+"_s"),9);
    take=time>=-20 & time<=60;
    v=values(take,{'Group','Mouse','PocketPct'});v.Seconds=time(take);
    [ix,p]=findgroups(v(:,{'Seconds'}));
    [im,m]=findgroups(v(:,{'Group','Mouse','Seconds'}));
    p.Pockets=zeros(height(p),1);p.MeanPct=p.Pockets;p.P25Pct=p.Pockets;p.P75Pct=p.Pockets;
    m.Pockets=zeros(height(m),1);m.MeanPct=m.Pockets;
    if ~isempty(v)
        p.Pockets=accumarray(ix,1);p.MeanPct=accumarray(ix,v.PocketPct,[],@mean);
        p.P25Pct=accumarray(ix,v.PocketPct,[],@(x)prctile(x,25));
        p.P75Pct=accumarray(ix,v.PocketPct,[],@(x)prctile(x,75));
        m.Pockets=accumarray(im,1);m.MeanPct=accumarray(im,v.PocketPct,[],@mean);
    end
    [ig,g]=findgroups(m(:,{'Group','Seconds'}));
    g.Mice=zeros(height(g),1);g.Pockets=g.Mice;g.MeanPct=g.Mice;
    if ~isempty(m)
        g.Mice=accumarray(ig,1);g.Pockets=accumarray(ig,m.Pockets);
        g.MeanPct=accumarray(ig,m.MeanPct,[],@mean);
    end
    p.Alignment=repmat(align(j),height(p),1);m.Alignment=repmat(align(j),height(m),1);g.Alignment=repmat(align(j),height(g),1);
    parts(j,:)={p,m,g};
end
pooled=vertcat(parts{:,1});mouse=vertcat(parts{:,2});sensor=vertcat(parts{:,3});
end

function plotPocketCurves(out,pooled,mouse,sensor)
align=["Onset","Offset"]; names=unique(sensor.Group);
order=["GFAP";"hSyn";"ECS"];names=[intersect(order,names,'stable');setdiff(names,order)];
colors=lines(max(3,numel(names)));
standard=[.60 .29 .14;.34 .27 .55;.06 .49 .44];
for g=1:numel(names)
    k=find(order==names(g));if ~isempty(k),colors(g,:)=standard(k,:);end
end
[f,tl]=canvas([1050 600],2,2,"Automatic pooled pocket traces | "+pooled.Condition(1));guard=onCleanup(@()close(f));
for j=1:2
    v=sortrows(pooled(pooled.Alignment==align(j),:),'Seconds');
    ax=nexttile(tl,j);hold(ax,'on');
    fill(ax,[v.Seconds;flip(v.Seconds)],[v.P25Pct;flip(v.P75Pct)],[.80 .89 .88],'EdgeColor','none','DisplayName','Middle 50% of pockets');
    plot(ax,v.Seconds,v.MeanPct,'Color',[0 .35 .38],'LineWidth',2,'DisplayName','Mean across pockets');
    axisTime(ax,align(j),'Change from baseline (%)');legend(ax,'Location','northwest');title(ax,align(j)+"-aligned");
    ax=nexttile(tl,j+2);plot(ax,v.Seconds,v.Pockets,'Color',[0 .35 .38],'LineWidth',1.6);
    axisTime(ax,align(j),'Contributing pockets');
end
exportgraphics(f,fullfile(out,'Pocket_traces.png'),'Resolution',160);clear guard

[f,tl]=canvas([1100 700],2,2,"Automatic pocket traces by sensor | "+pooled.Condition(1));guard=onCleanup(@()close(f));
for j=1:2
    ax=nexttile(tl,j);hold(ax,'on');
    for g=1:numel(names)
        v=sortrows(sensor(sensor.Group==names(g)&sensor.Alignment==align(j),:),'Seconds');
        plot(ax,v.Seconds,v.MeanPct,'Color',colors(g,:),'LineWidth',2,'DisplayName',names(g));
    end
    axisTime(ax,align(j),'Mean change across mice (%)');title(ax,align(j)+"-aligned");legend(ax,'Location','northwest');
    ax=nexttile(tl,j+2);hold(ax,'on');lag=[2 60];
    for g=1:numel(names)
        v=sort(mouse.MeanPct(mouse.Group==names(g)&mouse.Alignment==align(j)&mouse.Seconds==lag(j)));
        if isempty(v),continue;end
        offset=zeros(size(v));if numel(v)>1,offset=linspace(-.15,.15,numel(v))';end
        scatter(ax,v,g+offset,28,colors(g,:),'filled');plot(ax,mean(v),g,'k|','LineWidth',2,'MarkerSize',15);
    end
    ax.YTick=1:numel(names);ax.YTickLabel=names;ax.YDir='reverse';ylim(ax,[.5,numel(names)+.5]);xline(ax,0,':');grid(ax,'on');
    xlabel(ax,'Change from baseline (%)');title(ax,sprintf('+%d s from measurement %s | one dot per mouse',lag(j),lower(align(j))));
end
exportgraphics(f,fullfile(out,'Sensor_group_traces.png'),'Resolution',160);clear guard

[f,tl]=canvas([1160 max(480,250*numel(names))],numel(names),2,"Automatic pocket traces by mouse | "+pooled.Condition(1));guard=onCleanup(@()close(f));
axesList=gobjects(numel(names)*2,1);
for g=1:numel(names)
    ids=unique(mouse.Mouse(mouse.Group==names(g)));palette=lines(numel(ids));
    for j=1:2
        ax=nexttile(tl,(g-1)*2+j);axesList((g-1)*2+j)=ax;hold(ax,'on');
        for k=1:numel(ids)
            v=sortrows(mouse(mouse.Group==names(g)&mouse.Mouse==ids(k)&mouse.Alignment==align(j),:),'Seconds');
            plot(ax,v.Seconds,v.MeanPct,'Color',palette(k,:),'LineWidth',1.35,'DisplayName',ids(k));
        end
        axisTime(ax,align(j),'Change from baseline (%)');title(ax,names(g)+" | "+align(j));
        if j==2,legend(ax,'Location','eastoutside','Interpreter','none');end
    end
end
linkaxes(axesList,'y');
exportgraphics(f,fullfile(out,'Individual_mouse_traces.png'),'Resolution',160);
end

function plotPaired(out,v)
v=sortrows(v,'Seconds');[f,tl]=canvas([1100 460],1,2,"Automatic pocket versus nearby tissue | "+v.Condition(1));guard=onCleanup(@()close(f));
ax=nexttile(tl);hold(ax,'on');
plot(ax,v.Seconds,v.PocketPct,'Color',[0 .35 .38],'LineWidth',2,'DisplayName','Former pocket');
plot(ax,v.Seconds,v.RingPct,'--','Color',[.35 .38 .4],'LineWidth',2,'DisplayName','Nearby tissue');
axisTime(ax,"Offset",'Change from own baseline (%)');title(ax,'Mean across mice');legend(ax,'Location','northwest');
ax=nexttile(tl);hold(ax,'on');
fill(ax,[v.Seconds;flip(v.Seconds)],[v.Lower95ExcessPP;flip(v.Upper95ExcessPP)],[.86 .83 .92],'EdgeColor','none','DisplayName','Pointwise 95% mouse interval');
plot(ax,v.Seconds,v.ExcessPP,'Color',[.34 .27 .55],'LineWidth',2,'DisplayName','Pocket minus nearby tissue');
axisTime(ax,"Offset",'Difference (percentage points)');title(ax,'Local difference');legend(ax,'Location','northwest');
exportgraphics(f,fullfile(out,'Pocket_vs_nearby_tissue.png'),'Resolution',160);
end

function [f,tl]=canvas(sz,nrow,ncol,heading)
f=figure('Visible','off','Color','white','Position',[70 70 sz]);
tl=tiledlayout(f,nrow,ncol,'TileSpacing','compact','Padding','compact');title(tl,heading,'Interpreter','none');
end

function axisTime(ax,anchor,unit)
xline(ax,0,':','HandleVisibility','off');xlim(ax,[-20 60]);grid(ax,'on');
xlabel(ax,"Seconds from measurement "+lower(anchor));ylabel(ax,unit);
end
