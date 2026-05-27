function b = xlscol(a)
% XLSCOL Convert Excel column letters to numbers or vice versa.

base = 26;
if iscell(a)
  b = cellfun(@xlscol, a, 'UniformOutput', false);
elseif ischar(a)
  if contains(a, ':')
    b = cellfun(@xlscol, regexp(a, ':', 'split'));
  else
    b = a(isletter(a));
    if isempty(b)
      b = {[]};
    else
      b = double(upper(b)) - 64;
      n = length(b);
      b = b * base.^((n-1):-1:0)';
    end
  end
elseif isnumeric(a) && numel(a) ~= 1
  b = arrayfun(@xlscol, a, 'UniformOutput', false);
else
  n = ceil(log(a)/log(base));
  d = cumsum(base.^(0:n+1));
  n = find(a >= d, 1, 'last');
  d = d(n:-1:1);
  r = mod(floor((a-d)./base.^(n-1:-1:0)), base) + 1;
  b = char(r+64);
end

if iscell(b) && (iscell([b{:}]) || isnumeric([b{:}]))
  b = [b{:}];
end

end
