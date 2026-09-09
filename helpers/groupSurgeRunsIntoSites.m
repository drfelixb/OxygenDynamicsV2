function [Sites,Map] = groupSurgeRunsIntoSites(Runs,minOverlapFraction)
% Group retained runs by mutual overlap of fixed event footprints. Site anchors
% are the first retained run's footprint and never grow through chained matches.
% At least one empty frame separates same-site runs; grouping cannot join them.
assert(isscalar(minOverlapFraction)&&isfinite(minOverlapFraction)&&minOverlapFraction>0&&minOverlapFraction<=1);
N=size(Runs,2);Sites=cell(0,N);anchors={};last=[];count=[];n=size(Runs,1);
site=zeros(n,1);event=site;first=site;finish=site;ambiguous=false(n,1);
for r=1:n
    t=find(~cellfun(@isempty,Runs(r,:)));
    assert(~isempty(t)&&all(diff(t)==1),'Each input row must contain one contiguous run.');
    first(r)=t(1);finish(r)=t(end);
end
[~,order]=sortrows([first (1:n)'],[1 2]);
for r=reshape(order,1,[])
    footprint=unique(vertcat(Runs{r,:}));scores=zeros(1,numel(anchors));
    for s=1:numel(anchors)
        if first(r)<=last(s)+1,continue;end
        scores(s)=numel(intersect(footprint,anchors{s}))/max(numel(footprint),numel(anchors{s}));
    end
    eligible=find(scores>=minOverlapFraction);ambiguous(r)=numel(eligible)>1;
    if isempty(eligible)
        s=numel(anchors)+1;anchors{s}=footprint;Sites(s,1:N)={[]};count(s)=0;
    else
        [~,best]=max(scores(eligible));s=eligible(best);
    end
    site(r)=s;count(s)=count(s)+1;event(r)=count(s);last(s)=finish(r);
    Sites(s,first(r):finish(r))=Runs(r,first(r):finish(r));
end
Map=table(site,event,first,finish,ambiguous,'VariableNames', ...
    {'SurgeID','EventID','NativeStartFrame','NativeEndFrame','SiteAssignmentAmbiguous'});
end
