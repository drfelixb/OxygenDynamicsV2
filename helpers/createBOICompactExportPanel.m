function Panel=createBOICompactExportPanel(Parent,Host)
%CREATEBOICOMPACTEXPORTPANEL Saved source -> preview -> new compact workbook.
S=struct('Source',[],'FollowOpened',true,'SuggestedDestination','','Plan',[],'Selection',[], ...
    'Busy',false,'Result',[],'Options',struct(),'WriteObserver',[]);
g=uigridlayout(Parent,[6 6]);g.Padding=[8 8 8 8];g.ColumnWidth={106,86,190,'1x',170,184};
g.RowHeight={30,30,32,38,28,'1x'};
at(uilabel(g,'Text','Source'),1,1);
source=uieditfield(g,'text','Editable','off','Placeholder','Completed automatic export');at(source,1,[2 5]);
choose=uibutton(g,'Text','Choose automatic export…','ButtonPushedFcn',@chooseSource);at(choose,1,6);
at(uilabel(g,'Text','Save as'),2,1);
destination=uieditfield(g,'text','Placeholder','New compact .xlsx filename','ValueChangedFcn',@changed);at(destination,2,[2 5]);
destButton=uibutton(g,'Text','Choose location…','ButtonPushedFcn',@chooseOutput);at(destButton,2,6);
previewButton=uibutton(g,'Text','Preview compact workbook','Enable','off', ...
    'ButtonPushedFcn',@(~,~)guard(@preview));at(previewButton,3,[1 2]);
exportButton=uibutton(g,'Text','Export compact workbook','FontWeight','bold','Enable','off', ...
    'ButtonPushedFcn',@(~,~)guard(@export));at(exportButton,3,3);
openButton=uibutton(g,'Text','Open compact workbook','Visible','off','ButtonPushedFcn',@(~,~)openResult());at(openButton,3,5);
folderButton=uibutton(g,'Text','Open output folder','Visible','off','ButtonPushedFcn',@(~,~)openFolder());at(folderButton,3,6);
outcome=uilabel(g,'Text','','WordWrap','on','Interpreter','none');at(outcome,4,[1 6]);
optionalButton=uibutton(g,'state','Text','Optional settings','ValueChangedFcn',@(~,~)showOptional());at(optionalButton,5,[1 2]);
optionalSummary=uilabel(g,'Text','','WordWrap','on','Interpreter','none');at(optionalSummary,5,[3 6]);
body=uigridlayout(g,[2 1]);body.Padding=[0 0 0 0];body.RowSpacing=0;at(body,6,[1 6]);
details=uitextarea(body,'Editable','off');at(details,1,1);
optional=uigridlayout(body,[5 4]);optional.Padding=[6 6 6 6];optional.Scrollable='on';at(optional,2,1);
optional.ColumnWidth={184,'1x',184,'1x'};optional.RowHeight={30,64,30,30,30};
add=uibutton(optional,'Text','Add reviewed export…','ButtonPushedFcn',@addReviews);at(add,1,1);
remove=uibutton(optional,'Text','Remove selected review','ButtonPushedFcn',@removeReviews);at(remove,1,2);
restore=uibutton(optional,'Text','Restore review choices','ButtonPushedFcn',@(~,~)guard(@restoreChoices));at(restore,1,3);
remember=uicheckbox(optional,'Text','Remember review choices for this batch','ValueChangedFcn',@changed);at(remember,1,4);
reviews=uilistbox(optional,'Items',{},'Multiselect','on');at(reviews,2,[1 4]);
reviews.Tooltip='Select completed ReviewedHypoxicBurden.mat files from the same automatic export.';
metadataButton=uibutton(optional,'Text','Choose metadata CSV…','ButtonPushedFcn',@chooseMetadata);at(metadataButton,3,1);
metadataPath=uieditfield(optional,'text','Placeholder','Metadata with RecordingID','ValueChangedFcn',@changed);at(metadataPath,3,[2 4]);
phaseButton=uibutton(optional,'Text','Choose phases CSV…','ButtonPushedFcn',@choosePhases);at(phaseButton,4,1);
phasePath=uieditfield(optional,'text','Placeholder','Saved phase annotations','ValueChangedFcn',@changed);at(phasePath,4,[2 4]);
use=uibutton(optional,'Text','Use opened automatic export','ButtonPushedFcn',@(~,~)guard(@useOpened));at(use,5,1);
controls={use,source,choose,add,remove,restore,remember,reviews,metadataButton,metadataPath,phaseButton,phasePath, ...
    destButton,destination,previewButton,exportButton,openButton,folderButton,optionalButton};
Panel=struct('SetInputs',@setInputs,'UseOpened',@useOpened,'Preview',@preview,'Export',@export,'Cancel',@cancel, ...
    'State',@state,'SetWriteObserver',@setWriteObserver,'SetBusy',@setBusy,'Controls',{controls},'Destination',destination,'Source',source,'Reviews',reviews, ...
    'MetadataPath',metadataPath,'PhasePath',phasePath,'Details',details,'Outcome',outcome,'ExportButton',exportButton, ...
    'PreviewButton',previewButton,'ActionButton',previewButton,'OptionalButton',optionalButton,'OptionalSettings',optional,'OfferOpenedSource',@offerOpenedSource, ...
    'UseAutomaticButton',use,'OpenButton',openButton,'RestoreChoices',@restoreChoices);
invalidate();
    function value=state(),value=S;end
    function setWriteObserver(value)
        idle();assert(isempty(value)||isa(value,'function_handle'),'OxygenDynamics:CompactObserver','Writer observer must be a function handle.');S.WriteObserver=value;
    end
    function idle()
        assert(~S.Busy,'OxygenDynamics:BatchBusy','Wait for the current operation.');Host.AssertIdle();
    end
    function setInputs(auto,paths,output,options)
        idle();if nargin<4,options=struct();end
        S.Source=auto;S.FollowOpened=false;S.SuggestedDestination='';S.Options=options;
        showSource();reviews.Items=cellstr(string(paths));
        destination.Value=char(output);metadataPath.Value='';phasePath.Value='';invalidate();
    end
    function useOpened()
        idle();selectSource(Host.AutomaticSource(),true);
    end
    function offerOpenedSource(auto)
        if S.FollowOpened&&~isequaln(S.Source,auto),selectSource(auto,true);end
    end
    function selectSource(auto,followOpened)
        S.Source=auto;S.FollowOpened=followOpened;S.Options=struct();reviews.Items={};remember.Value=false;
        if isempty(strtrim(destination.Value))||strcmp(destination.Value,S.SuggestedDestination)
            S.SuggestedDestination=suggestDestination(sourceLabel(auto));
            destination.Value=S.SuggestedDestination;
        end
        showSource();invalidate();
    end
    function showSource()
        path=sourceLabel(S.Source);
        source.Value=shortName(path);source.Tooltip=path;
        choose.Text='Choose automatic export…';
        if ~isempty(S.Source),choose.Text='Change source…';end
    end
    function restoreChoices()
        idle();if isempty(S.Source),return;end
        b=batchContext();
        if isempty(b.FilePath)||~isfile([char(b.FilePath) '.compact-selection.json']),return;end
        L=loadBOICompactWorkbookSources(S.Source,{},struct());
        V=boiCompactExportSelection('load',b.FilePath,L.AutomaticSHA256);
        if V.Restored,reviews.Items=V.ReviewPaths;invalidate();outcome.Text='Saved compatible batch review selection restored; preview required.';end
    end
    function p=preview()
        idle();invalidate();begin('Preparing compact workbook from saved tables.');c=onCleanup(@finish);
        try
            options=inputOptions();[p,prepared]=prepareBOICompactWorkbook(S.Source,reviews.Items,destination.Value,options);
            recordingCount=height(prepared.Source.Registry);clear prepared;
            S.Plan=p;S.Selection=selection();
            details.Value=[{sprintf('%d recordings · %d detections',recordingCount,p.Counts.Events); ...
                ['Worksheets: ' strjoin(p.Sheets,', ')]};optionDetails(options)];
            optionalButton.Value=false;showOptional();
            outcome.Text=sprintf('Preview ready · %d recordings · %d worksheets',recordingCount,numel(p.Sheets));
        catch err
            S.Plan=[];S.Selection=[];outcome.Text='Preview failed; previous completed workbook retained.';rethrow(err);
        end
        clear c;
    end
    function lines=optionDetails(options)
        lines=cell(0,1);
        for k=1:numel(reviews.Items)
            path=reviews.Items{k};
            lines{end+1,1}=['Reviewed export: ' shortName(fileparts(path)) '/' shortName(path)]; %#ok<AGROW>
        end
        if ~isempty(metadataPath.Value)
            lines{end+1,1}=['Metadata: ' shortName(metadataPath.Value)];
        elseif isfield(options,'Metadata')&&~isempty(options.Metadata)
            lines{end+1,1}='Metadata: batch recording fields';
        end
        if ~isempty(phasePath.Value)
            lines{end+1,1}=['Phase annotations: ' shortName(phasePath.Value)];
        elseif isfield(options,'Phases')&&~isempty(options.Phases)
            lines{end+1,1}='Phase annotations: supplied table';
        end
        if isempty(lines),lines={'Automatic values'};end
    end
    function receipt=export()
        idle();assert(~isempty(S.Plan),'OxygenDynamics:CompactPreview','Preview the current compact selection first.');
        if ~isequaln(S.Selection,selection()),invalidate();error('OxygenDynamics:CompactPlanChanged','Selection changed. Preview again.');end
        p=S.Plan;begin('Writing compact saved-value workbook.');c=onCleanup(@finish);
        try
            before=S.WriteObserver;if isfield(Host,'BeforeWrite'),before=Host.BeforeWrite;end
            receipt=exportBOICompactWorkbook(S.Source,reviews.Items,destination.Value,inputOptions(),p,before);S.Result=receipt;
            outcome.Text=['Compact workbook complete: ' receipt.Workbook];
            if remember.Value
                b=batchContext();
                if ~isempty(b.FilePath)
                    try,boiCompactExportSelection('save',b.FilePath,p.AutomaticSHA256,reviews.Items);
                    catch err,details.Value=[cellstr(string(details.Value(:)));{['Workbook complete; selection was not remembered: ' err.message]}];end
                end
            end
        catch err
            S.Plan=[];S.Selection=[];outcome.Text='Export failed; previous completed workbook retained. Preview again.';rethrow(err);
        end
        S.Plan=[];S.Selection=[];clear c;
    end
    function options=inputOptions()
        options=S.Options;b=batchContext();
        if isfield(b,'Metadata')&&~isempty(b.Metadata),options.Metadata=b.Metadata;end
        if ~isempty(metadataPath.Value),options.Metadata=readText(metadataPath.Value);end
        if ~isempty(phasePath.Value)
            P=readText(phasePath.Value);
            for f={'StartSec','EndSec'},if ismember(f,P.Properties.VariableNames),P.(f{1})=str2double(P.(f{1}));end,end
            options.Phases=P;
        end
    end
    function b=batchContext()
        b=struct('FilePath','','Metadata',table());
        if isfield(Host,'BatchContext')
            if nargin(Host.BatchContext)==0,b=Host.BatchContext();else,b=Host.BatchContext(S.Source);end
        end
    end
    function v=selection()
        v=struct('Source',S.Source,'Reviews',{reviews.Items},'Output',destination.Value,'Metadata',metadataPath.Value, ...
            'Phases',phasePath.Value,'Options',S.Options,'Remember',remember.Value);
    end
    function invalidate()
        S.Plan=[];S.Selection=[];sync();details.Value={''};showOptional();
        if isempty(S.Source),outcome.Text='Choose a completed automatic export.';
        elseif isempty(strtrim(destination.Value)),outcome.Text='Choose where to save the compact workbook.';
        else,outcome.Text='Preview the workbook to check its contents before export.';end
    end
    function cancel(),idle();invalidate();outcome.Text='Preview cancelled; previous completed workbook retained.';end
    function setBusy(v),S.Busy=logical(v);sync();end
    function begin(message),Host.Begin(message);S.Busy=true;sync();end
    function finish(),S.Busy=false;Host.End();sync();end
    function sync()
        for j=1:numel(controls),controls{j}.Enable=onoff(~S.Busy);end
        previewButton.Enable=onoff(~S.Busy&&~isempty(S.Source)&&~isempty(strtrim(destination.Value)));
        exportButton.Enable=onoff(~S.Busy&&~isempty(S.Plan)&&isequaln(S.Selection,selection()));
        ready=~isempty(S.Result)&&isfile(S.Result.Workbook);
        openButton.Visible=onoff(ready);folderButton.Visible=onoff(ready);
        openButton.Enable=onoff(ready&&~S.Busy);folderButton.Enable=onoff(ready&&~S.Busy);
        destination.Tooltip=destination.Value;
        labels=strings(0,1);
        if ~isempty(reviews.Items),labels(end+1)=sprintf('%d reviewed exports',numel(reviews.Items));end
        if ~isempty(metadataPath.Value),labels(end+1)="Metadata CSV";end
        if ~isempty(phasePath.Value),labels(end+1)="Phase annotations";end
        optionalSummary.Text=char(strjoin(labels,' · '));
    end
    function showOptional()
        if optionalButton.Value
            body.RowHeight={0,'1x'};optionalButton.Text='▾ Optional settings';
        else
            body.RowHeight={'1x',0};optionalButton.Text='▸ Optional settings';
        end
        optional.Visible=onoff(optionalButton.Value);
        details.Visible=onoff(~optionalButton.Value&&any(strlength(string(details.Value))>0));
    end
    function changed(~,~),idle();invalidate();end
    function chooseSource(~,~)
        idle();[f,p]=uigetfile({'*.mat;*.xlsx','Saved automatic export'},'Choose automatic export');if isequal(f,0),return;end
        selectSource(fullfile(p,f),false);
    end
    function addReviews(~,~)
        idle();[f,p]=uigetfile('*.mat','Choose completed ReviewedHypoxicBurden.mat','MultiSelect','on');if isequal(f,0),return;end
        if ischar(f),f={f};end
        values=cellfun(@(n)fullfile(p,n),f,'UniformOutput',false);reviews.Items=unique([reshape(reviews.Items,1,[]) values],'stable');invalidate();
    end
    function removeReviews(~,~),idle();reviews.Items=setdiff(reviews.Items,reviews.Value,'stable');invalidate();end
    function chooseMetadata(~,~)
        idle();[f,p]=uigetfile('*.csv','Choose optional explicit metadata');if isequal(f,0),return;end
        metadataPath.Value=fullfile(p,f);invalidate();
    end
    function choosePhases(~,~)
        idle();[f,p]=uigetfile('*.csv','Choose supplied phase annotations');if isequal(f,0),return;end
        phasePath.Value=fullfile(p,f);invalidate();
    end
    function chooseOutput(~,~)
        idle();[f,p]=uiputfile('*.xlsx','Choose a new compact workbook',destination.Value);if isequal(f,0),return;end
        destination.Value=fullfile(p,f);invalidate();
    end
    function openResult(),idle();if ~isempty(S.Result),open(S.Result.Workbook);end,end
    function openFolder(),idle();if ~isempty(S.Result),folder=fileparts(S.Result.Workbook);if ispc,winopen(folder);else,exe='xdg-open';if ismac,exe='/usr/bin/open';end;args=javaArray('java.lang.String',2);args(1)=java.lang.String(exe);args(2)=java.lang.String(folder);process=java.lang.ProcessBuilder(args).start();process.waitFor();end;end,end
    function guard(action)
        try,action();catch err,uialert(ancestor(Parent,'figure'),err.message,'Compact export needs attention');end
    end
end
function v=sourceLabel(s)
if isempty(s),v='';return;end
if isstruct(s)
    if isfield(s,'Workbook'),v=char(s.Workbook);elseif isfield(s,'DataOutput'),v=char(s.DataOutput);else,v='Constructed saved tables';end
else,v=char(string(s));end
end
function name=shortName(path)
[~,stem,extension]=fileparts(path);name=[stem extension];
end
function path=suggestDestination(source)
path='';if ~isfile(source),return;end
[folder,stem]=fileparts(source);
stem=[regexprep(stem,'^FilteredData_','') '_compact'];
path=fullfile(folder,[stem '.xlsx']);suffix=1;
while isfile(path)||isfolder(path)||isfile([path '.receipt.json'])
    suffix=suffix+1;path=fullfile(folder,sprintf('%s_%d.xlsx',stem,suffix));
end
end
function T=readText(p)
opt=detectImportOptions(p,'VariableNamingRule','preserve');opt=setvartype(opt,opt.VariableNames,'string');T=readtable(p,opt);
end
function at(c,r,col),c.Layout.Row=r;c.Layout.Column=col;end
function v=onoff(b),if b,v='on';else,v='off';end,end
