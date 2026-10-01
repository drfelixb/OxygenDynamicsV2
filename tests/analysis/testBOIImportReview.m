function tests=testBOIImportReview
tests=functiontests(localfunctions);
end
function setupOnce(~)
setupOxygenDynamicsPath;
end
function testUnknownReviewDoesNotBlockReadableInput(t)
[folder,V,c]=fixture(); %#ok<ASGLU>
R=createBOIImportReview(V,1,2.5);
verifyTrue(t,R.InputCompatible);verifyEqual(t,R.ScientificStatus,'not_established');
verifyTrue(t,any(R.QC.IssueID=="R1-STATIC-TISSUE"));
[rows,details]=buildBOIImportReviewRows({R},"fixture");
verifyEqual(t,rows{1,3},'Readable; review open');verifyEqual(t,rows{1,6},'Not established');
verifyTrue(t,any(contains(string(details{1}),'Affected') | contains(string(details{1}),'Affects:')));
verifyTrue(t,any(contains(string(details{1}),'Action:')));
end
function testConfirmedClockAndSourceIssueAreDisplayed(t)
[folder,V,c]=fixture(); %#ok<ASGLU>
D=declaration(V);D.UniformSamplingConfirmed=true;D.SamplingRateEvidence='Exact external 1 Hz trigger in synthetic fixture';
D.CameraExposureSec=.96;D.ExposureEvidence='Fixture integration duration';
D.SourceClockTimesSec=[4;5.2;6.1;7.3;8.4];D.SourceClockStatus='known_unreliable';
D.SourceClockReference='incorrect embedded clock';D.SourceClockEvidence='fixture acquisition evidence';
D.ReviewIssues=struct('IssueID','SOURCE-IDENTITY','Disposition','review','AffectedMeasurements','Animal comparisons', ...
    'Message','Synthetic folder/header identity conflict','Action','Resolve identity before comparison','Evidence','Fixture ledger entry');
write(folder,D);R=createBOIImportReview(V,1,2.5);
[rows,details]=buildBOIImportReviewRows({R},"fixture");
verifyEqual(t,rows{1,4},'Confirmed uniform: 1 Hz');verifyTrue(t,R.InputCompatible);
verifyTrue(t,any(contains(string(details{1}),'Fixture ledger entry')));
verifyTrue(t,any(contains(string(details{1}),'Camera exposure: 0.96 s')));
verifyTrue(t,all(isnan(R.Acquisition.DeclaredFrameTimesSec)));
verifyEqual(t,R.MetadataSnapshot.RawJSON,fileread(fullfile(folder,'BOIInputMetadata.json')));
end
function testHoldCannotBeReportedReadable(t)
[folder,V,c]=fixture(); %#ok<ASGLU>
D=declaration(V);D.FrameTimesSec=[0;1;2.2;3.2;4.2];D.FrameTimeReference='fixture frame starts';D.TimingEvidence='synthetic irregular input';
write(folder,D);R=createBOIImportReview(V,1,2.5);
verifyFalse(t,R.InputCompatible);verifyEqual(t,R.Status,'held_for_current_uniform_time_pipeline');
rows=buildBOIImportReviewRows({R},"fixture");verifyEqual(t,rows{1,3},'Held: unsupported input');
end
function testMalformedDeclarationRetainsFailureAndFingerprint(t)
[folder,V,c]=fixture(); %#ok<ASGLU>
file=fullfile(folder,'BOIInputMetadata.json');fid=fopen(file,'w');fprintf(fid,'{broken');fclose(fid);
R=createBOIImportReview(V,1,2.5);
verifyFalse(t,R.InputCompatible);verifyEqual(t,R.Status,'import_failure');
verifyEqual(t,R.DeclarationFiles.SHA256,oxygenFileSHA256(file));
verifyTrue(t,any(R.QC.Disposition=="import_failure"));
end
function testUnreadableInputHasActionableIssue(t)
[folder,V,c]=fixture(); %#ok<ASGLU>
V.IsValid=false;V.Errors={'No original TIFF supplied'};
R=createBOIImportReview(V,1,2.5);verifyFalse(t,R.InputCompatible);
verifyEqual(t,R.QC.IssueID,"IMPORT-FILES");verifyNotEmpty(t,R.QC.Action);
end
function testReviewedMaskRetainsActorAndLimits(t)
[folder,V,c]=fixture(); %#ok<ASGLU>
D=struct('Schema','boi-static-tissue-support-1','Modality','BOI','RawSHA256',oxygenFileSHA256(V.RawFile), ...
    'FrameSize',[8 9],'IndexConvention','MATLAB_one_based_column_major_row_column','MaskPixels',[10;11;18], ...
    'ReviewStatus','reviewed_for_static_support','DecisionID','SYNTHETIC-REVIEW','Actor','Synthetic actor', ...
    'Reason','Fixture only','Evidence','Known fixture geometry','AlignmentEvidence','Native fixture coordinates', ...
    'RecordedUTC','2026-09-11T10:00:00Z');
fid=fopen(fullfile(folder,'BOITissueSupport.json'),'w');fprintf(fid,'%s',jsonencode(D));fclose(fid);
R=createBOIImportReview(V,1,2.5);[rows,details]=buildBOIImportReviewRows({R},"fixture");
verifyEqual(t,rows{1,5},'Reviewed mask declared');verifyEqual(t,rows{1,6},'Not established');
verifyTrue(t,any(contains(string(details{1}),'Synthetic actor')));
verifyTrue(t,any(contains(string(details{1}),'Native fixture coordinates')));
end
function testVerificationExportAndGuiSelection(t)
[root,V,c]=fixture(); %#ok<ASGLU>
good=fullfile(root,'good');held=fullfile(root,'held');mkdir(good);mkdir(held);
copyfile(V.RawFile,fullfile(good,'source.tif'));copyfile(V.RawFile,fullfile(held,'source.tif'));
D=declaration(V);D.FrameTimesSec=[0;1;2.2;3.2;4.2];D.FrameTimeReference='fixture starts';D.TimingEvidence='fixture';write(held,D);
Paths={good;held};PostureFile=[NaN;NaN];PupilFile=PostureFile;PuffsFile=PostureFile;
Mouse={'good';'held'};Genotype={'Unknown';'Unknown'};Condition=Genotype;DrugID=Genotype;Promoter=Genotype;
SampleF=[1;1];Pixelsize=[2.5;2.5];input=table(Paths,PostureFile,PupilFile,PuffsFile,Mouse,Genotype,Condition,DrugID,Promoter,SampleF,Pixelsize);
file=fullfile(root,'input.csv');writetable(input,file);
R=runOxygenPipelineVerificationReport('inputCsv',file,'masterFolder',root,'outputRoot','reports');
verifyEqual(t,R.SummaryTable.Status,["Partial";"Blocked"]);
verifyEqual(t,R.SummaryTable.BOIInputCompatible,[true;false]);
verifyTrue(t,isfile(R.OutputFiles.BOIJson));
Q=readtable(R.OutputFiles.Xlsx,'Sheet','BOIInputReview','TextType','string');
verifyTrue(t,any(Q.RecordingIndex==2 & Q.Disposition=="hold_recording"));
saved=load(R.OutputFiles.Mat);verifyEqual(t,saved.VerificationReport.BOIInputIssues,R.BOIInputIssues);
fig=uifigure('Visible','off');closeFig=onCleanup(@()delete(fig));panel=createBOIImportReviewPanel(fig);
panel.Update(R);verifyTrue(t,any(contains(string(panel.Detail.Value),'Recording: good')));
panel.Summary.CellSelectionCallback(panel.Summary,struct('Indices',[2 1]));
verifyTrue(t,any(contains(string(panel.Detail.Value),'Recording: held')));
verifyTrue(t,any(contains(string(panel.Detail.Value),'HOLD RECORDING')));
panel.OpenButton.ButtonPushedFcn(panel.OpenButton,[]);
popup=findall(groot,'Type','figure','Name','BOI input review — saved view');
verifyEqual(t,numel(popup),1);delete(popup);
panel.Update([]);verifyEmpty(t,panel.Summary.Data);
verifyEqual(t,char(panel.OpenButton.Enable),'off');
end
function [folder,V,c]=fixture()
folder=tempname;mkdir(folder);c=onCleanup(@()rmdir(folder,'s'));
saveastiff(uint16(ones(8,9,5)),fullfile(folder,'source.tif'));
V=validateOxygenRecording(folder,1,2.5,false,struct());
end
function D=declaration(V)
D=struct('Schema','boi-acquisition-metadata-1','Modality','BOI','RawSHA256',oxygenFileSHA256(V.RawFile));
end
function write(folder,D)
fid=fopen(fullfile(folder,'BOIInputMetadata.json'),'w');c=onCleanup(@()fclose(fid));fprintf(fid,'%s',jsonencode(D));
end
