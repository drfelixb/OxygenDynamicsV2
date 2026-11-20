function Report=auditSurgeContactLedger(Frames,P,Q,E,C)
% Independent candidate-policy implementation supplies the overlap graph and
% native runs; verify production contacts, exposure and identity joins.
[Runs,Base,A]=compareSurgeBranchPolicy(Frames,P,"isolated_shape");
fields=Base.Properties.VariableNames;assert(isequaln(Q(:,fields),Base));
fields={'FromFrame','ToFrame','PreviousCandidateRunID','NextCandidateRunID','SharedPixels','PreviousPixels','NextPixels', ...
 'MutualCoverage','SmallerRegionCoverage','AreaRatio','PreviousPartnerCount','NextPartnerCount','PrimaryEligible','Linked','Contact'};
assert(isequaln(table2array(E(:,fields)),table2array(A)));
shape=~A.PrimaryEligible & A.PreviousPartners==1 & A.NextPartners==1 & ...
 A.SmallerRegionCoverage>=P.surgeTrackingContainmentFraction & A.AreaRatio<=P.surgeTrackingMaxAreaRatio;
assert(isequal(E.ShapeFallbackEligible,shape));
for side=["Previous","Next"]
 ids=E.(side+"CandidateRunID");
 assert(isequal(E.(side+"KeptAsEvent"),Q.KeptAsEvent(ids)));
 assert(isequaln(E.(side+"SurgeID"),Q.SurgeID(ids))&&isequaln(E.(side+"EventID"),Q.EventID(ids)));
end
assert(isequal(C.KeptAsEvent,Q.KeptAsEvent(C.CandidateRunID)));
assert(isequaln(C.SurgeID,Q.SurgeID(C.CandidateRunID))&&isequaln(C.EventID,Q.EventID(C.CandidateRunID)));
contact=A(A.Contact,:);total=0;
for r=1:height(Q)
 left=contact.PreviousRunID==r;right=contact.NextRunID==r;
 expected=union(contact.FromFrame(left),contact.ToFrame(right));expected=expected(:);actual=C(C.CandidateRunID==r,:);
 assert(isequal(actual.Frame,expected));total=total+numel(expected);
 assert(Q.ContactFrameCount(r)==numel(expected));
 assert(Q.ContactFrames(r)==strjoin(string(expected'),';'));
 assert(Q.ContactDurationSec(r)==numel(expected)/P.fs&&Q.ContactFrameFraction(r)==numel(expected)/Base.DurationFrames(r));
 native=vertcat(Runs{r,:});px=vertcat(Runs{r,expected});fraction=numel(unique(px))/numel(unique(native));
 assert(Q.ContactFrameFootprintFraction(r)==fraction);
 neighbors=unique([contact.PreviousRunID(right);contact.NextRunID(left)]);neighbors(neighbors==r)=[];
 assert(Q.ContactNeighborCandidateRunIDs(r)==strjoin(string(neighbors'),';'));
 assert(Q.ContactWithRejectedCandidate(r)==any(~Base.KeptAsEvent(neighbors)));
 assert(Q.ContactEdgeCount(r)==nnz(left|right)&&Q.LinkedContactEdgeCount(r)==nnz((left|right)&contact.Linked));
 for j=1:height(actual)
  f=actual.Frame(j);incoming=right & contact.ToFrame==f;outgoing=left & contact.FromFrame==f;
  assert(actual.TimeSec(j)==(f-1)/P.fs&&actual.CandidatePixels(j)==numel(Runs{r,f}));
  assert(actual.CandidateAreaUm2(j)==numel(Runs{r,f})*P.PixelSize^2);
  assert(actual.IncomingContactEdges(j)==nnz(incoming)&&actual.OutgoingContactEdges(j)==nnz(outgoing));
  assert(actual.LinkedContactEdges(j)==nnz((incoming|outgoing)&contact.Linked));
 end
end
assert(total==height(C));
Report=struct('CandidateRuns',height(Q),'RetainedEvents',nnz(Q.KeptAsEvent), ...
 'RetainedContactEvents',nnz(Q.KeptAsEvent & Q.ContactFrameCount>0),'AllOverlapEdges',height(E), ...
 'ContactEdges',nnz(E.Contact),'AllCandidateContactFrames',height(C), ...
 'RetainedContactEventFrames',sum(Q.ContactFrameCount(Q.KeptAsEvent)), ...
 'RetainedEventsTouchingRejectedCandidates',nnz(Q.KeptAsEvent & Q.ContactWithRejectedCandidate), ...
 'AllContactGeometryAndExposureVerified',true);
end
