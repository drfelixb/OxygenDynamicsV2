function fig=viewBOIMultichannel(file)
% Inspect any anchor event, including events without a counterpart.
P=loadBOIMultichannel(file); e=P.Events; O=P.Options;
fig=uifigure('Name',char("Paired results · "+O.RecordingID),'Position',[100 80 1120 740]);
g=uigridlayout(fig,[2 1]); g.RowHeight={36,'1x'};
tabs=uitabgroup(g); tabs.Layout.Row=2;
summary=uitab(tabs,'Title','Recording'); sg=uigridlayout(summary,[3 1]); sg.RowHeight={90,'1x','1x'};
uitable(sg,'Data',P.Channels); uitable(sg,'Data',P.Summary); uitable(sg,'Data',P.Comparisons);
tab=uitab(tabs,'Title','Event traces and links'); v=uigridlayout(tab,[4 2]);
v.ColumnWidth={'1x','2x'}; v.RowHeight={32,36,'1x',150};
ids=compose('%d · %s %s · site %d / event %d',e.EventRow,e.Sensor,e.Sign,e.SiteID,e.EventID);
anchor=uidropdown(v,'Items',cellstr(ids),'ValueChangedFcn',@selectEvent);
anchor.Layout.Row=1; anchor.Layout.Column=1;
units=uidropdown(v,'Items',{'Change from reference (%)','Preserved intensity (camera units)'},'ValueChangedFcn',@render);
units.Layout.Row=1; units.Layout.Column=2;
map=plotArea(v,1); trace=plotArea(v,2);
partner=uidropdown(v,'ValueChangedFcn',@render); partner.Layout.Row=2; partner.Layout.Column=1;
note=uilabel(v,'WordWrap','on'); note.Layout.Row=2; note.Layout.Column=2;
links=uitable(v); links.Layout.Row=4; links.Layout.Column=[1 2];
head=uigridlayout(g,[1 3]); head.Layout.Row=1; head.ColumnWidth={'1x',150,170}; head.Padding=[0 0 0 0];
uilabel(head,'Text',char(O.RecordingID+" · "+strjoin(O.Promoters+"-"+O.Sensors," / ")),'Interpreter','none');
scope=uidropdown(head,'Items',{'Event window','Full recording'},'ValueChangedFcn',@render);
exp=uibutton(head,'Text','Export selected trace…','ButtonPushedFcn',@exportTrace);
eventsTab=uitab(tabs,'Title','Independent events'); et=uigridlayout(eventsTab,[1 1]); uitable(et,'Data',e);
row=[]; peers=[];
if isempty(ids)
    note.Text='No oxygen events detected.'; exp.Enable='off'; return
end
selectEvent();
    function selectEvent(~,~)
        row=find(ids==string(anchor.Value),1);
        ix=find(P.Links.EventRowA==row | P.Links.EventRowB==row);
        L=P.Links(ix,:);
        links.Data=L(:,{'EventRowA','EventRowB','OnsetLagSec_BminusA','MinimumLagSec_BminusA','GapSec', ...
            'FootprintJaccard','FramesWithCoincidentPixels','Relation'});
        links.ColumnName={'A event','B event','Onset lag (s)','Minimum lag (s)','Gap (s)', ...
            'Footprint overlap','Coincident frames','Candidate relation'};
        links.ColumnWidth={75,75,100,120,75,120,130,260};
        peers=L.EventRowB; if e.Channel(row)==2, peers=L.EventRowA; end
        partner.Items=cellstr(["Anchor footprint";"Overlay event row "+string(peers)]);
        partner.Value=partner.Items{1};
        if any(~isfinite([e.ReferenceMeanA(row),e.ReferenceMeanB(row)])), units.Value=units.Items{2}; end
        render();
    end
    function t=traceTable()
        t=table((1:O.NFrames)',P.TimeSec',P.RawA(row,:)',P.RawB(row,:)','VariableNames', ...
            {'Frame','TimeSec','IntensityA','IntensityB'});
        t.ChangePctA=100*(t.IntensityA/e.ReferenceMeanA(row)-1);
        t.ChangePctB=100*(t.IntensityB/e.ReferenceMeanB(row)-1);
        t.ReferenceFrame=ismember(t.Frame,P.ReferenceFrames{row});
        t.AnchorEvent=t.Frame>=e.StartFrame(row) & t.Frame<=e.EndFrame(row);
    end
    function render(~,~)
        t=traceTable(); shape=O.FrameSize; rgb=zeros([shape 3]);
        mask=zeros(shape); mask(P.Footprints{row})=1; rgb(:,:,1)=mask;
        choice=find(strcmp(partner.Items,partner.Value),1)-1;
        if choice>0
            mask(:)=0; mask(P.Footprints{peers(choice)})=1; rgb(:,:,2)=mask;
        end
        image(map,rgb); axis(map,'image'); title(map,'Anchor (red) · counterpart (green)');
        cla(trace);
        if strcmp(units.Value,units.Items{1}), y=[t.ChangePctA,t.ChangePctB]; ylabelText='Change from reference (%)';
        else, y=[t.IntensityA,t.IntensityB]; ylabelText='Preserved intensity (camera units)'; end
        plot(trace,t.TimeSec,y); xlabel(trace,'Time (s)'); ylabel(trace,ylabelText);
        legend(trace,cellstr(["A · "+O.Sensors(1),"B · "+O.Sensors(2)]),'Interpreter','none');
        xline(trace,t.TimeSec(e.StartFrame(row)),'--','Start','HandleVisibility','off');
        xline(trace,t.TimeSec(e.EndFrame(row)),':','End','HandleVisibility','off');
        if strcmp(scope.Value,'Event window')
            bounds=[e.StartFrame(row),e.EndFrame(row)];
            if choice>0
                k=peers(choice); bounds=[bounds,e.StartFrame(k),e.EndFrame(k)];
                xline(trace,t.TimeSec(e.StartFrame(k)),'-.','Peer start','HandleVisibility','off');
            end
            pad=max(2,round(5*O.SampleHz));
            limits=[max(1,min(bounds)-pad),min(O.NFrames,max(bounds)+pad)];
            xlim(trace,t.TimeSec(limits));
        else
            xlim(trace,[0,t.TimeSec(end)]);
        end
        title(trace,'Both channels on the selected anchor footprint');
        if choice>0
            k=peers(choice);
            link=P.Links((P.Links.EventRowA==row & P.Links.EventRowB==k) | ...
                (P.Links.EventRowA==k & P.Links.EventRowB==row),:);
            note.Text=sprintf('Candidate B − A   |   onset %+.2g s   |   minimum %+.2g s   |   positive values mean A was earlier', ...
                link.OnsetLagSec_BminusA,link.MinimumLagSec_BminusA);
        else
            note.Text=sprintf('%d candidate links   |   %d pre-event reference frames   |   %s', ...
                numel(peers),e.ReferenceSamples(row),replace(e.RC1ReferenceStatus(row),"_"," "));
        end
    end
    function exportTrace(~,~)
        [name,folder]=uiputfile('*.csv','Save trace',sprintf('EventRow%d_trace.csv',row));
        if isequal(name,0), return; end
        t=traceTable(); t.RecordingID=repmat(O.RecordingID,height(t),1); t.AnchorRow=repmat(row,height(t),1);
        t.SensorA=repmat(O.Sensors(1),height(t),1); t.SensorB=repmat(O.Sensors(2),height(t),1);
        writetable(t,fullfile(folder,name));
    end
end

function ax=plotArea(parent,column)
panel=uipanel(parent,'BorderType','none'); panel.Layout.Row=3; panel.Layout.Column=column;
layout=uigridlayout(panel,[1 1]); layout.Padding=[0 0 0 0];
ax=uiaxes(layout);
end
