function Report = runOxygenEventFirstBatch(Recordings,C,OutputRoot)
% Explicit Recording structs (cell array); every failure and valid zero is retained.
if isstruct(Recordings), Recordings=num2cell(Recordings); end
rows=struct('RecordingID',{},'MouseID',{},'Detector',{},'Status',{},'Error',{},'OutputFolder',{});
Report.Results=cell(size(Recordings));
ids=cellfun(@(r)string(r.RecordingID),Recordings);
assert(numel(unique(ids))==numel(ids),'eventFirst:Identity','RecordingID must be unique within a batch.');
for k=1:numel(Recordings)
    R=Recordings{k}; status="failed"; message=""; folder="";
    try
        result=runOxygenEventFirst(R,C); folder=string(saveOxygenEventFirst(result,fullfile(OutputRoot,sprintf('recording-%04d',k))));
        Report.Results{k}=result; status=result.RecordingQC.Status;
    catch ME, message=string(ME.identifier)+": "+string(ME.message);
    end
    rows(end+1)=struct('RecordingID',string(R.RecordingID),'MouseID',string(R.MouseID),'Detector',"eventFirst", ...
        'Status',status,'Error',message,'OutputFolder',folder); %#ok<AGROW>
end
Report.RecordingQC=struct2table(rows);
if ~isfolder(OutputRoot), mkdir(OutputRoot); end
writetable(Report.RecordingQC,fullfile(OutputRoot,'BatchRecordingQC.csv'));
save(fullfile(OutputRoot,'BatchReport.mat'),'Report','-v7.3');
end
