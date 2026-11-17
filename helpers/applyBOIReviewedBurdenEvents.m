function B=applyBOIReviewedBurdenEvents(B,Registry,Events)
% Import already approved event values; keep automatic columns as evidence.
id='OxygenDynamics:ReviewedBurdenEvent';E=B.EventTable;input=E;
selection=[];if isfield(B,'SelectionPolicy'),selection=B.SelectionPolicy;end
selection=boiBurdenSelectionPolicy(E,selection);
% Internal calculation inputs use the already selected automatic burden
% amplitudes, so manual rows cannot fall back to an old episode reference.
episode=E.Properties.VariableNames(startsWith(E.Properties.VariableNames,'Episode'));
% Prevent the new automatic selector from overriding an approved manual value.
episode=[episode intersect({'EventReferenceVersion'},E.Properties.VariableNames)];
if ~isempty(episode),input=removevars(input,episode);end
input.NormOxySinkAmpPercent=E.BurdenAmplitudePercent;
input.AmplitudeSignConvention=repmat("positive_drop_percent",height(E),1);
[keys,~]=oxygenEventJoinKeys(E,E);applied=false(height(E),1);paths=strings(height(E),1);hashes=paths;
eventIds=E.EventID;if ismember('EventIndex',E.Properties.VariableNames),eventIds=E.EventIndex;end
refStart=nan(height(E),1);refEnd=refStart;refCount=refStart;revisionRows=cell(0,1);
areas=E.BurdenArea_um2;areaStates=strings(height(E),1);areaFrames=nan(height(E),1);hasAreaRevision=false;
for k=1:numel(Events)
    V=Events{k};S=V.Document;
    artifact=table();
    if isfield(S,'BurdenSelectionPolicyVersion')
        artifact=table(string(S.BurdenSelectionPolicyVersion),'VariableNames',{'BurdenSelectionPolicyVersion'});
    end
    artifactPolicy=boiBurdenSelectionPolicy(artifact);
    assert(strcmp(selection.Version,artifactPolicy.Version)|| ...
        (selection.IncludeFiniteNegative&&~artifactPolicy.IncludeFiniteNegative&&isfinite(S.BurdenAmplitudePercent)&&S.BurdenAmplitudePercent>=0), ...
        'OxygenDynamics:BurdenSelectionPolicy','Reviewed event and automatic selection policies are incompatible.');
    K=table(string(S.RecordingID),S.SiteID,S.EventID,'VariableNames',{'RecordingID','SinkID','EventIndex'});
    [~,key]=oxygenEventJoinKeys(E,K);j=find(keys==key);assert(isscalar(j)&&~applied(j),id,'Missing, rejected or duplicate reviewed event.');
    D=B.ReviewDecisions;di=find(string(D.RecordingID)==string(S.RecordingID)&D.SinkID==S.SiteID&D.EventIndex==S.EventID);
    assert(isscalar(di)&&D.RecognitionStatus(di)=="recognized"&&~D.ExcludedFromReviewedBurden(di)&& ...
        string(D.ReviewSHA256(di))==string(S.BoundarySHA256),id,'Choose the matching saved recognition/boundary revision.');
    reviewedArea=isfield(S,'Schema')&&strcmp(S.Schema,'boi-reviewed-single-event-burden-2');
    originalArea=S.BurdenArea_um2;
    if reviewedArea,originalArea=S.OriginalAutomaticArea_um2;end
    ri=find(string(Registry.RecordingID)==string(S.RecordingID));
    assert(isscalar(ri)&&string(Registry.RawSHA256(ri))==string(S.RawSourceSHA256)&& ...
        E.StartFrame(j)==S.OriginalAutomaticStartFrame&&E.EndFrame(j)==S.OriginalAutomaticEndFrame&& ...
        sameSavedNumber(E.BurdenArea_um2(j),originalArea)&&sameSavedNumber(E.BurdenRecordingArea_um2(j),S.BurdenRecordingArea_um2)&& ...
        E.BurdenRecordingDuration_sec(j)==S.BurdenRecordingDuration_sec&&E.SampleF(j)==S.SampleHz,id,'Event area, clock, exposure or automatic identity differs.');
    input.StartFrame(j)=S.StartFrame;input.EndFrame(j)=S.EndFrame;input.DurationSec(j)=S.DurationSec;
    input.NormOxySinkAmpPercent(j)=S.BurdenAmplitudePercent;applied(j)=true;paths(j)=string(V.Path);hashes(j)=string(V.ManifestSHA256);
    if reviewedArea
        hasAreaRevision=true;areas(j)=S.BurdenArea_um2;areaStates(j)=string(S.AreaStatus);areaFrames(j)=S.AreaMeanFrameCount;
    end
    refStart(j)=S.ReferenceStartFrame;refEnd(j)=S.ReferenceEndFrame;refCount(j)=S.ReferenceSamples;
    row=table(string(S.RecordingID),S.SiteID,S.EventID,S.StartFrame,S.EndFrame,S.DurationSec,S.ReferenceStartFrame,S.ReferenceEndFrame, ...
        S.ReferenceSamples,S.BurdenAmplitudePercent,S.PerEventBurdenContribution,S.PerEventBurdenContribution_per_mm2_per_min, ...
        string(V.Path),string(V.ManifestSHA256),string(S.BoundarySHA256),string(S.ReferenceSHA256),logical(S.AreaRemeasured), ...
        string(S.AreaQualification),'VariableNames',{'RecordingID','SinkID','EventIndex','BurdenStartFrame','BurdenEndFrame','BurdenDurationSec', ...
        'ReferenceStartFrame','ReferenceEndFrame','ReferenceSamples','RawDropPercent','EventContribution','NormalizedEventContribution', ...
        'EventArtifact','ManifestSHA256','BoundarySHA256','ReferenceSHA256','AreaRemeasured','AreaQualification'});
    revisionRows{end+1}=row; %#ok<AGROW>
end
specific=E(:,intersect({'RecordingID','SinkID','EventIndex','EventID'},E.Properties.VariableNames,'stable'));specific.Area_um=areas;
% All retained events and full recording exposures enter the shared calculator.
% Missing required contributions still withhold every complete recording sum.
N=createHypoxicBurdenMetrics(input,specific,table(),Registry,selection);
numeric={'BurdenAmplitudePercent','BurdenDuration_sec','PerEventBurdenContribution','PerEventBurdenContribution_per_mm2', ...
    'PerEventBurdenContribution_per_sec','PerEventBurdenContribution_per_min','PerEventBurdenContribution_per_mm2_per_sec', ...
    'PerEventBurdenContribution_per_mm2_per_min','BurdenRankAmplitudeQuantile','PerEventBurdenOccupancy_per_mm2_per_min', ...
    'PerEventBurdenRankAmplitude_per_mm2_per_min','PerEventBurdenAmplitudeComposite'};
for f={'BurdenAmplitudePercent','BurdenDuration_sec','PerEventBurdenContribution','PerEventBurdenContribution_per_mm2_per_min'}
    assert(isequaln(E.(f{1})(~applied),N.EventTable.(f{1})(~applied)),id,'Unchanged event ingredients changed.');
end
for k=1:numel(Events)
    S=Events{k}.Document;j=find(string(E.RecordingID)==string(S.RecordingID)&E.SinkID==S.SiteID&eventIds==S.EventID);
    assert(sameResult(N.EventTable.PerEventBurdenContribution(j),S.PerEventBurdenContribution)&& ...
        sameResult(N.EventTable.PerEventBurdenContribution_per_mm2_per_min(j),S.PerEventBurdenContribution_per_mm2_per_min), ...
        id,'Imported contribution differs from the approved event.');
end
for f=numeric,E.(f{1})=N.EventTable.(f{1});end
if hasAreaRevision
    E.AutomaticBurdenArea_um2=E.BurdenArea_um2;E.BurdenArea_um2=N.EventTable.BurdenArea_um2;
    E.ReviewedAreaStatus=areaStates;E.ReviewedAreaMeanFrames=areaFrames;
    E.BurdenAreaSource(areaStates~="")={'saved complete-interval reviewed area revision; missing area is withheld'};
end
E.BurdenAmplitudeSource(applied)={'saved approved reviewed event reference'};
E.BurdenDurationSource(applied)={'saved approved reviewed onset/recovery'};
E.BurdenStartFrame=input.StartFrame;E.BurdenEndFrame=input.EndFrame;
E.ReviewedBurdenValuesApplied=applied;E.ReviewedBurdenArtifact=paths;E.ReviewedBurdenManifestSHA256=hashes;
E.ReviewedReferenceStartFrame=refStart;E.ReviewedReferenceEndFrame=refEnd;E.ReviewedReferenceSamples=refCount;
B.EventTable=E;B.RecordingTable=appendBOIEpisodeReferenceSummary(N.RecordingTable,E);
B.RecordingTable=appendBOIEventReferenceSummary(B.RecordingTable,E);
B.GroupSummaryTable=summarizeOxygenMouseMetrics(B.RecordingTable);B.TimeSeriesTable=N.TimeSeriesTable;B.TimeSeriesBasis=N.TimeSeriesBasis;
B.EventRevisions=vertcat(revisionRows{:});
B.ReviewSummary.ReviewedEventValues=zeros(height(Registry),1);
for i=1:height(Registry)
    m=string(E.RecordingID)==string(Registry.RecordingID(i));
    B.ReviewSummary.AvailableContributions(i)=sum(m&isfinite(E.PerEventBurdenContribution));
    B.ReviewSummary.MissingContributions(i)=sum(m&~isfinite(E.PerEventBurdenContribution));
    B.ReviewSummary.ReviewedEventValues(i)=sum(m&applied);
end
B.ReviewDecisions.ReviewedValuesApplied=false(height(B.ReviewDecisions),1);
B.ReviewDecisions.ReviewedEventArtifact=strings(height(B.ReviewDecisions),1);
for j=find(applied)'
    di=find(string(B.ReviewDecisions.RecordingID)==string(E.RecordingID(j))& ...
        B.ReviewDecisions.SinkID==E.SinkID(j)&B.ReviewDecisions.EventIndex==eventIds(j));assert(isscalar(di));
    B.ReviewDecisions.ReviewedValuesApplied(di)=true;B.ReviewDecisions.ReviewedEventArtifact(di)=paths(j);
end
B.ReviewPolicy.ReviewedEventValues='Only explicitly supplied, source-bound approved single-event artifacts; no reference inference.';
B.ReviewPolicy.AutomaticEvidence='StartFrame/EndFrame/DurationSec, Episode* and Event/RecordingReference* columns retain automatic evidence; burden intervals use BurdenStartFrame/BurdenEndFrame/BurdenDuration_sec. Reference summary contributor counts exclude rows with explicit reviewed values.';
B.ReviewPolicy.EpisodeSummaryRole='Automatic episode-reference evidence, separate from the imported reviewed event values.';
B.MetricBasis=[B.MetricBasis;cell2table({'BurdenStartFrame / BurdenEndFrame','Approved reviewed interval when supplied; otherwise automatic interval', ...
    'Frame-wise and recording burden use these intervals and BurdenDuration_sec; original automatic StartFrame/EndFrame/DurationSec remain evidence.'; ...
    'EventRevisions','Explicit saved reviewed contribution import','Lists selected reference, timing, area qualification and exact source/revision hashes. Reviewed area revisions can withhold unavailable area; legacy event areas remain unchanged. Episode* summaries describe automatic evidence.'}, ...
    'VariableNames',B.MetricBasis.Properties.VariableNames)];
B=appendBOISignedBurdenSummary(B,selection);
end
function yes=sameSavedNumber(a,b)
% JSON serialization can differ from the binary source by a few ULPs.
% Keep exact identities/clocks; only scalar area metadata uses this bound.
yes=isnumeric(a)&&isnumeric(b)&&isscalar(a)&&isscalar(b)&&isfinite(a)&&isfinite(b)&& ...
    abs(a-b)<=32*eps(max(abs([a b])));
end
function yes=sameResult(a,b)
yes=(isnan(a)&&isnan(b))||(isfinite(a)&&isfinite(b)&&abs(a-b)<=1e-9+1e-12*abs(b));
end
