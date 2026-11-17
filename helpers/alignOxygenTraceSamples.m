function [X,fs,coverage] = alignOxygenTraceSamples(traces,rates)
% Align frame-held measurements on elapsed time; never infer seconds from row length.
rates=double(rates(:));
assert(numel(rates)==numel(traces) && all(isfinite(rates)&rates>0), ...
    'OxygenDynamics:MissingSampleRate','Every trace needs a positive sampling frequency.');
fs=max(rates); duration=cellfun(@numel,traces)./rates;
if isempty(duration),X=[];coverage=false(0);return;end
t=(0:ceil(max(duration)*fs)-1)/fs; X=nan(numel(traces),numel(t));
coverage=false(size(X));
for i=1:numel(traces)
    ix=floor(t*rates(i)+1e-9)+1; valid=ix<=numel(traces{i}) & t<duration(i);
    X(i,valid)=traces{i}(ix(valid));coverage(i,valid)=true;
end
end
