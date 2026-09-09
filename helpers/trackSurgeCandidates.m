function [Runs,Info] = trackSurgeCandidates(Frames,minDurationFrames,minOverlapFraction,minContainmentFraction,maxAreaRatio)
% Adjacent-frame, one-to-one native runs. No missing frames are bridged.
% Primary link: mutual coverage. Isolated shape-change fallback: containment
% of the smaller region plus bounded area ratio, with exactly one overlapping
% partner at both endpoints. No lineage or missing-frame inference is made.
assert(isscalar(minDurationFrames)&&isfinite(minDurationFrames)&&minDurationFrames>0);
assert(isscalar(minOverlapFraction)&&isfinite(minOverlapFraction)&&minOverlapFraction>=0&&minOverlapFraction<=1);
assert(isscalar(minContainmentFraction)&&isfinite(minContainmentFraction)&&minContainmentFraction>0&&minContainmentFraction<=1);
assert(isscalar(maxAreaRatio)&&isfinite(maxAreaRatio)&&maxAreaRatio>=1);
N=numel(Frames);Runs=cell(0,N);ambiguous=false(0,1);lastPixels={};lastIDs=[];
shapeFrames=cell(0,1);minimumCoverage=zeros(0,1);maximumRatio=zeros(0,1);
for f=1:N
    current={};
    for r=1:numel(Frames{f})
        px=Frames{f}(r).PixelIdxList;
        if isRemovedRegion(px)||isempty(px),continue;end
        assert(all(isfinite(px(:))&px(:)>=1&px(:)==fix(px(:))),'Invalid candidate pixels.');
        current{end+1}=unique(px(:)); %#ok<AGROW>
    end
    % Regionprops candidates are disjoint: their minimum indices are unique.
    % Reject malformed overlapping candidates rather than duplicating pixels.
    if ~isempty(current)
        allPixels=vertcat(current{:});
        assert(numel(unique(allPixels))==numel(allPixels),'Candidates within a frame must be disjoint.');
        [~,order]=sort(cellfun(@(p)p(1),current));current=current(order);
    end
    score=zeros(numel(lastPixels),numel(current));containment=score;ratios=score;
    if ~isempty(current)&&~isempty(lastPixels)
        maxPixel=max([cellfun(@max,current) cellfun(@max,lastPixels)]);
        membership=false(maxPixel,1);
        for a=1:numel(lastPixels)
            membership(lastPixels{a})=true;
            for b=1:numel(current)
                overlap=nnz(membership(current{b}));
                if overlap>0
                    largest=max(numel(lastPixels{a}),numel(current{b}));smallest=min(numel(lastPixels{a}),numel(current{b}));
                    score(a,b)=overlap/largest;containment(a,b)=overlap/smallest;ratios(a,b)=largest/smallest;
                end
            end
            membership(lastPixels{a})=false;
        end
    end
    primary=score>0 & score>=minOverlapFraction;
    overlaps=score>0;
    isolated=sum(overlaps,2)==1 & sum(overlaps,1)==1;
    shape=~primary & isolated & containment>=minContainmentFraction & ratios<=maxAreaRatio;
    eligible=primary|shape;branch=sum(overlaps,2)>1;merge=sum(overlaps,1)>1;
    oldAmbiguous=branch | any(overlaps(:,merge),2);
    newAmbiguous=merge | any(overlaps(branch,:),1);
    ambiguous(lastIDs(oldAmbiguous))=true;
    [a,b]=find(eligible);values=score(eligible);edges=[-values(:) a(:) b(:)];
    edges=sortrows(edges,[1 2 3]);used=false(numel(lastIDs),1);ids=zeros(1,numel(current));
    for e=1:size(edges,1)
        a=edges(e,2);b=edges(e,3);
        if ~used(a)&&ids(b)==0
            ids(b)=lastIDs(a);used(a)=true;
            minimumCoverage(ids(b))=min(minimumCoverage(ids(b)),score(a,b));
            maximumRatio(ids(b))=max(maximumRatio(ids(b)),ratios(a,b));
            if shape(a,b),shapeFrames{ids(b)}(end+1)=f;end
        end
    end
    for b=1:numel(current)
        if ids(b)==0
            ids(b)=size(Runs,1)+1;Runs(ids(b),1:N)={[]};ambiguous(ids(b),1)=false;
            shapeFrames{ids(b),1}=[];minimumCoverage(ids(b),1)=Inf;maximumRatio(ids(b),1)=0;
        end
        Runs{ids(b),f}=current{b};ambiguous(ids(b))=ambiguous(ids(b))||newAmbiguous(b);
    end
    lastPixels=current(ids>0);lastIDs=ids(ids>0);
end
first=zeros(size(Runs,1),1);last=first;
for r=1:size(Runs,1),t=find(~cellfun(@isempty,Runs(r,:)));first(r)=t(1);last(r)=t(end);end
Info=table(first,last,ambiguous,'VariableNames',{'NativeStartFrame','NativeEndFrame','AmbiguousTracking'});
Info.ShapeChangeLinkCount=cellfun(@numel,shapeFrames);
Info.ShapeChangeLinkFrames=strings(height(Info),1);
for r=1:height(Info),Info.ShapeChangeLinkFrames(r)=strjoin(string(shapeFrames{r}),';');end
minimumCoverage(isinf(minimumCoverage))=NaN;maximumRatio(maximumRatio==0)=NaN;
Info.MinimumMatchedMutualCoverage=minimumCoverage;Info.MaximumMatchedAreaRatio=maximumRatio;
% All runs, including too-short terminal candidates, remain available for QC.
Info.DurationFrames=last-first+1;
Info.KeptAsEvent=Info.DurationFrames>=ceil(minDurationFrames);
end
