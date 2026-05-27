function Result = runOxygenDynamicsVascularAnalysis(varargin)
%RUNOXYGENDYNAMICSVASCULARANALYSIS Compute ROI-level vascular distances.

setupOxygenDynamicsPath();

Parser = inputParser;
Parser.addParameter('inputCsv','DataPathsExample.csv',@(Value) ischar(Value) || isstring(Value));
Parser.addParameter('masterFolder',pwd,@(Value) ischar(Value) || isstring(Value));
Parser.parse(varargin{:});

InputCsv = char(Parser.Results.inputCsv);
Masterfolder = char(Parser.Results.masterFolder);

InputD = readInputTable(InputCsv);
Paths = table2cell(InputD(:,{'Paths'}));

Result = struct();
Result.InputCsv = InputCsv;
Result.Masterfolder = Masterfolder;
Result.Recordings = repmat(struct('RecordingFolder','','ManualCurationFile','', ...
    'OutputXlsx','','NumObjects',0),numel(Paths),1);

for datai = 1:numel(Paths)
    RecordingFolder = makeFullRecordingPath(Paths{datai},Masterfolder);
    fprintf('Running ROI vascular analysis for %s\n',RecordingFolder);

    [Arteries,Veins] = loadVascularAnnotationMasks(RecordingFolder);
    OxySinksDir = findFilesMatchingName(RecordingFolder,'ManualCurOxySinksData', ...
        'label','manual oxygen-sink output');
    OxySinksDataFile = findFilesMatchingName(OxySinksDir{1},'ManualCuration', ...
        'label','ManualCuration MAT');

    OxySinksData = load(OxySinksDataFile{1});
    Table_OxygenSinks_Out = OxySinksData.Table_OxygenSinks_Out;
    Map = OxySinksData.OxySink_Map;

    CentroidCoordinates = [round(Table_OxygenSinks_Out.MeanCentroid_y), ...
        round(Table_OxygenSinks_Out.MeanCentroid_x)];
    ExportTable = computeVascularDistances(Table_OxygenSinks_Out.OxySink_Pxls_all, ...
        CentroidCoordinates,size(Map),Veins,Arteries);

    matObj = matfile(OxySinksDataFile{1},'Writable',true);
    matObj.Veins_Distance_all = ExportTable.Veins_Distance_all;
    matObj.Veins_Distance_centroid = ExportTable.Veins_Distance_centroid;
    matObj.Arteries_Distance_all = ExportTable.Arteries_Distance_all;
    matObj.Arteries_Distance_centroid = ExportTable.Arteries_Distance_centroid;

    OutputXlsx = fullfile(OxySinksDir{1},'Vascular_Analysis.xlsx');
    writetable(ExportTable,OutputXlsx);

    Result.Recordings(datai).RecordingFolder = RecordingFolder;
    Result.Recordings(datai).ManualCurationFile = OxySinksDataFile{1};
    Result.Recordings(datai).OutputXlsx = OutputXlsx;
    Result.Recordings(datai).NumObjects = height(ExportTable);
end

end
