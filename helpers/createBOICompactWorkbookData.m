function D=createBOICompactWorkbookData(S)
%CREATEBOICOMPACTWORKBOOKDATA Flat saved-value projection; no scientific estimators.
R=metadata(S.Registry,S.Metadata);D=struct();events=cell(2,1);records=cell(2,1);times=cell(2,1);
for ki=1:2
    kind=string({'sink','surge'});kind=kind(ki);
    nativeName=char("Oxy"+upper(extractBefore(kind,2))+extractAfter(kind,1)+"Events");
    if kind=="sink",nativeName='OxySinkEvents';end
    if kind=="surge",nativeName='OxySurgeEvents';end
    N=get(S.Tables,nativeName);B=table();BR=table();BT=table();
    if kind=="sink",B=get(S.Tables,'HypoxicBurden_EventBased');BR=get(S.Tables,'HypoxicBurden_ByRecording');BT=get(S.Tables,'HypoxicBurden_TimeSeries');end
    E=identity(N,R);E.EventType=repmat(kind,height(E),1);
    E.SiteID=txt(N,{'SiteID','SinkID','SurgeID'});E.EventIndex=txt(N,{'EventIndex','EventID'});
    assert(all(strlength(E.SiteID)>0)&all(strlength(E.EventIndex)>0),'OxygenDynamics:CompactIdentity','Event site/index is missing.');
    K=key(E);assert(numel(unique(K))==height(E),'OxygenDynamics:CompactIdentity','Duplicate automatic event key.');
    fields={'StartFrame',{'StartFrame'};'EndFrame',{'EndFrame'};'Duration_sec',{'DurationSec'}; ...
        'AmplitudePercent',{'EventAmplitudePercent','NormOxySinkAmpPercent','NormOxySurgeAmpPercent'}; ...
        'MeanArea_um2',{'EventArea_um2','Area_um'};'Diameter_um',{'Diameter_um','MeanOxySinkDiameter_um','MeanOxySurgeDiameter_um'}; ...
        'Circularity',{'MeanCircularity','MeanCircularity_Surge'};'OpticalAUC_fraction_sec',{'SignedTraceAUC_sec'}};
    for i=1:size(fields,1),E.(['Automatic' fields{i,1}])=num(N,fields{i,2});end
    if ~any(ismember({'EventAmplitudePercent','NormOxySinkAmpPercent','NormOxySurgeAmpPercent'},N.Properties.VariableNames))
        E.AutomaticAmplitudePercent=100*num(N,{'NormOxySinkAmp','NormOxySurgeAmp'}); % explicit fraction-to-percent unit conversion only
    end
    E.AutomaticStartSec=num(N,{'StartSec'});E.AutomaticEndSec=num(N,{'EndSec'});
    E.AutomaticAUCReference=txt(N,{'AUCReferenceSource','BaselineStatus'});
    E.AutomaticAUCVersion=txt(N,{'AUCVersion','AnalysisSchemaVersion'});
    E.AutomaticAUCBaselineValue=num(N,{'BaselineValue'});
    E.AutomaticAUCBaselineStartFrame=num(N,{'BaselineStartFrame'});E.AutomaticAUCBaselineEndFrame=num(N,{'BaselineEndFrame'});
    E.AutomaticMeasurementSource=repmat(string(nativeName),height(E),1);
    E.AutomaticBurdenPolicy=repmat(policy(S.Tables),height(E),1);
    E=burden(E,B,'Automatic',false);
    E=quality(E,N,'Automatic');
    reviewed=E(:,1:0); %#ok<NASGU>
    E.ReviewStatus=repmat("No compatible reviewed snapshot",height(E),1);
    E.ReviewSnapshot=strings(height(E),1);E.ReviewReason=strings(height(E),1);
    E.ReviewedExcluded=nan(height(E),1);
    E.ReviewedAmplitudePercent=nan(height(E),1);E.ReviewedMeanArea_um2=nan(height(E),1);
    E.ReviewedDuration_sec=nan(height(E),1);E.ReviewedStartFrame=nan(height(E),1);E.ReviewedEndFrame=nan(height(E),1);
    E=burden(E,table(),'Reviewed',true);
    E.ReviewedBurdenPolicy=strings(height(E),1);
    for j=1:numel(S.Reviews)
        Q=S.Reviews{j};Q=Q.HypoxicBurden;
        if kind~="sink",continue;end
        ids=string(Q.RecordingTable.RecordingID);scope=ismember(E.RecordingID,ids);
        E.ReviewStatus(scope)="No manual review";
        E.ReviewedExcluded(scope)=0;E.ReviewSnapshot(scope)=reviewName(S.Reviews{j},j);
        V=Q.EventTable;vk=eventKeys(V,kind);[match,idx]=ismember(K,vk);
        decision=get(Q,'ReviewDecisions');dk=eventKeys(decision,kind);[dm,di]=ismember(K,dk);
        if ~isempty(decision)
            st=txt(decision,{'RecognitionStatus'});reason=txt(decision,{'Reason'});excluded=num(decision,{'ExcludedFromReviewedBurden'});
            for z=find(dm)'
                if st(di(z))~="not_reviewed"&&strlength(st(di(z)))>0,E.ReviewStatus(z)=st(di(z));end
                E.ReviewReason(z)=reason(di(z));E.ReviewedExcluded(z)=excluded(di(z));
            end
        end
        ex=get(Q,'ExcludedDetections');[em,~]=ismember(K,eventKeys(ex,kind));
        assert(~any(match&em)&&all(~scope|((E.ReviewedExcluded==1)==em)), ...
            'OxygenDynamics:CompactReview','Saved retained/excluded membership conflicts.');
        E.ReviewedExcluded(em)=1;E.ReviewStatus(em)="Excluded: not a pocket";
        assert(all(~scope|match|em),'OxygenDynamics:CompactReview','Reviewed snapshot omits detections without saved exclusion.');
        assert(all(ismember(vk,K)),'OxygenDynamics:CompactReview','Reviewed snapshot contains unknown events.');
        T=E(match,:);T=burden(T,V,'Reviewed',false);
        bn=string(T.Properties.VariableNames);bn=bn(startsWith(bn,'ReviewedBurden')|startsWith(bn,'ReviewedContribution'));
        for f=bn,E.(f)(match)=T.(f);end
        cols={'AmplitudePercent','BurdenAmplitudePercent';'MeanArea_um2','BurdenArea_um2';'Duration_sec','BurdenDuration_sec'; ...
            'StartFrame','BurdenStartFrame';'EndFrame','BurdenEndFrame'};
        for z=1:size(cols,1)
            v=num(V,{cols{z,2}});
            if all(isnan(v))&&ismember(cols{z,1},{'StartFrame','EndFrame'}),v=num(V,{cols{z,1}});end
            E.(['Reviewed' cols{z,1}])(match)=v(idx(match));
        end
        E.ReviewedBurdenPolicy(scope)=policy(struct('Burden_SelectionPolicy',get(Q,'SelectionPolicy')));
        E=reviewQuality(E,V,match,idx);
    end
    E.SourceAnalysisID=repmat(string(S.AutomaticSHA256),height(E),1);
    events{ki}=E;
    C=R;C.EventType=repmat(kind,height(C),1);n=height(C);
    C.SourceAnalysisID=repmat(string(S.AutomaticSHA256),n,1);
    C.AutomaticInventoryCount=nan(n,1);C.AutomaticSiteCount=nan(n,1);
    C.AutomaticInventoryStatus=repmat("unavailable",n,1);
    C.AutomaticEventRate_per_min=nan(n,1);C.AutomaticEventDensity_per_mm2=nan(n,1);
    C.AutomaticEventRate_per_mm2_per_min=nan(n,1);
    C.InventoryBasis=repmat("original automatic detection inventory; includes reviewed exclusions",n,1);
    C.Duration_sec=num(R,{'RecordingDuration_sec','RecDuration'});
    if kind=="surge",C.AnalyzedArea_um2=num(R,{'SurgeRecordingArea_um2'});else,C.AnalyzedArea_um2=num(R,{'RecordingArea_um2'});end
    W=get(S.Tables,'RecordingWindowMetrics');if kind=="surge",W=get(S.Tables,'SurgeRecordingWindowMetrics');end
    for ai=1:height(C)
        am=txt(W,{'RecordingID'})==C.RecordingID(ai)&num(W,{'StartSec'})==0&abs(num(W,{'EndSec'})-C.Duration_sec(ai))<1e-9;
        assert(sum(am)<=1,'OxygenDynamics:CompactConflict','Ambiguous sign-specific exposure.');
        if any(am),C.AnalyzedArea_um2(ai)=num(W(am,:),{'AreaUm2'});end
    end
    for i=1:n
        mask=E.RecordingID==C.RecordingID(i);
        analyzed=txt(R(i,:),{'AnalysisStatus'})=="loaded";
        if isfield(S.Tables,nativeName)&&analyzed
            C.AutomaticInventoryCount(i)=sum(mask);C.AutomaticSiteCount(i)=numel(unique(E.SiteID(mask)));
            C.AutomaticInventoryStatus(i)="analyzed";
            t=C.Duration_sec(i);a=C.AnalyzedArea_um2(i);
            if isfinite(t)&&t>0,C.AutomaticEventRate_per_min(i)=sum(mask)*60/t;end
            if isfinite(a)&&a>0,C.AutomaticEventDensity_per_mm2(i)=sum(mask)*1e6/a;end
            if isfinite(t)&&t>0&&isfinite(a)&&a>0,C.AutomaticEventRate_per_mm2_per_min(i)=sum(mask)*1e6/a*60/t;end
        end
    end
    C=recordBurden(C,BR,'Automatic');C=recordBurden(C,table(),'Reviewed');
    C.ReviewStatus=repmat("No compatible reviewed snapshot",n,1);
    C.AutomaticBurdenPolicy=repmat(policy(S.Tables),n,1);C.ReviewedBurdenPolicy=strings(n,1);
    C.ReviewedExcludedCount=nan(n,1);C.ReviewedRetainedCount=nan(n,1);
    if kind=="sink"
        for j=1:numel(S.Reviews)
            Q=S.Reviews{j}.HypoxicBurden;mask=ismember(C.RecordingID,string(Q.RecordingTable.RecordingID));
            temp=recordBurden(C(mask,:),Q.RecordingTable,'Reviewed');
            for f=string(temp.Properties.VariableNames)
                if startsWith(f,'Reviewed')&&~ismember(f,["ReviewedBurdenPolicy","ReviewedExcludedCount","ReviewedRetainedCount"]),C.(f)(mask)=temp.(f);end
            end
            C.ReviewStatus(mask)="Saved reviewed snapshot";C.ReviewedBurdenPolicy(mask)=policy(struct('Burden_SelectionPolicy',get(Q,'SelectionPolicy')));
            summary=get(Q,'ReviewSummary');[m,ix]=ismember(C.RecordingID,txt(summary,{'RecordingID'}));
            rejected=num(summary,{'RejectedDetections'});retained=num(summary,{'RetainedDetections'});
            C.ReviewedExcludedCount(m)=rejected(ix(m));C.ReviewedRetainedCount(m)=retained(ix(m));
        end
    else
        C.ReviewStatus(:)="Not applicable: sink burden only";
    end
    window='RecordingWindowMetrics';ingredient='WindowFrameIngredients';
    if kind=="surge",window='SurgeRecordingWindowMetrics';ingredient='SurgeWindowFrameIngredients';end
    C=windowValues(C,get(S.Tables,window));records{ki}=C;
    T=timeData(get(S.Tables,ingredient),BT,R,kind,S);
    times{ki}=T;
end
D.Events=unionTables(events);
front={'RecordingID','Experiment','Mouse','SessionID','Condition','EventType','SiteID','EventIndex', ...
    'AutomaticAmplitudePercent','ReviewedAmplitudePercent','AutomaticDuration_sec','ReviewedDuration_sec', ...
    'AutomaticMeanArea_um2','ReviewedMeanArea_um2','AutomaticContribution','ReviewedContribution', ...
    'AutomaticContribution_per_mm2_per_min','ReviewedContribution_per_mm2_per_min','ReviewStatus','ReviewedExcluded'};
D.Events=D.Events(:,[front setdiff(D.Events.Properties.VariableNames,front,'stable')]);
D.Recordings=unionTables(records);D.Sites=siteData(D.Events,R,S);D.TimeSeries=unionTables(times);
D.Phases=table();if ~isempty(S.Phases)
    assert(all(ismember({'RecordingID','Phase','StartSec','EndSec'},S.Phases.Properties.VariableNames)), ...
        'OxygenDynamics:CompactPhases','Phases require RecordingID, Phase, StartSec and EndSec.');
    P=S.Phases;assert(all(isfinite(P.StartSec)&isfinite(P.EndSec)&P.EndSec>P.StartSec&P.StartSec>=0), ...
        'OxygenDynamics:CompactPhases','Invalid supplied phase interval.');
    D.Phases=identity(P,R);D.Phases.Phase=string(P.Phase);D.Phases.StartSec=P.StartSec;D.Phases.EndSec=P.EndSec;
    D.Phases.AnnotationSource=txt(P,{'AnnotationSource'});D.Phases.AnnotationUncertainty=txt(P,{'AnnotationUncertainty'});
    D.Phases.Role=repmat("supplied metadata only; no event assignment or phase calculations",height(P),1);
end
D.Availability=createBOICompactAvailabilitySummary(D,@meaning);D.Definitions=definitions(D,S);
end
function R=metadata(R,M)
assert(istable(M),'OxygenDynamics:CompactMetadata','Metadata must be a table.');
if ismember('Session',R.Properties.VariableNames)&&~ismember('SessionID',R.Properties.VariableNames),R.SessionID=string(R.Session);end
if ~isempty(M)
    assert(ismember('RecordingID',M.Properties.VariableNames),'OxygenDynamics:CompactMetadata','Metadata requires an explicit RecordingID crosswalk.');
    assert(numel(unique(string(M.RecordingID)))==height(M)&&all(ismember(string(M.RecordingID),string(R.RecordingID))), ...
        'OxygenDynamics:CompactConflict','Duplicate or foreign metadata recording IDs.');
    [found,ix]=ismember(string(R.RecordingID),string(M.RecordingID));
    for f=string(M.Properties.VariableNames)
        if f=="RecordingID",continue;end
        if ~ismember(f,R.Properties.VariableNames),R.(f)=strings(height(R),1);end
        a=string(R.(f));b=strings(height(R),1);b(found)=string(M.(f)(ix(found)));b(ismissing(b))="";a(ismissing(a))="";
        assert(~any(found&strlength(a)>0&strlength(b)>0&a~=b),'OxygenDynamics:CompactConflict','Conflicting metadata for %s.',f);
        fill=found&strlength(b)>0;a(fill)=b(fill);R.(f)=a;
    end
end
for f=["Experiment","Mouse","SessionID","Condition"]
    if ~ismember(f,R.Properties.VariableNames),R.(f)=strings(height(R),1);else,R.(f)=string(R.(f));end
end
for f=string(R.Properties.VariableNames)
    if isstring(R.(f))||iscellstr(R.(f)),v=string(R.(f));v(ismissing(v))="";R.(f)=v;end
end
% The first five columns stay fixed on every data sheet.
first={'RecordingID','Experiment','Mouse','SessionID','Condition'};R=R(:,[first setdiff(R.Properties.VariableNames,first,'stable')]);
end
function E=identity(N,R)
if height(N)==0,E=R([],:);return;end
assert(ismember('RecordingID',N.Properties.VariableNames),'OxygenDynamics:CompactIdentity','Missing event/series RecordingID.');
[m,ix]=ismember(string(N.RecordingID),string(R.RecordingID));assert(all(m),'OxygenDynamics:CompactIdentity','Source rows have unknown recording IDs.');
E=R(ix,:);
for f=intersect({'Experiment','Mouse','SessionID','Condition'},N.Properties.VariableNames)
    a=txt(N,f);b=string(E.(f{1}));assert(~any(strlength(a)>0&strlength(b)>0&a~=b), ...
        'OxygenDynamics:CompactConflict','Source identity metadata conflicts: %s.',f{1});
    use=strlength(b)==0;E.(f{1})(use)=a(use);
end
end
function E=burden(E,B,prefix,empty)
n=height(E);aliases={'BurdenAmplitudePercent','BurdenAmplitudePercent';'BurdenMeanArea_um2','BurdenArea_um2'; ...
    'BurdenDuration_sec','BurdenDuration_sec';'Contribution','PerEventBurdenContribution'; ...
    'Contribution_per_mm2_per_min','PerEventBurdenContribution_per_mm2_per_min'; ...
    'BurdenAmplitudeNegative','BurdenAmplitudeNegative';'BurdenContributionNegative','BurdenContributionNegative'};
if empty||isempty(B),idx=zeros(n,1);m=false(n,1);else,[m,idx]=ismember(key(E),eventKeys(B,"sink"));end
for i=1:size(aliases,1)
    v=nan(n,1);b=num(B,aliases(i,2));v(m)=b(idx(m));E.([prefix aliases{i,1}])=v;
end
end
function E=quality(E,N,prefix)
names=string(N.Properties.VariableNames);
keep=startsWith(names,["EventReference","RecordingReference","AboveRecordingReference","EpisodeReference","Baseline","PreviousNativeGap","NextNativeGap","CloseNative","RecurrenceStatus","TimingResolved","Onset","Recovery","Boundary","Truncated","QuantificationSource","AnalysisSchemaVersion"]);
for f=names(keep)
    v=N.(f);if size(v,2)==1&&(isnumeric(v)||islogical(v)||isstring(v)||iscellstr(v)||iscategorical(v))
        if iscellstr(v)||iscategorical(v),v=string(v);end
        if isstring(v),v(ismissing(v))="";end
        E.([prefix char(f)])=v;
    end
end
end
function E=reviewQuality(E,V,match,idx)
T=quality(table(),V,'Reviewed');
for f=string(T.Properties.VariableNames)
    v=T.(f);if ~ismember(f,E.Properties.VariableNames)
        if isnumeric(v)||islogical(v),E.(f)=nan(height(E),1);else,E.(f)=strings(height(E),1);end
    end
    E.(f)(match)=v(idx(match));
end
end
function C=recordBurden(C,B,prefix)
fields={'Burden','HypoxicBurden';'Burden_per_mm2_per_min','HypoxicBurden_per_mm2_per_min'; ...
    'RequiredContributions','NumRequiredBurdenContributions';'AvailableContributions','NumAvailableBurdenContributions'; ...
    'NegativeContributions','NumNegativeBurdenContributions'};
[m,ix]=ismember(C.RecordingID,txt(B,{'RecordingID'}));
assert(numel(unique(txt(B,{'RecordingID'})))==height(B),'OxygenDynamics:CompactConflict','Duplicate recording burden rows.');
for i=1:size(fields,1),v=nan(height(C),1);b=num(B,fields(i,2));v(m)=b(ix(m));C.([prefix fields{i,1}])=v;end
for f={'BurdenTotalSign','NormalizedBurdenTotalSign'}
    v=strings(height(C),1);b=txt(B,f);v(m)=b(ix(m));C.([prefix f{1}])=v;
end
end
function C=windowValues(C,W)
fields={'MeanConcurrentEvents_per_mm2','MeanOccupiedTissueFraction','CoveredAreaTime_um2_sec', ...
    'AnalyzedTissueTime_mm2_min','AcquisitionStartEvents','OngoingAtWindowStart'};
for f=fields,C.(['Automatic' f{1}])=nan(height(C),1);end
C.AutomaticOccupancyStatus=repmat("unavailable",height(C),1);
for i=1:height(C)
    m=txt(W,{'RecordingID'})==C.RecordingID(i)&num(W,{'StartSec'})==0&abs(num(W,{'EndSec'})-C.Duration_sec(i))<1e-9;
    assert(sum(m)<=1,'OxygenDynamics:CompactConflict','Ambiguous whole-recording window.');
    if any(m)
        for f=fields,C.(['Automatic' f{1}])(i)=num(W(m,:),f);end
        C.AutomaticOccupancyStatus(i)=txt(W(m,:),{'OccupancyStatus'});
    end
end
end
function T=timeData(F,B,R,kind,S)
% Frame clock comes only from explicit saved rows, never event bounds.
if isempty(F),F=B;end
if isempty(F),T=identity(table(),R);else
    assert(all(ismember({'RecordingID','Frame'},F.Properties.VariableNames)),'OxygenDynamics:CompactClock','Saved time series needs recording and frame.');
    if ismember('WindowID',F.Properties.VariableNames)
        assert(height(unique(F(:,{'RecordingID','Frame'}),'rows'))==height(F), ...
            'OxygenDynamics:CompactClock','Overlapping saved windows are ambiguous; select a whole-recording source.');
    end
    T=identity(F,R);
end
T.EventType=repmat(kind,height(T),1);T.Frame=num(F,{'Frame'});T.TimeSec=num(F,{'TimeSec','ModeledStartSec'});
assert(all(isfinite(T.Frame)&T.Frame>=1&isfinite(T.TimeSec)),'OxygenDynamics:CompactClock','Invalid or missing saved frame clock.');
k=framekey(T);assert(numel(unique(k))==height(T),'OxygenDynamics:CompactClock','Duplicate saved frame.');
T.AutomaticOccupiedArea_um2=num(F,{'OccupiedArea_um2'});T.AnalyzedArea_um2=num(F,{'AnalyzedArea_um2'});
if kind=="sink"&&~ismember('AnalyzedArea_um2',F.Properties.VariableNames),T.AnalyzedArea_um2=num(T,{'RecordingArea_um2'});end
T.AutomaticActiveEvents=num(F,{'ActiveEvents'});
T.AutomaticActiveEvents_per_mm2=num(F,{'ActiveEvents_per_mm2'});
T.AutomaticOccupiedTissueFraction=num(F,{'OccupiedTissueFraction'});
a=T.AnalyzedArea_um2;valid=isfinite(a)&a>0&isfinite(T.AutomaticOccupiedArea_um2);
T.AutomaticOccupiedTissueFraction(valid)=T.AutomaticOccupiedArea_um2(valid)./a(valid);
T.AutomaticBurdenActiveEvents=nan(height(T),1);
T.AutomaticBurdenPerMm2=nan(height(T),1);T.ReviewedBurdenPerMm2=nan(height(T),1);
T.AutomaticBurdenPolicy=repmat(policy(S.Tables),height(T),1);T.ReviewedBurdenPolicy=strings(height(T),1);
T.ReviewStatus=repmat("No compatible reviewed snapshot",height(T),1);
if kind=="sink"
    T=curve(T,B,'Automatic');
    for j=1:numel(S.Reviews)
        Q=S.Reviews{j}.HypoxicBurden;ids=string(Q.RecordingTable.RecordingID);mask=ismember(T.RecordingID,ids);
        T.ReviewStatus(mask)="Saved reviewed snapshot; absent curve stays unavailable";
        T.ReviewedBurdenPolicy(mask)=policy(struct('Burden_SelectionPolicy',get(Q,'SelectionPolicy')));
        T=curve(T,get(Q,'TimeSeriesTable'),'Reviewed');
    end
end
T=aggregateCounts(T,R,kind,S.Tables);
valid=isfinite(T.AnalyzedArea_um2)&T.AnalyzedArea_um2>0&isfinite(T.AutomaticActiveEvents);
missing=~isfinite(T.AutomaticActiveEvents_per_mm2)&valid;
T.AutomaticActiveEvents_per_mm2(missing)=T.AutomaticActiveEvents(missing)*1e6./T.AnalyzedArea_um2(missing);
T.SourceAnalysisID=repmat(string(S.AutomaticSHA256),height(T),1);
T.CurveBasis=repmat("saved area-normalized amplitude-area contribution spread over event duration; not per minute or per-frame oxygen",height(T),1);
end
function T=curve(T,B,p)
if isempty(B),return;end
bk=framekey(B);assert(numel(unique(bk))==height(B),'OxygenDynamics:CompactClock','Duplicate burden frame.');
[m,ix]=ismember(framekey(T),bk);t=num(B,{'TimeSec'});
assert(all(abs(T.TimeSec(m)-t(ix(m)))<1e-9),'OxygenDynamics:CompactClock','Saved burden and frame clocks conflict.');
v=num(B,{'HypoxicBurdenPerMm2OverTime'});T.([p 'BurdenPerMm2'])(m)=v(ix(m));
if strcmp(p,'Automatic')
    v=num(B,{'ActiveHypoxicEvents'});T.AutomaticBurdenActiveEvents(m)=v(ix(m));
end
end
function T=siteData(E,R,S)
cols={'RecordingID','EventType','SiteID'};U=unique(E(:,cols),'rows','stable');T=identity(U,R);
T.EventType=U.EventType;T.SiteID=U.SiteID;T.AutomaticEventCount=zeros(height(T),1);
T.AutomaticRecurrentDetection=false(height(T),1);T.AutomaticEvents_per_min=nan(height(T),1);
for i=1:height(T)
    m=E.RecordingID==T.RecordingID(i)&E.EventType==T.EventType(i)&E.SiteID==T.SiteID(i);
    T.AutomaticEventCount(i)=sum(m);T.AutomaticRecurrentDetection(i)=sum(m)>1;
    d=num(T(i,:),{'RecordingDuration_sec','RecDuration'});if isfinite(d)&&d>0,T.AutomaticEvents_per_min(i)=sum(m)*60/d;end
end
T.Basis=repmat("automatic same-site detection inventory; recurrence does not establish separate physiological episodes",height(T),1);
T.SourceAnalysisID=repmat(string(S.AutomaticSHA256),height(T),1);
end
function X=definitions(D,S)
rows=cell(0,12);
for sheet=string(fieldnames(D))'
    T=D.(sheet);if ~istable(T),continue;end
    for f=string(T.Properties.VariableNames)
        [unit,normalization,description,comparison]=meaning(f);
        rows(end+1,:)={sheet,f,description,unit,normalization,comparison, ...
            "copied source values; unavailable means absent/nonfinite, never zero", ...
            "automatic native values and reviewed burden ingredients are separate; original AUC and gaps stay automatic", ...
            string(S.AutomaticSHA256),"boi-compact-workbook-2; availability summary-1; actual source policy shown in data",sourceColumn(f,sheet),counterpart(f)}; %#ok<AGROW>
    end
end
X=cell2table(rows,'VariableNames',{'Sheet','Field','Meaning','Units','Normalization','ComparisonScope','Missingness','ReferenceAndRole','SourceAnalysisID','ExportVersion','SourceColumn','Counterpart'});
end
function [unit,norm,desc,compare]=meaning(f)
f=string(f);unit="source-specific";norm="none or not assessed";desc="saved "+f;
compare="not_assessed: inspect saved acquisition, support, source and policy before comparison";
if ismember(f,["NumRows","Segment"])
    unit="source-row count / segment index";norm="none; reporting inventory only";desc="status summary count, never a burden sum or biological weight";
    compare="within exact recording/type/sheet/metric/state/reason/quality; sum disjoint segments only to reconstruct status counts";
elseif ismember(f,["FirstSourceRow","LastSourceRow","SourceRows"])
    unit="1-based primary-table data-row positions";norm="none; Excel row = data row + 1";
    desc="SourceRows gives exact inclusive ranges/comma-separated row IDs; bounds alone do not imply every intervening row";
    compare="row locator only within the named Sheet and unchanged export; use recording/event/frame identity across exports";
elseif f=="RowsAreContiguous"
    unit="numeric 0/1 flag";norm="none";desc="1 when this segment contains every row between its first and last source data row";compare="reporting provenance only";
elseif ismember(f,["RecordingID","Experiment","Mouse","SessionID","Condition","EventType","SiteID","EventIndex","SourceAnalysisID"])
    unit="identifier/text";norm="not applicable";desc="explicit source identity; never inferred or pooled";compare="grouping identity only; preserve recording and mouse hierarchy";
elseif contains(f,["BaselineValue","ReferenceValue","MinimumValue"])
    unit="raw intensity a.u.";norm="none";compare="NOT directly comparable across mice/sessions/settings; acquisition gain/exposure/camera may differ";
elseif contains(f,'AUC')
    unit="fraction seconds (signed optical integral)";norm="own original raw-reference fraction, integrated over time; no area/exposure normalization";
    desc="original automatic signed optical AUC; independent original baseline/bounds/version, not reviewed burden";
    compare="conditional: same optical assay, own AUC reference/footprint and clock; no absolute oxygen interpretation";
elseif ismember(f,["SampleF","SampleFs"])
    unit="Hz (frames/second)";norm="saved acquisition rate";compare="clock calibration; no assumed 1 Hz for new acquisitions";
elseif ismember(f,["PixelSize","Pixelsize"])
    unit="um/pixel";norm="saved scalar spatial calibration; equal X/Y declared";compare="calibration metadata; camera/binning/resolution differences still require comparison review";
elseif contains(f,'CoveredAreaTime')
    unit="um^2 seconds";norm="saved native union area-time; no exposure division";compare="unnormalized extent/time integral; use tissue fraction for exposure comparison";
elseif contains(f,'AnalyzedTissueTime_mm2_min')
    unit="mm^2 minutes";norm="saved area-time exposure denominator";compare="describes sampling effort; not an event measurement or biological response";
elseif contains(f,'MeanConcurrentEvents_per_mm2')
    unit="mean concurrent events per mm^2";norm="saved native event-time / recording time / analyzed area in mm^2";compare="conditional: same native masks, analyzed support, acquisition clock and detector";
elseif contains(f,'BurdenPerMm2')
    unit="percent um^2 per mm^2";norm="area normalized saved curve; NOT per minute";desc="saved matching source burden curve; not instantaneous per-frame oxygen";
    compare="conditional: matching amplitude reference, area support, clock, inventory and correction; recording duration not pointwise divisor";
elseif contains(f,'per_mm2_per_min')
    unit="events per mm^2 per minute";if contains(f,["Burden","Contribution"]),unit="percent um^2 seconds per mm^2 per minute";end
    norm="saved area/time normalization: 1e6/area_um2 and 60/recording_duration_sec; no second normalization";
    compare="conditional between recordings/mice/sessions: calibrated analyzed support/exposure, same assay, policy and event set; not pooled across mice";
elseif contains(f,["Burden","Contribution"])&&~contains(f,["Policy","Sign","Negative","Required","Available"])
    unit="percent um^2 seconds";norm="unnormalized product or sum; exact burden ingredients separately labelled";
    desc="saved signed burden contribution/strict total; no partial or positive-only sum";
    if contains(f,'Amplitude'),unit="percent (not fraction)";norm="saved event-local reference; no exposure normalization";end
    if contains(f,'Area'),unit="um^2";norm="calibrated event mean area; not recording area normalized";end
    if contains(f,'Duration'),unit="seconds";norm="frame-rate calibrated event duration; not recording-time normalized";end
    compare="conditional event descriptors; raw totals depend on sampled area/time; use saved area/time normalized totals for exposure comparison";
elseif contains(f,'AmplitudePercent')
    unit="percent (not Excel percentage)";norm="event-specific nominal 20-second reference; no extra factor of 100";
    compare="conditional relative optical change: same reporter/acquisition/correction and suitable flagged reference; no absolute intensity or pO2 equivalence";
elseif contains(f,["Area_um2","AreaSize"])
    unit="um^2";norm="calibrated physical size; no division by exposure";compare="conditional: pixel calibration, same support/mask method and resolution; no common-FOV inference";
elseif contains(f,'Diameter')
    unit="um";norm="calibrated physical length";compare="conditional: equal X/Y pixel calibration and same shape method/resolution";
elseif contains(f,'Circularity')
    unit="dimensionless";norm="shape ratio";compare="conditional: same masks, method and effective resolution";
elseif contains(f,["Fraction","Occupancy"])
    unit="fraction (0 to 1 when defined)";norm="saved union tissue area or area-time / analyzed tissue or tissue-time; not percent";
    compare="conditional: same analyzed support and native mask method, actual calibration/exposure; reviewed burden does not revise native occupancy";
elseif contains(f,'per_mm2')
    unit="events per mm^2";norm="count / analyzed area in mm^2; duration not normalized";compare="conditional area comparison only; duration and detection effort still matter";
elseif contains(f,'per_min')
    unit="events per minute";norm="inventory count * 60 / saved recording seconds; area not normalized";compare="conditional time comparison only; sampled area still matters";
elseif contains(f,["Duration","TimeSec","Sec","_sec"])
    unit="seconds";norm="saved acquisition clock; no recording-exposure division for event duration";compare="conditional: correct supplied constant sample rate and original frame clock";
elseif contains(f,["Frame","Samples"])
    unit="frames/samples";norm="none; source frame convention";compare="within recording; use calibrated seconds across acquisitions";
elseif contains(f,["BaselineValue","ReferenceValue","MinimumValue"])
    unit="raw intensity a.u.";norm="none";compare="NOT directly comparable across mice/sessions/settings; acquisition gain/exposure/camera may differ";
elseif contains(f,["Count","Contributions","Events","Negative","Resolved","Excluded","Above","Short","Overlap"])
    unit="count or numeric 0/1 flag (NaN unknown)";norm="none";compare="descriptive QC/inventory; not a biological exclusion or cross-recording normalized rate";
end
end

function T=aggregateCounts(T,R,kind,tables)
name='NumOngoingOxysinks';if kind=="surge",name='NumOngoingOxysurges';end
if ~isfield(tables,name),return;end
A=tables.(name);if ~iscell(A)||size(A,2)~=6,return;end
cols={'Experiment','Mouse','Condition','DrugID','PuffStim'};
if ~all(ismember(cols,R.Properties.VariableNames)),return;end
for i=1:height(R)
    hit=true(size(A,1),1);
    for c=1:5
        a=string(A(:,c));a(ismissing(a))="";b=string(R.(cols{c})(i));if ismissing(b),b="";end
        if c==5,a=replace(lower(a),["false","true"],["0","1"]);b=replace(lower(b),["false","true"],["0","1"]);end
        hit=hit&a==b;
    end
    % Only a unique complete metadata association with exact saved frame count.
    if sum(hit)~=1,continue;end
    row=find(hit);v=A{row,6};nf=num(R(i,:),{'NFrames'});
    if ~isnumeric(v)||~isvector(v)||numel(v)~=nf,continue;end
    m=T.RecordingID==R.RecordingID(i);frames=T.Frame(m);
    assert(all(frames==fix(frames)&frames<=nf),'OxygenDynamics:CompactClock','Count vector/frame association conflicts.');
    T.AutomaticActiveEvents(m)=v(frames);
    if kind=="sink"&&isfield(tables,'NumOngoingOxysinksPerMm2')
        B=tables.NumOngoingOxysinksPerMm2;
        if iscell(B)&&isequal(B(:,1:5),A(:,1:5))&&numel(B{row,6})==nf,T.AutomaticActiveEvents_per_mm2(m)=B{row,6}(frames);end
    end
end
end
function s=sourceColumn(f,sheet)
s=sheet+" saved source / registry scalar "+f;
if sheet=="Availability",s="unchanged primary sheet/Metric; boi-cell-status-1 rules; exact SourceRows segments and status counts";return;end
if contains(f,'OpticalAUC'),s="OxySinkEvents/OxySurgeEvents.SignedTraceAUC_sec; original Baseline* and AnalysisSchemaVersion";
elseif endsWith(f,'AmplitudePercent')&&~contains(f,'Burden')
    if startsWith(f,'Reviewed'),s="selected HypoxicBurden.EventTable.BurdenAmplitudePercent";else,s="OxySinkEvents.EventAmplitudePercent, else NormOxySinkAmpPercent; surge NormOxySurgeAmpPercent; only legacy fraction aliases x100";end
elseif contains(f,'Contribution_per_mm2_per_min'),s="HypoxicBurden.EventTable.PerEventBurdenContribution_per_mm2_per_min";
elseif endsWith(f,'Contribution'),s="HypoxicBurden.EventTable.PerEventBurdenContribution";
elseif endsWith(f,'MeanArea_um2'),s="native EventArea_um2, else event Area_um; reviewed BurdenArea_um2";
elseif endsWith(f,'Burden_per_mm2_per_min'),s="HypoxicBurden.RecordingTable.HypoxicBurden_per_mm2_per_min";
elseif endsWith(f,'Burden'),s="HypoxicBurden.RecordingTable.HypoxicBurden";
elseif endsWith(f,'BurdenPerMm2'),s="HypoxicBurden.TimeSeriesTable.HypoxicBurdenPerMm2OverTime";
elseif contains(f,'Reference')||contains(f,'Baseline')||contains(f,'NativeGap'),s="same named saved native/selected reviewed event scalar; prefix identifies role";
elseif contains(f,'Inventory')||sheet=="Sites",s="exact original event inventory grouping (RecordingID + EventType + SiteID); unit conversion uses saved registry exposure";
elseif sheet=="TimeSeries",s="saved frame ingredients and original NumOngoing* vectors with unique exact metadata association; no clock reconstruction";
end
end
function s=counterpart(f)
s="";if startsWith(f,'Automatic'),s=replaceBetween(f,1,9,'Reviewed');elseif startsWith(f,'Reviewed'),s=replaceBetween(f,1,8,'Automatic');end
end

function T=unionTables(parts)
T=table();for i=1:numel(parts)
    A=parts{i};if width(A)==0,continue;end
    if width(T)==0,T=A;continue;end
    names=union(T.Properties.VariableNames,A.Properties.VariableNames,'stable');
    for f=names
        if ~ismember(f,T.Properties.VariableNames),T.(f{1})=blank(A.(f{1}),height(T));end
        if ~ismember(f,A.Properties.VariableNames),A.(f{1})=blank(T.(f{1}),height(A));end
    end
    T=[T(:,names);A(:,names)]; %#ok<AGROW>
end
end
function v=blank(proto,n)
if isnumeric(proto)||islogical(proto),v=nan(n,1);else,v=strings(n,1);end
end
function k=eventKeys(T,kind)
if isempty(T),k=strings(0,1);return;end
E=table(txt(T,{'RecordingID'}),repmat(string(kind),height(T),1),txt(T,{'SiteID','SinkID','SurgeID'}),txt(T,{'EventIndex','EventID'}), ...
    'VariableNames',{'RecordingID','EventType','SiteID','EventIndex'});k=key(E);
assert(numel(unique(k))==height(T),'OxygenDynamics:CompactIdentity','Duplicate saved event keys.');
end
function k=key(E)
k=encode(string(E.RecordingID))+encode(string(E.EventType))+encode(string(E.SiteID))+encode(string(E.EventIndex));
end
function k=framekey(T)
k=encode(txt(T,{'RecordingID'}))+encode(string(num(T,{'Frame'})));
end
function s=encode(s),s=string(strlength(s))+":"+s;end
function T=get(S,f)
T=table();if isfield(S,f)&&istable(S.(f)),T=S.(f);end
end
function v=num(T,names)
v=nan(height(T),1);for f=string(names)
    if ismember(f,T.Properties.VariableNames)
        a=T.(f);if isnumeric(a)||islogical(a),v=double(a);else,v=str2double(string(a));end
        return;
    end
end
end
function v=txt(T,names)
v=strings(height(T),1);for f=string(names)
    if ismember(f,T.Properties.VariableNames),v=string(T.(f));v(ismissing(v))="";return;end
end
end
function v=policy(T)
v="unmarked legacy policy; retained as saved";P=get(T,'Burden_SelectionPolicy');
if ~isempty(P),a=txt(P,{'Version','BurdenSelectionPolicyVersion'});if any(strlength(a)>0),v=a(1);end,end
end
function v=reviewName(R,i)
v="selected completed snapshot "+i;if isfield(R,'Path'),v=string(R.Path);elseif isfield(R.Receipt,'Workbook'),v=string(R.Receipt.Workbook);end
end
