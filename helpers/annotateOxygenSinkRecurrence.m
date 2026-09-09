function E=annotateOxygenSinkRecurrence(E,fs,closeGapSec)
% Per-recording native-run proximity; never a physiological event classifier.
assert(isscalar(fs)&&isfinite(fs)&&fs>0&&isscalar(closeGapSec)&&isfinite(closeGapSec)&&closeGapSec>=0);
if ismember('RecordingID',E.Properties.VariableNames)
 assert(numel(unique(E.RecordingID))<=1,'Annotate one recording at a time.');
end
n=height(E);E.PreviousNativeGapSec=nan(n,1);E.NextNativeGapSec=nan(n,1);
E.CloseNativeRun=false(n,1);E.CloseNativeGapThresholdSec=repmat(closeGapSec,n,1);
E.RecurrenceStatus=repmat("no_close_native_neighbor",n,1);
assert(all(isfinite(E.NativeStartFrame)&isfinite(E.NativeEndFrame)&E.NativeStartFrame>=1& ...
 E.NativeEndFrame>=E.NativeStartFrame&E.NativeStartFrame==fix(E.NativeStartFrame)&E.NativeEndFrame==fix(E.NativeEndFrame)));
for s=reshape(unique(E.SinkID),1,[])
 rows=find(E.SinkID==s);[~,order]=sort(E.NativeStartFrame(rows));rows=rows(order);
 if numel(rows)<2,continue;end
 gap=(E.NativeStartFrame(rows(2:end))-E.NativeEndFrame(rows(1:end-1))-1)/fs;
 assert(all(gap>0),'Native runs at one site must have at least one empty frame.');
 E.PreviousNativeGapSec(rows(2:end))=gap;E.NextNativeGapSec(rows(1:end-1))=gap;
 close=gap<closeGapSec;
 E.CloseNativeRun(rows(find(close)))=true; %#ok<FNDSB>
 E.CloseNativeRun(rows(find(close)+1))=true;
end
E.RecurrenceStatus(E.CloseNativeRun)="close_native_runs_review";
end
