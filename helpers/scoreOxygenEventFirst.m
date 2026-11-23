function [Score,QC,Diagnostics] = scoreOxygenEventFirst(D,Valid,R,C)
% Each scale gets its own residual SD. No temporal difference independence assumption.
[h,w,n]=size(D); Score=zeros(h,w,n,'single');
QC=struct('InvalidNoisePixels',zeros(numel(C.SpatialScalesUm),1), ...
    'ExcludedFraction',zeros(numel(C.SpatialScalesUm),1),'NoiseIntensityCorrelation',zeros(numel(C.SpatialScalesUm),1));
Diagnostics=cell(numel(C.SpatialScalesUm),1);
win=max(3,2*floor(C.BaselineWindowSec*R.fs/2)+1);
pad=ceil(C.RecoveryPaddingSec*R.fs);
for s=1:numel(C.SpatialScalesUm)
    sigma=C.SpatialScalesUm(s);
    if C.Verbose, fprintf('eventFirst: spatial scale %g um\n',sigma); end
    F=D; F(~Valid)=NaN;
    if sigma>0
        assert(all(isfinite(R.PixelSizeUm)),'eventFirst:Calibration','Positive physical scales require known pixel size; use scale 0 in pixel-only mode.');
        for t=1:n
            v=Valid(:,:,t); z=D(:,:,t); z(~v)=0;
            den=imgaussfilt(double(v),sigma./R.PixelSizeUm,'Padding','replicate');
            z=imgaussfilt(z,sigma./R.PixelSizeUm,'Padding','replicate')./den;
            z(~v|den<0.5)=NaN; F(:,:,t)=z;
        end
    end
    X=reshape(F,h*w,n); V=isfinite(X); Z=nan(size(X),'single');
    noiseMap=nan(h*w,1); level=nan(h*w,1); excluded=0; validCount=0;
    % Tile independent pixel traces to bound moving-median working memory.
    for lo=1:2048:h*w
        ix=lo:min(h*w,lo+2047); x=X(ix,:); good=V(ix,:); clean=x;
        b=movmedian(clean,win,2,'omitnan','Endpoints','shrink');
        for it=1:C.BaselineIterations
            residual=x-b;
            noise=1.4826*median(abs(residual-median(residual,2,'omitnan')),2,'omitnan');
            bad=abs(residual)>C.GrowSD.*max(noise,C.MinNoiseSD);
            if pad>0, bad=movmax(bad,[pad pad],2)>0; end
            clean=x; clean(bad)=NaN;
            b=movmedian(clean,win,2,'omitnan','Endpoints','shrink');
        end
        residual=x-b; residual(bad)=NaN;
        noise=1.4826*median(abs(residual-median(residual,2,'omitnan')),2,'omitnan');
        noise(sum(isfinite(residual),2)<C.MinBaselineSamples)=NaN;
        noiseMap(ix)=noise; level(ix)=median(x,2,'omitnan');
        Z(ix,:)=single(x-b); excluded=excluded+nnz(bad&good); validCount=validCount+nnz(good);
    end
    finite=isfinite(noiseMap)&noiseMap>C.MinNoiseSD & isfinite(level);
    if nnz(finite)>2
        a=corrcoef(level(finite),noiseMap(finite).^2); QC.NoiseIntensityCorrelation(s)=a(1,2);
    else, QC.NoiseIntensityCorrelation(s)=NaN; end
    if string(C.NoiseMethod)=="intensityBinnedMAD"
        assert(nnz(finite)>=100,'eventFirst:Noise','Intensity-binned noise needs at least 100 estimable pixels.');
        edges=quantile(level(finite),linspace(0,1,6));
        for j=1:5
            ids=finite & level>=edges(j)&level<=edges(j+1);
            if nnz(ids)>=10, noiseMap(ids)=median(noiseMap(ids)); end
        end
    end
    noiseMap(~finite)=NaN; Z=Z./single(noiseMap);
    Z=reshape(Z,h,w,n); Z(~Valid | ~isfinite(Z))=0;
    % Maximum absolute evidence wins, ties prefer earlier (smaller) scale.
    take=abs(Z)>abs(Score); Score(take)=Z(take);
    QC.InvalidNoisePixels(s)=nnz(~finite); QC.ExcludedFraction(s)=excluded/max(1,validCount);
    if C.SaveDiagnostics, Diagnostics{s}=struct('NoiseSD',reshape(noiseMap,h,w),'Score',Z); end
end
QC.BaselineUnidentified=any(QC.ExcludedFraction>C.MaxExcludedFraction) || n/R.fs<C.BaselineWindowSec;
QC.NoiseAssumption="event-free residual MAD after each spatial filter; autocorrelation and threshold search require empirical null validation";
end
