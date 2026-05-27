function R = safeCorrMatrix(X)
%SAFECORRMATRIX Toolbox-free Pearson correlation matrix between columns.

if isempty(X)
    R = [];
    return
end

X = double(X);
NumColumns = size(X,2);

if all(isfinite(X),'all')
    X = X - mean(X,1);
    Denom = sqrt(sum(X.^2,1));
    R = (X' * X) ./ (Denom' * Denom);
    R(Denom==0,:) = NaN;
    R(:,Denom==0) = NaN;
    ValidDiagonal = Denom>0;
    R(sub2ind([NumColumns,NumColumns],find(ValidDiagonal),find(ValidDiagonal))) = 1;
else
    R = NaN(NumColumns,NumColumns);
    for i = 1:NumColumns
        for j = i:NumColumns
            Rij = safePairCorr(X(:,i),X(:,j));
            R(i,j) = Rij;
            R(j,i) = Rij;
        end
    end
end

R = max(min(R,1),-1);

end

function R = safePairCorr(x,y)

FiniteMask = isfinite(x) & isfinite(y);
if nnz(FiniteMask)<2
    R = NaN;
    return
end

x = x(FiniteMask) - mean(x(FiniteMask));
y = y(FiniteMask) - mean(y(FiniteMask));
Denom = sqrt(sum(x.^2) * sum(y.^2));
if Denom==0
    R = NaN;
else
    R = sum(x .* y) / Denom;
end

end
