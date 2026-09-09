function tests=testSurgeTrackingEquivalence
tests=functiontests(localfunctions);
end
function setupOnce(~)
setupOxygenDynamicsPath;
end
function testRandomizedExactEquivalence(t)
rng(171);
for trial=1:40
    F=cell(randi([5 25]),1);
    for f=1:numel(F)
        F{f}=struct('PixelIdxList',{});
        for r=1:randi([0 6])
            px=randi(80,randi([0 35]),1);
            if rand<.1,px=NaN;end
            F{f}(r).PixelIdxList=px;
        end
    end
    duration=randi([1 5]);overlap=randi([0 12]);
    verifyEqual(t,trackSurgeCandidates(F,duration,overlap),originalTracker(F,duration,overlap));
end
end
function testStrictOverlapAndFirstMatch(t)
F={struct('PixelIdxList',{[1;2;3]}); ...
   struct('PixelIdxList',{[1;2;4],[1;2;3;5]}); ...
   struct('PixelIdxList',{[1;2;3],[4;5;6]}); ...
   struct('PixelIdxList',{[2;3;4]})};
verifyEqual(t,trackSurgeCandidates(F,1,2),originalTracker(F,1,2));
verifyEqual(t,trackSurgeCandidates(cell(4,1),1,2),originalTracker(cell(4,1),1,2));
end
function O=originalTracker(F,minDuration,minOverlap)
% Pre-optimization matching oracle with the corrected terminal seed bound.
O=cell(1,length(F));counter=1;
for frame=1:(length(F)-ceil(minDuration)+1)
    for region=1:length(F{frame,1})
        start=F{frame,1}(region).PixelIdxList;
        if isRemovedRegion(start),continue;end
        O{counter,frame}=start;
        for next=frame+1:length(F)
            for region2=1:length(F{next,1})
                pixels=F{next,1}(region2).PixelIdxList;
                if isRemovedRegion(pixels),continue;end
                if length(intersect(start,pixels))>minOverlap
                    O{counter,next}=pixels;F{next,1}(region2).PixelIdxList=NaN;break
                end
            end
        end
        F{frame,1}(region).PixelIdxList=NaN;counter=counter+1;
    end
end
end
