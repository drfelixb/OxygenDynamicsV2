function T=resolveSinkEventTiming(nativeFrames,trace,trend,tolerance,maxExtensionFrames,leftLimit,rightLimit)
% Refine only the connected negative excursion adjacent to each native edge.
% Limits partition gaps between same-site events; unresolved edges stay native.
trace=double(trace(:)');trend=double(trend(:)');N=numel(trace);
assert(numel(trend)==N && N>0 && isfinite(tolerance)&&tolerance>=0);
assert(isscalar(maxExtensionFrames)&&isfinite(maxExtensionFrames)&&maxExtensionFrames>=0&&maxExtensionFrames==floor(maxExtensionFrames));
nativeFrames=nativeFrames(:)';
assert(~isempty(nativeFrames)&&all(diff(nativeFrames)==1)&&all(nativeFrames==round(nativeFrames)));
a=nativeFrames(1);b=nativeFrames(end);
assert(leftLimit>=1&&leftLimit<=a&&b<=rightLimit&&rightLimit<=N&&all([leftLimit rightLimit]==round([leftLimit rightLimit])));
lo=max(leftLimit,a-maxExtensionFrames);hi=min(rightLimit,b+maxExtensionFrames);
residual=trace-trend;
[first,startStatus]=edge(a,-1,lo,residual,tolerance,N);
[last,endStatus]=edge(b,1,hi,residual,tolerance,N);
T=struct('StartFrame',first,'EndFrame',last,'NativeStartFrame',a,'NativeEndFrame',b, ...
    'TimingSearchStartFrame',lo,'TimingSearchEndFrame',hi, ...
    'StartBoundaryStatus',startStatus,'EndBoundaryStatus',endStatus, ...
    'TimingResolved',startStatus=="return_crossing"&&endStatus=="return_crossing" ...
        &&all(isfinite(residual(a:b))&residual(a:b)<-tolerance), ...
    'NativeTraceCrossesReturnLevel',any(~isfinite(residual(a:b))|residual(a:b)>=-tolerance), ...
    'TimingMaxExtensionFrames',maxExtensionFrames);
end
function [boundary,status]=edge(seed,direction,limit,r,tol,N)
boundary=seed;
if ~isfinite(r(seed)),status="nonfinite_seed";return;end
if r(seed)>=-tol,status="seed_not_below_return_level";return;end
q=seed;
while q~=limit
    next=q+direction;
    if ~isfinite(r(next)),status="nonfinite_search";return;end
    if r(next)>=-tol
        boundary=q;status="return_crossing";return;
    end
    q=next;
end
% A crossing just outside a search limit confirms the boundary at the limit
% without extending the measurement outside that limit.
next=q+direction;
if next>=1&&next<=N&&isfinite(r(next))&&r(next)>=-tol
    boundary=q;status="return_crossing";
elseif next<1||next>N
    status="recording_boundary_unresolved";
elseif ~isfinite(r(next))
    status="nonfinite_search";
else
    status="search_limit_unresolved";
end
end
