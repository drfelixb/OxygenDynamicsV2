function Summary=runDandiReferenceSet(profileFile,cacheRoot,outputRoot)
% Run each explicitly selected reference independently, retaining all failures.
setupOxygenDynamicsPath;
% Statistics resolves CSV paths from its own working directory.
% Pin all roots before any stage can change the working directory.
j=java.io.File(char(profileFile));profileFile=char(j.getCanonicalPath());
j=java.io.File(char(cacheRoot));cacheRoot=char(j.getCanonicalPath());
j=java.io.File(char(outputRoot));outputRoot=char(j.getCanonicalPath());
assert(~isfolder(outputRoot),'Use a new output folder for every batch.');
P=jsondecode(fileread(profileFile));mkdir(outputRoot);Summary=table();
copyfile(profileFile,fullfile(outputRoot,'reference-set-profile.json'));
projectRoot=fileparts(fileparts(fileparts(mfilename('fullpath'))));
CodeManifest=createOxygenRegressionCodeManifest(projectRoot);
writetable(CodeManifest,fullfile(outputRoot,'code-manifest.csv'));
save(fullfile(outputRoot,'code-manifest.mat'),'CodeManifest');
for i=1:numel(P.Records)
    R=P.Records(i);folder=fullfile(outputRoot,R.Session);mkdir(folder);
    rec=fullfile(folder,'Recording');mkdir(rec);
    fprintf('\nREFERENCE %d/%d: %s (%s)\n',i,numel(P.Records),R.Session,R.Role);
    report=struct('Dandiset',P.Dandiset,'Version',P.Version,'Profile',R, ...
        'Frames',R.Frames,'SampleHz',R.SampleHz,'PixelSizeUm',R.PixelSize, ...
        'PipelineContract',oxygenPipelineContract(),'MatlabVersion',version, ...
        'LabelsAvailable',false,'Status','running','Stage','conversion');
    qc=struct();started=tic;
    try
        nwb=fullfile(cacheRoot,[R.AssetID '.nwb']);
        report.Conversion=convertDandiReferenceStack(nwb,fullfile(rec,'archive_original.tif'),R);
        report.Stage='master';writeReport(folder,report);
        C=struct('SFs',R.SampleHz,'PiSz',R.PixelSize,'Mous',R.Mouse,'Cond',R.Condition, ...
            'Drug',R.DrugID,'Gen',R.Genotype,'Promo',R.Promoter,'Puff',NaN,'strOW','Y');
        master=runOxygenDynamicsMaster(rec,C);
        assert(master.AnalysisInfo.NFrames==R.Frames);
        assert(master.AnalysisInfo.RecordingDurationSec==R.Frames/R.SampleHz);
        clear master
        report.Stage='statistics';writeReport(folder,report);
        Paths={rec};PostureFile=NaN;PupilFile=NaN;PuffsFile=NaN;WhiskingFile=NaN;
        Mouse={R.Mouse};Genotype={R.Genotype};Condition={R.Condition};DrugID={R.DrugID};Promoter={R.Promoter};
        SampleF=R.SampleHz;Pixelsize=R.PixelSize;Puff_2use=NaN;RecordingID=string(R.AssetID);
        T=table(Paths,PostureFile,PupilFile,PuffsFile,WhiskingFile,Mouse,Genotype,Condition, ...
            DrugID,Promoter,SampleF,Pixelsize,Puff_2use,RecordingID);
        csv=fullfile(folder,'reference-input.csv');writetable(T,csv);
        stats=runOxygenDynamicsStats(struct('inputCsv',csv,'masterFolder',folder, ...
            'outputRoot',fullfile(folder,'stats'),'interactive',false));
        assert(isfile(stats.DataOutputMat)&&isfile(stats.OutputXlsx));
        report.StatsOutput=stats.DataOutputMat;report.Status='master_and_stats_completed';
        report.Stage='numerical_qc';writeReport(folder,report);
        qc=inspectDandiReferenceResults(folder);
        report.Status='passed';report.Stage='complete';
    catch exception
        report.Status='failed';report.ErrorIdentifier=exception.identifier;
        report.Error=getReport(exception,'extended','hyperlinks','off');
        fprintf('REFERENCE FAILED: %s at %s\n%s\n',R.Session,report.Stage,report.Error);
    end
    report.ElapsedSeconds=toc(started);writeReport(folder,report);
    row=table(string(R.Session),string(R.Mouse),string(R.Role),string(R.Condition),string(R.DrugID), ...
        R.PixelSize,R.SampleHz,R.Frames,R.Frames/R.SampleHz,string(report.Status),string(report.Stage), ...
        'VariableNames',{'Session','Mouse','Role','Condition','DrugID','PixelSizeUm','SampleHz','Frames','DurationSec','Status','Stage'});
    for f={'SinkSites','SinkEvents','SinkFiniteAmplitudes','SinkWrongDirectionAmplitudes', ...
            'SurgeSites','SurgeEvents','SurgeFiniteAmplitudes','SurgeWrongDirectionAmplitudes','MeanOccupiedTissueFraction'}
        row.(f{1})=NaN;if isfield(qc,f{1}),row.(f{1})=qc.(f{1});end
    end
    row.ElapsedSeconds=report.ElapsedSeconds;
    Summary=[Summary;row]; %#ok<AGROW>
    writetable(Summary,fullfile(outputRoot,'reference-set-summary.csv'));
    save(fullfile(outputRoot,'reference-set-summary.mat'),'Summary');
    fprintf('REFERENCE RESULT: %s %s (%.1f seconds)\n',R.Session,report.Status,report.ElapsedSeconds);
    close all force
end
disp(Summary);
FinalCodeManifest=createOxygenRegressionCodeManifest(projectRoot);
assert(isequal(CodeManifest(:,{'RelativePath','SHA256'}),FinalCodeManifest(:,{'RelativePath','SHA256'})), ...
    'OxygenDynamics:CodeChangedDuringReference','MATLAB source files changed during the reference run.');
end

function writeReport(folder,report)
save(fullfile(folder,'reference-report.mat'),'report');
fid=fopen(fullfile(folder,'reference-report.json'),'w');assert(fid>=0);
closer=onCleanup(@()fclose(fid));fprintf(fid,'%s\n',jsonencode(report,'PrettyPrint',true));
end
