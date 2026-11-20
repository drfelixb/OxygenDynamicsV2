function t = readPocketTable(file)
% Preserve text IDs including numeric mouse names and leading zeroes.
opts = detectImportOptions(file,'Delimiter',',','TextType','string','VariableNamingRule','preserve');
ids = intersect(opts.VariableNames,{'Mouse','BatchMouse','Group','Condition','SourceSHA256','SelectionDigest','AuditSHA256','RecordingID','BatchRowID','PocketSet','Alignment','Analysis'});
if ~isempty(ids), opts = setvartype(opts,ids,'string'); end
% Header-only tables contain no type evidence for MATLAB's CSV inference.
numeric = intersect(opts.VariableNames,{'PocketKey','RecordingFrame','FromOnset_s','FromOffset_s', ...
    'PocketPct','NearPct','FarPct','FromNativeOnset_s','FromNativeOffset_s','Start_s','End_s','Seconds', ...
    'SinkID','EventID','StartFrame','EndFrame','NativeStartFrame','NativeEndFrame','SampleF','NFrames'});
if ~isempty(numeric), opts = setvartype(opts,numeric,'double'); end
t = readtable(file,opts);
end
