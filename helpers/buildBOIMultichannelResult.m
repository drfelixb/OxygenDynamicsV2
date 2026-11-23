function P = buildBOIMultichannelResult(O,D,files)
% Compare independently saved RC1 events on a confirmed common grid and clock.
oxygen = find(~cellfun(@isempty,D));
n = O.NFrames; fs = O.SampleHz; pixelArea = O.PixelSizeUm^2;
P = struct('Schema','boi-multichannel-1','Options',O,'TimeSec',(0:n-1)/fs);
modality = ["BLI";"BLI"];
if O.Mode=="bli-fluorescence", modality(2)="Fluorescence"; end
P.Channels = table(repmat(O.RecordingID,2,1),(1:2)',modality,O.Sensors(:),O.Promoters(:), ...
    O.RawFiles(:),O.DenoisedFiles(:),'VariableNames', ...
    {'RecordingID','Channel','Modality','Sensor','Promoter','PreservedMovie','DetectionDenoised'});
eventTables = cell(1,numel(oxygen)); P.Footprints = cell(0,1); P.ReferenceFrames = cell(0,1);
P.RawA = zeros(0,n); P.RawB = zeros(0,n);
summaries = cell(0,1); native = cell(0,1);
for c = oxygen
    other = 3-c; data = D{c}; a = data.Audit; count = height(a);
    e = table(repmat(O.RecordingID,count,1),repmat(c,count,1),repmat(O.Sensors(c),count,1), ...
        repmat(O.Promoters(c),count,1),string(a.EventType),a.SiteID,a.EventID,a.StartFrame,a.EndFrame, ...
        a.DetectedStartFrame,a.DetectedEndFrame,(a.EndFrame-a.StartFrame+1)/fs,data.MeanArea, ...
        100*a.StoredAmplitude,string(a.StoredStatus),a.FootprintPixels, ...
        'VariableNames',{'RecordingID','Channel','Sensor','Promoter','Sign','SiteID','EventID','StartFrame','EndFrame', ...
        'NativeStartFrame','NativeEndFrame','DurationSec','MeanNativeAreaUm2','OpticalDepthOrRisePct', ...
        'RC1ReferenceStatus','FootprintPixels'});
    e.SharedTissuePixels = nan(count,1); e.ExtremeFrame = nan(count,1); e.TiedExtreme = false(count,1);
    e.ReferenceMeanA = nan(count,1); e.ReferenceMeanB = nan(count,1);
    e.ReferenceSamples = zeros(count,1);
    e.MeanChangePctA=nan(count,1); e.MeanChangePctB=nan(count,1);
    e.ChangeAtAnchorExtremePctA=nan(count,1); e.ChangeAtAnchorExtremePctB=nan(count,1);
    footprints = cellfun(@(t)t.Footprint(:),data.Traces,'UniformOutput',false);
    footprints = footprints(:); own = zeros(count,n);
    for j = 1:count, own(j,:) = data.Traces{j}.Raw; end
    peer = readFootprintTraces(files(other),footprints,O.FrameSize,n);
    raw = cell(1,2); raw{c}=own; raw{other}=peer;
    for j = 1:count
        frames = e.StartFrame(j):e.EndFrame(j); values = own(j,frames);
        if all(isfinite(values))
            if e.Sign(j)=="sink", v=min(values); else, v=max(values); end
            positions = find(values==v); e.ExtremeFrame(j)=frames(positions(1)); e.TiedExtreme(j)=numel(positions)>1;
        end
        ref = data.Traces{j}.CleanBaselineFrames(:)';
        P.ReferenceFrames{end+1,1} = ref;
        e.ReferenceSamples(j)=numel(ref);
        if numel(ref)==a.BaselineWindowFrames(j)
            e.ReferenceMeanA(j)=positiveMean(raw{1}(j,ref)); e.ReferenceMeanB(j)=positiveMean(raw{2}(j,ref));
            e.MeanChangePctA(j)=100*(mean(raw{1}(j,frames))/e.ReferenceMeanA(j)-1);
            e.MeanChangePctB(j)=100*(mean(raw{2}(j,frames))/e.ReferenceMeanB(j)-1);
            extreme=e.ExtremeFrame(j);
            if isfinite(extreme)
                e.ChangeAtAnchorExtremePctA(j)=100*(raw{1}(j,extreme)/e.ReferenceMeanA(j)-1);
                e.ChangeAtAnchorExtremePctB(j)=100*(raw{2}(j,extreme)/e.ReferenceMeanB(j)-1);
            end
        end
    end
    for sign = ["sink","surge"]
        field = 'SinkEligibleTissuePixels'; if sign=="surge", field='SurgeEligibleTissuePixels'; end
        selected = find(e.Sign==sign); num = numel(selected);
        eligible = unique(data.AnalysisInfo.(field)); area = numel(eligible)*pixelArea;
        jointArea = NaN; inside = NaN; edge = NaN;
        if numel(oxygen)==2
            joint = intersect(eligible,D{other}.AnalysisInfo.(field)); jointArea=numel(joint)*pixelArea;
            for j=selected'
                e.SharedTissuePixels(j)=nnz(ismember(footprints{j},joint));
            end
            inside=nnz(e.SharedTissuePixels(selected)==e.FootprintPixels(selected));
            edge=nnz(e.SharedTissuePixels(selected)>0 & e.SharedTissuePixels(selected)<e.FootprintPixels(selected));
        end
        factor = 60e6/(n/fs);
        rate=NaN; fullRate=NaN; intersectRate=NaN;
        if area>0, rate=num*factor/area; end
        if jointArea>0, fullRate=inside*factor/jointArea; intersectRate=(inside+edge)*factor/jointArea; end
        summaries{end+1,1}=table(O.RecordingID,c,O.Sensors(c),O.Promoters(c),sign,num,n/fs,area,rate, ...
            jointArea,inside,edge,fullRate,intersectRate,median(e.DurationSec(selected),'omitnan'), ...
            median(e.MeanNativeAreaUm2(selected),'omitnan'),median(e.OpticalDepthOrRisePct(selected),'omitnan'), ...
            nnz(isfinite(e.OpticalDepthOrRisePct(selected))), ...
            'VariableNames',{'RecordingID','Channel','Sensor','Promoter','Sign','IndependentCount','RecordingSeconds', ...
            'RC1TissueAreaUm2','IndependentRatePerMm2Min','CommonTissueAreaUm2','FullyInsideCount','CrossesBoundaryCount', ...
            'FullyInsideRatePerMm2Min','AnyIntersectionRatePerMm2Min','MedianDurationSec','MedianAreaUm2', ...
            'MedianDepthOrRisePct','AvailableDepthCount'}); %#ok<AGROW>
    end
    eventTables{c}=e;
    P.Footprints=[P.Footprints;footprints]; native=[native;data.Native(:)]; %#ok<AGROW>
    P.RawA=[P.RawA;raw{1}]; P.RawB=[P.RawB;raw{2}];
end
P.Events=vertcat(eventTables{:}); P.Events.EventRow=(1:height(P.Events))';
P.Summary=boiPairSummaryMeans(vertcat(summaries{:}),P.Events);
P.Links=candidateLinks(P.Events,P.Footprints,native,prod(O.FrameSize),fs);
P.Links.RecordingID=repmat(O.RecordingID,height(P.Links),1);
if ~isempty(P.Links)
    countA=accumarray(P.Links.EventRowA,1); countB=accumarray(P.Links.EventRowB,1);
    P.Links.CandidatesForA=countA(P.Links.EventRowA); P.Links.CandidatesForB=countB(P.Links.EventRowB);
else
    P.Links.CandidatesForA=zeros(0,1); P.Links.CandidatesForB=zeros(0,1);
end
P.Comparisons=compareChannels(P.Summary,O);
end

function v=positiveMean(x)
v=mean(x); if ~isfinite(v) || v<=0, v=NaN; end
end

function W=footprintMatrix(pixels,nPixels)
counts=cellfun(@numel,pixels);
rows=repelem((1:numel(pixels))',counts);
W=sparse(rows,vertcat(pixels{:}),1,numel(pixels),nPixels);
end

function values=readFootprintTraces(file,pixels,sz,n)
values=zeros(numel(pixels),n);
if isempty(pixels), return; end
W=footprintMatrix(pixels,prod(sz)); sizes=full(sum(W,2));
movie=Tiff(char(file),'r'); closeMovie=onCleanup(@()close(movie));
for f=1:n
    img=read(movie);
    values(:,f)=(W*double(img(:)))./sizes;
    if f<n, nextDirectory(movie); end
end
end

function L=candidateLinks(e,pixels,native,nPixels,fs)
names={'EventRowA','EventRowB','SharedFootprintPixels','FootprintJaccard','IntervalOverlapSec','GapSec', ...
    'FramesWithCoincidentPixels','OnsetLagSec_BminusA','MinimumLagSec_BminusA'};
a=find(e.Channel==1 & e.Sign=="sink"); b=find(e.Channel==2 & e.Sign=="sink");
rows=zeros(0,numel(names));
if ~isempty(a) && ~isempty(b)
    overlap=footprintMatrix(pixels(a),nPixels)*footprintMatrix(pixels(b),nPixels)';
    [i,j,shared]=find(overlap); rows=zeros(numel(i),numel(names));
    for k=1:numel(i)
        x=a(i(k)); y=b(j(k));
        frames=min(e.EndFrame(x),e.EndFrame(y))-max(e.StartFrame(x),e.StartFrame(y))+1;
        together=0;
        for f=max(e.NativeStartFrame(x),e.NativeStartFrame(y)):min(e.NativeEndFrame(x),e.NativeEndFrame(y))
            px=native{x}{f-e.NativeStartFrame(x)+1}; py=native{y}{f-e.NativeStartFrame(y)+1};
            together=together+double(~isempty(intersect(px,py)));
        end
        rows(k,:)=[x y shared(k) shared(k)/(numel(pixels{x})+numel(pixels{y})-shared(k)), ...
            max(0,frames)/fs max(0,-frames)/fs together (e.StartFrame(y)-e.StartFrame(x))/fs ...
            (e.ExtremeFrame(y)-e.ExtremeFrame(x))/fs];
    end
end
L=array2table(rows,'VariableNames',names);
L.Relation=repmat("possible delayed counterpart",height(L),1);
L.Relation(L.IntervalOverlapSec>0)="overlapping intervals and fixed footprints";
L.Relation(L.FramesWithCoincidentPixels>0)="native pixels coincide in time";
end

function T=compareChannels(s,O)
names={'Comparison','RecordingID','Sign','FirstSensor','SecondSensor','FirstPromoter','SecondPromoter', ...
    'DeltaFullyInsideRatePerMm2Min','DeltaAnyIntersectionRatePerMm2Min','DeltaMedianDurationSec','DeltaMedianAreaUm2','DeltaMedianDepthOrRisePct'};
T=table('Size',[0 numel(names)],'VariableTypes',[repmat({'string'},1,7) repmat({'double'},1,5)],'VariableNames',names);
if O.Mode~="dual-bli", return; end
order=[1 2];
if any(ismember(lower(O.Promoters),["unknown","unspecified"]))
    label="Unspecified promoter comparison";
elseif strcmpi(O.Promoters(1),O.Promoters(2))
    label="1. Sensors within promoter";
    if strcmpi(O.Sensors(2),'GeNL'), order=[2 1]; end
else
    label="2. Promoters across channels";
    if strcmpi(O.Promoters(2),'hSyn'), order=[2 1]; end
end
metrics={'FullyInsideRatePerMm2Min','AnyIntersectionRatePerMm2Min','MedianDurationSec','MedianAreaUm2','MedianDepthOrRisePct'};
for sign=["sink","surge"]
    x=s(s.Sign==sign & s.Channel==order(1),:); y=s(s.Sign==sign & s.Channel==order(2),:);
    delta=num2cell(y{1,metrics}-x{1,metrics});
    T(end+1,:)=[{label,O.RecordingID,sign,x.Sensor,y.Sensor,x.Promoter,y.Promoter},delta]; %#ok<AGROW>
end
end
