function fig=showPocketNearbyTissue(resultFolder, mouse, site, event, sourceHash, visible)
%SHOWPOCKETNEARBYTISSUE Overlay fixed masks and plot same-frame original intensities.
arguments
    resultFolder (1,1) string
    mouse (1,1) string
    site (1,1) double
    event (1,1) double
    sourceHash (1,1) string = ""
    visible (1,1) string = "on"
end
setupOxygenDynamicsPath;
read=@(f)readPocketTable(fullfile(resultFolder,f));
events=read('Pocket_index.csv');sources=read('Recording_sources.csv');
e=events(events.Mouse==mouse & events.SinkID==site & events.EventID==event,:);
if sourceHash~="",e=e(e.SourceSHA256==sourceHash,:);end
assert(height(e)==1,'Select a unique mouse/site/event. For a repeated session, pass the source SHA-256 as the fifth argument.');
s=sources(sources.SourceSHA256==e.SourceSHA256 & sources.DistinctSource==1,:);
g=load(fullfile(resultFolder,s.GeometryFile),'geom');g=g.geom;
j=find(g.PocketKey==e.PocketKey);fp=false(g.FrameSize);fp(g.Masks{j,1})=true;
ring=false(g.FrameSize);ring(g.Masks{j,2})=true;
raw=nearbyRawFile(s.VerifiedRawFile,fileparts(s.VerifiedRawFile),"",s.SourceSHA256);
pre=max(1,e.StartFrame-round(20*g.SampleHz)):e.StartFrame-1;
if isempty(pre),pre=e.StartFrame;back="onset frame";else,back="pre-onset mean";end
img=mean(tiffreadVolume(raw,'PixelRegion',{[1 g.FrameSize(1)],[1 g.FrameSize(2)],[pre(1) pre(end)]}),3,'double');
[y,x]=find(fp|ring);spanY=max(1,min(y)-7):min(g.FrameSize(1),max(y)+7);spanX=max(1,min(x)-7):min(g.FrameSize(2),max(x)+7);
t=read(s.TraceFile);t=t(t.PocketKey==e.PocketKey,:);
fig=figure('Visible',visible,'Color','w','Position',[60 80 1040 480]);
tl=tiledlayout(fig,1,2,'TileSpacing','compact','Padding','compact');
ax=nexttile(tl);imagesc(ax,img(spanY,spanX));axis(ax,'image','off');colormap(ax,gray(256));hold(ax,'on');
lims=prctile(reshape(img(spanY,spanX),[],1),[1 99]);if diff(lims)>0,clim(ax,lims);end
colors=[.84 .40 .035;.005 .55 .57];
for k=1:2
    mask=fp;if k==2,mask=ring;end
    patchColor=repmat(reshape(colors(k,:),1,1,3),numel(spanY),numel(spanX),1);
    hh=image(ax,patchColor);hh.AlphaData=.64*mask(spanY,spanX);
end
title(ax,sprintf('Pocket (%d px) and nearby tissue (%d px)',nnz(fp),nnz(ring)));xlabel(ax,back);
ax=nexttile(tl);hold(ax,'on');
plot(ax,t.FromOffset_s,t.PocketRaw,'Color',colors(1,:),'LineWidth',1.5,'DisplayName','Pocket');
plot(ax,t.FromOffset_s,t.NearRaw,'Color',colors(2,:),'LineWidth',1.5,'DisplayName','Nearby tissue');
xline(ax,(e.StartFrame-e.EndFrame)/g.SampleHz,':','Measurement onset','HandleVisibility','off');xline(ax,0,'--','Measurement offset','HandleVisibility','off');
if height(t)>1,xlim(ax,[min(t.FromOffset_s) max(t.FromOffset_s)]);end
legend(ax,'Location','best');xlabel(ax,'Seconds from measurement offset');ylabel(ax,'Mean raw intensity (camera units)');grid(ax,'on');
title(tl,sprintf('Automatic | %s | %s, site %d, event %d | %s',e.Condition,mouse,site,event,back),'Interpreter','none');
end
