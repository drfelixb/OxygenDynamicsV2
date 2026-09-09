function [Runs,Info,Edges]=compareSurgeBranchPolicy(Frames,P,policy)
% TEST-ONLY candidate replay. Never called by production analysis.
% All nonzero adjacent-frame overlaps are retained, including rejected runs.
arguments
 Frames cell
 P struct
 policy (1,1) string {mustBeMember(policy,["isolated_shape","majority_shape","split_only","segment_contacts"])}
end
assert(P.surgeTrackingOverlapFraction>.5);
N=numel(Frames);Runs=cell(0,N);last={};lastIDs=[];ambiguous=false(0,1);
edgeRows=zeros(0,15);
for f=1:N
 current={};
 for k=1:numel(Frames{f})
  px=Frames{f}(k).PixelIdxList;
  if isRemovedRegion(px)||isempty(px),continue;end
  assert(all(isfinite(px(:))&px(:)>=1&px(:)==fix(px(:))));current{end+1}=unique(px(:)); %#ok<AGROW>
 end
 if ~isempty(current)
  px=vertcat(current{:});assert(numel(px)==numel(unique(px)));
  [~,order]=sort(cellfun(@(v)v(1),current));current=current(order);
 end
 counts=zeros(numel(last),numel(current));
 for a=1:numel(last)
  for b=1:numel(current),counts(a,b)=numel(intersect(last{a},current{b}));end
 end
 na=reshape(cellfun(@numel,last),[],1);nb=reshape(cellfun(@numel,current),1,[]);
 mutual=counts./max(na,nb);containment=counts./min(na,nb);ratio=max(na,nb)./min(na,nb);
 overlaps=counts>0;previousPartners=sum(overlaps,2);nextPartners=sum(overlaps,1);
 isolated=previousPartners==1 & nextPartners==1;
 primary=overlaps & mutual>=P.surgeTrackingOverlapFraction;
 geometry=overlaps & containment>=P.surgeTrackingContainmentFraction & ratio<=P.surgeTrackingMaxAreaRatio;
 eligible=primary | (isolated & geometry);
 if policy=="majority_shape",eligible=eligible | (geometry & mutual>.5);end
 if policy=="split_only",eligible=eligible | (geometry & mutual>.5 & nextPartners==1);end
 if policy=="segment_contacts",eligible=eligible & isolated;end
 % Disjoint candidates and strict majority imply unique eligible endpoints.
 assert(all(sum(eligible,1)<=1)&&all(sum(eligible,2)<=1));
 ids=zeros(1,numel(current));[aa,bb]=find(eligible);
 for j=1:numel(aa),ids(bb(j))=lastIDs(aa(j));end
 contact=(previousPartners>1 | nextPartners>1) & overlaps;
 if ~isempty(lastIDs),ambiguous(lastIDs(any(contact,2)))=true;end
 for b=1:numel(current)
  if ids(b)==0,ids(b)=size(Runs,1)+1;Runs(ids(b),1:N)={[]};ambiguous(ids(b),1)=false;end
  Runs{ids(b),f}=current{b};ambiguous(ids(b))=ambiguous(ids(b))||any(contact(:,b));
 end
 [aa,bb]=find(overlaps);
 rows=zeros(numel(aa),15);
 for j=1:numel(aa)
  a=aa(j);b=bb(j);
  rows(j,:)=[f-1 f lastIDs(a) ids(b) counts(a,b) na(a) nb(b) mutual(a,b) containment(a,b) ratio(a,b) ...
   previousPartners(a) nextPartners(b) primary(a,b) eligible(a,b) contact(a,b)];
 end
 edgeRows=[edgeRows;rows]; %#ok<AGROW>
 last=current;lastIDs=ids;
end
first=zeros(size(Runs,1),1);last=first;
for r=1:size(Runs,1)
 t=find(~cellfun(@isempty,Runs(r,:)));assert(all(diff(t)==1));first(r)=t(1);last(r)=t(end);
end
duration=last-first+1;
Info=table((1:size(Runs,1))',first,last,duration,ambiguous,duration>=ceil(P.ThresholMinddur_Surges), ...
 'VariableNames',{'CandidateRunID','NativeStartFrame','NativeEndFrame','DurationFrames','AmbiguousTracking','KeptAsEvent'});
Edges=array2table(edgeRows,'VariableNames',{'FromFrame','ToFrame','PreviousRunID','NextRunID','SharedPixels', ...
 'PreviousPixels','NextPixels','MutualCoverage','SmallerRegionCoverage','AreaRatio','PreviousPartners','NextPartners', ...
 'PrimaryEligible','Linked','Contact'});
for v=["PrimaryEligible","Linked","Contact"],Edges.(v)=logical(Edges.(v));end
% Verify conservation independently of linking decisions, including short runs.
for f=1:N
 expected=[];
 for k=1:numel(Frames{f})
  px=Frames{f}(k).PixelIdxList;if ~isRemovedRegion(px),expected=[expected;px(:)];end %#ok<AGROW>
 end
 actual=vertcat(Runs{:,f});assert(isequal(sort(expected),sort(actual)));
 assert(numel(actual)==numel(unique(actual)));
end
end
