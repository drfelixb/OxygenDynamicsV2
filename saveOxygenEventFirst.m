function OutputFolder = saveOxygenEventFirst(Result,OutputRoot)
% New schema never impersonates legacy stats tables. UUID folder prevents overwrite.
id=char(Result.RunManifest.AnalysisRunID);
assert(~isempty(regexp(id,'^[a-zA-Z0-9_-]+$','once')),'eventFirst:Output','Run ID must be path-safe for export.');
OutputFolder=fullfile(OutputRoot,'eventFirst',id);
assert(~isfolder(OutputFolder),'eventFirst:Output','Run folder already exists: %s',OutputFolder);
mkdir(OutputFolder);
save(fullfile(OutputFolder,'EventFirstResult.mat'),'Result','-v7.3');
for name={'RecordingQC','Events','RecordingWindowMetrics','BaselineContrasts','TimeSeries'}
    writetable(Result.(name{1}),fullfile(OutputFolder,[name{1} '.csv']));
end
% Ragged geometry remains lossless in MAT; CSV is one pixel per event/frame/row.
fid=fopen(fullfile(OutputFolder,'EventFramePixels.csv'),'w'); cleanup=onCleanup(@()fclose(fid));
fprintf(fid,'EventID,Frame,FullFrameLinearPixelIndex\n');
for j=1:height(Result.EventFrameMasks)
    pixels=Result.EventFrameMasks.PixelIdxList{j};
    id=replace(string(Result.EventFrameMasks.EventID(j)),'"','""');
    for p=pixels(:)', fprintf(fid,'"%s",%d,%d\n',id,Result.EventFrameMasks.Frame(j),p); end
end
S=Result.Sites;
if ismember('Footprint',S.Properties.VariableNames), S.Footprint=[]; end
writetable(S,fullfile(OutputFolder,'Sites.csv'));
end
