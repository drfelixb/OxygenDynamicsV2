function envelope=surgeTracePanelEnvelope(n,start,rise,shape)
% Double-precision mean-trace pulse. First nonzero sample is start.
validateattributes(n,{'numeric'},{'scalar','integer','positive'});
validateattributes(start,{'numeric'},{'scalar','integer','positive','<=',n});
validateattributes(rise,{'numeric'},{'scalar','integer','positive'});
shape=string(shape);assert(isscalar(shape)&&ismember(shape,["linear","sine_squared"]));
j=(1:n)-start+1;envelope=zeros(1,n);up=j>=1&j<=rise;plateau=j>rise&j<=rise+20;
down=j>rise+20&j<=2*rise+20;
envelope(up)=j(up)/rise;envelope(plateau)=1;envelope(down)=1-(j(down)-rise-20)/rise;
if shape=="sine_squared"
 envelope(up)=sin(pi*envelope(up)/2).^2;
 envelope(down)=sin(pi*envelope(down)/2).^2;
end
end
