function report = runDandiReference(nwbFile, outputRoot, runAnalysis)
% Reproducible, unlabelled biological reference; never an accuracy benchmark.
% Uses every frame/pixel without intensity rescaling or added denoising.
if nargin<3, runAnalysis=true; end
setupOxygenDynamicsPath;
assert(~isfolder(outputRoot),'Use a new output folder for each reference run.');
expected='dbdb847b52a501eaf826b191f0affb2bcfc7078c95cddf035aa785e1aac3b23f';
assert(strcmp(oxygenFileSHA256(nwbFile),expected),'Reference NWB checksum mismatch.');
series='/acquisition/1hz_mcor.tif';
info=h5info(nwbFile,[series '/data']);
assert(isequal(info.Dataspace.Size,[600 512 512]),'Unexpected MATLAB HDF5 dimensions.');
rate=h5readatt(nwbFile,[series '/starting_time'],'rate');
assert(rate==1,'Unexpected reference sampling rate.');
mkdir(outputRoot); rec=fullfile(outputRoot,'ID400_awake'); mkdir(rec);
tiffFile=fullfile(rec,'archive_original.tif');
range=[Inf -Inf];
for frame=1:600
    % MATLAB HDF5 axes are [time, spatial1, spatial2] for this exact asset.
    plane=reshape(h5read(nwbFile,[series '/data'],[frame 1 1],[1 512 512]),512,512);
    assert(isa(plane,'uint16'));
    range=[min(range(1),double(min(plane(:)))) max(range(2),double(max(plane(:))))];
    if frame==1
        imwrite(plane,tiffFile,'Compression','none');
    else
        imwrite(plane,tiffFile,'WriteMode','append','Compression','none');
    end
end
% Check every converted sample, not only dimensions or histogram.
for frame=1:600
    plane=reshape(h5read(nwbFile,[series '/data'],[frame 1 1],[1 512 512]),512,512);
    assert(isequal(imread(tiffFile,frame),plane),'TIFF roundtrip changed pixels.');
end
report=struct('Dandiset','000891','Version','0.240215.0831', ...
    'AssetID','8ba82dc1-aaba-411d-a196-ff8ef0b61fc3', ...
    'ArchivePath','sub-ID400/sub-ID400_ses-M400-01-baseline-awake_image.nwb', ...
    'NwbSHA256',expected,'Series',series,'MatlabInputAxes','time,spatial1,spatial2', ...
    'TiffSHA256',oxygenFileSHA256(tiffFile),'Frames',600,'SampleHz',rate, ...
    'PixelSizeUm',4.75,'IntensityRange',range,'PixelRoundtripVerified',true, ...
    'PipelineContract',oxygenPipelineContract(),'MatlabVersion',version, ...
    'LabelsAvailable',false,'Status','converted', ...
    'Limitations','Motion-corrected archive; camera intensity provenance uncertain; one animal, no reviewed labels.');
save(fullfile(outputRoot,'reference-report.mat'),'report');
writeReport(report,outputRoot);
if ~runAnalysis, return; end
C=struct('SFs',rate,'PiSz',4.75,'Mous','ID400','Cond','Awake_immobile', ...
    'Drug','awake','Gen','unspecified','Promo','GFAP.PHP','Puff',NaN,'strOW','Y');
started=tic;
try
    master=runOxygenDynamicsMaster(rec,C);
    assert(master.AnalysisInfo.NFrames==600);
    assert(master.AnalysisInfo.RecordingDurationSec==600);
    Paths={rec};PostureFile=NaN;PupilFile=NaN;PuffsFile=NaN;WhiskingFile=NaN;
    Mouse={'ID400'};Genotype={'unspecified'};Condition={'Awake_immobile'};
    DrugID={'awake'};Promoter={'GFAP.PHP'};SampleF=rate;Pixelsize=4.75;Puff_2use=NaN;
    RecordingID="dandi000891_ID400_awake";
    T=table(Paths,PostureFile,PupilFile,PuffsFile,WhiskingFile,Mouse,Genotype,Condition, ...
        DrugID,Promoter,SampleF,Pixelsize,Puff_2use,RecordingID);
    csv=fullfile(outputRoot,'reference-input.csv');writetable(T,csv);
    stats=runOxygenDynamicsStats(struct('inputCsv',csv,'masterFolder',outputRoot, ...
        'outputRoot',fullfile(outputRoot,'stats'),'interactive',false));
    assert(isfile(stats.DataOutputMat) && isfile(stats.OutputXlsx));
    report.Status='master_and_stats_completed';report.StatsOutput=stats.DataOutputMat;
catch exception
    report.Status='failed';report.Error=getReport(exception,'extended','hyperlinks','off');
    report.ElapsedSeconds=toc(started);writeReport(report,outputRoot);
    save(fullfile(outputRoot,'reference-report.mat'),'report');
    rethrow(exception);
end
report.ElapsedSeconds=toc(started);writeReport(report,outputRoot);
save(fullfile(outputRoot,'reference-report.mat'),'report');
inspectDandiReferenceResults(outputRoot);
end

function writeReport(report,root)
fid=fopen(fullfile(root,'reference-report.json'),'w');assert(fid>=0);
closer=onCleanup(@()fclose(fid));
fprintf(fid,'%s\n',jsonencode(report,'PrettyPrint',true));
end
