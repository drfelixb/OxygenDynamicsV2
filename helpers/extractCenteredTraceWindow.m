function Snip = extractCenteredTraceWindow(Trace,CenterFrame,WindowFrames)
%EXTRACTCENTEREDTRACEWINDOW Extract a fixed trace window with NaN edge padding.

Snip = nan(1,WindowFrames*2+1);
RequestedStart = CenterFrame-WindowFrames;
RequestedEnd = CenterFrame+WindowFrames;
TraceStart = max(1,RequestedStart);
TraceEnd = min(numel(Trace),RequestedEnd);
SnipStart = TraceStart-RequestedStart+1;
SnipEnd = SnipStart+(TraceEnd-TraceStart);

if TraceStart<=TraceEnd
    Snip(SnipStart:SnipEnd) = Trace(TraceStart:TraceEnd);
end

end
