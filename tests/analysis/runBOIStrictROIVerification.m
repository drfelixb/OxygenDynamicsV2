function Report=runBOIStrictROIVerification(OutputRoot)
% Full source -> both signs -> stats -> independent source audit. Synthetic only.
setupOxygenDynamicsPath;
assert(~isfolder(OutputRoot),'Use a fresh evidence folder.');mkdir(OutputRoot);
Report=struct('Schema','boi-strict-roi-verification-1','Status','started','MatlabVersion',version);
started=tic;
try
    if isempty(gcp('nocreate')),parpool('Threads',2);end
    rng(7201);N=240;Mask=false(192);Mask(18:177,18:177)=true;Mask(26:30,26:30)=false;
    X=10000+20*randn(192,192,N);
    for frames={60:74,145:158},X(54:78,54:78,frames{1})=X(54:78,54:78,frames{1})-1500;end
    for frames={75:110,175:214},X(108:162,108:162,frames{1})=X(108:162,108:162,frames{1})+1800;end
    X=uint16(X);Y=reshape(X,[],N);Y(~Mask(:),:)=uint16(30000+12000*randn(nnz(~Mask),N));Y=reshape(Y,size(X));
    context=struct('SFs',1,'PiSz',2.5,'Mous','synthetic','Cond','Unknown','Drug','Unknown', ...
        'Gen','Unknown','Promo','Unknown','Puff',NaN,'strOW','N','BOISupportProfile','craniotomy-roi-1');
    Sources={X,Y,uint16(10000*ones(size(X)))};Labels={'original','exterior-perturbed','constant'};
    Masters=cell(3,1);Saves=cell(3,1);AuditCounts=zeros(3,1);EventCounts=zeros(3,2);Times=zeros(3,1);
    for k=1:3
        rec=fullfile(OutputRoot,Labels{k});mkdir(rec);
        saveastiff(Sources{k},fullfile(rec,'synthetic_original.tif'));
        proposal=fullfile(OutputRoot,[Labels{k} '-proposal']);reviewBOITissueSupport(rec,Mask,proposal);
        decision=struct('DecisionID',['SYNTHETIC-STRICT-' num2str(k)],'Actor','automated synthetic fixture', ...
            'Reason','Verify ROI-restricted processing and exact support transport', ...
            'Evidence','Known synthetic rectangle with a hole; no biological anatomy claim', ...
            'AlignmentEvidence','Logical mask constructed in exact source pixel coordinates');
        writeBOITissueSupport(rec,proposal,decision);
        clock=tic;Masters{k}=runOxygenDynamicsMaster(rec,context);Times(k)=toc(clock);
        I=Masters{k}.AnalysisInfo;validateOxygenPipelineContract(I,struct('SampleF',1,'PixelSize',2.5));
        assert(strcmp(I.PipelineContract.Schema,'3.1-roi-dev'));
        S=dir(fullfile(rec,'OxygenSinks_Output','*Urefined*.mat'));G=dir(fullfile(rec,'OxygenSurges_Output','OxygenSurges*.mat'));
        assert(numel(S)==1&&numel(G)==1);sink=load(fullfile(S.folder,S.name));surge=load(fullfile(G.folder,G.name));
        Saves{k}=struct('sink',sink,'surge',surge,'SinkFile',fullfile(S.folder,S.name),'SurgeFile',fullfile(G.folder,G.name));
        EventCounts(k,:)=[height(sink.Table_OxygenSinkEvents_Out),height(surge.Table_OxygenSurgeEvents_Out)];
        [A,T]=auditOxygenEventAmplitudeSource(rec,'reconstructDetection',true);
        assert(all(A.MeasurementMatches));AuditCounts(k)=height(A);save(fullfile(OutputRoot,[Labels{k} '-audit.mat']),'A','T','I');
    end
    assert(isequaln(Saves{1}.surge.Mean_ROI_TraceZ,Saves{2}.surge.Mean_ROI_TraceZ));
    assert(all(EventCounts(1,:)>0),'Synthetic full workflow must exercise both event signs.');
    assert(isequal(EventCounts(1,:),EventCounts(2,:))&&all(EventCounts(3,:)==0));
    for sign={'sink','surge'}
        if strcmp(sign{1},'sink'),site='Table_OxygenSinks_Out';event='Table_OxygenSinkEvents_Out';else,site='Table_OxygenSurges_Out';event='Table_OxygenSurgeEvents_Out';end
        a=Saves{1}.(sign{1});b=Saves{2}.(sign{1});
        assert(isequaln(a.(site).FramePixels,b.(site).FramePixels));
        E=a.(event);F=b.(event);fields=setdiff(E.Properties.VariableNames,{'RecordingID','Experiment'});
        assert(isequaln(E(:,fields),F(:,fields)),'Exterior perturbation changed final event values.');
    end
    rec=fullfile(OutputRoot,Labels{1});Paths={rec};PostureFile=NaN;PupilFile=NaN;PuffsFile=NaN;WhiskingFile=NaN;
    Mouse={'synthetic'};Genotype={'Unknown'};Condition={'Unknown'};DrugID={'Unknown'};Promoter={'Unknown'};
    SampleF=1;Pixelsize=2.5;Puff_2use=NaN;RecordingID="SYNTHETIC-STRICT-001";
    Input=table(Paths,PostureFile,PupilFile,PuffsFile,WhiskingFile,Mouse,Genotype,Condition,DrugID,Promoter,SampleF,Pixelsize,Puff_2use,RecordingID);
    csv=fullfile(OutputRoot,'input.csv');writetable(Input,csv);
    clock=tic;stats=runOxygenDynamicsStats(struct('inputCsv',csv,'masterFolder',OutputRoot, ...
        'outputRoot',fullfile(OutputRoot,'statistics'),'interactive',false));Report.StatsSeconds=toc(clock);
    D=load(stats.DataOutputMat);assert(strcmp(D.StatsInfo.PipelineContract.Schema,'3.1-roi-dev'));
    assert(strcmp(D.BOIInputContracts{1}.DetectionSupportProfile,'craniotomy-roi-1'));
    assert(strcmp(D.RecordingRegistry.DetectionSupportProfile,'craniotomy-roi-1'));
    guide=fileread(fullfile(fileparts(stats.DataOutputMat),'RecordingInputReview.md'));
    assert(contains(guide,'ROI-restricted candidate')&&contains(guide,'3.1-roi-dev'));
    exported=jsondecode(fileread(fullfile(fileparts(stats.DataOutputMat),'RecordingInputContracts.json')));
    assert(strcmp(exported.PipelineContract.Schema,'3.1-roi-dev'));
    % Independent CSV arithmetic replay of the exported occupied fraction.
    ingredients=readtable(fullfile(fileparts(stats.DataOutputMat),'WindowFrameIngredients.csv'));
    denominator=sum(ingredients.AnalyzedTissueTime_um2_sec);
    assert(denominator==Masters{1}.AnalysisInfo.RecordingAreaUm2*N);
    assert(abs(sum(ingredients.CoveredAreaTime_um2_sec)/denominator-D.RecordingWindowMetrics.MeanOccupiedTissueFraction)<1e-12);
    % A mixed-method registry must fail before aggregation, even when source IDs differ.
    I=Masters{1}.AnalysisInfo;I=rmfield(I,{'BOISupportProfile','DetectionSupportAudit'});I.PipelineContract=oxygenPipelineContract();I.AnalysisSchemaVersion=I.PipelineContract.Schema;
    AnalysisInfo=I;legacy=fullfile(OutputRoot,'legacy-method-info.mat');save(legacy,'AnalysisInfo');
    registry=[D.RecordingRegistry;D.RecordingRegistry];registry.RecordingID(2)="SYNTHETIC-LEGACY";
    recordings=repmat(struct('SinksMatFile',Saves{1}.SinkFile,'SurgesMatFile',Saves{1}.SurgeFile),2,1);
    recordings(2).SinksMatFile=legacy;recordings(2).SurgesMatFile=legacy;
    caught=false;try,buildBOIRecordingInputContracts(registry,recordings);catch err,caught=strcmp(err.identifier,'OxygenDynamics:MixedSupportProfiles');end
    assert(caught,'Mixed methods must be rejected.');
    % Tampered saved weights fail strict validation.
    bad=Masters{1}.AnalysisInfo;bad.DetectionSupportAudit.NeighborWeightMap(40,40)=0;
    caught=false;try,validateOxygenPipelineContract(bad,struct('SampleF',1,'PixelSize',2.5));catch err,caught=strcmp(err.identifier,'OxygenDynamics:ReanalysisRequired');end
    assert(caught,'Mutated smoothing evidence must be rejected.');
    Report.EventCounts=EventCounts;Report.AuditCounts=AuditCounts;Report.MasterSeconds=Times;
    Report.ExteriorIndependence='exact_final_native_pixels_and_event_measurements';
    Report.Containment='all_final_native_pixels_inside_sign_support';Report.StatsMat=stats.DataOutputMat;
    Report.Status='passed_synthetic_implementation_checks';Report.ElapsedSeconds=toc(started);
    save(fullfile(OutputRoot,'results.mat'),'Report','Masters','stats');
catch err
    Report.Status='failed';Report.ErrorID=err.identifier;Report.Error=err.message;Report.ElapsedSeconds=toc(started);
    writeReport(OutputRoot,Report);rethrow(err)
end
writeReport(OutputRoot,Report);
end
function writeReport(folder,Report)
f=fopen(fullfile(folder,'report.json'),'w');assert(f>=0);cleanup=onCleanup(@()fclose(f));fprintf(f,'%s\n',jsonencode(Report,'PrettyPrint',true));
end
