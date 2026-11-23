function order=boiPairSensorOrder(raw,sensors)
% Return camera indices only if the TIFF names identify both channels uniquely.
order=[];
if any(ismissing(sensors) | sensors=="") || any(raw==""), return; end
[~,stems]=fileparts(raw);
a=find(contains(stems,sensors(1),'IgnoreCase',true));
b=find(contains(stems,sensors(2),'IgnoreCase',true));
if isscalar(a) && isscalar(b) && a~=b, order=[a b]; end
end
