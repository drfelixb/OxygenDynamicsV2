function [Fig,UI]=openBOIReviewedPocketEvidence(Folder)
%OPENBOIREVIEWEDPOCKETEVIDENCE Portable read-only view; no implicit calculation.
setupOxygenDynamicsPath;
if nargin<1,Folder=uigetdir(pwd,'Choose saved reviewed-pocket evidence');if isequal(Folder,0),Fig=[];UI=[];return;end;end
store=loadBOIReviewedPocketEvidence(Folder);e=store.Document;
Fig=uifigure('Name','BOI saved reviewed pocket','Position',[90 80 1120 800],'AutoResizeChildren','off');
g=uipanel(Fig,'BorderType','none','AutoResizeChildren','off');
header=uilabel(g,'Text',['Saved exploratory revision; no replay on open. External audit: ' store.ExternalAuditVerification], ...
    'WordWrap','on','Interpreter','none','FontSize',12,'Tooltip',store.Path);
summary=uilabel(g,'Text',sprintf('Corrected signed trough: %.15g%% (%s)\nRaw companion: %.15g%% (%s) — %% of raw reference intensity, not oxygen %%.', ...
    e.Measures.CorrectedSignedTroughPercent,e.Measures.PrimaryStatus,e.Measures.RawSignedTroughPercent,e.Measures.CompanionStatus), ...
    'WordWrap','on','Interpreter','none','FontSize',12);
referenceText=char(e.Judgment.ReferenceSuitability);
if strcmp(referenceText,'provisional_local_state'),referenceText=['CONDITIONAL — ' referenceText];end
qualification=uilabel(g,'Text',sprintf('Reference: %s (%d frames). Endpoint: %s; confirmed duration not established.\n%s\nSaved detector sign: %s; %d fixed pixels. Automatic amplitude: %s.', ...
    referenceText,numel(e.ReferenceFrames),e.Judgment.EndpointStatus,e.FootprintQualification,e.FootprintOrigin,numel(e.FixedFootprint),automaticText(e)), ...
    'WordWrap','on','Interpreter','none','FontSize',12);
a=uiaxes(g);a.FontSize=12;hold(a,'on');
if ~isempty(e.Ingredients.Corrected)
    plot(a,(1:numel(e.Ingredients.Corrected))',e.Ingredients.Corrected,'Color',[.1 .4 .8],'LineWidth',1.3,'Tag','BOIPocketCorrected');
    scatter(a,e.ReferenceFrames,e.Ingredients.Corrected(e.ReferenceFrames),22,[0 .6 .2],'filled');
    title(a,'Primary: saved corrected intensity; green = reviewed reference');
else
    title(a,'Primary unavailable: matching saved correction is missing');
end
xline(a,e.EventFrames(1),'--');xline(a,e.EventFrames(end),'--');hold(a,'off');
xlim(a,[max(1,min([e.ReferenceFrames;e.EventFrames])-20) min(numel(e.Ingredients.Raw),max(e.EventFrames)+20)]);grid(a,'on');
if ~isempty(e.Ingredients.Corrected)
    visible=e.Ingredients.Corrected(max(1,min([e.ReferenceFrames;e.EventFrames])-20):min(numel(e.Ingredients.Raw),max(e.EventFrames)+20));
    visible=visible(isfinite(visible));
    if ~isempty(visible)
        bounds=[min(visible) max(visible)];padding=max(diff(bounds)*.06,max(1,max(abs(bounds)))*.01);
        ylim(a,bounds+[-padding padding]);
    end
end
xlabel(a,'One-based recording frame');ylabel(a,'Saved corrected intensity (a.u.)');
d=uitextarea(g,'Value',[{['Saved evidence folder: ' store.Path]};cellstr(splitlines(string(formatBOIPocketEvidence(e))))],'Editable','off','FontSize',12);
verifyButton=uibutton(g,'Text','Verify saved arithmetic','FontSize',12,'ButtonPushedFcn',@verify);
exportButton=uibutton(g,'Text','Export to NEW folder','FontSize',12,'ButtonPushedFcn',@export);
state=uilabel(g,'Text','Stored values displayed.','WordWrap','on','Interpreter','none','FontSize',12);
Fig.SizeChangedFcn=@resize;resize();
UI=struct('Store',store,'Details',d,'Axes',a,'State',state,'Summary',summary,'Qualification',qualification, ...
    'Grid',g,'VerifyButton',verifyButton,'ExportButton',exportButton,'Verify',@verifyValues,'Export',@(path)exportBOIReviewedPocketEvidence(store,path));
    function m=verifyValues()
        m=verifyBOIReviewedPocketArithmetic(store.Document);
    end
    function resize(varargin)
        % Explicit nonoverlapping rectangles also survive exportapp capture.
        width=Fig.Position(3)-20;height=Fig.Position(4)-20;
        g.Position=[10 10 width height];
        header.Position=[0 height-42 width 42];
        summary.Position=[0 height-96 width 48];
        qualification.Position=[0 height-182 width 80];
        a.OuterPosition=[14 192 width-28 max(220,height-380)];
        d.Position=[0 62 width 124];
        verifyButton.Position=[0 0 190 56];exportButton.Position=[200 0 220 56];
        state.Position=[430 0 max(1,width-430) 56];
    end
    function verify(~,~)
        try,verifyValues();state.Text='Explicit saved arithmetic replay passed; no physiology or source-recording validation.';
        catch err,uialert(Fig,err.message,'Replay failed');end
    end
    function export(~,~)
        parent=uigetdir(fileparts(store.Path),'Choose PARENT folder; a NEW export child will be created');if isequal(parent,0),return;end
        [~,name]=fileparts(tempname(parent));target=fullfile(parent,['ReviewedPocket_' name]);
        try
            exportBOIReviewedPocketEvidence(store,target);
            state.Text='Export complete. Full folder path is at the top of the details.';state.Tooltip=target;
            d.Value=[{['Exported folder: ' target]};d.Value];
        catch err,uialert(Fig,err.message,'Export failed');end
    end
end
function text=automaticText(e)
text='unavailable (unchanged)';
if isfinite(e.OriginalAutomatic.StoredAmplitude),text=sprintf('%.15g%% (unchanged)',100*e.OriginalAutomatic.StoredAmplitude);end
end
