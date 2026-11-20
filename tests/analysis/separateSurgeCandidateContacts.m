function [Out,Decisions]=separateSurgeCandidateContacts(Input,Signal,Tissue,P,Options)
% TEST ONLY: partition accepted components with two persistent, resolved peaks.
% Does not establish physiological independence; preserves every input pixel.
assert(numel(Input)==size(Signal,3)&&isequal(size(Tissue),size(Signal,[1 2])));
assert(P.surgeTrackingOverlapFraction>.5);
assert(Options.MinimumHistorySec>0&&Options.MinimumMarkerDistanceUm>0&& ...
 Options.MinimumSaddleDropFraction>0&&Options.MinimumSaddleDropFraction<1);
Out=cell(size(Input));previous=struct('PixelIdxList',{});ages=[];
Decisions=table('Size',[0 10],'VariableTypes',[repmat({'double'},1,8) {'logical','string'}], ...
 'VariableNames',{'Frame','ParentCandidateIndex','PreviousCandidates','MinimumPreviousHistoryFrames', ...
 'Marker1Pixel','Marker2Pixel','MarkerDistanceUm','SaddleDropFraction','PartitionApplied','Outcome'});
for f=1:numel(Input)
 native=Input{f};current=struct('PixelIdxList',{},'Area',{},'ParentCandidateIndex',{},'PartitionApplied',{});
 if ~isempty(native),[~,order]=sort(arrayfun(@(x)min(x.PixelIdxList),native));native=native(order);end
 for j=1:numel(native)
  px=native(j).PixelIdxList(:);neighbors=[];coverage=[];
  for a=1:numel(previous)
   n=numel(intersect(px,previous(a).PixelIdxList));
   if n>0,neighbors(end+1)=a;coverage(end+1)=n/numel(previous(a).PixelIdxList);end %#ok<AGROW>
  end
  children={px};history=NaN;markers=[NaN NaN];distance=NaN;drop=NaN;applied=false;
  outcome="not_a_two_parent_contact";
  if numel(neighbors)==2
   history=min(ages(neighbors));outcome="insufficient_history";
   if history>=ceil(Options.MinimumHistorySec*P.fs)
    outcome="insufficient_previous_coverage";
    if all(coverage>=.5)
     parent=false(size(Tissue));parent(px)=true;
     heightMap=zeros(size(Tissue));plane=double(Signal(:,:,f));assert(all(isfinite(plane(px))));
     heightMap(px)=plane(px)-min(plane(px));
     for a=1:2
      support=intersect(px,previous(neighbors(a)).PixelIdxList);
      [~,at]=max(heightMap(support));markers(a)=support(at);
     end
     markers=sort(markers);[yy,xx]=ind2sub(size(Tissue),markers);
     distance=hypot(diff(xx),diff(yy))*P.PixelSize;outcome="markers_too_close";
     if distance>=Options.MinimumMarkerDistanceUm
      marker=zeros(size(Tissue));marker(markers(1))=heightMap(markers(1));
      flooded=imreconstruct(marker,heightMap,8);peak=min(heightMap(markers));drop=0;
      if peak>0,drop=1-flooded(markers(2))/peak;end
      outcome="insufficient_saddle_drop";
      if drop>=Options.MinimumSaddleDropFraction
       first=bwdistgeodesic(parent,markers(1),'quasi-euclidean');
       second=bwdistgeodesic(parent,markers(2),'quasi-euclidean');
       assert(all(isfinite(first(px)))&&all(isfinite(second(px))));
       left=parent & first<=second;right=parent & second<first;outcome="child_filter_failed";
       if validChild(left,Tissue,P)&&validChild(right,Tissue,P)
        children={find(left),find(right)};applied=true;outcome="split_applied";
       end
      end
     end
    end
   end
  end
  for a=1:numel(children)
   current(end+1)=struct('PixelIdxList',children{a},'Area',numel(children{a}), ...
    'ParentCandidateIndex',j,'PartitionApplied',applied); %#ok<AGROW>
  end
  Decisions(end+1,:)={f,j,numel(neighbors),history,markers(1),markers(2),distance,drop,applied,outcome}; %#ok<AGROW>
 end
 if ~isempty(current),[~,order]=sort(arrayfun(@(x)min(x.PixelIdxList),current));current=current(order);end
 expected=[];actual=[];
 for j=1:numel(native),expected=[expected;native(j).PixelIdxList(:)];end %#ok<AGROW>
 for j=1:numel(current),actual=[actual;current(j).PixelIdxList(:)];end %#ok<AGROW>
 assert(isequal(sort(expected(:)),sort(actual(:)))&&numel(unique(actual))==numel(actual));
 ages=nextAges(previous,current,ages,P);previous=current;Out{f}=current;
end
end
function ok=validChild(mask,tissue,P)
cc=bwconncomp(mask,8);ok=false;if cc.NumObjects~=1,return;end
r=regionprops(cc,'Area','Circularity','PixelIdxList');
ok=r.Area>=P.ThresholdMinsize_Surges&&r.Circularity>=P.surgeCircularityThreshold&& ...
 mean(~tissue(r.PixelIdxList))<=P.maxOutsideRecordingAreaFraction;
end
function ages=nextAges(A,B,old,P)
n=zeros(numel(A),numel(B));mutual=n;containment=n;ratio=n;
for a=1:numel(A)
 for b=1:numel(B)
  sizes=[numel(A(a).PixelIdxList) numel(B(b).PixelIdxList)];
  n(a,b)=numel(intersect(A(a).PixelIdxList,B(b).PixelIdxList));
  mutual(a,b)=n(a,b)/max(sizes);containment(a,b)=n(a,b)/min(sizes);ratio(a,b)=max(sizes)/min(sizes);
 end
end
isolated=sum(n>0,2)==1 & sum(n>0,1)==1;
eligible=n>0 & (mutual>=P.surgeTrackingOverlapFraction | (isolated & ...
 containment>=P.surgeTrackingContainmentFraction & ratio<=P.surgeTrackingMaxAreaRatio));
assert(all(sum(eligible,1)<=1)&&all(sum(eligible,2)<=1));
ages=ones(1,numel(B));[a,b]=find(eligible);ages(b)=old(a)+1;
end
