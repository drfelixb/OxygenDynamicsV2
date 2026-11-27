function nearbySummaries(events,frames,out,condition)
files=["Windows_by_pocket","Aligned_by_mouse","Windows_by_mouse","Aligned_by_group","Windows_by_group"];
tables=summarize(events,frames,condition);
if ismember('IntensityRatiosOffsetCorrected',events.Properties.VariableNames)
    for k=1:5
        T=tables{k};T.CorrectedRecordings=zeros(height(T),1);T.UncorrectedRecordings=zeros(height(T),1);
        T.IntensityRatioDefinition=strings(height(T),1);
        for row=1:height(T)
            selected=true(height(events),1);
            for key=["Mouse","Group","PocketKey"]
                if ismember(key,T.Properties.VariableNames) && ~isequal(string(T.(key)(row)),"All")
                    selected=selected & events.(key)==T.(key)(row);
                end
            end
            corrected=events.IntensityRatiosOffsetCorrected;
            T.CorrectedRecordings(row)=numel(unique(events.RecordingID(selected & corrected)));
            T.UncorrectedRecordings(row)=numel(unique(events.RecordingID(selected & ~corrected)));
            T.IntensityRatioDefinition(row)=strjoin(unique(events.IntensityRatioDefinition(selected)),", ");
        end
        tables{k}=T;
    end
end
for k=1:numel(files)
    T=tables{k};
    if ismember('PocketsAboveBaselineAndRing',T.Properties.VariableNames)
        T.PocketRingCountBasis=repmat("reported_percentages",height(T),1);
    end
    writetable(T,fullfile(out,files(k)+".csv"));
end
end

function tables=summarize(events,frames,condition)
[found,i]=ismember(frames.PocketKey,events.PocketKey);assert(all(found));
frames.Group=events.Group(i);frames.Mouse=events.Mouse(i);frames.SampleF=events.SampleF(i);
screen=~logical(frames.PocketBaselineFlagged | frames.NearPotentialEventDuringBaseline | frames.NearPotentialEvent | frames.AfterNextSameSiteSink);
curve={};windows={};pocketWindows={};
for spec=["Primary","Flag-screened","Far ring","Same tissue support"]
    f=frames;
    switch spec
        case "Flag-screened", f=f(screen,:);
        case "Far ring", f.NearPct=f.FarPct;
        case "Same tissue support",f.PocketPct=f.TissueOnlyPocketPct;
    end
    f=f(isfinite(f.PocketPct)&isfinite(f.NearPct),:);
    for anchor=["Offset","Onset"]
        if anchor=="Onset" && spec~="Primary",continue;end
        lag=f.("From"+anchor+"_s");
        keep=lag>=-20-1e-9 & lag<=60+1e-9;
        t=f(keep,:);t.Seconds=round(lag(keep),9);
        c=mouseMeans(t,{'Group','Mouse','Seconds'});c.Analysis=repmat(spec,height(c),1);c.Alignment=repmat(anchor,height(c),1);
        curve{end+1}=c; %#ok<AGROW>
    end
    if ~ismember(spec,["Primary","Flag-screened"]),continue;end
    for window=[1 31]
        last=10;if window==31,last=60;end
        t=f(f.FromOffset_s>=window-1e-9 & f.FromOffset_s<=last+1e-9,:);
        [g,id]=findgroups(t(:,{'Group','Mouse','PocketKey','SampleF'}));
        if ~isempty(t)
            id.PocketPct=accumarray(g,t.PocketPct,[],@mean);id.NearPct=accumarray(g,t.NearPct,[],@mean);
            cnt=accumarray(g,1);required=floor(last*id.SampleF+1e-9)-ceil(window*id.SampleF-1e-9)+1;
            id=id(cnt==required & required>0,:);
        else
            id.PocketPct=zeros(0,1);id.NearPct=zeros(0,1);
        end
        id.Analysis=repmat(spec,height(id),1);id.Start_s=repmat(window,height(id),1);id.End_s=repmat(last,height(id),1);
        id.ExcessPP=id.PocketPct-id.NearPct;
        pocketWindows{end+1}=id; %#ok<AGROW>
        v=mouseMeans(id,{'Group','Mouse'});v.Analysis=repmat(spec,height(v),1);
        v.Start_s=repmat(window,height(v),1);v.End_s=repmat(last,height(v),1);
        windows{end+1}=v; %#ok<AGROW>
    end
end
c=vertcat(curve{:});w=vertcat(windows{:});
pw=vertcat(pocketWindows{:});
pw.Condition=repmat(condition,height(pw),1);
c.Condition=repmat(condition,height(c),1); w.Condition=repmat(condition,height(w),1);
tables={pw,c,w,groupMeans(c,{'Analysis','Alignment','Seconds','Condition'}), ...
    groupMeans(w,{'Analysis','Start_s','End_s','Condition'})};
end

function v=mouseMeans(t,keys)
[g,v]=findgroups(t(:,keys));
v.Pockets=zeros(height(v),1);v.PocketPct=v.Pockets;v.RingPct=v.Pockets;v.ExcessPP=v.Pockets;v.PocketsAboveBaselineAndRing=v.Pockets;
if isempty(t),return;end
diff=t.PocketPct-t.NearPct;
v.Pockets=accumarray(g,1);v.PocketPct=accumarray(g,t.PocketPct,[],@mean);
v.RingPct=accumarray(g,t.NearPct,[],@mean);v.ExcessPP=accumarray(g,diff,[],@mean);
v.PocketsAboveBaselineAndRing=accumarray(g,double(t.PocketPct>0&diff>0));
end

function grouped=groupMeans(mouse,period)
% Keep the ordering of the mouse-resampling design stable across operating systems.
blocks={}; names=["All";unique(mouse.Group)];
for i=1:numel(names)
    if i==1,s=mouse;else,s=mouse(mouse.Group==names(i),:);end
    s=sortrows(s,[period,{'Group','Mouse'}]);
    [ix,t]=findgroups(s(:,period));
    vals=zeros(height(t),12);
    if ~isempty(s)
        indices=accumarray(ix,(1:height(s))',[],@(x){x});
        for j=1:height(t)
            u=s(indices{j},:);u=sortrows(u,{'Group','Mouse'});
            if numel(unique(u.Mouse))<height(u)
                % A mouse recorded under several sensors still gets one vote in the condition mean.
                [im,pooled]=findgroups(u(:,{'Mouse'}));
                pooled.Pockets=accumarray(im,u.Pockets);
                for field=["PocketPct","RingPct","ExcessPP"]
                    pooled.(field)=accumarray(im,u.(field).*u.Pockets)./pooled.Pockets;
                end
                pooled.PocketsAboveBaselineAndRing=accumarray(im,u.PocketsAboveBaselineAndRing);
                u=pooled; ns=height(u);
            else
                ns=accumarray(findgroups(u.Group),1);
            end
            ci=nearbyBootstrap(u.ExcessPP,ns);
            vals(j,:)=[height(u),sum(u.Pockets),mean(u.PocketPct),mean(u.RingPct),mean(u.ExcessPP),ci, ...
                nnz(u.ExcessPP>0),nnz(u.ExcessPP>0 & u.PocketPct>0),sum(u.PocketsAboveBaselineAndRing),min(u.ExcessPP),max(u.ExcessPP)];
        end
    end
    t.Group=repmat(names(i),height(t),1);
    blocks{end+1}=[t,array2table(vals,'VariableNames',{'Mice','Pockets','PocketPct','RingPct','ExcessPP','Lower95ExcessPP', ...
        'Upper95ExcessPP','MiceAboveRing','MiceAboveBaselineAndRing','PocketsAboveBaselineAndRing','MinMouseExcessPP','MaxMouseExcessPP'})]; %#ok<AGROW>
end
grouped=vertcat(blocks{:});
end
