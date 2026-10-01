function P=createBOIBoundaryPanel(Parent,ViewTiming,SaveNew,LoadSaved)
%CREATEBOIBOUNDARYPANEL Explicit human judgments with per-event session drafts.
Grid=uigridlayout(Parent,[9 1]);Grid.RowHeight={40,55,35,130,35,105,36,55,'1x'};
Identity=uilabel(Grid,'Text','Select an event.','Interpreter','none','WordWrap','on');
uilabel(Grid,'Text',['Use the corrected intensity trace as the primary reference. Detection scores support interpretation; raw intensity checks correction. ' ...
    'Entries are one-based recording FRAMES: at 1 Hz frame 1154 is modeled time 1153 s. No snapping or new baseline fit.'], 'WordWrap','on');
controls=uigridlayout(Grid,[1 4]);controls.Padding=[0 0 0 0];controls.ColumnWidth={160,220,130,'1x'};
uilabel(controls,'Text','Recognition judgment');
Status=uidropdown(controls,'Items',{'Recognized','Uncertain','Not recognized'},'ItemsData',{'recognized','uncertain','not_recognized'},'Value','uncertain','ValueChangedFcn',@changed);
uilabel(controls,'Text','Reviewer / actor');Reviewer=uieditfield(controls,'text','ValueChangedFcn',@changed);
fields=uigridlayout(Grid,[3 3]);fields.Padding=[0 0 0 0];fields.ColumnWidth={210,'1x','1x'};
uilabel(fields,'Text','Endpoint');uilabel(fields,'Text','Discrete alternatives (comma separated frames)');uilabel(fields,'Text','Preferred frame (optional; must be listed)');
uilabel(fields,'Text','Onset');Onset=uieditfield(fields,'text','ValueChangedFcn',@changed);PreferredOnset=uieditfield(fields,'text','ValueChangedFcn',@changed);
uilabel(fields,'Text','Recovery / offset');Recovery=uieditfield(fields,'text','ValueChangedFcn',@changed);PreferredRecovery=uieditfield(fields,'text','ValueChangedFcn',@changed);
uilabel(Grid,'Text','Leave unresolved endpoints blank. “Not recognized” requires blank current endpoints; earlier marks stay in history.','WordWrap','on');
Reason=uitextarea(Grid,'Value',{''},'ValueChangedFcn',@changed,'Tooltip','Required: evidence, uncertainty and reason for this revision.');
actions=uigridlayout(Grid,[1 4]);actions.Padding=[0 0 0 0];actions.ColumnWidth={180,190,180,'1x'};
View=uibutton(actions,'Text','View timing traces','ButtonPushedFcn',@(~,~)ViewTiming());
Save=uibutton(actions,'Text','Save new revision...','ButtonPushedFcn',@(~,~)SaveNew());
Load=uibutton(actions,'Text','Load saved review...','ButtonPushedFcn',@(~,~)LoadSaved());
uilabel(actions,'Text','Reason / uncertainty above is required.','WordWrap','on');
Message=uilabel(Grid,'Text','No researcher review saved. Drafts are session-only until you save a NEW file.','WordWrap','on','Interpreter','none');
History=uitextarea(Grid,'Editable','off','Value',{'Revision history appears here. Saved manual marks are purple on the timing traces.'});
CurrentIndex=[];Drafts={};Dirty=false;CurrentReview=[];
P=struct('Update',@update,'ReadDraft',@readDraft,'SetDraft',@setDraft,'Saved',@saved,'HasDrafts',@hasDrafts, ...
    'Identity',Identity,'Status',Status,'Reviewer',Reviewer,'Onset',Onset,'Recovery',Recovery, ...
    'PreferredOnset',PreferredOnset,'PreferredRecovery',PreferredRecovery,'Reason',Reason, ...
    'Message',Message,'History',History,'View',View,'Save',Save,'Load',Load,'Grid',Grid);
    function update(Review,Index)
        cacheDraft();CurrentReview=Review;CurrentIndex=Index;Dirty=false;
        row=Review.Audit(Index,:);B=getBOIBoundaryReview(Review,Index);
        Identity.Text=sprintf('%s | saved %s site %d / event %d | researcher judgments do not change saved measurements',row.RecordingID,row.EventType,row.SiteID,row.EventID);
        if numel(Drafts)>=Index&&~isempty(Drafts{Index})
            fill(Drafts{Index});Dirty=true;Message.Text='UNSAVED draft restored for this event. Timing overlays and exports still use the last saved judgment.';
        elseif ~isempty(B.Annotation)
            a=B.Annotation;fill(struct('Status',a.Status,'Reviewer',a.Reviewer,'Reason',a.Reason, ...
                'Onset',numbers(a.OnsetFrames),'Recovery',numbers(a.RecoveryFrames), ...
                'PreferredOnset',numbers(a.PreferredOnsetFrame),'PreferredRecovery',numbers(a.PreferredRecoveryFrame)));
            Message.Text=['Saved revision loaded: ' B.ArtifactPath];
        else
            fill(struct('Status','uncertain','Reviewer',Reviewer.Value,'Reason','','Onset','','Recovery','','PreferredOnset','','PreferredRecovery',''));
            Message.Text='This event has no saved judgment. Blank endpoints are unresolved, never automatic or zero.';
        end
        if isempty(B.History),History.Value={'No saved revisions for this event.'};
        else
            lines=strings(0,1);
            for k=1:numel(B.History)
                r=B.History(k);a=r.Annotation;
                lines(end+1)=sprintf('Revision %d | %s | %s | %s',r.Revision,r.CreatedUTC,a.Reviewer,a.Status);
                lines(end+1)=sprintf('Onset [%s], preferred [%s]; recovery [%s], preferred [%s]',numbers(a.OnsetFrames),numbers(a.PreferredOnsetFrame),numbers(a.RecoveryFrames),numbers(a.PreferredRecoveryFrame));
                lines(end+1)="Reason: "+string(a.Reason);lines(end+1)="";
            end
            History.Value=cellstr(lines);
        end
    end
    function changed(~,~)
        Dirty=true;Message.Text='UNSAVED draft. Switching events retains it in this session; save a NEW revision file to persist it. Exports use saved judgments only.';
    end
    function d=rawDraft()
        d=struct('Status',Status.Value,'Reviewer',Reviewer.Value,'Reason',char(strjoin(string(Reason.Value),newline)), ...
            'Onset',Onset.Value,'Recovery',Recovery.Value,'PreferredOnset',PreferredOnset.Value,'PreferredRecovery',PreferredRecovery.Value);
    end
    function cacheDraft()
        if ~isempty(CurrentIndex)&&Dirty,Drafts{CurrentIndex}=rawDraft();end
    end
    function fill(d)
        Status.Value=d.Status;Reviewer.Value=d.Reviewer;Reason.Value=cellstr(splitlines(string(d.Reason)));
        Onset.Value=d.Onset;Recovery.Value=d.Recovery;PreferredOnset.Value=d.PreferredOnset;PreferredRecovery.Value=d.PreferredRecovery;
    end
    function a=readDraft()
        d=rawDraft();a=struct('Status',d.Status,'OnsetFrames',parse(d.Onset),'RecoveryFrames',parse(d.Recovery), ...
            'PreferredOnsetFrame',parse(d.PreferredOnset),'PreferredRecoveryFrame',parse(d.PreferredRecovery),'Reviewer',d.Reviewer,'Reason',d.Reason);
        a=validateBOIBoundaryAnnotation(CurrentReview,CurrentIndex,a);
    end
    function setDraft(a)
        a=validateBOIBoundaryAnnotation(CurrentReview,CurrentIndex,a);
        fill(struct('Status',a.Status,'Reviewer',a.Reviewer,'Reason',a.Reason,'Onset',numbers(a.OnsetFrames), ...
            'Recovery',numbers(a.RecoveryFrames),'PreferredOnset',numbers(a.PreferredOnsetFrame),'PreferredRecovery',numbers(a.PreferredRecoveryFrame)));
        changed([],[]);
    end
    function saved()
        Dirty=false;if numel(Drafts)>=CurrentIndex,Drafts{CurrentIndex}=[];end
    end
    function yes=hasDrafts()
        yes=Dirty||any(~cellfun(@isempty,Drafts));
    end
end
function s=numbers(v)
s=char(strjoin(string(v),', '));
end
function v=parse(s)
s=strtrim(s);if isempty(s),v=[];return;end
assert(~isempty(regexp(s,'^\d+(\s*,\s*\d+)*$','once')),'OxygenDynamics:InvalidBoundaryReview','Enter integer frames separated by commas, or leave blank.');
v=str2double(strsplit(s,','));
end
