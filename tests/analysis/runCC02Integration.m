function Results=runCC02Integration(Root,CaseNumbers,Batch,Packet)
%RUNCC02INTEGRATION Finite saved-data-only CC-02 matrix; never an engine test.
cd(fullfile(Root,'existing-analysis'));setupOxygenDynamicsPath;
if nargin<4,Packet=fullfile(Root,'reference-validation','cc-02-completion-extension-20260930');end
if nargin<2,CaseNumbers=1:14;end
if nargin<3,Batch=1;end
CaseNumbers=CaseNumbers(:)';
budgetPath=fullfile(Packet,'budget.json');b=jsondecode(fileread(budgetPath));
assert(isnumeric(CaseNumbers)&&all(ismember(CaseNumbers,1:14))&&numel(unique(CaseNumbers))==numel(CaseNumbers),'CC02:Dispatch','Expected unique named numeric case IDs.');
assert(b.case_evaluations+numel(CaseNumbers)<=b.case_evaluation_limit,'CC02:Budget','Evaluation budget exhausted.');
assert(seconds(datetime('now','TimeZone','UTC')-datetime(b.started_utc,'InputFormat','yyyy-MM-dd''T''HH:mm:ss.SSSSSSXXX','TimeZone','UTC'))<b.maximum_active_seconds,'CC02:Budget','Time budget exhausted.');
b.validation_batches=b.validation_batches+1;write(budgetPath,b);
config=jsondecode(fileread(fullfile(Packet,'cases.json')));
sourcePins=jsondecode(fileread(fullfile(Packet,'source-pins.json')));verifyPins(sourcePins);
codePins=jsondecode(fileread(fullfile(Packet,sprintf('batch-%02d-code-pins.json',Batch))));verifyPins(codePins);
fixturePins=struct('Path',{},'SHA256',{});
for k=[5 10 11]
    path=fullfile(Packet,'fixtures',sprintf('T%02d.mat',k));fixturePins(end+1)=struct('Path',path,'SHA256',oxygenFileSHA256(path)); %#ok<AGROW>
end
write(fullfile(Packet,sprintf('batch-%02d-fixture-pins.json',Batch)),fixturePins);
verifyPins(fixturePins);
Results=struct('Case',{},'Status',{},'ErrorID',{},'Message',{},'Seconds',{},'Evidence',{});
for k=CaseNumbers
    if ismember(k,[6 7 8 9 12 13 14]),validatePrerequisite();end
    b=jsondecode(fileread(budgetPath));assert(b.case_evaluations<b.case_evaluation_limit,'CC02:Budget','Evaluation budget exhausted.');
    b.case_evaluations=b.case_evaluations+1;write(budgetPath,b);started=tic;
    result=struct('Case',sprintf('T%02d',k),'Status','running','ErrorID','','Message','','Seconds',0,'Evidence',[]);
    write(fullfile(Packet,sprintf('batch-%02d-T%02d.json',Batch,k)),result);
    try
        result.Evidence=evaluate(k);result.Status='pass';
    catch err
        result.Status='fail';result.ErrorID=err.identifier;result.Message=getReport(err,'extended','hyperlinks','off');
    end
    result.Seconds=toc(started);Results(end+1)=result; %#ok<AGROW>
    write(fullfile(Packet,sprintf('batch-%02d-T%02d.json',Batch,k)),result);
    if k==1&&strcmp(result.Status,'pass')
        prerequisite=struct('CodeManifestSHA256',oxygenFileSHA256(fullfile(Packet,sprintf('batch-%02d-code-pins.json',Batch))), ...
            'CaseReceipt',fullfile(Packet,sprintf('batch-%02d-T01.json',Batch)),'CaseReceiptSHA256',oxygenFileSHA256(fullfile(Packet,sprintf('batch-%02d-T01.json',Batch))), ...
            'Saved',result.Evidence.Saved,'SavedManifestSHA256',oxygenFileSHA256(fullfile(result.Evidence.Saved,'Manifest.json')), ...
            'Export',result.Evidence.Export,'ExportManifestSHA256',oxygenFileSHA256(fullfile(result.Evidence.Export,'Manifest.json')));
        write(fullfile(Packet,'prerequisite.json'),prerequisite);
    end
    fprintf('%s %s [%s] %.2fs\n',result.Case,result.Status,result.ErrorID,result.Seconds);
    % Primary identity/provenance failures are material, never repaired by substitution.
    if strcmp(result.Status,'fail')
        fprintf('STOP: remaining cases untested.\n');break;
    end
end
verifyPins(codePins);verifyPins(sourcePins);verifyPins(fixturePins);
write(fullfile(Packet,sprintf('batch-%02d-results.json',Batch)),Results);
write(fullfile(Packet,sprintf('batch-%02d-post-hash-gate.json',Batch)),struct('Code','pass','Sources','pass','Fixtures','pass','CheckedUTC',char(datetime('now','TimeZone','UTC'))));
    function prerequisite=validatePrerequisite()
        path=fullfile(Packet,'prerequisite.json');
        assert(isfile(path),'CC02:Prerequisite','T01 must pass on this pinned code before dependent checks.');
        prerequisite=jsondecode(fileread(path));
        assert(strcmp(prerequisite.CodeManifestSHA256,oxygenFileSHA256(fullfile(Packet,sprintf('batch-%02d-code-pins.json',Batch))))&& ...
            strcmp(prerequisite.CaseReceiptSHA256,oxygenFileSHA256(prerequisite.CaseReceipt))&& ...
            strcmp(prerequisite.SavedManifestSHA256,oxygenFileSHA256(fullfile(prerequisite.Saved,'Manifest.json')))&& ...
            strcmp(prerequisite.ExportManifestSHA256,oxygenFileSHA256(fullfile(prerequisite.Export,'Manifest.json'))), ...
            'CC02:Prerequisite','Prerequisite artifacts or code differ. Rerun T01 before dependent checks.');
        receipt=jsondecode(fileread(prerequisite.CaseReceipt));assert(strcmp(receipt.Status,'pass'),'CC02:Prerequisite','T01 prerequisite did not pass.');
    end
    function evidence=evaluate(k)
        evidence=struct();target=fullfile(Packet,sprintf('batch-%02d-T%02d',Batch,k));
        if k<=3
            c=config(k);r=loadBOIEventReview(c.Audit,c.Metadata);i=c.Row;
            original=r.Audit;j=createBOIPocketJudgment(r,i,c.Onset,c.End,c.Reference,c.Suitability,c.Endpoint, ...
                'CC-02 saved-fixture researcher judgment','Approved exact CC-01 pair; scientific qualifications retained','external_trigger_1Hz');
            [fig,ui]=openBOIEventReview(c.Audit,[],true,c.Metadata);cleanup=onCleanup(@()delete(fig));
            ui.Select(i);assert(isempty(ui.Pocket.Current())&&~ui.Pocket.HasDrafts(),'CC02:Selection','Selection inferred a pocket judgment.');
            ui.Pocket.SetDraft(j);e=ui.PreviewPocket();
            assertNear(e.Measures.CorrectedSignedTroughPercent,c.ExpectedCorrected);assertNear(e.Measures.RawSignedTroughPercent,c.ExpectedRaw);
            assert(isequal(e.Measures.CorrectedMinimumFrames,c.Minimum)&&isequal(e.Measures.RawMinimumFrames,c.Minimum),'CC02:Minima','Minima differ.');
            assert(numel(e.FixedFootprint)==c.Pixels&&isequal(e.ReferenceFrames,c.Reference(:))&&isequal(e.EventFrames,(c.Onset:c.End)'),'CC02:Frames','Frames or footprint differ.');
            assertNear(100*(min(e.Ingredients.Corrected(e.EventFrames))-sum(e.Ingredients.Corrected(e.ReferenceFrames))/numel(e.ReferenceFrames))/(sum(e.Ingredients.Raw(e.ReferenceFrames))/numel(e.ReferenceFrames)),c.ExpectedCorrected);
            assertNear(100*(min(e.Ingredients.Raw(e.EventFrames))/(sum(e.Ingredients.Raw(e.ReferenceFrames))/numel(e.ReferenceFrames))-1),c.ExpectedRaw);
            store=ui.SavePocket([target '-saved']);assert(isequaln(ui.CurrentReview().Audit,original),'CC02:Automatic','Automatic audit changed.');
            assert(~ui.Pocket.HasDrafts()&&isempty(ui.Pocket.Current()),'CC02:State','Saved state remains a draft.');
            ui.LoadPocket(store.Path);assert(isequaln(store.Document,ui.CurrentReview().PocketEvidence{i}.Document),'CC02:Reopen','Reopened evidence differs.');
            % An unsaved edit must not leak into either export path.
            altered=j;altered.Reason='UNSAVED export exclusion probe';ui.Pocket.SetDraft(altered);assert(ui.Pocket.HasDrafts());
            out=ui.ExportPocket([target '-export']);assert(isequaln(out.Document,store.Document),'CC02:Export','Draft leaked into export.');
            receipt=ui.ExportSelected([target '-event-export']);embedded=loadBOIReviewedPocketEvidence(fullfile([target '-event-export'],'ReviewedPocket'));
            assert(isequaln(embedded.Document,store.Document)&&isfield(receipt,'ReviewedPocket'),'CC02:Integration','Selected-evidence export lost reviewed pocket.');
            saved=load(fullfile([target '-event-export'],'SelectedEventReview.mat'),'Data');assert(isequaln(saved.Data.Row,original(i,:)),'CC02:Automatic','Export altered automatic row.');
            ui.LoadPocket(store.Path);assert(~ui.Pocket.HasDrafts());
            [portable,pu]=openBOIReviewedPocketEvidence(out.Path);pc=onCleanup(@()delete(portable));
            assert(~pu.Store.ReplayedOnOpen&&isequaln(pu.Store.Document,store.Document),'CC02:Portable','Portable open replayed or changed evidence.');
            verifyBOIReviewedPocketArithmetic(pu.Store.Document);
            text=strjoin(string(ui.Pocket.Details.Value),newline);assert(contains(text,c.Suitability)&&contains(text,c.Endpoint),'CC02:Flags','UI flags missing.');
            if k>1,assert(contains(text,'saved surge footprint'),'CC02:Footprint','Surge footprint qualification missing.');end
            if k==2,assert(isnan(e.ConfirmedPocketDurationSec)&&e.Judgment.ObservedEndFrame==417);end
            if k==3,assert(strcmp(e.Measures.PrimaryStatus,'conditional_exploratory')&&isnan(e.OriginalAutomatic.StoredAmplitude)&&e.Measures.ReferenceSampleCount==6);end
            displayed=findobj(ui.Pocket.Axes,'Type','line','Tag','BOIPocketCorrected');
            assert(isscalar(displayed)&&~isempty(displayed.YData)&&all(isfinite(displayed.YData)),'CC02:VisibleTrace','Corrected review curve is absent.');
            shownFrames=displayed.XData(:);assert(isequal(displayed.YData(:),e.Ingredients.Corrected(shownFrames)),'CC02:VisibleTrace','Review curve differs from saved corrected samples.');
            portableCurve=findobj(pu.Axes,'Type','line','Tag','BOIPocketCorrected');
            assert(isscalar(portableCurve)&&isequal(portableCurve.YData(:),e.Ingredients.Corrected),'CC02:VisibleTrace','Portable corrected curve differs.');
            drawnow;exportapp(fig,[target '-review.png']);exportapp(portable,[target '-portable.png']);
            write([target '-measures.json'],e.Measures);
            evidence=struct('Saved',store.Path,'Export',out.Path,'SelectedEventExport',[target '-event-export'], ...
                'CorrectedPercent',e.Measures.CorrectedSignedTroughPercent,'RawPercent',e.Measures.RawSignedTroughPercent, ...
                'Replay','pass','AutomaticUnchanged',true,'DraftExcluded',true,'ReplayedOnOpen',false,'Flags',c.Suitability,'Journey',{{'select','explicit draft','preview','save','reopen','draft exclusion','pocket export','selected-event export','portable reopen','explicit arithmetic replay'}}, ...
                'Endpoint',c.Endpoint,'FootprintQualification',e.FootprintQualification,'MinimumFrames',e.Measures.CorrectedMinimumFrames, ...
                'AuditSHA256',e.AuditSHA256,'ReferenceFrames',e.ReferenceFrames,'EventFrames',e.EventFrames);
        elseif k==4
            [fig,ui]=openBOIRecordingWorkflow;cleanup=onCleanup(@()delete(fig));
            ui.OpenRun(fullfile(Root,'reference-validation','software-g2-workflow-20260923','gui-run'));
            [eventFig,eventUI]=ui.OpenEvents();ec=onCleanup(@()delete(eventFig));
            eventUI.Select(1);assert(isempty(eventUI.Pocket.Current())&&~eventUI.Pocket.HasDrafts());
            r=eventUI.CurrentReview();assert(~isfield(r,'PocketEvidence'));s=buildBOIReviewedOpticalPreview(r,1);
            assert(strcmp(s.Definition.ID,'boi-reviewed-optical-0.1.0-draft'));
            bundle=loadBOIG4EvidenceBundle(fullfile(Root,'reference-validation','software-g4-evidence-20260927','saved-bundle-final'));
            assert(strcmp(bundle.ReviewedEvent.ReviewedAmplitudeStatus,'not_calculated'));getBOIReviewedOpticalDefinition;
            evidence=struct('G2Reopen','pass','LegacyDefinition',s.Definition.ID,'G4ReviewedAmplitude','not_calculated','NewPocketInferred',false);
        elseif ismember(k,[5 10 11])
            r=loadBOIEventReview(fullfile(Packet,'fixtures',sprintf('T%02d.mat',k)));j=judgment(r,1,'accepted_local_state',73:81);
            e=buildBOIReviewedPocketEvidence(r,1,j);store=saveBOIReviewedPocketEvidence(e,target);verifyBOIReviewedPocketArithmetic(store.Document);
            if k==5,assert(strcmp(e.Measures.PrimaryStatus,'unavailable_missing_saved_correction')&&isfinite(e.Measures.RawSignedTroughPercent));
            elseif k==10,assert(strcmp(e.Measures.ArithmeticStatus,'unavailable_nonfinite_reference')&&isnan(e.Measures.RawSignedTroughPercent));
            else,assert(strcmp(e.Measures.ArithmeticStatus,'unavailable_nonpositive_reference_mean')&&isnan(e.Measures.CorrectedSignedTroughPercent)&&isnan(e.Measures.RawSignedTroughPercent));end
            evidence=e.Measures;
        else
            r=loadBOIEventReview(config(1).Audit,config(1).Metadata);i=config(1).Row;j=judgment(r,i,'accepted_local_state',73:81);
            prerequisite=validatePrerequisite();store=loadBOIReviewedPocketEvidence(prerequisite.Saved);e=store.Document;
            if k==6
                e.Correction.RawSourceSHA256=repmat('0',1,64);expect(@()saveBOIReviewedPocketEvidence(e,target),'OxygenDynamics:PocketIdentityMismatch');assert(~isfolder(target));
            elseif k==7
                e.FixedFootprint(1)=e.FixedFootprint(1)+1;expect(@()saveBOIReviewedPocketEvidence(e,target),'OxygenDynamics:PocketIdentityMismatch');assert(~isfolder(target));
            elseif k==8
                e.Judgment.BoundaryRevision.Revision=e.Judgment.Revision+1;e.JudgmentSHA256=boiPocketDigest(e.Judgment);
                expect(@()saveBOIReviewedPocketEvidence(e,target),'OxygenDynamics:PocketRevisionMismatch');assert(~isfolder(target));
            elseif k==9
                j=judgment(r,i,'accepted_local_state',[73:81 82]);expect(@()buildBOIReviewedPocketEvidence(r,i,j),'OxygenDynamics:InvalidPocketFrames');assert(~isfolder(target));
            elseif k==12
                previousHash=oxygenFileSHA256(fullfile(store.Path,'Manifest.json'));
                j=createBOIPocketJudgment(r,i,82,98,73:81,'unsuitable','recovery_observed','CC02 fixture','Reference judged unsuitable','external_trigger_1Hz',store.Document);
                new=buildBOIReviewedPocketEvidence(r,i,j);ns=saveBOIReviewedPocketEvidence(new,target);
                assert(new.Judgment.Revision==2&&strcmp(new.Measures.ArithmeticStatus,'unavailable_reference_unsuitable')&&isnan(new.Measures.CorrectedSignedTroughPercent));
                assert(strcmp(previousHash,oxygenFileSHA256(fullfile(store.Path,'Manifest.json')))&&isequaln(ns.Document.OriginalAutomatic,e.OriginalAutomatic));
            elseif k==13
                j=judgment(r,i,'accepted_local_state',[]);new=buildBOIReviewedPocketEvidence(r,i,j);saveBOIReviewedPocketEvidence(new,target);
                assert(strcmp(new.Measures.ArithmeticStatus,'unavailable_empty_reference')&&isempty(new.ReferenceFrames));
            elseif k==14
                copyfile(prerequisite.Export,target);
                p=fullfile(target,'ReviewedPocket.mat');s=load(p,'E');s.E.Schema='boi-reviewed-pocket-evidence-999';E=s.E;save(p,'E'); %#ok<NASGU>
                mp=fullfile(target,'Manifest.json');m=jsondecode(fileread(mp));q=find(strcmp({m.Files.Name},'ReviewedPocket.mat'));m.Files(q).SHA256=oxygenFileSHA256(p);m.EvidenceSHA256=boiPocketDigest(E);write(mp,m);
                expect(@()loadBOIReviewedPocketEvidence(target),'OxygenDynamics:UnsupportedPocketSchema');
            end
            evidence=struct('ExpectedOutcome','pass','OriginalArtifactUnchanged',true);
        end
    end
end
function j=judgment(r,i,s,frames)
j=createBOIPocketJudgment(r,i,82,98,frames,s,'recovery_observed','CC02 fixture','Named saved-vector guard fixture','external_trigger_1Hz');
end
function expect(f,id)
try,f();catch err,assert(strcmp(err.identifier,id),'CC02:UnexpectedError','Expected %s, received %s: %s',id,err.identifier,err.message);return;end
error('CC02:MissingRejection','Expected rejection %s.',id);
end
function assertNear(a,b)
assert(isfinite(a)&&abs(a-b)<=1e-10*max(1,abs(b)),'CC02:Numeric','Expected %.17g; got %.17g.',b,a);
end
function verifyPins(entries)
for k=1:numel(entries),assert(strcmp(oxygenFileSHA256(entries(k).Path),entries(k).SHA256),'CC02:SourceChanged','Pinned file changed: %s',entries(k).Path);end
end
function write(p,s)
f=fopen(p,'w');assert(f>=0);c=onCleanup(@()fclose(f));fprintf(f,'%s\n',jsonencode(s,'PrettyPrint',true));
end
