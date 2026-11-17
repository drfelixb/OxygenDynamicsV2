function W=surgeSeparationRecipe(height,width,frame,pixelSize,name)
% Prespecified full-image Gaussian increments; channels are imposed sources.
assert(any(name==["separate_pair","approach_pair","crossing_pair","single_expanding"]));
count=2;if name=="single_expanding",count=1;end
W=zeros(height,width,count);if frame<101||frame>180,return;end
u=(frame-101)/79;envelope=sin(pi*(frame-100)/81)^2;
offset=160;sigma=60;amplitudes=[.20 .16];
if name=="approach_pair",offset=160-100*sin(pi*u)^2;end
if name=="crossing_pair",offset=160*(1-2*u);end
if count==1,offset=0;sigma=40+50*sin(pi*u)^2;end
centers=[round(width/2)-offset/pixelSize round(width/2)+offset/pixelSize];
[y,x]=ndgrid(1:height,1:width);
for k=1:count
 assert(centers(k)-3*sigma/pixelSize>=1&&centers(k)+3*sigma/pixelSize<=width);
 assert(round(height/2)-3*sigma/pixelSize>=1&&round(height/2)+3*sigma/pixelSize<=height);
 d2=((x-centers(k))*pixelSize).^2+((y-round(height/2))*pixelSize).^2;
 W(:,:,k)=amplitudes(k)*envelope*exp(-d2/(2*sigma^2)).*(d2<=(3*sigma)^2);
end
end
