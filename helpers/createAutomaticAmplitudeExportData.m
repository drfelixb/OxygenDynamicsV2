function D = createAutomaticAmplitudeExportData(Core,Burden)
% Additive reporting only. Never replace existing measurements or summaries.
D.Schema="boi-automatic-amplitude-export-1";
D.Definitions=definitions();
D.AverageCounts=table('Size',[0 13],'VariableTypes', ...
    [repmat({'string'},1,7),{'double','double','double'},repmat({'string'},1,3)], ...
    'VariableNames',{'SummaryLevel','EventType','RecordingID','Mouse','SiteID','GroupKey','Metric', ...
    'Value','ContributingCount','TotalCount','CountUnit','Units','ContributingRule'});
D.Availability=table('Size',[0 9],'VariableTypes', ...
    [repmat({'string'},1,4),repmat({'double'},1,5)], ...
    'VariableNames',{'SummaryLevel','EventType','RecordingID','SiteID','TotalEvents', ...
    'UnavailableAmplitudeEvents','NegativeAmplitudeEvents','NegativeAmplitudeExcludedFromBurdenEvents','UnavailableCompositeEvents'});
for kind=["sink","surge"]
    if kind=="sink",S=Core.TableOxygenSinks;E=Core.TableOxygenSinkEvents; amp='NormOxySinkAmp';
    else,S=Core.TableOxygenSurges;E=Core.TableOxygenSurgeEvents;amp='NormOxySurgeAmp';end
    for i=1:height(S)
        values=S.(amp){i};
        site=id(S,'SiteID',i,string(i));rec=id(S,'RecordingID',i,"");mouse=id(S,'Mouse',i,"");
        D.AverageCounts(end+1,:)={"site",kind,rec,mouse,site,"","MeanOxy"+titleKind(kind)+"Event_NormAmp", ...
            safeCellMean(values),sum(isfinite(values)),numel(values),"events","fraction", ...
            "Finite amplitudes at this site, including negative values; grouped metric sheets list these site means by mouse."};
        excluded=NaN;composite=NaN;
        if kind=="sink" && ~isempty(E) && ismember('SinkID',E.Properties.VariableNames)
            local=string(E.SinkID)==site;
            if ismember('RecordingID',E.Properties.VariableNames),local=local & string(E.RecordingID)==rec;end
            Q=E(local,:);
            if height(Q)==numel(values),a=dropPercent(Q);excluded=sum(isfinite(a)&a<0);end
            B=Burden.EventTable;
            if ~isempty(B)&&all(ismember({'RecordingID','SinkID'},B.Properties.VariableNames))
                Q=B(string(B.RecordingID)==rec & string(B.SinkID)==site,:);
                if height(Q)==numel(values),composite=sum(~isfinite(Q.PerEventBurdenContribution));end
            end
        end
        D.Availability(end+1,:)={"site",kind,rec,site,numel(values),sum(~isfinite(values)), ...
            sum(isfinite(values)&values<0),excluded,composite};
    end
    recordingIDs=strings(0,1);
    if isfield(Core,'RecordingRegistry') && ismember('RecordingID',Core.RecordingRegistry.Properties.VariableNames)
        recordingIDs=string(Core.RecordingRegistry.RecordingID);
    elseif ~isempty(E)&&ismember('RecordingID',E.Properties.VariableNames)
        recordingIDs=unique(string(E.RecordingID),'stable');
    end
    for rec=reshape(recordingIDs,1,[])
            if ismember('RecordingID',E.Properties.VariableNames),T=E(string(E.RecordingID)==rec,:);else,T=E;end
            values=[];if ismember(amp,T.Properties.VariableNames),values=T.(amp);end
            excluded=NaN; composite=NaN;
            if kind=="sink"
                raw=[];if ~isempty(T),raw=dropPercent(T);end
                excluded=sum(isfinite(raw)&raw<0);if isempty(T),composite=0;end
                B=Burden.EventTable;
                if ~isempty(B)&&ismember('RecordingID',B.Properties.VariableNames)
                    Q=B(string(B.RecordingID)==rec,:);
                    if height(Q)==height(T),composite=sum(~isfinite(Q.PerEventBurdenContribution));end
                end
            end
            D.Availability(end+1,:)={"recording",kind,rec,"",height(T),sum(~isfinite(values)), ...
                sum(isfinite(values)&values<0),excluded,composite};
    end
end
R=Burden.RecordingTable; B=Burden.EventTable;
pairs={'MeanEventBurdenContribution','PerEventBurdenContribution'; ...
    'MedianEventBurdenContribution','PerEventBurdenContribution'; ...
    'MeanEventBurdenContribution_per_mm2','PerEventBurdenContribution_per_mm2'; ...
    'MedianEventBurdenContribution_per_mm2','PerEventBurdenContribution_per_mm2'; ...
    'MeanBurdenAmplitudePercent','BurdenAmplitudePercent'; ...
    'MeanBurdenArea_um2','BurdenArea_um2';'MeanBurdenDuration_sec','BurdenDuration_sec'};
for i=1:height(R)
    rec=id(R,'RecordingID',i,"");mouse=id(R,'Mouse',i,"");
    % Use the same metadata grouping as the legacy no-registry recording path.
    cols=intersect({'RecordingID','Experiment','Mouse','Condition','DrugID','Genotype','Promoter','PuffStim'}, ...
        intersect(R.Properties.VariableNames,B.Properties.VariableNames),'stable');
    mask=true(height(B),1);
    for c=cols,mask=mask & string(B.(c{1}))==string(R.(c{1})(i));end
    Q=B(mask,:);
    for j=1:size(pairs,1)
        metric=pairs{j,1};source=pairs{j,2};
        if ~ismember(metric,R.Properties.VariableNames),continue;end
        n=0;if ismember(source,Q.Properties.VariableNames),n=sum(~isnan(Q.(source)));end
        D.AverageCounts(end+1,:)={"recording","sink",rec,mouse,"","",string(metric),R.(metric)(i), ...
            n,height(Q),"events",units(metric),"Non-NaN event inputs for this metric (existing omitnan rule); each metric has its own subset."};
    end
end
G=Burden.GroupSummaryTable;
if isempty(G),return;end
cols=intersect({'DrugID','Condition','PuffStim','Genotype','Promoter'},R.Properties.VariableNames,'stable');
metrics=G.Properties.VariableNames(endsWith(G.Properties.VariableNames,'_Mean'));
for i=1:height(G)
    mask=true(height(R),1);key="";
    for c=cols
        value=string(G.(c{1})(i));mask=mask & string(R.(c{1}))==value;
        key=key+string(c{1})+"="+value+"; ";
    end
    T=R(mask,:);mice=unique(string(T.Mouse));
    for j=1:numel(metrics)
        out=metrics{j};metric=extractBefore(string(out),strlength(out)-4);
        values=T.(char(metric));contributingMice=0;
        for m=reshape(mice,1,[])
            v=values(string(T.Mouse)==m); value=mean(v); % same strict within-mouse mean
            D.AverageCounts(end+1,:)={"within_mouse","sink","",m,"",key,metric,value, ...
                sum(~isnan(v)),numel(v),"recordings",units(metric), ...
                "All recordings required; any NaN makes this mouse mean unavailable. Count shows non-NaN inputs, not a partial mean."};
            contributingMice=contributingMice+isfinite(value);
        end
        D.AverageCounts(end+1,:)={"equal_mouse_group","sink","","","",key,string(out),G.(out)(i), ...
            contributingMice,numel(mice),"mice",units(metric), ...
            "Finite within-mouse recording means; each contributing mouse has equal weight. SEM uses the same mice and needs at least two."};
    end
end
end

function value=id(T,name,i,fallback)
value=fallback;if ismember(name,T.Properties.VariableNames),value=string(T.(name)(i));end
end
function value=titleKind(kind)
if kind=="sink",value="Sink";else,value="Surge";end
end
function a=dropPercent(T)
if ismember('NormOxySinkAmpPercent',T.Properties.VariableNames),a=T.NormOxySinkAmpPercent;
else,a=100*T.NormOxySinkAmp;end
if ismember('AmplitudeSignConvention',T.Properties.VariableNames)
    flip=string(T.AmplitudeSignConvention)=="negative_drop_percent";a(flip)=-a(flip);
end
end
function u=units(metric)
metric=char(metric);
if contains(metric,'AmplitudePercent'),u="percent";
elseif contains(metric,'Area_um2'),u="um^2";
elseif contains(metric,'Duration_sec'),u="seconds";
elseif contains(metric,'EventOnsetRate'),u="events/mm^2/min";
elseif contains(metric,'RankAmplitude'),u="rank-weighted event-seconds/mm^2/min";
elseif contains(metric,'Occupancy'),u="event-seconds/mm^2/min";
else
    u="percent*um^2*seconds";
    if contains(metric,'per_mm2'),u=u+"/mm^2";end
    if contains(metric,'per_sec'),u=u+"/second";
    elseif contains(metric,'per_min'),u=u+"/minute";end
end
end
function T=definitions()
Metric=["NormOxySinkAmp";"NormOxySinkAmpPercent";"NormOxySurgeAmp";"NormOxySurgeAmpPercent"; ...
    "DetectionOxySinkAmp";"MeanOxySinkEvent_NormAmp / MeanOxySurgeEvent_NormAmp"; ...
    "MeanBurdenAmplitudePercent";"MeanBurdenArea_um2 / MeanBurdenDuration_sec"; ...
    "MeanEventBurdenContribution / MedianEventBurdenContribution (and per_mm2 variants)"; ...
    "Within-mouse recording means / *_Mean / *_SEM"];
SignalSource=[repmat("Preserved-input TIFF mean over fixed union of native event pixels",4,1); ...
    "Processed site detection trace and its seventh-order trend"; ...
    "Saved automatic event fractions at one site";"Saved automatic sink percentages after sign-provenance conversion"; ...
    "Saved event area and duration used by the composite";"Saved event amplitude*area*duration contributions"; ...
    "Saved recording metrics; then within-mouse recording means"];
Reference=[repmat("Mean of all requested immediately preceding clean finite samples; saved measurement start, configured window (default 20 seconds); both native signs screen overlap; positive mean required",4,1); ...
    "Seventh-order full-site fitted trend; detection-domain diagnostic"; ...
    "Each event's own saved reference; no shared site reference fitted"; ...
    "Each event's own saved reference; no new reference or correction"; ...
    "Native event geometry / saved measurement duration, not an intensity reference"; ...
    "Each event's own reference; saved recording area for per_mm2 variant"; ...
    "Each underlying event's reference; no mouse reference or correction fitted"];
Formula=["(B - min(signal))/B";"100 * NormOxySinkAmp";"(max(signal) - B)/B"; ...
    "100 * NormOxySurgeAmp";"abs(abs(min(processed trace)) - abs(min(trend))) over saved sink bounds"; ...
    "mean(finite automatic event fractions) within one site"; ...
    "mean(non-NaN BurdenAmplitudePercent); negative drop-oriented inputs are NaN"; ...
    "Separate mean(non-NaN area) and mean(non-NaN duration)"; ...
    "mean/median(non-NaN contributions); per_mm2 uses each contribution * 1e6 / recording area"; ...
    "mouse=mean(all recording values); group=mean(finite mouse means); SEM=std(mouse means)/sqrt(n) for n>1"];
Units=["fraction";"percent";"fraction";"percent";"processed detection units";"fraction"; ...
    "percent";"area: um^2; duration: seconds";"percent*um^2*seconds (per_mm2 additionally /mm^2)";"same units as underlying metric"];
SignAndAvailability=["Current automatic convention: positive optical drop; negative means event minimum above reference; unavailable stays unavailable. Explicit older negative_drop_percent provenance reverses this sign and is converted only for burden inputs"; ...
    "Same sign, exactly one multiplication by 100";"Positive optical increase; negative means event maximum below reference"; ...
    "Same sign, exactly one multiplication by 100";"Nonnegative diagnostic; not an optical percentage"; ...
    "Negative finite values contribute; no contributing events gives NaN; grouped site sheets are not mouse means"; ...
    "Zero contributes; negative drop-oriented amplitudes excluded; missing reference remains unavailable; zero contributors gives NaN"; ...
    "Separate subsets; these means may include events with unavailable amplitude or composite"; ...
    "Unavailable amplitude, excluded negative amplitude, missing area/duration or normalization can prevent a contribution; strict recording total remains unavailable if required contributions are missing"; ...
    "Any missing recording makes its mouse mean unavailable; group omits unavailable mouse means; zero contributing mice gives NaN"];
ClaimLimit=repmat("Optical/descriptive output; not calibrated oxygen concentration, pressure or oxygen debt. Arithmetic does not establish reference suitability, correction validity or biological interpretation.",numel(Metric),1);
T=table(Metric,SignalSource,Reference,Formula,Units,SignAndAvailability,ClaimLimit);
end
