function [e,last]=surgeUnseenEnvelope(n,onset,r,shape)
validateattributes(n,{'numeric'},{'scalar','integer','positive'});
validateattributes(onset,{'numeric'},{'scalar','integer','positive','<=',n});
validateattributes(r,{'numeric'},{'scalar','integer','positive'});
shape=string(shape);j=(1:n)-onset+1;e=zeros(1,n);
if shape=="gamma"
 active=j>0&j<=8*r;u=j(active)/r;e(active)=u.*exp(1-u);last=onset+8*r-1;
elseif shape=="exponential"||shape=="quadratic"
 up=j>0&j<=r;hold=j>r&j<=r+11;e(hold)=1;
 if shape=="exponential"
  e(up)=(1-exp(-3*j(up)/r))/(1-exp(-3));down=j>r+11&j<=r+11+12*r;
  e(down)=exp(-(j(down)-r-11)/(2*r));last=onset+13*r+10;
 else
  e(up)=(j(up)/r).^2;down=j>r+11&j<=3*r+11;e(down)=(1-(j(down)-r-11)/(2*r)).^2;
  last=onset+3*r+10;
 end
else,error('OxygenDynamics:UnknownChallenge','Unknown waveform.');end
end
