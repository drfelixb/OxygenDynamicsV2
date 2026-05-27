function Trace_PotentialNoise = computeTracePotentialNoise(traceMatrix,correlationThreshold,noiseCorrelationPercentile)
%COMPUTETRACEPOTENTIALNOISE Flag sink traces that correlate with unusually many traces.

Trace_CrossCorrelation = safeCorrMatrix(traceMatrix');
HighCorrelationCount = sum(Trace_CrossCorrelation>correlationThreshold,2);
Trace_PotentialNoise = ~(HighCorrelationCount > prctile(HighCorrelationCount,noiseCorrelationPercentile));

end
