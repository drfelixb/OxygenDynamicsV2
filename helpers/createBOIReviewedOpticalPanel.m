function Panel=createBOIReviewedOpticalPanel(Parent,ViewReference,ViewTiming)
%CREATEBOIREVIEWEDOPTICALPANEL Explain proposed arithmetic beside original data.
G=uigridlayout(Parent,[8 1]);G.RowHeight={30,34,66,58,120,'1x','1x',65};G.Scrollable='on';
Identity=uilabel(G,'Text','Select an event.','Interpreter','none','WordWrap','on');
actions=uigridlayout(G,[1 3]);actions.Padding=[0 0 0 0];actions.ColumnWidth={180,170,'1x'};
uibutton(actions,'Text','View accepted reference','ButtonPushedFcn',@(~,~)ViewReference());
uibutton(actions,'Text','View corrected timing','ButtonPushedFcn',@(~,~)ViewTiming());
Choice=uidropdown(actions,'Items',{'No saved interval'},'ItemsData',0,'Value',0,'Enable','off','ValueChangedFcn',@(~,~)choose());
Summary=uilabel(G,'Text','No reviewed optical results.','WordWrap','on','Interpreter','none');
Original=uilabel(G,'Text','Original automatic result remains unchanged.','WordWrap','on','Interpreter','none');
Results=uitable(G,'Data',table(),'RowName',{},'ColumnEditable',false);
host=uigridlayout(G,[1 1]);host.Padding=[0 0 0 0];RawAxes=uiaxes(host);
host=uigridlayout(G,[1 1]);host.Padding=[0 0 0 0];FractionAxes=uiaxes(host);
uilabel(G,'Text',['Draft 0.1.0: B = mean of exactly the selected preserved-input samples; signed change = 100*(I-B)/B. ' ...
    'Saved sink convention = -minimum; saved surge convention = maximum. Integral = sum(fraction)/fs. ' ...
    'These are optical descriptions, not oxygen concentration or scientific acceptance. NaN means unavailable.'], 'WordWrap','on');
Current=[];R=[];Index=[];
Panel=struct('Update',@update,'Data',@data,'Choice',Choice,'Summary',Summary,'Original',Original,'Results',Results,'RawAxes',RawAxes,'FractionAxes',FractionAxes);
    function v=data(),v=Current;end
    function reset()
        Current=[];Results.Data=table();cla(RawAxes,'reset');cla(FractionAxes,'reset');
        Choice.Enable='off';Choice.ItemsData=[];Choice.Items={'No saved interval'};Choice.ItemsData=0;Choice.Value=0;
    end
    function update(review,index)
        R=review;Index=index;reset();a=review.Audit(index,:);
        Identity.Text=sprintf('Saved %s site %d / event %d | reviewed optical preview',a.EventType,a.SiteID,a.EventID);
        Original.Text=sprintf('Original automatic interval %d-%d | amplitude %s | reference status: %s.\nThe original result is preserved; recognition remains a separate saved judgment.', ...
            a.StartFrame,a.EndFrame,pct(a.StoredAmplitude),strrep(char(a.StoredStatus),'_',' '));
        try
            Current=buildBOIReviewedOpticalPreview(review,index);Summary.Text=Current.Message;
            if isempty(Current.Intervals),return;end
            M=Current.Intervals;labels=cell(1,numel(M));
            for k=1:numel(M)
                labels{k}=sprintf('Onset %d%s; recovery %d%s',M(k).OnsetFrame,preferred(M(k).PreferredOnset),M(k).RecoveryFrame,preferred(M(k).PreferredRecovery));
            end
            Choice.ItemsData=[];Choice.Items=labels;Choice.ItemsData=1:numel(M);
            ix=find([M.PreferredOnset]&[M.PreferredRecovery],1);if isempty(ix),ix=find([M.PreferredOnset],1);end
            if isempty(ix),ix=1;end
            Choice.Value=ix;Choice.Enable='on';
            Results.Data=table([M.OnsetFrame]',[M.RecoveryFrame]',[M.ReferenceSampleCount]',100*[M.MinimumSignedChangeFraction]', ...
                100*[M.MaximumSignedChangeFraction]',100*[M.SavedSignDirectionalAmplitudeFraction]',[M.SignedTraceIntegralSec]', ...
                replace(string({M.Status})',"_"," "),'VariableNames',{'Onset','Recovery','ReferenceSamples','MinPercent','MaxPercent','SavedSignPercent','IntegralSec','Status'});
            Results.ColumnName={'Onset','Recovery','Reference samples','Signed min (%)','Signed max (%)','Saved-sign amplitude (%)','Integral (fraction s)','Status'};
            Results.ColumnWidth={65,85,145,125,125,215,175,'auto'};render();
        catch err
            reset();Summary.Text=['Reviewed optical preview unavailable: ' err.message];
        end
    end
    function choose()
        chosen=Choice.Value;update(R,Index);
        if ~isempty(Current)&&numel(Current.Intervals)>=chosen,Choice.Value=chosen;render();end
    end
    function render()
        M=Current.Intervals(Choice.Value);C=M.ReferenceFrames;E=M.EventFrames;
        Summary.Text=sprintf('Reference %s: %s samples; B = %s input units; %s native eligible within selection (original request: %d).\nInterval %d-%d; duration %.3g s; endpoint span %.3g s. %s. Recognition: %s.', ...
            frameText(C),num(M.ReferenceSampleCount),num(M.ReferenceMean),num(M.NativeEligibleWithinSelectedReference),M.OriginalRequiredReferenceSamples, ...
            M.OnsetFrame,M.RecoveryFrame,M.DurationSec,M.EndpointSpanSec,strrep(M.Status,'_',' '),M.RecognitionStatus);
        if isempty(C)
            Summary.Text=sprintf('No accepted reference for onset %d. Reviewed optical quantities are unavailable.\nInterval %d-%d; duration %.3g s; endpoint span %.3g s. Recognition: %s.', ...
                M.OnsetFrame,M.OnsetFrame,M.RecoveryFrame,M.DurationSec,M.EndpointSpanSec,M.RecognitionStatus);
        end
        lo=max(1,min([C;E])-5);hi=min(R.AnalysisInfo.NFrames,max(E)+5);frames=(lo:hi)';raw=double(R.Traces{Index}.Raw(:));
        cla(RawAxes,'reset');plot(RawAxes,frames,raw(frames),'k.-');hold(RawAxes,'on');
        scatter(RawAxes,C,raw(C),45,[0 .35 .9],'o','LineWidth',1.4,'Tag','BOIOpticalReferenceSamples');
        if isfinite(M.ReferenceMean),yline(RawAxes,M.ReferenceMean,'--','B','Color',[0 .35 .9],'Tag','BOIReviewedReferenceMean');end
        for f=[M.OnsetFrame M.RecoveryFrame],xline(RawAxes,f,':','Color',[.6 .15 .7]);end
        title(RawAxes,'Measurement source: preserved-input fixed-footprint mean; blue = accepted reference');ylabel(RawAxes,'Input intensity');xlabel(RawAxes,'Recording frame (1-based)');grid(RawAxes,'on');hold(RawAxes,'off');
        cla(FractionAxes,'reset');plot(FractionAxes,E,100*M.SignedFraction,'k.-','Tag','BOIReviewedSignedPercent');hold(FractionAxes,'on');xlim(FractionAxes,[M.OnsetFrame-.5 M.RecoveryFrame+.5]);
        if strcmp(M.Status,'computed_exploratory'),yline(FractionAxes,0,':','Tag','BOIOpticalZero');end
        if ~strcmp(M.Status,'computed_exploratory'),text(FractionAxes,.5,.5,strrep(M.Status,'_',' '),'Units','normalized','HorizontalAlignment','center','Interpreter','none','BackgroundColor',[1 1 1],'Tag','BOIOpticalUnavailable');end
        title(FractionAxes,'Signed change relative to the accepted reference; no sign correction');ylabel(FractionAxes,'Signed change (%)');xlabel(FractionAxes,'Recording frame (1-based; elapsed s = frame-1)');grid(FractionAxes,'on');hold(FractionAxes,'off');
    end
end
function s=num(v)
s='unavailable';if isfinite(v),s=sprintf('%.6g',v);end
end
function s=preferred(v)
s='';if v,s=' (preferred)';end
end
function s=frameText(f)
s='not accepted';if ~isempty(f),s=char(strjoin(string(f(:)'),', '));if all(diff(f)==1),s=sprintf('%d-%d',f(1),f(end));end,end
end

function s=pct(v)
s='unavailable';if isfinite(v),s=sprintf('%.6g %%',100*v);end
end
