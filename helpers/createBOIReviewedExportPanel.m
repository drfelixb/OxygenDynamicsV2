function Panel=createBOIReviewedExportPanel(Parent,Host)
%CREATEBOIREVIEWEDEXPORTPANEL Explicit saved-review handoff to the existing writer.
S=struct('Plan',[],'Confirmed',false,'Busy',false,'Result',[],'Selection',[]);
g=uigridlayout(Parent,[9 4]);g.Padding=[8 8 8 8];g.RowSpacing=6;g.Scrollable='on';
g.ColumnWidth={155,'1x',155,'1x'};g.RowHeight={30,30,72,30,104,26,32,24,65};
sourceButton=uibutton(g,'Text','Choose automatic MAT…','ButtonPushedFcn',@chooseSource);at(sourceButton,1,1);
source=uieditfield(g,'text','Placeholder','Saved automatic combined DataOutput.mat','ValueChangedFcn',@changed);at(source,1,[2 3]);
useAutomatic=uibutton(g,'Text','Use opened automatic export','ButtonPushedFcn',@useSource);at(useAutomatic,1,4);
addReview=uibutton(g,'Text','Add saved reviews…','ButtonPushedFcn',@chooseReviews);at(addReview,2,1);
removeReview=uibutton(g,'Text','Remove selected review','ButtonPushedFcn',@removeReviews);at(removeReview,2,2);
addEvent=uibutton(g,'Text','Add event result…','ButtonPushedFcn',@chooseEvent);at(addEvent,2,3);
removeEvent=uibutton(g,'Text','Remove selected event','ButtonPushedFcn',@removeEvents);at(removeEvent,2,4);
reviews=uilistbox(g,'Items',{},'Multiselect','on');at(reviews,3,[1 2]);
reviews.Tooltip='Explicit saved boundary-review JSON revisions. Select one reconciled snapshot per event; no drafts or automatic latest selection.';
events=uilistbox(g,'Items',{},'Multiselect','on');at(events,3,[3 4]);
events.Tooltip='Optional already approved single-event result folders containing ReviewedEventBurden.json and Checksums.json. Experimental previews are not imported.';
parentButton=uibutton(g,'Text','Choose output parent…','ButtonPushedFcn',@chooseParent);at(parentButton,4,1);
destination=uieditfield(g,'text','Placeholder','NEW separate reviewed-burden destination','ValueChangedFcn',@changed);at(destination,4,[2 4]);
details=uitextarea(g,'Editable','off','Value',{'Optional reviewed burden-only companion. Automatic full statistics remain in their original export.', ...
    'Select an automatic DataOutput.mat, saved review JSON revisions and optional accepted event results, then preview.', ...
    'Only saved not-a-pocket decisions are excluded. Unreviewed/uncertain detections remain included; missing required contributions withhold complete burden.', ...
    'Drafts and experimental previews are not applied. Individual review is not required for ordinary automatic export.'});at(details,5,[1 4]);
confirm=uicheckbox(g,'Text','I checked these saved revisions, applied decisions and the new destination','Enable','off', ...
    'ValueChangedFcn',@confirmed);at(confirm,6,[1 4]);
previewButton=uibutton(g,'Text','Preview reviewed export','ButtonPushedFcn',@previewCallback);at(previewButton,7,1);
runButton=uibutton(g,'Text','Export reviewed burden','Enable','off','ButtonPushedFcn',@runCallback);at(runButton,7,2);
workbookButton=uibutton(g,'Text','Open reviewed workbook','Enable','off','ButtonPushedFcn',@openWorkbook);at(workbookButton,7,3);
outcome=uilabel(g,'Text','No reviewed export created.','WordWrap','on','Interpreter','none');at(outcome,7,4);
folder=createBOIExportFolderPanel(g);at(folder.Grid,[8 9],[1 4]);
controls={sourceButton,source,useAutomatic,addReview,removeReview,addEvent,removeEvent,reviews,events, ...
    parentButton,destination,confirm,previewButton,runButton,workbookButton,folder.OpenButton,folder.CopyButton};
Panel=struct('SetInputs',@setInputs,'Preview',@preview,'Confirm',@confirmPlan,'Export',@export, ...
    'SetBusy',@setBusy,'State',@state,'Controls',{controls},'Source',source,'Destination',destination, ...
    'Reviews',reviews,'Events',events,'Details',details,'Confirmation',confirm,'PreviewButton',previewButton, ...
    'RunButton',runButton,'WorkbookButton',workbookButton,'UseAutomaticButton',useAutomatic,'Outcome',outcome,'Folder',folder);
    function s=state(),s=S;end
    function idle()
        assert(~S.Busy,'OxygenDynamics:BatchBusy','Wait for the current operation to finish.');Host.AssertIdle();
    end
    function setInputs(mat,paths,eventPaths,output)
        idle();source.Value=char(string(mat));destination.Value=char(string(output));
        reviews.Items=list(paths);events.Items=list(eventPaths);invalidate();
    end
    function invalidate()
        S.Plan=[];S.Selection=[];S.Confirmed=false;confirm.Value=false;sync();
        outcome.Text='Preview required for current selection.';
    end
    function setBusy(value),S.Busy=logical(value);sync();end
    function sync()
        for k=1:numel(controls),controls{k}.Enable=enabled(~S.Busy);end
        confirm.Enable=enabled(~S.Busy&&~isempty(S.Plan));
        runButton.Enable=enabled(~S.Busy&&S.Confirmed&&~isempty(S.Plan));
        available=~isempty(S.Result)&&isfile(S.Result.Workbook);
        workbookButton.Enable=enabled(~S.Busy&&available);
        folder.OpenButton.Enable=enabled(~S.Busy&&available);folder.CopyButton.Enable=enabled(~S.Busy&&available);
    end
    function p=preview()
        idle();invalidate();Host.Begin('Checking saved reviewed-burden inputs. No export or original-movie reading.');
        cleanup=onCleanup(@()Host.End());
        try
            p=prepareBOIReviewedBurdenExport(source.Value,reviews.Items,destination.Value,events.Items);
            S.Plan=p;S.Selection=selection();details.Value=formatPlan(p);outcome.Text='Preview ready; confirmation required.';
        catch err
            details.Value={['Preview failed: ' err.message],'No export was started. Correct the selected paths and preview again.'};
            outcome.Text='Preview failed; previous export retained.';rethrow(err);
        end
        clear cleanup
    end
    function confirmPlan(value)
        idle();assert(~isempty(S.Plan),'OxygenDynamics:ReviewedExportNotReviewed','Preview the selected saved inputs first.');
        assert(islogical(value)&&isscalar(value),'OxygenDynamics:ReviewedExportConfirmation','Confirm with one logical value.');
        S.Confirmed=value;confirm.Value=value;sync();
    end
    function result=export()
        idle();assert(S.Confirmed&&~isempty(S.Plan),'OxygenDynamics:ReviewedExportNotConfirmed','Preview and confirm the selected saved inputs first.');
        if ~isequaln(S.Selection,selection())
            invalidate();error('OxygenDynamics:ReviewedExportPlanChanged','Selection changed. Preview and confirm again.');
        end
        p=S.Plan;Host.Begin('Rechecking the confirmed saved inputs, then writing a separate reviewed-burden companion.');
        cleanup=onCleanup(@()finish());
        try
            result=folder.ExportTo(@(~)exportBOIReviewedBurden(p.StatsMAT,p.ReviewPaths,p.OutputFolder,p.ReviewedEventFolders,p),p.OutputFolder);
            S.Result=result;
            outcome.Text=sprintf('Export complete; %d / %d normalized burdens available.',p.Counts.AvailableNormalizedRecordings,p.Counts.Recordings);
            details.Value=[formatPlan(p);{'';'COMPLETED reviewed burden-only companion.'; ...
                ['Workbook: ' result.Workbook];'ReviewDecisions / ExcludedDetections / EventRevisions preserve applied identities and provenance.'; ...
                'HypoxicBurden_ByRecording / EventBased / TimeSeries use the retained set. Missing values remain unavailable, not zero or partial sums.'}];
        catch err
            outcome.Text='Export failed; previous completed export retained.';
            details.Value=[{['Export stopped: ' err.message];'Preview and confirm again. No automatic result was overwritten.'};cellstr(string(details.Value(:)))];rethrow(err);
        end
        clear cleanup
    end
    function value=selection()
        value=struct('Source',source.Value,'Reviews',{reviews.Items},'Events',{events.Items},'Destination',destination.Value);
    end
    function finish()
        S.Plan=[];S.Confirmed=false;confirm.Value=false;Host.End();
    end
    function changed(~,~),idle();invalidate();end
    function confirmed(~,~),guard(@()confirmPlan(logical(confirm.Value)));end
    function previewCallback(~,~),guard(@preview);end
    function runCallback(~,~),guard(@export);end
    function chooseSource(~,~)
        idle();[name,path]=uigetfile('*.mat','Choose saved automatic combined DataOutput.mat');
        if isequal(name,0),return;end
        source.Value=fullfile(path,name);invalidate();
    end
    function useSource(~,~)
        guard(@useOpened);
    end
    function useOpened()
        idle();source.Value=Host.AutomaticMAT();invalidate();
    end
    function chooseReviews(~,~)
        idle();[names,path]=uigetfile('*.json','Choose explicit saved boundary-review revisions','MultiSelect','on');
        if isequal(names,0),return;end
        if ischar(names),names={names};end
        values=cellfun(@(n)fullfile(path,n),names,'UniformOutput',false);
        reviews.Items=unique([reshape(reviews.Items,1,[]) values],'stable');invalidate();
    end
    function chooseEvent(~,~)
        idle();path=uigetdir(pwd,'Choose approved single-event result folder (contains ReviewedEventBurden.json)');
        if isequal(path,0),return;end
        events.Items=unique([reshape(events.Items,1,[]) {path}],'stable');invalidate();
    end
    function removeReviews(~,~),idle();reviews.Items=setdiff(reviews.Items,reviews.Value,'stable');invalidate();end
    function removeEvents(~,~),idle();events.Items=setdiff(events.Items,events.Value,'stable');invalidate();end
    function chooseParent(~,~)
        idle();path=uigetdir(pwd,'Choose parent for a NEW reviewed burden-only export');
        if isequal(path,0),return;end
        destination.Value=fullfile(path,['ReviewedBurden_' char(java.util.UUID.randomUUID())]);invalidate();
    end
    function openWorkbook(~,~)
        idle();if ~isempty(S.Result),open(S.Result.Workbook);end
    end
    function guard(action)
        try,action();catch err,uialert(ancestor(Parent,'figure'),err.message,'Reviewed burden export needs attention');end
    end
end
function lines=formatPlan(p)
c=p.Counts;
lines={sprintf('REVIEWED BURDEN-ONLY PREVIEW | %d recordings | %d automatic detections',c.Recordings,c.AutomaticDetections); ...
    sprintf('%d excluded | %d retained | %d saved recognition decisions | %d imported event results',c.RejectedDetections,c.RetainedDetections,c.SavedRecognitionDecisions,c.ReviewedEventValues); ...
    sprintf('%d available / %d missing retained contributions; %d / %d complete normalized recording burdens.',c.AvailableContributions,c.MissingContributions,c.AvailableNormalizedRecordings,c.Recordings); ...
    'Unreviewed/uncertain detections retain automatic ingredients. This is not a fully adjudicated set.'; ...
    'Existing formula, normalization and automatic reference policy are preserved; only explicitly selected saved decisions/measurements apply.'; ...
    'Missing required retained contributions withhold complete burden. No partial sums.'; ...
    ['Automatic source: ' p.StatsMAT];['Source SHA-256: ' p.SourceSHA256];['NEW destination: ' p.OutputFolder];'';'SELECTED SAVED REVISIONS'};
for k=1:numel(p.ReviewSources)
    x=p.ReviewSources(k);lines{end+1,1}=sprintf('%s | SHA-256 %s',x.Path,x.SHA256); %#ok<AGROW>
end
lines{end+1,1}='APPLIED RECOGNITION DECISIONS';
for k=1:height(p.Decisions)
    d=p.Decisions(k,:);lines{end+1,1}=sprintf('%s | site %g / event %g | %s | reviewer: %s | reason: %s', ...
        d.RecordingID,d.SinkID,d.EventIndex,d.RecognitionStatus,d.Reviewer,d.Reason); %#ok<AGROW>
end
lines{end+1,1}='SELECTED SINGLE-EVENT RESULTS';
for k=1:numel(p.EventSources)
    x=p.EventSources(k);m=x.Measurement;
    lines{end+1,1}=sprintf('%s | site %g / event %g | frames %g-%g | reference %g-%g (%g samples) | amplitude %.9g%% | area %.9g um^2 | contribution %.9g', ...
        m.RecordingID,m.SiteID,m.EventID,m.StartFrame,m.EndFrame,m.ReferenceStartFrame,m.ReferenceEndFrame,m.ReferenceSamples,m.BurdenAmplitudePercent,m.BurdenArea_um2,m.PerEventBurdenContribution); %#ok<AGROW>
    lines{end+1,1}=sprintf('%s | manifest SHA-256 %s | %s',x.Path,x.ManifestSHA256,m.AreaQualification); %#ok<AGROW>
end
if isempty(p.EventSources),lines{end+1,1}='None. Boundary judgments alone do not replace amplitude, duration or area.';end
lines{end+1,1}='RECORDING AVAILABILITY';
for k=1:height(p.Summary)
    q=p.Summary(k,:);lines{end+1,1}=sprintf('%s | %d retained | %d missing contributions',q.RecordingID,q.RetainedDetections,q.MissingContributions); %#ok<AGROW>
end
end
function value=enabled(value)
if value
    value='on';
else
    value='off';
end
end
function at(h,row,column),h.Layout.Row=row;h.Layout.Column=column;end

function paths=list(paths)
if ischar(paths),paths={paths};else,paths=cellstr(string(paths(:)));end
end
