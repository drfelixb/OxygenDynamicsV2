function A=runSourceAmplitudeRecheck(referenceRoot,session,outputRoot)
% Reanalyze one unchanged source under the current contract, then audit both signs.
setupOxygenDynamicsPath;assert(~isfolder(outputRoot));mkdir(outputRoot);
R=jsondecode(fileread(fullfile(referenceRoot,session,'reference-report.json')));P=R.Profile;
source=fullfile(referenceRoot,session,'Recording','archive_original.tif');
assert(strcmp(oxygenFileSHA256(source),R.Conversion.TiffSHA256));
rec=fullfile(outputRoot,'Recording');mkdir(rec);copyfile(source,fullfile(rec,'archive_original.tif'));
C=struct('SFs',P.SampleHz,'PiSz',P.PixelSize,'Mous',P.Mouse,'Cond',P.Condition, ...
 'Drug',P.DrugID,'Gen',P.Genotype,'Promo',P.Promoter,'Puff',NaN,'strOW','Y');
runOxygenDynamicsMaster(rec,C);
A=auditOxygenEventAmplitudeSource(rec);assert(all(A.MeasurementMatches));
writetable(A,fullfile(outputRoot,'independent-amplitude-audit.csv'));
f=dir(fullfile(rec,'OxygenSinks_Output','*Urefined*.mat'));S=load(fullfile(f.folder,f.name));
f=dir(fullfile(rec,'OxygenSurges_Output','*.mat'));G=load(fullfile(f.folder,f.name));
Q=createOxygenMeasurementQC(table(string(S.AnalysisInfo.RecordingID),'VariableNames',{'RecordingID'}), ...
 S.Table_OxygenSinkEvents_Out,G.Table_OxygenSurgeEvents_Out);
writetable(Q,fullfile(outputRoot,'measurement-qc.csv'));
report=struct('SourceProfile',P,'SourceSHA256',R.Conversion.TiffSHA256,'PipelineContract',oxygenPipelineContract(), ...
 'EventsAudited',height(A),'MeasurementMismatches',sum(~A.MeasurementMatches));
f=fopen(fullfile(outputRoot,'source-audit-report.json'),'w');assert(f>=0);fprintf(f,'%s\n',jsonencode(report,'PrettyPrint',true));fclose(f);
writetable(createOxygenRegressionCodeManifest(),fullfile(outputRoot,'code-manifest.csv'));disp(Q);
end
