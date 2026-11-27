function rows=boiPairQueueTable(pairs)
% One CSV row per recording, including the settings displayed before dispatch.
names={'Include','RecordingID','Mode','SensorA','SensorB','PromoterA','PromoterB','SampleHz','PixelSizeUm', ...
    'RawA','RawB','DenoisedA','DenoisedB','Status','Message','ResultFolder','Mouse','Condition','Genotype','DrugID', ...
    'SourceCSV','SourceCSVPath','SourceFolder','CameraOffsetCountsA','CameraOffsetCountsB'};
types=repmat({'string'},size(names)); types{1}='logical'; types(8:9)={'double','double'};
rows=table('Size',[numel(pairs),numel(names)],'VariableTypes',types,'VariableNames',names);
for i=1:numel(pairs)
    o=pairs{i};
    rows(i,:)={o.Include,o.RecordingID,o.Mode,o.Sensors(1),o.Sensors(2),o.Promoters(1),o.Promoters(2), ...
        o.SampleHz,o.PixelSizeUm,o.RawFiles(1),o.RawFiles(2),o.DenoisedFiles(1),o.DenoisedFiles(2), ...
        o.Status,o.Message,o.ResultFolder,o.Mouse,o.Condition,o.Genotype,o.DrugID,o.SourceCSV,o.SourceCSVPath,o.SourceFolder, ...
        string(num2str(boiPairCameraOffset(o,1),17)),string(num2str(boiPairCameraOffset(o,2),17))};
    % An interruption can leave a completed pair between the two queue checkpoints.
    if ismember(rows.Status(i),["Running","Complete"]) && isfile(fullfile(rows.ResultFolder(i),'PairStatus.json'))
        try
            receipt=jsondecode(fileread(fullfile(rows.ResultFolder(i),'PairStatus.json')));
            if strcmp(receipt.Status,'complete')
                saved=loadBOIMultichannel(rows.ResultFolder(i));
                if saved.Options.RecordingID==o.RecordingID && saved.Options.Mode==o.Mode && ...
                        isequal(saved.Options.RawFiles,o.RawFiles) && isequal(saved.Options.Sensors,o.Sensors) && ...
                        isequal(saved.Options.DenoisedFiles,o.DenoisedFiles) && isequal(saved.Options.Promoters,o.Promoters) && ...
                        isequal(boiPairCameraOffset(saved.Options,1),boiPairCameraOffset(o,1)) && ...
                        isequal(boiPairCameraOffset(saved.Options,2),boiPairCameraOffset(o,2)) && ...
                        saved.Options.SampleHz==o.SampleHz && saved.Options.PixelSizeUm==o.PixelSizeUm
                    rows.Status(i)="Complete"; rows.Include(i)=false; rows.Message(i)="";
                else
                    rows.Status(i)="Changed";rows.Message(i)="The saved pair and current calculation settings differ.";
                end
            end
        catch err
            rows.Status(i)="Unverified";rows.Message(i)="Could not verify the previous attempt: "+string(err.message);
        end
    elseif rows.Status(i)=="Complete"
        rows.Status(i)="Unverified";rows.Message(i)="The saved pair completion record is missing.";
    end
end
end
