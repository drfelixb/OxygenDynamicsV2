function Panel=createBOIWholeEpisodePanel(Parent)
% Opt-in full saved-trace model; no scientific-save or export connection.
G=uigridlayout(Parent,[6 1]);G.RowHeight={36,54,34,145,'1x',105};
Identity=uilabel(G,'Text','Select a saved sink footprint.','Interpreter','none','WordWrap','on');
Status=uilabel(G,'Text','Experimental episode prototype. Nothing has run.','WordWrap','on','Interpreter','none');
Actions=uigridlayout(G,[1 3]);Actions.Padding=[0 0 0 0];Actions.ColumnWidth={220,170,'1x'};
Run=uibutton(Actions,'Text','Scan full saved trace','Enable','off','ButtonPushedFcn',@runClicked);
uibutton(Actions,'Text','Show full recording','ButtonPushedFcn',@(~,~)showFull());
uilabel(Actions,'Text','Recognition preview only. No new reference, amplitude, area or burden.','WordWrap','on');
Summary=uitable(G,'Data',cell(0,6),'RowName',{},'ColumnName', ...
    {'Stage','Proposed frames','Model outcome','Gain vs background','Background alternative','Timing alternatives'}, ...
    'ColumnWidth',{85,125,170,150,160,'auto'},'SelectionType','row','Multiselect','off','CellSelectionCallback',@selected);
Plots=uigridlayout(G,[1 2]);Plots.Padding=[0 0 0 0];RawAxes=uiaxes(Plots);CorrectedAxes=uiaxes(Plots);
Details=uitextarea(G,'Editable','off','Value',{'Computational model settings are experimental; scores are not pocket probabilities.'});
Review=[];Index=[];Input=[];Result=[];RowMap=cell(0,2);P=boiWholeEpisodeSettings;
Panel=struct('Update',@update,'SetEvidence',@setEvidence,'SetSettings',@setSettings, ...
    'Preview',@preview,'SelectProposal',@selectProposal,'ShowFull',@showFull,'State',@state, ...
    'RunButton',Run,'Identity',Identity,'Status',Status,'Summary',Summary,'Details',Details, ...
    'RawAxes',RawAxes,'CorrectedAxes',CorrectedAxes);
    function clearResult()
        Result=[];RowMap=cell(0,2);Summary.Data=cell(0,6);Summary.Selection=[];
        cla(RawAxes,'reset');cla(CorrectedAxes,'reset');
        Status.Text='Opt-in prototype: scan the entire saved trace at this footprint; old event bounds are annotations.';
        Details.Value={'Separate raw/corrected fits compare an episode with trend and transition explanations.', ...
            'Fitted background is display-only, never an accepted amplitude reference.', ...
            'No scientific save, measurement or export is available here.'};
    end
    function update(R,ix)
        clearResult();Review=R;Index=ix;Input=[];a=R.Audit(ix,:);
        Identity.Text=sprintf('%s | %s site %d / event %d footprint',a.RecordingID,a.EventType,a.SiteID,a.EventID);
        Run.Enable='off';if string(a.EventType)=="sink",Run.Enable='on';else,Status.Text='Prototype supports saved sink footprints only.';end
    end
    function setEvidence(E)
        clearResult();Review=[];Index=[];Input=E;Run.Enable='on';Identity.Text='Saved trace example';
        if isfield(E,'Identity'),Identity.Text=E.Identity;end
    end
    function setSettings(Q),P=Q;clearResult();end
    function runClicked(~,~)
        try,preview();catch err,Status.Text=['Prototype unavailable: ' err.message];Details.Value={err.message};end
    end
    function R=preview()
        clearResult();Run.Enable='off';restore=onCleanup(@()set(Run,'Enable','on'));
        E=Input;if isempty(E),E=buildBOIWholeEventEvidence(Review,Index);end
        R=previewBOIWholeEpisode(E,P);Input=E;Result=R;data=cell(0,6);
        for stage={'Raw','Corrected'}
            S=R.(stage{1});
            for j=1:numel(S.Proposals)
                c=S.Proposals(j);data(end+1,:)={stage{1},sprintf('%d–%d',c.StartFrame,c.EndFrame), ...
                    strrep(c.Status,'_',' '),c.ScoreGain,strrep(c.BackgroundExplanation,'_',' '), ...
                    sprintf('start %d–%d; end %d–%d',c.OnsetRange,c.RecoveryRange)}; %#ok<AGROW>
                RowMap(end+1,:)={stage{1},j}; %#ok<AGROW>
            end
        end
        Summary.Data=data;
        Status.Text=sprintf('Full trace scanned: %d raw / %d corrected proposals; %d boundary cautions. Scores are model evidence, not probabilities.', ...
            numel(R.Raw.Proposals),numel(R.Corrected.Proposals),numel(R.Raw.BoundaryAssessments)+numel(R.Corrected.BoundaryAssessments));
        Details.Value=[{sprintf('Duration grid: %s seconds. Episode background degree %d; complexity penalty %g.',mat2str(P.DurationsSec),P.EpisodeBackgroundDegree,P.ScorePenalty); ...
            sprintf('Screening cap reached: raw %d, corrected %d. Unsupported durations: raw %s, corrected %s.',R.Raw.ScreeningCapReached,R.Corrected.ScreeningCapReached,mat2str(R.Raw.UnsupportedDurationsSec),mat2str(R.Corrected.UnsupportedDurationsSec)); ...
            'Boundary cautions describe unobserved phases, not confirmed pockets. Timing alternatives are not confidence intervals.'};R.Limitations(:)];
        showFull();
        if ~isempty(RowMap)
            choice=1;
            if all(isfield(E,{'SeedStartFrame','SeedEndFrame'}))
                midpoint=(E.SeedStartFrame+E.SeedEndFrame)/2;distance=zeros(size(RowMap,1),1);
                for j=1:numel(distance),c=R.(RowMap{j,1}).Proposals(RowMap{j,2});distance(j)=abs(c.CenterFrame-midpoint);end
                [~,choice]=min(distance);
            end
            selectProposal(choice);
        end
    end
    function selected(~,event),if ~isempty(event.Indices),selectProposal(event.Indices(1,1));end;end
    function selectProposal(row)
        if isempty(Result)||row<1||row>size(RowMap,1),return;end
        stage=RowMap{row,1};c=Result.(stage).Proposals(RowMap{row,2});Summary.Selection=row;
        draw([c.ContextStartFrame c.ContextEndFrame],stage,c);
    end
    function showFull()
        if isempty(Result),return;end
        draw([1 Result.NFrames],'',[]);
    end
    function draw(bounds,stage,c)
        E=Input;f=(bounds(1):bounds(2))';
        for side=1:2
            name='Raw';ax=RawAxes;if side==2,name='Corrected';ax=CorrectedAxes;end
            cla(ax,'reset');hold(ax,'on');y=E.(name);plot(ax,f,y(f),'k','DisplayName','Saved trace');
            if all(isfield(E,{'SeedStartFrame','SeedEndFrame'}))
                xline(ax,E.SeedStartFrame,'r--','DisplayName','Original detection');xline(ax,E.SeedEndFrame,'r--','HandleVisibility','off');
            end
            if ~isempty(c)
                xline(ax,c.StartFrame,'--','Color',[.1 .55 .3],'DisplayName',[stage ' proposal']);xline(ax,c.EndFrame,'--','Color',[.1 .55 .3],'HandleVisibility','off');
                if strcmp(name,stage)
                    w=c.EndFrame-c.StartFrame;t=(f-c.CenterFrame)/w;b=c.BackgroundCoefficients;
                    bg=b(1)+b(2)*t;if numel(b)==3,bg=bg+b(3)*t.^2;end
                    plot(ax,f,bg,'Color',[.3 .4 .85],'LineWidth',1.4,'DisplayName','Fitted background (display only)');
                    profile=P.Profiles(c.ProfileIndex,:);a=c.StartFrame;bnd=c.EndFrame;l=a+(bnd-a)*profile(1);r=a+(bnd-a)*profile(2);
                    pulse=zeros(size(f));i=f>a&f<l;pulse(i)=(f(i)-a)/(l-a);i=f>=l&f<=r;pulse(i)=1;i=f>r&f<bnd;pulse(i)=(bnd-f(i))/(bnd-r);
                    plot(ax,f,bg-c.DepthInputUnits*pulse,'Color',[.1 .55 .3],'LineWidth',1.3,'DisplayName','Episode model');
                    X=[ones(size(f)) t];if strcmp(c.BackgroundExplanation,'curved_trend'),X=[X t.^2];
                    elseif strcmp(c.BackgroundExplanation,'step'),X=[X double(f>=c.TransitionFrame)];
                    elseif strcmp(c.BackgroundExplanation,'slope_change'),X=[X max(0,(f-c.TransitionFrame)/w)];end
                    observed=double(y(f));plot(ax,f,X*(X\observed),'--','Color',[.5 .5 .5],'DisplayName','Best background alternative');
                end
            end
            for k=1:numel(Result.(name).BoundaryAssessments)
                e=Result.(name).BoundaryAssessments(k);if e.BoundaryFrame>=bounds(1)&&e.BoundaryFrame<=bounds(2),xline(ax,e.BoundaryFrame,':','Color',[.7 .4 .1],'DisplayName','Incomplete boundary context');end
            end
            title(ax,[name ' saved intensity'],'Interpreter','none');xlabel(ax,'Recording frame (one-based)');ylabel(ax,'Intensity (a.u.)');
            xlim(ax,[bounds(1)-.5 bounds(2)+.5]);grid(ax,'on');legend(ax,'show','Location','best');hold(ax,'off');
        end
        linkaxes([RawAxes CorrectedAxes],'x');
    end
    function S=state(),S=struct('Preview',Result,'Settings',P,'SelectedIndex',Index);end
end
