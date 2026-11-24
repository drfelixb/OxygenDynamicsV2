function Receipt=exportBOICompactWorkbook(Source,ReviewPaths,OutputFile,Options,ExpectedPlan,BeforeWrite)
%EXPORTBOICOMPACTWORKBOOK Copy completed saved measurements to a new workbook.
% Optional BeforeWrite callback is a harness/host dispatch observer, not a calculator.
if nargin<4,Options=struct();end
if nargin<5,ExpectedPlan=[];end
if nargin<6,BeforeWrite=[];end
[Plan,Prepared]=prepareBOICompactWorkbook(Source,ReviewPaths,OutputFile,Options);
if ~isempty(ExpectedPlan)
    assert(isequaln(Plan,ExpectedPlan),'OxygenDynamics:CompactPlanChanged', ...
        'Saved source, review selection, metadata or destination changed. Preview again.');
end
out=Plan.OutputFile;
stage=makeStage(tempdir);
cleanup=onCleanup(@()cleanupStage(stage));
target=fullfile(stage,'compact.xlsx');
if ~isempty(BeforeWrite),BeforeWrite();end % every dispatch, including a failed write
writeBOICompactWorkbook(target,Prepared.Data,Plan.Sheets);
formatBOICompactWorkbook(target,Prepared.Data,Plan.Sheets);
% Read back source precision and text identity before publishing the new file.
for i=1:numel(Plan.Sheets)
    sheet=Plan.Sheets{i};A=Prepared.Data.(sheet);
    opt=detectImportOptions(target,'Sheet',sheet,'VariableNamingRule','preserve');
    text=A.Properties.VariableNames(varfun(@(x)isstring(x)||iscellstr(x),A,'OutputFormat','uniform'));
    if ~isempty(text),opt=setvartype(opt,intersect(text,opt.VariableNames),'string');end
    B=readtable(target,opt);assert(height(A)==height(B)&&isequal(A.Properties.VariableNames,B.Properties.VariableNames), ...
        'OxygenDynamics:CompactReadback','Workbook shape changed: %s.',sheet);
    for f=string(A.Properties.VariableNames)
        a=A.(f);b=B.(f);
        if isnumeric(a)||islogical(a)
            if ~isnumeric(b)&&~islogical(b),v=lower(string(b));v(v=="false")="0";v(v=="true")="1";b=str2double(v);end
            m=isfinite(a);assert(isequal(isnan(double(a)),isnan(double(b)))&& ...
                all(abs(double(a(m))-double(b(m)))<=1e-10*max(1,abs(double(a(m))))), ...
                'OxygenDynamics:CompactReadback','Numeric readback changed: %s.%s.',sheet,f);
        else
            a=string(a);b=string(b);a(ismissing(a))="";b(ismissing(b))="";
            assert(isequal(a,b),'OxygenDynamics:CompactReadback','Text identity changed: %s.%s.',sheet,f);
        end
    end
end
Receipt=Plan;Receipt.Status='complete';Receipt.Workbook=out;Receipt.WorkbookSHA256=oxygenFileSHA256(target);
Receipt.CreatedUTC=char(datetime('now','TimeZone','UTC','Format',"yyyy-MM-dd'T'HH:mm:ss'Z'"));
Receipt.SoftwareProvenance=table2struct(Prepared.Source.SoftwareProvenance);
Receipt.ImplementationSHA256=oxygenFileSHA256(which('createBOICompactWorkbookData'));
localReceipt=fullfile(stage,'receipt.json');writeBOIRunJSON(localReceipt,Receipt);
publishWorkbook(target,localReceipt,Receipt);
clear cleanup;
end

function publishWorkbook(target,localReceipt,Receipt)
out=Receipt.Workbook;outReceipt=[out '.receipt.json'];parent=fileparts(out);
checkDestination(out,outReceipt);
copyOptions=javaArray('java.nio.file.CopyOption',0);
try
    % Copy only finished files to the chosen volume. Keep incomplete copies
    % away from both final filenames, including on a sync or network drive.
    stage=makeStage(parent);
    cleanup=onCleanup(@()cleanupStage(stage));
    stagedWorkbook=fullfile(stage,'compact.xlsx');
    stagedReceipt=fullfile(stage,'receipt.json');
    java.nio.file.Files.copy(java.io.File(target).toPath(),java.io.File(stagedWorkbook).toPath(),copyOptions);
    java.nio.file.Files.copy(java.io.File(localReceipt).toPath(),java.io.File(stagedReceipt).toPath(),copyOptions);
    assert(strcmp(oxygenFileSHA256(stagedWorkbook),Receipt.WorkbookSHA256), ...
        'OxygenDynamics:CompactCopyChanged','The saved workbook copy did not match the verified workbook.');
catch err
    throwPublishError(parent,err);
end
for i=1:numel(Receipt.SourceFiles)
    assert(strcmp(oxygenFileSHA256(Receipt.SourceFiles(i).Path),Receipt.SourceFiles(i).SHA256), ...
        'OxygenDynamics:CompactSourceChanged','Source changed while writing.');
end
checkDestination(out,outReceipt);
try
    java.nio.file.Files.move(java.io.File(stagedWorkbook).toPath(),java.io.File(out).toPath(),copyOptions);
catch err
    checkDestination(out,outReceipt);
    throwPublishError(parent,err);
end
try
    java.nio.file.Files.move(java.io.File(stagedReceipt).toPath(),java.io.File(outReceipt).toPath(),copyOptions);
catch err
    % Keep the verified new workbook. The completion receipt was not published.
    failure=MException('OxygenDynamics:CompactReceipt', ...
        'The workbook was saved, but its export receipt could not be saved. Choose a new filename in a local folder to retry.\n\n%s',out);
    throw(addCause(failure,err));
end
clear cleanup;
end

function checkDestination(out,outReceipt)
assert(~isfile(out)&&~isfolder(out)&&~isfile(outReceipt)&&~isfolder(outReceipt), ...
    'OxygenDynamics:CompactDestination','The destination appeared during export. Choose a new workbook filename.');
end

function throwPublishError(folder,err)
failure=MException('OxygenDynamics:CompactPublish', ...
    'The verified workbook could not be saved to the chosen folder. Use Choose location to select a local folder, such as Downloads, then preview and export again.\n\n%s',folder);
throw(addCause(failure,err));
end

function stage=makeStage(parent)
attributes=javaArray('java.nio.file.attribute.FileAttribute',0);
path=java.nio.file.Files.createTempDirectory(java.io.File(parent).toPath(),'boi-compact-',attributes);
stage=char(path.toString());
end

function cleanupStage(p)
if isfolder(p)
    [ok,msg]=rmdir(p,'s');
    if ~ok,warning('OxygenDynamics:CompactCleanup','Could not remove temporary export folder %s. %s',p,msg);end
end
end
