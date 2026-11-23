function [Events,Sites] = assignOxygenEventSites(Events,Masks,R,C)
% Complete-link footprint IoU prevents single-link chaining. Ambiguous ties unassigned.
clusters={}; scores=zeros(height(Events),1);
pixelSites=cell(size(R.Intensity,1)*size(R.Intensity,2),1);
for k=1:height(Events)
    candidates=[]; quality=[];
    % Complete-link compatibility necessarily intersects the first member.
    % Index only representative footprints; this prunes impossible sites exactly.
    candidateSites=unique([pixelSites{double(Masks(k).Footprint)}]);
    for s=candidateSites(:)'
        members=clusters{s}; iou=zeros(size(members));
        for j=1:numel(members)
            a=Masks(k).Footprint; b=Masks(members(j)).Footprint;
            iou(j)=numel(intersect(a,b))/numel(union(a,b));
        end
        if all(iou>=C.SiteMinIoU), candidates(end+1)=s; quality(end+1)=min(iou); end %#ok<AGROW>
    end
    if isempty(candidates)
        clusters{end+1}=k; Events.SiteID(k)=numel(clusters); scores(k)=1;
        for p=double(Masks(k).Footprint(:))', pixelSites{p}(end+1)=numel(clusters); end %#ok<AGROW>
    elseif numel(candidates)==1
        s=candidates(1); clusters{s}(end+1)=k; Events.SiteID(k)=s; scores(k)=quality(1);
    else
        Events.SiteAmbiguous(k)=true; scores(k)=max(quality);
    end
end
Events.SiteMembershipIoU=scores;
rows=struct('RecordingID',{},'AnalysisRunID',{},'SiteID',{},'EventCount',{},'EventIDs',{},'Footprint',{});
for s=1:numel(clusters)
    members=clusters{s}; fp=uint32([]);
    for k=members, fp=union(fp,Masks(k).Footprint); end
    rows(end+1)=struct('RecordingID',R.RecordingID,'AnalysisRunID',C.AnalysisRunID,'SiteID',s, ...
        'EventCount',numel(members),'EventIDs',join(Events.EventID(members),";"),'Footprint',{fp}); %#ok<AGROW>
end
Sites=struct2table(rows,'AsArray',true);
Sites.Footprint=reshape({rows.Footprint},[],1);
end
