function P=createBOIReviewedPocketPanel(Parent,Actions)
%CREATEBOIREVIEWEDPOCKETPANEL Explicit pocket judgments, never inferred from selection.
g=uigridlayout(Parent,[9 1]);g.RowHeight={38,36,36,36,36,40,52,'1x',190};
header=uilabel(g,'Text','Select an event. No pocket judgment is inferred.','WordWrap','on','Interpreter','none');
a=uigridlayout(g,[1 6]);a.Padding=[0 0 0 0];a.ColumnWidth={130,100,150,100,120,'1x'};
uilabel(a,'Text','Onset frame');onset=uieditfield(a,'numeric','Limits',[1 Inf],'RoundFractionalValues','on','Value',1,'ValueChangedFcn',@changed);
uilabel(a,'Text','Observation end');last=uieditfield(a,'numeric','Limits',[1 Inf],'RoundFractionalValues','on','Value',1,'ValueChangedFcn',@changed);
uilabel(a,'Text','Recovery status');endpoint=uidropdown(a,'Items',{'recovery_observed','recovery_unresolved','recording_censored'},'Value','recovery_unresolved','ValueChangedFcn',@changed);
b=uigridlayout(g,[1 4]);b.Padding=[0 0 0 0];b.ColumnWidth={135,'1x',120,220};
uilabel(b,'Text','Exact reference frames');reference=uieditfield(b,'text','Placeholder','e.g. 73:81 or 73,75,78','ValueChangedFcn',@changed);
uilabel(b,'Text','Reference suitability');suitability=uidropdown(b,'Items',{'not_assessed','accepted_local_state','provisional_local_state','unsuitable'},'ValueChangedFcn',@changed);
c=uigridlayout(g,[1 4]);c.Padding=[0 0 0 0];c.ColumnWidth={70,160,55,'1x'};
uilabel(c,'Text','Reviewer');reviewer=uieditfield(c,'text','ValueChangedFcn',@changed);uilabel(c,'Text','Reason');reason=uieditfield(c,'text','ValueChangedFcn',@changed);
d=uigridlayout(g,[1 2]);d.Padding=[0 0 0 0];d.ColumnWidth={'1x','1x'};
interpret= uicheckbox(d,'Text','I explicitly interpret this interval as a pocket','ValueChangedFcn',@changed);
clock=uicheckbox(d,'Text','External trigger at 1 Hz is established for this recording','ValueChangedFcn',@changed);
buttons=uigridlayout(g,[1 5]);buttons.Padding=[0 0 0 0];buttons.ColumnWidth={150,160,160,170,'1x'};
preview=uibutton(buttons,'Text','Preview draft','ButtonPushedFcn',@(~,~)invoke('Preview'));
saveButton=uibutton(buttons,'Text','Save NEW revision','ButtonPushedFcn',@(~,~)invoke('Save'));
loadButton=uibutton(buttons,'Text','Reopen saved revision','ButtonPushedFcn',@(~,~)invoke('Load'));
exportButton=uibutton(buttons,'Text','Export SAVED revision','Enable','off','ButtonPushedFcn',@(~,~)invoke('Export'));
state=uilabel(buttons,'Text','No saved revision selected.','WordWrap','on');
measureSummary=uilabel(g,'Text','No new reviewed quantity.','WordWrap','on');
plots=uigridlayout(g,[1 2]);plots.Padding=[0 0 0 0];plots.ColumnWidth={'2x','1x'};
ax=uiaxes(plots);map=uiaxes(plots);details=uitextarea(g,'Editable','off','Value',{'Reviewed quantities are separate from automatic and legacy results.'});
Review=[];Index=[];current=[];dirty=false;drafts={};
P=struct('Update',@update,'ReadDraft',@readDraft,'SetDraft',@setDraft,'ShowPreview',@showPreview, ...
    'ShowSaved',@showSaved,'HasDrafts',@hasDrafts,'Current',@getCurrent,'Details',details, ...
    'State',state,'Axes',ax,'FootprintAxes',map,'PreviewButton',preview,'SaveButton',saveButton, ...
    'LoadButton',loadButton,'ExportButton',exportButton,'Onset',onset,'ObservedEnd',last, ...
    'ReferenceFrames',reference,'Suitability',suitability,'Endpoint',endpoint);
    function value=getCurrent()
        % A nested accessor reads current state; anonymous handles capture a value.
        value=current;
    end
    function invoke(name)
        try,Actions.(name)();catch err,uialert(ancestor(Parent,'figure'),[err.identifier newline err.message],'Pocket review');end
    end
    function changed(~,~)
        dirty=true;current=[];state.Text='UNSAVED draft; saved revision remains separate and is the only export target.';
        cla(ax);cla(map);measureSummary.Text='Draft changed; preview required.';details.Value={'Draft changed. Preview again before saving. No new measurement is adopted.'};
        if ~isempty(Index),drafts{Index}=snapshot();end
    end
    function s=snapshot()
        s=struct('OnsetFrame',onset.Value,'ObservedEndFrame',last.Value,'ReferenceText',reference.Value, ...
            'ReferenceSuitability',suitability.Value,'EndpointStatus',endpoint.Value,'Reviewer',reviewer.Value, ...
            'Reason',reason.Value,'Interpretation',interpret.Value,'Clock',clock.Value);
    end
    function apply(s)
        onset.Value=s.OnsetFrame;last.Value=s.ObservedEndFrame;reference.Value=s.ReferenceText;
        suitability.Value=s.ReferenceSuitability;endpoint.Value=s.EndpointStatus;reviewer.Value=s.Reviewer;
        reason.Value=s.Reason;interpret.Value=s.Interpretation;clock.Value=s.Clock;
    end
    function update(r,i)
        if ~isempty(Index)&&dirty,drafts{Index}=snapshot();end
        Review=r;Index=i;current=[];dirty=false;cla(ax);cla(map);measureSummary.Text='No new reviewed quantity.';
        row=r.Audit(i,:);automatic='unavailable';if isfinite(row.StoredAmplitude),automatic=sprintf('%.6g%%',100*row.StoredAmplitude);end
        header.Text=sprintf('Saved %s | site %d / event %d | automatic amplitude %s. Explicit reviewed pocket only.', ...
            row.EventType,row.SiteID,row.EventID,automatic);
        apply(struct('OnsetFrame',1,'ObservedEndFrame',1,'ReferenceText','','ReferenceSuitability','not_assessed', ...
            'EndpointStatus','recovery_unresolved','Reviewer','','Reason','','Interpretation',false,'Clock',false));
        exportButton.Enable='off';state.Text='No pocket judgment inferred; enter explicit choices.';
        details.Value={'No pocket calculation on selection. Automatic and legacy results retain their original definitions.'};
        if isfield(r,'PocketEvidence')&&numel(r.PocketEvidence)>=i&&~isempty(r.PocketEvidence{i})
            showSaved(r.PocketEvidence{i});
        end
        if numel(drafts)>=i&&~isempty(drafts{i})
            apply(drafts{i});dirty=true;current=[];state.Text='Restored UNSAVED draft; export still uses the separately saved revision.';
        end
    end
    function setDraft(j)
        apply(struct('OnsetFrame',j.OnsetFrame,'ObservedEndFrame',j.ObservedEndFrame, ...
            'ReferenceText',strjoin(string(j.ReferenceFrames(:)'),','),'ReferenceSuitability',j.ReferenceSuitability, ...
            'EndpointStatus',j.EndpointStatus,'Reviewer',j.Reviewer,'Reason',j.Reason,'Interpretation',true, ...
            'Clock',strcmp(j.ClockAuthority,'external_trigger_1Hz')));
        changed([],[]);
    end
    function j=readDraft()
        assert(~isempty(Index)&&interpret.Value,'OxygenDynamics:PocketJudgmentRequired','Explicit pocket interpretation required.');
        assert(clock.Value,'OxygenDynamics:PocketClock','Confirm established external 1 Hz authority; file timestamps are not authority.');
        previous=[];
        if isfield(Review,'PocketEvidence')&&numel(Review.PocketEvidence)>=Index&&~isempty(Review.PocketEvidence{Index}),previous=Review.PocketEvidence{Index}.Document;end
        j=createBOIPocketJudgment(Review,Index,onset.Value,last.Value,parseFrames(reference.Value),suitability.Value, ...
            endpoint.Value,reviewer.Value,reason.Value,'external_trigger_1Hz',previous);
    end
    function showPreview(e)
        current=e;render(e);state.Text='UNSAVED preview. Export excludes this draft until Save NEW revision.';dirty=true;
    end
    function showSaved(store)
        current=[];j=store.Document.Judgment;setDraft(j);dirty=false;drafts{Index}=[];
        render(store.Document);exportButton.Enable='on';state.Text=['SAVED revision ' num2str(j.Revision) ' | folder path in details; no replay.'];
        state.Tooltip=store.Path;details.Value=[{['Saved evidence folder: ' store.Path]};details.Value];
    end
    function yes=hasDrafts()
        yes=dirty||any(~cellfun(@isempty,drafts));
    end
    function render(e)
        measureSummary.Text=sprintf('Primary corrected signed trough: %.6g%% (%s) | raw companion: %.6g%% (%s) | reference: %s, %d frames | end: %s.', ...
            e.Measures.CorrectedSignedTroughPercent,e.Measures.PrimaryStatus,e.Measures.RawSignedTroughPercent, ...
            e.Measures.CompanionStatus,e.Judgment.ReferenceSuitability,numel(e.ReferenceFrames),e.Judgment.EndpointStatus);
        details.Value=cellstr(splitlines(string(formatBOIPocketEvidence(e))));
        n=numel(e.Ingredients.Raw);f=(1:n)';lo=max(1,min([e.ReferenceFrames;e.EventFrames])-20);hi=min(n,max(e.EventFrames)+20);sel=f>=lo&f<=hi;
        cla(ax);hold(ax,'on');
        if ~isempty(e.Ingredients.Corrected)
            plot(ax,f(sel),e.Ingredients.Corrected(sel),'Color',[.1 .4 .8],'LineWidth',1.3,'Tag','BOIPocketCorrected');
            scatter(ax,e.ReferenceFrames,e.Ingredients.Corrected(e.ReferenceFrames),25,[0 .6 .15],'filled');
            title(ax,'Primary: saved corrected intensity; reference samples in green');
        else
            title(ax,'Primary unavailable: matching saved correction is missing');
        end
        xline(ax,e.EventFrames(1),'--','Onset');xline(ax,e.EventFrames(end),'--','Observed end');hold(ax,'off');
        ylabel(ax,'Saved corrected intensity (a.u.)');xlabel(ax,'One-based recording frame');xlim(ax,[lo hi]);grid(ax,'on');
        mask=false(e.FrameSize);mask(e.FixedFootprint)=true;imagesc(map,mask);axis(map,'image');title(map,['Saved ' e.FootprintOrigin ' footprint']);
        xlabel(map,'Column');ylabel(map,'Row');
    end
end
function f=parseFrames(text)
text=strtrim(char(text));f=[];if isempty(text),return;end
parts=regexp(text,'[,;\s]+','split');
for k=1:numel(parts)
    p=parts{k};assert(~isempty(regexp(p,'^\d+(?::\d+)?$','once')), ...
        'OxygenDynamics:InvalidPocketFrames','Use frame numbers separated by commas, or inclusive a:b ranges.');
    a=sscanf(p,'%d:%d');assert(numel(a)<=2&&all(a>=1),'OxygenDynamics:InvalidPocketFrames','Invalid reference frames.');
    if numel(a)==2,assert(a(2)>=a(1)&&a(2)-a(1)<100000,'OxygenDynamics:InvalidPocketFrames','Invalid reference range.');f=[f;(a(1):a(2))'];else,f=[f;a];end %#ok<AGROW>
end
end
