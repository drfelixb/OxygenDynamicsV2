function out=uniqueStrCell(inputStrCell)
% uniqueStrCell performs unique for mixed string/numeric cell arrays.
out=[];
if nargin<1, disp('Not enough input argument!'); return; end
A=cellfun('isclass', inputStrCell, 'char'); 
B=cellfun(@isnumeric, inputStrCell); 
C=cellfun(@isnan, inputStrCell,'UniformOutput',false);
C=logical(cell2mat(cellfun(@sum, C,'UniformOutput',false)));
D=cellfun(@isempty, inputStrCell);
numCell = cellfun(@num2str,inputStrCell(logical(B-C-D)),'UniformOutput',false);
numCell = unique(numCell);
strCell = unique(inputStrCell(A));
out = [strCell numCell];
end
