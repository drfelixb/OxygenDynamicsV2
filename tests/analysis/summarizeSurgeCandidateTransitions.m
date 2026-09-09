function T=summarizeSurgeCandidateTransitions(Runs,truth,P)
% Independent geometric explanation of every relevant adjacent candidate edge.
% Runs include rejected candidates. Candidate IDs are row numbers, not events.
T=table('Size',[0 17],'VariableTypes',[repmat({'double'},1,13) repmat({'logical'},1,3) {'string'}], ...
 'VariableNames',{'FromFrame','ToFrame','PreviousCandidateRunID','NextCandidateRunID','PreviousAreaUm2','NextAreaUm2', ...
 'MutualCoverage','SmallerRegionCoverage','AreaRatio','PreviousOverlapPartners','NextOverlapPartners', ...
 'PreviousTruthPixels','NextTruthPixels','PrimaryEligible','FallbackEligible','ActualLinked','Reason'});
for t=2:size(Runs,2)
 if isempty(truth{t-1})&&isempty(truth{t}),continue;end
 aa=find(~cellfun(@isempty,Runs(:,t-1)));bb=find(~cellfun(@isempty,Runs(:,t)));
 overlap=zeros(numel(aa),numel(bb));ha=zeros(size(aa));hb=zeros(size(bb));
 for a=1:numel(aa)
  ha(a)=numel(intersect(Runs{aa(a),t-1},truth{t-1}));
  for b=1:numel(bb),overlap(a,b)=numel(intersect(Runs{aa(a),t-1},Runs{bb(b),t}));end
 end
 for b=1:numel(bb),hb(b)=numel(intersect(Runs{bb(b),t},truth{t}));end
 for a=1:numel(aa)
  for b=1:numel(bb)
   n=overlap(a,b);if n==0||(ha(a)==0&&hb(b)==0),continue;end
   na=numel(Runs{aa(a),t-1});nb=numel(Runs{bb(b),t});mutual=n/max(na,nb);coverage=n/min(na,nb);ratio=max(na,nb)/min(na,nb);
   pa=nnz(overlap(a,:));pb=nnz(overlap(:,b));primary=mutual>=P.surgeTrackingOverlapFraction;
   fallback=~primary&&coverage>=P.surgeTrackingContainmentFraction&&ratio<=P.surgeTrackingMaxAreaRatio&&pa==1&&pb==1;
   linked=aa(a)==bb(b);assert(linked==(primary||fallback),'Default unique-link oracle disagrees with tracker.');
   if primary
    reason="primary_link";
   elseif fallback
    reason="isolated_shape_link";
   elseif coverage<P.surgeTrackingContainmentFraction
    reason="insufficient_containment";
   elseif ratio>P.surgeTrackingMaxAreaRatio
    reason="excessive_area_change";
   else
    reason="competing_overlap_blocks_fallback";
   end
   T(end+1,:)={t-1,t,aa(a),bb(b),na*P.PixelSize^2,nb*P.PixelSize^2,mutual,coverage,ratio,pa,pb,ha(a),hb(b),primary,fallback,linked,reason}; %#ok<AGROW>
  end
  if ha(a)>0&&~any(overlap(a,:))
   T(end+1,:)={t-1,t,aa(a),NaN,numel(Runs{aa(a),t-1})*P.PixelSize^2,NaN,0,0,NaN,0,NaN,ha(a),0,false,false,false,"no_overlapping_successor"}; %#ok<AGROW>
  end
 end
 for b=1:numel(bb)
  if hb(b)>0&&~any(overlap(:,b))
   T(end+1,:)={t-1,t,NaN,bb(b),NaN,numel(Runs{bb(b),t})*P.PixelSize^2,0,0,NaN,NaN,0,0,hb(b),false,false,false,"no_overlapping_predecessor"}; %#ok<AGROW>
  end
 end
end
end
