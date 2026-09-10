function [Masks,Fractions,Recipe]=createSurgeMovieRecipe(eligible,pixelSize,n)
validateattributes(eligible,{'logical'},{'2d','nonempty'});
validateattributes(pixelSize,{'numeric'},{'scalar','finite','positive'});
assert(n>=570);[h,w]=size(eligible);radius=85.5/pixelSize;d=round(radius);
[dy,dx]=ndgrid(-ceil(radius):ceil(radius));disk=dx.^2+dy.^2<=radius^2;
coverage=conv2(double(eligible),double(disk),'same')/nnz(disk);
[yy,xx]=ndgrid(1:h,1:w);valid=xx-radius>=1&xx+d+radius<=w&yy-radius>=1&yy+radius<=h;
neighbor=zeros(h,w);neighbor(:,1:w-d)=coverage(:,1+d:w);
valid=valid&coverage>=.95&neighbor>=.95;
distance=(xx-(w+1)/2).^2+(yy-(h+1)/2).^2;distance(~valid)=Inf;
[best,idx]=min(distance(:));assert(isfinite(best),'OxygenDynamics:NoEligibleChallengePosition','No eligible disk pair.');
centers=[xx(idx) yy(idx);xx(idx)+d yy(idx)];Masks=false(h,w,6);
Fractions=zeros(6,n);onsets=[101 201 401 409 501 509];rises=[7 23 7 7 7 7];signs=[1 1 1 1 1 -1];which=[1 1 1 2 1 2];
shapes=["quadratic","gamma","quadratic","quadratic","quadratic","quadratic"];
labels=["isolated_early","isolated_slow","target_positive_neighbor","positive_neighbor","target_negative_neighbor","negative_neighbor"];
for q=1:6
 c=centers(which(q),:);Masks(:,:,q)=(xx-c(1)).^2+(yy-c(2)).^2<=radius^2;
 Fractions(q,:)=.2*signs(q)*surgeUnseenEnvelope(n,onsets(q),rises(q),shapes(q));
end
Recipe=struct('CentersXY',centers,'RadiusUm',85.5,'RadiusPixels',radius,'ComponentCenter',which, ...
 'Onsets',onsets,'RiseScales',rises,'Shapes',shapes,'Signs',signs,'Labels',labels, ...
 'ControlEligibleFractions',[mean(eligible(Masks(:,:,1))) mean(eligible(Masks(:,:,4)))]);
end
