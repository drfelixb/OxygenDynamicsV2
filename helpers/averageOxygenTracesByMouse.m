function [X,labels] = averageOxygenTracesByMouse(X,labels,mice,coverage)
% Equal mouse weighting after averaging recordings within biological groups.
if nargin<4,coverage=true(size(X));end
keys=table(string(labels(:)),string(mice(:)),'VariableNames',{'Group','Mouse'});
[K,~,ix]=unique(keys,'rows','stable'); Y=nan(height(K),size(X,2));
for i=1:height(K)
    rows=ix==i; missing=any(coverage(rows,:) & ~isfinite(X(rows,:)),1);
    Y(i,:)=mean(X(rows,:),1,'omitnan');Y(i,missing)=NaN;
end
X=Y;labels=K.Group;
end
