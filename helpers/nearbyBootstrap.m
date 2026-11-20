function ci=nearbyBootstrap(values,sizes)
% Percentile interval for an equal-mouse mean; fixed PCG64(42771) resamples.
% Keep complete mouse rows and resample within each sensor group.
persistent cache
if isempty(cache),cache=containers.Map('KeyType','char','ValueType','any');end
key=sprintf('%d,',sizes);
if ~isKey(cache,key),cache(key)=makeWeights(sizes,20000);end
draw=sort(double(cache(key))*values(:)/numel(values));
loc=1+(numel(draw)-1)*[.025 .975];
ci=draw(floor(loc))'.*(1-mod(loc,1))+draw(ceil(loc))'.*mod(loc,1);
end

function W=makeWeights(sizes,nDraw)
% Integers use multiply-high with rejection, filled in row-major draw order.
needed=sum(sizes(sizes>1))*nDraw;
pool=pcgWords(needed+64);cursor=1;col=0;
W=zeros(nDraw,sum(sizes),'uint16');
for n=sizes(:)'
    if n==1
        W(:,col+1)=1;
    else
        count=nDraw*n;left=count;samples=zeros(count,1);
        while left>0
            if cursor+left-1>numel(pool),pool=pcgWords(cursor+left+64);end
            product=pool(cursor:cursor+left-1)*n;cursor=cursor+left;
            ok=mod(product,2^32)>=mod(2^32,n);
            ids=floor(product(ok)/2^32)+1;
            samples(count-left+(1:numel(ids)))=ids;left=left-numel(ids);
        end
        W(:,col+(1:n))=uint16(full(sparse(repelem((1:nDraw)',n),samples,1,nDraw,n)));
    end
    col=col+n;
end
end

function words=pcgWords(count)
% PCG XSL-RR 128/64. The initial state and stream are the PCG64 state
% initialized by SeedSequence(42771). 16-bit limbs keep products exact.
state=[44047 42219 49364 29941 54153 54222 11062 30108];
mult=[63045 40908 57188 17285 23972 8134 60677 9056];
inc=[35201 3263 3534 41377 39450 54182 36964 31249];
n=ceil(count/2); k=1;
% Double the covered interval by applying one affine jump to each known state.
while k<=n
    advance=min(k,n+1-k);
    state=[state; affine(state(1:advance,:),mult,inc)]; %#ok<AGROW>
    inc=affine(inc,mult,inc);mult=affine(mult,mult,zeros(1,8));k=k*2;
end
state=state(2:end,:); parts=bitxor(uint64(state(:,1:4)),uint64(state(:,5:8)));
x=parts(:,1);
for i=2:4,x=bitor(x,bitshift(parts(:,i),16*(i-1)));end
rotation=floor(state(:,8)/1024);
x=bitor(bitshift(x,-rotation),bitshift(x,64-rotation));
words=reshape([double(bitand(x,uint64(4294967295))),double(bitshift(x,-32))]',[],1);
end

function y=affine(x,m,c)
y=zeros(size(x));carry=zeros(size(x,1),1);
for j=1:8
    z=carry+c(j);
    for k=1:j,z=z+x(:,k)*m(j+1-k);end
    y(:,j)=mod(z,65536);carry=floor(z/65536);
end
end
