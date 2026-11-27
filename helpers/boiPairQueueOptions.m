function o=boiPairQueueOptions(row,output,confirmed)
o=table2struct(row(:,{'RecordingID','Mode','SampleHz','PixelSizeUm','Mouse','Condition','Genotype', ...
    'DrugID','SourceCSV','SourceCSVPath','SourceFolder'}));
source=table2struct(row);
o.CameraOffsetCountsA=boiPairCameraOffset(source,1);
o.CameraOffsetCountsB=boiPairCameraOffset(source,2);
o.Sensors=[row.SensorA row.SensorB]; o.Promoters=[row.PromoterA row.PromoterB];
o.RawFiles=[row.RawA row.RawB]; o.DenoisedFiles=[row.DenoisedA row.DenoisedB];
o.AlignedAndSynchronized=confirmed; o.OutputFolder=output;
end
