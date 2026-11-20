function PooledTraces = formatPooledTracesForExport(PooledTraces,PooledTraceMice,time)
% Baseline mean excludes onset. Spatial-bin features use additive changes.
% Legacy two-argument callers are supported only for the explicit 1-Hz grid.
if nargin<3,time=-30:60;end
time=double(time(:)');
assert(all(isfinite(time)) && all(diff(time)>0) && any(time<0), ...
    'OxygenDynamics:InvalidTraceTimes','Provide increasing physical sample times with a pre-onset window.');
for g=1:size(PooledTraces,2)
    for m=4:size(PooledTraces,1)
        X=PooledTraces{m,g}; if isempty(X), continue; end
        assert(size(X,2)==numel(time),'OxygenDynamics:TraceTimeMismatch','Trace columns must match the physical time vector.');
        pre=time<0;
        B=mean(X(:,pre),2); % require a complete pre-stimulus baseline
        if ismember(m,[4:6,12:14])
            Y=X-B; method="AdditiveChange";
        else
            Y=(X-B)./B; Y(~isfinite(B)|B<=0,:)=NaN; method="FractionalChange";
        end
        T=array2table(Y,'VariableNames',cellstr(compose('t_%.12g_sec',time)));
        Meta=table(string(PooledTraceMice{m,g}(:)),B,repmat(method,size(X,1),1), ...
            'VariableNames',{'Mouse','BaselineValue','Normalization'});
        PooledTraces{m,g}=[Meta,T];
    end
end
end
