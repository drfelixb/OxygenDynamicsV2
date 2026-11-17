function tests=testBOIBatchSupportDefault
tests=functiontests(localfunctions);
end

function setupOnce(~)
setupOxygenDynamicsPath;
end

function testDefaultAndExplicitSettingsSurviveCSV(t)
root=tempname;
mkdir(root);
cleanup=onCleanup(@()rmdir(root,'s'));
rows=table(["recording-a";"recording-b";"recording-c"], ...
    ["";"whole-image";"craniotomy-roi-1"], ...
    'VariableNames',{'Paths','BOISupportProfile'});
batch=createBOIBatch(rows,root);
batch.Shared.BOISupportProfile='craniotomy-roi-1';
[resolved,origins]=resolveBOIBatch(batch);
verifyEqual(t,resolved.BOISupportProfile,["whole-image";"whole-image";"craniotomy-roi-1"]);
verifyEqual(t,origins.BOISupportProfile,["default";"row";"row"]);
verifyEqual(t,origins.SampleF,repmat("missing",3,1));
verifyEqual(t,origins.Pixelsize,repmat("missing",3,1));

target=fullfile(root,'saved.csv');
saved=writeBOIBatchCSV(batch,target);
reopened=readBOIBatchCSV(target);
verifyEqual(t,reopened.Rows.BatchRowID,saved.Rows.BatchRowID);
verifyEqual(t,reopened.Rows.BOISupportProfile,rows.BOISupportProfile);
verifyFalse(t,reopened.SharedConfirmed);
[resolvedAgain,originsAgain]=resolveBOIBatch(reopened);
verifyEqual(t,resolvedAgain.BOISupportProfile,resolved.BOISupportProfile);
verifyEqual(t,originsAgain,origins);

reopened.SharedConfirmed=true;
[resolvedShared,originsShared]=resolveBOIBatch(reopened);
verifyEqual(t,resolvedShared.BOISupportProfile,["craniotomy-roi-1";"whole-image";"craniotomy-roi-1"]);
verifyEqual(t,originsShared.BOISupportProfile,["shared";"row";"row"]);
end

function testBlankSupportReachesPreparedRequestWithDefaultOrigin(t)
root=tempname;
mkdir(root);
cleanup=onCleanup(@()rmdir(root,'s'));
source=fullfile(root,'source');
mkdir(source);
file=fullfile(source,'raw.tif');
for k=1:30
    frame=uint16(100*ones(48));
    frame(20,20)=90+k;
    if k==1
        imwrite(frame,file);
    else
        imwrite(frame,file,'WriteMode','append');
    end
end
batch=createBOIBatch(table(string(source),"2","4.75", ...
    'VariableNames',{'Paths','SampleF','Pixelsize'}));
[checked,report,requests]=checkBOIBatch(batch);
verifyEqual(t,report.InputStatus,"Ready");
verifyEqual(t,checked.Rows.BOISupportProfile,"");
request=requests{1};
verifyEqual(t,request.Options.SupportProfile,'whole-image');
verifyEqual(t,request.SettingOrigins.SupportProfile,'default');
verifyFalse(t,isfolder(request.Options.OutputFolder));
end
