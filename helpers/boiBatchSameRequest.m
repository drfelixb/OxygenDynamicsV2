function same=boiBatchSameRequest(a,b)
%BOIBATCHSAMEREQUEST Compare the existing immutable scientific request fields.
fields={'Schema','Options','Sources','Context','AnalysisParams','InputReview'};
same=isstruct(a)&&isscalar(a)&&isstruct(b)&&isscalar(b)&&all(isfield(a,fields))&&all(isfield(b,fields));
if ~same,return;end
for k=1:numel(fields)
    same=same&&isequaln(a.(fields{k}),b.(fields{k}));
end
end
