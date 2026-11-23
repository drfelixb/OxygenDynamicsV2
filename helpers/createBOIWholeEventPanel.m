function Panel=createBOIWholeEventPanel(Parent,ReturnToTiming,AttachSources)
% Optional, opt-in experimental display. No scientific save/export controls.
G=uigridlayout(Parent,[7 1]);G.RowHeight={38,58,150,32,'1x',120,86};
Header=uigridlayout(G,[1 2]);Header.Padding=[0 0 0 0];Header.ColumnWidth={'1x',170};
Identity=uilabel(Header,'Text','Select a saved sink event.','WordWrap','on','Interpreter','none');
uibutton(Header,'Text','View saved timing','ButtonPushedFcn',@(~,~)ReturnToTiming());
Status=uilabel(G,'Text','Experimental whole-event assessment. No preview has run.','WordWrap','on','Interpreter','none');
Settings=uitable(G,'ColumnName',{'Experimental parameter','Value','Units / meaning'}, ...
    'ColumnEditable',[false true false],'ColumnWidth',{280,110,'auto'},'RowName',{},'CellEditCallback',@changed);
Actions=uigridlayout(G,[1 3]);Actions.Padding=[0 0 0 0];Actions.ColumnWidth={200,210,'1x'};
Run=uibutton(Actions,'Text','Preview whole event','Enable','off','ButtonPushedFcn',@runClicked);
Sources=uibutton(Actions,'Text','Attach both-sign masks','ButtonPushedFcn',@(~,~)AttachSources());
uilabel(Actions,'Text','References: 10 s and 20 s, assessed separately. Green = candidate bounds; red = saved bounds.','WordWrap','on');
Plots=uigridlayout(G,[1 2]);Plots.Padding=[0 0 0 0];RawAxes=uiaxes(Plots);CorrectedAxes=uiaxes(Plots);
Summary=uitable(G,'Data',cell(0,7),'RowName',{},'ColumnName', ...
    {'Reference (s)','Stage','Outcome','Baseline frames','Onset','Recovery','Dip runs'}, ...
    'ColumnWidth',{95,85,275,115,75,80,'auto'});
Details=uitextarea(G,'Editable','off','Value',{'Preview cannot change event membership, boundaries, area or burden.'});
CurrentReview=[];Index=[];Input=[];Result=[];P=boiWholeEventPreviewSettings;
names={'LookBackSec','LookAheadSec','MinimumDipSec','RecoveryHoldSec','DipSigma','ReturnSigma', ...
    'NoiseFloorPercent','MaximumBaselineDriftSigma','MaximumStageBoundaryDifferenceSec'};
labels={'Look back','Look ahead','Sustained dip','Sustained recovery','Dip threshold','Return band', ...
    'Noise floor','Maximum baseline drift','Raw/corrected boundary agreement'};
units={'seconds before saved start','seconds after saved end','seconds below dip threshold', ...
    'seconds inside return band','multiples of reference noise','multiples of reference noise', ...
    '% of positive raw reference','reference noise across the baseline window','seconds'};
setSettings(P);
Panel=struct('Update',@update,'SetEvidence',@setEvidence,'SetSettings',@setSettings,'Preview',@preview, ...
    'State',@state,'RunButton',Run,'SourcesButton',Sources,'Settings',Settings,'Identity',Identity, ...
    'Status',Status,'RawAxes',RawAxes,'CorrectedAxes',CorrectedAxes,'Summary',Summary,'Details',Details);
    function clearResult()
        Result=[];Summary.Data=cell(0,7);
        for ax=[RawAxes CorrectedAxes],cla(ax,'reset');end
        Status.Text='Experimental preview required for this event and these settings.';
        Details.Value={'Settings are experimental, not accepted biological thresholds.', ...
            'Saved spatial seeds limit this preview; missed pockets cannot be discovered here.', ...
            'Unknown native overlap remains unavailable. No burden or scientific result is saved.'};
    end
    function update(R,ix)
        clearResult();CurrentReview=R;Index=ix;Input=[];a=R.Audit(ix,:);
        Identity.Text=sprintf('%s | %s site %d / event %d',a.RecordingID,a.EventType,a.SiteID,a.EventID);
        Run.Enable='off';Sources.Enable='on';
        if string(a.EventType)=="sink",Run.Enable='on';else,Status.Text='Whole-event preview currently supports sink candidates only.';end
    end
    function setEvidence(E)
        clearResult();CurrentReview=[];Index=[];Input=E;Run.Enable='on';Sources.Enable='off';
        Identity.Text='Saved trace example';if isfield(E,'Identity'),Identity.Text=E.Identity;end
    end
    function setSettings(settings)
        P=settings;data=cell(numel(names),3);
        for j=1:numel(names),data(j,:)={labels{j},P.(names{j}),units{j}};end
        Settings.Data=data;clearResult();
    end
    function changed(~,~),clearResult();end
    function runClicked(~,~)
        try,preview();catch err,Status.Text=['Preview unavailable: ' err.message];Details.Value={err.message};end
    end
    function R=preview()
        clearResult();Q=P;
        for j=1:numel(names)
            v=Settings.Data{j,2};if ischar(v)||isstring(v),v=str2double(v);end
            Q.(names{j})=v;
        end
        E=Input;if isempty(E),E=buildBOIWholeEventEvidence(CurrentReview,Index);end
        R=previewBOIWholeEvent(E,Q);Result=R;
        if isfield(E,'AuditSHA256'),Result.SourceAuditSHA256=E.AuditSHA256;end
        candidates=R.Candidates;data=cell(2*numel(candidates),7);line=0;
        for j=1:numel(candidates)
            C=candidates(j);
            for stage={'Raw','Corrected'}
                line=line+1;T=C.(stage{1});baseline='unavailable';
                if isfinite(T.ReferenceStartFrame),baseline=sprintf('%d–%d',T.ReferenceStartFrame,T.ReferenceEndFrame);end
                data(line,:)={C.ReferenceSec,stage{1},displayStatus(T.Status),baseline,frameValue(T.OnsetFrame),frameValue(T.RecoveryFrame),T.SustainedDipRuns};
            end
        end
        Summary.Data=data;
        captions=cell(numel(candidates),1);
        for j=1:numel(candidates),captions{j}=sprintf('%g s: %s',candidates(j).ReferenceSec,displayStatus(candidates(j).Status));end
        Status.Text=strjoin(captions,' | ');
        messages={['EXPERIMENTAL ONLY: ' R.BaselinePolicy],R.RecoveryPolicy,R.SpatialQualification};
        for j=1:numel(candidates)
            C=candidates(j);messages{end+1}=sprintf('%g s spatial evidence: %s. Raw: %s Corrected: %s',C.ReferenceSec,displayStatus(C.SpatialStatus),C.Raw.Message,C.Corrected.Message); %#ok<AGROW>
        end
        if isfield(E,'AuditSHA256'),messages{end+1}=['Saved audit SHA256: ' E.AuditSHA256];end
        Details.Value=[messages(:);R.Limitations(:)];
        f=R.ContextStartFrame:R.ContextEndFrame;
        for side=1:2
            ax=RawAxes;y=E.Raw;stage='Raw';if side==2,ax=CorrectedAxes;y=E.Corrected;stage='Corrected';end
            cla(ax,'reset');hold(ax,'on');plot(ax,f,y(f),'k-','LineWidth',1.1,'DisplayName','Saved trace');
            xline(ax,E.SeedStartFrame,'r--','DisplayName','Saved start');xline(ax,E.SeedEndFrame,'r--','DisplayName','Saved end');
            for j=1:numel(candidates)
                C=candidates(j);T=C.(stage);color=[.15 .5 .2];if j==2,color=[.5 .2 .7];end
                if isfinite(T.ReferenceStartFrame)
                    plot(ax,[T.ReferenceStartFrame T.ReferenceEndFrame],[T.ReferenceMean T.ReferenceMean], ...
                        '-','Color',color,'LineWidth',2,'DisplayName',sprintf('%g s reference',C.ReferenceSec));
                    xline(ax,T.OnsetFrame,'--','Color',color,'HandleVisibility','off');
                    if isfinite(T.RecoveryFrame),xline(ax,T.RecoveryFrame,':','Color',color,'LineWidth',2,'HandleVisibility','off');end
                    plot(ax,[T.OnsetFrame R.ContextEndFrame],T.ReferenceMean+[0 0],':','Color',color,'HandleVisibility','off');
                end
            end
            xlabel(ax,'Recording frame (one-based)');ylabel(ax,[stage ' intensity (a.u.)']);
            title(ax,[stage ' context; no new correction']);xlim(ax,[f(1)-.5 f(end)+.5]);grid(ax,'on');hold(ax,'off');
            legend(ax,'show','Location','best','Interpreter','none');
        end
        linkaxes([RawAxes CorrectedAxes],'x');R=Result;
    end
    function S=state(),S=struct('Preview',Result,'Settings',P,'SelectedIndex',Index);end
end

function value=frameValue(frame)
value=frame;if ~isfinite(frame),value='Unavailable';end
end

function text=displayStatus(status)
switch string(status)
    case "complete",text='Sustained dip and return';
    case "complete_trace_candidate",text='Complete trace candidate; review required';
    case "trace_candidate_spatial_unavailable",text='Trace candidate; spatial evidence unavailable';
    case "trace_candidate_reference_screening_unavailable",text='Trace candidate; native overlap not checked';
    case "raw_corrected_boundary_disagreement",text='Raw and corrected boundaries disagree';
    case "raw_corrected_disagreement",text='Raw and corrected event shapes disagree';
    case "unresolved_stage_disagreement",text='Unresolved; raw and corrected assessments differ';
    case "left_censored",text='Recording-start candidate; baseline unavailable';
    case "right_censored",text='No sustained return before recording end';
    case "recovery_outside_context_or_absent",text='No sustained return within search window';
    case "insufficient_acquired_reference",text='Too few acquired baseline samples';
    case "baseline_unresolved",text='No supported pre-event baseline';
    case "baseline_drift",text='Pre-event baseline is drifting';
    case "nonfinite_reference",text='Missing samples in baseline';
    case "nonfinite_signal",text='Missing samples interrupt event';
    case "no_sustained_dip",text='No sustained dip under these settings';
    case "saved_native_support_only",text='Saved native support only; coherence unvalidated';
    case "no_native_support_at_seed",text='No saved native support at original candidate';
    case "unavailable",text='Unavailable';
    otherwise,text='Unresolved; inspect trace context';
end
end
