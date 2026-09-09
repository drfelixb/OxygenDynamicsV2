function [Runs,Info] = trackSurgeCandidates(Frames,minDurationFrames,minOverlapFraction)
% Adjacent-frame, one-to-one native runs. No missing frames are bridged.
% Mutual coverage = intersection / max(region sizes). Greedy highest coverage
% wins; canonical pixel order breaks ties. All eligible branch/merge choices
% are flagged from any nonzero overlap, including losing tracks. This is not a lineage reconstruction.
assert(isscalar(minDurationFrames)&&isfinite(minDurationFrames)&&minDurationFrames>0);
assert(isscalar(minOverlapFraction)&&isfinite(minOverlapFraction)&&minOverlapFraction>=0&&minOverlapFraction<=1);
N=numel(Frames);Runs=cell(0,N);ambiguous=false(0,1);lastPixels={};lastIDs=[];
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
    score=zeros(numel(lastPixels),numel(current));
    if ~isempty(current)&&~isempty(lastPixels)
        maxPixel=max([cellfun(@max,current) cellfun(@max,lastPixels)]);
        membership=false(maxPixel,1);
        for a=1:numel(lastPixels)
            membership(lastPixels{a})=true;
            for b=1:numel(current)
                overlap=nnz(membership(current{b}));
                if overlap>0,score(a,b)=overlap/max(numel(lastPixels{a}),numel(current{b}));end
            end
            membership(lastPixels{a})=false;
        end
    end
    eligible=score>0 & score>=minOverlapFraction;
    overlaps=score>0;branch=sum(overlaps,2)>1;merge=sum(overlaps,1)>1;
    oldAmbiguous=branch | any(overlaps(:,merge),2);
    newAmbiguous=merge | any(overlaps(branch,:),1);
    ambiguous(lastIDs(oldAmbiguous))=true;
    [a,b]=find(eligible);values=score(eligible);edges=[-values(:) a(:) b(:)];
    edges=sortrows(edges,[1 2 3]);used=false(numel(lastIDs),1);ids=zeros(1,numel(current));
    for e=1:size(edges,1)
        a=edges(e,2);b=edges(e,3);
        if ~used(a)&&ids(b)==0,ids(b)=lastIDs(a);used(a)=true;end
    end
    for b=1:numel(current)
        if ids(b)==0
            if f>N-ceil(minDurationFrames)+1,continue;end
            ids(b)=size(Runs,1)+1;Runs(ids(b),1:N)={[]};ambiguous(ids(b),1)=false;
        end
        Runs{ids(b),f}=current{b};ambiguous(ids(b))=ambiguous(ids(b))||newAmbiguous(b);
    end
    lastPixels=current(ids>0);lastIDs=ids(ids>0);
end
first=zeros(size(Runs,1),1);last=first;
for r=1:size(Runs,1),t=find(~cellfun(@isempty,Runs(r,:)));first(r)=t(1);last(r)=t(end);end
Info=table(first,last,ambiguous,'VariableNames',{'NativeStartFrame','NativeEndFrame','AmbiguousTracking'});
end
