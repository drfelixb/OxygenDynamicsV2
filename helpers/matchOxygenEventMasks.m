function Report = matchOxygenEventMasks(Truth,Detected,MinIoU)
% Deterministic descending spatiotemporal IoU greedy one-to-one matching.
% Explicitly reports rule; not an optimal assignment. Signs must match.
A=Truth.Events; B=Detected.Events; scores=zeros(height(A),height(B));
for i=1:height(A)
    for j=1:height(B)
        if string(A.EventType(i))~=string(B.EventType(j)), continue; end
        a=Truth.EventFrameMasks(string(Truth.EventFrameMasks.EventID)==string(A.EventID(i)),:);
        b=Detected.EventFrameMasks(string(Detected.EventFrameMasks.EventID)==string(B.EventID(j)),:);
        intersection=0; na=sum(cellfun(@numel,a.PixelIdxList)); nb=sum(cellfun(@numel,b.PixelIdxList));
        for t=intersect(a.Frame,b.Frame)'
            pa=a.PixelIdxList{find(a.Frame==t,1)}; pb=b.PixelIdxList{find(b.Frame==t,1)};
            intersection=intersection+numel(intersect(pa,pb));
        end
        if na+nb>0, scores(i,j)=intersection/(na+nb-intersection); end
    end
end
[ii,jj]=find(scores>=MinIoU); val=scores(sub2ind(size(scores),ii,jj));
[~,order]=sortrows([-val(:) ii(:) jj(:)],[1 2 3]); usedA=false(height(A),1); usedB=false(height(B),1);
rows=struct('ReferenceEventID',{},'DetectedEventID',{},'SpatiotemporalIoU',{},'OnsetErrorSec',{},'OffsetErrorSec',{},'PeakRelativeBLIError',{},'MeanAreaUm2Error',{},'ObservedDurationSecError',{});
for q=order'
    i=ii(q); j=jj(q); if usedA(i)||usedB(j), continue; end
    usedA(i)=true; usedB(j)=true;
    r=struct('ReferenceEventID',string(A.EventID(i)),'DetectedEventID',string(B.EventID(j)), ...
        'SpatiotemporalIoU',val(q),'OnsetErrorSec',B.IntervalStartSec(j)-A.IntervalStartSec(i), ...
        'OffsetErrorSec',B.IntervalEndSec(j)-A.IntervalEndSec(i),'PeakRelativeBLIError',NaN,'MeanAreaUm2Error',NaN,'ObservedDurationSecError',NaN);
    for name={'PeakRelativeBLI','MeanAreaUm2','ObservedDurationSec'}
        if ismember(name{1},A.Properties.VariableNames)&&ismember(name{1},B.Properties.VariableNames)
            r.([name{1} 'Error'])=B.(name{1})(j)-A.(name{1})(i);
        end
    end
    rows(end+1)=r; %#ok<AGROW>
end
Report=struct('Matches',struct2table(rows),'TruePositives',nnz(usedA),'FalsePositives',nnz(~usedB),'FalseNegatives',nnz(~usedA), ...
    'SplitCandidates',nnz(sum(scores>=MinIoU,2)>1),'MergeCandidates',nnz(sum(scores>=MinIoU,1)>1), ...
    'MinIoU',MinIoU,'MatchingRule',"descending 3D voxel IoU greedy; signs match; deterministic row-order tie break");
Report.Precision=NaN; Report.Recall=NaN;
if height(B)>0, Report.Precision=nnz(usedB)/height(B); end
if height(A)>0, Report.Recall=nnz(usedA)/height(A); end
end
