function S=loadBOICompactWorkbookSources(Source,ReviewPaths,Options)
%LOADBOICOMPACTWORKBOOKSOURCES Read small saved tables only. Never calculate.
if nargin<2,ReviewPaths={};end
if nargin<3,Options=struct();end
S=readAutomatic(Source);S.Reviews={};S.Metadata=table();S.Phases=table();
if isfield(Options,'Metadata'),S.Metadata=Options.Metadata;end
if isfield(Options,'Phases'),S.Phases=Options.Phases;end
if ischar(ReviewPaths)||isstring(ReviewPaths),ReviewPaths=cellstr(string(ReviewPaths));end
claimed=strings(0,1);reviewBindings={};
for k=1:numel(ReviewPaths)
    value=ReviewPaths{k};
    if isstruct(value)
        R=value;reviewBindings{end+1}=boiCompactWorkbookDigest(R);assert(isfield(R,'Receipt'),'OxygenDynamics:CompactReview','A completed saved receipt is required.');
    else
        p=char(string(value));if isfolder(p),p=fullfile(p,'ReviewedHypoxicBurden.mat');end
        R=smallMAT(p,{'HypoxicBurden','Receipt'});R.Path=p;
        S.Files=addFile(S.Files,p);
        receiptPath=fullfile(fileparts(p),'ReviewedBurdenStatus.json');
        assert(isfile(receiptPath),'OxygenDynamics:CompactReview','Completed reviewed status receipt is missing.');
        status=jsondecode(fileread(receiptPath));assert(strcmp(status.Status,'complete'),'OxygenDynamics:CompactReview','Reviewed export is incomplete.');
        S.Files=addFile(S.Files,receiptPath);
        reviewBindings{end+1}=struct('MAT',S.Files(end-1),'Status',S.Files(end));
    end
    assert(strcmp(string(R.Receipt.Status),'complete')&&isfield(R,'HypoxicBurden'), ...
        'OxygenDynamics:CompactReview','Select a completed reviewed export, not an individual draft.');
    assert(strcmp(string(R.Receipt.SourceStatsSHA256),S.AutomaticSHA256), ...
        'OxygenDynamics:CompactParent','Reviewed export belongs to a different automatic source.');
    B=R.HypoxicBurden;
    ap=policyVersion(S.Tables,'Burden_SelectionPolicy');rp=policyVersion(B,'SelectionPolicy');
    assert(strlength(ap)==0||strlength(rp)==0||ap==rp,'OxygenDynamics:CompactParent','Reviewed and automatic selection policies conflict.');
    assert(isfield(B,'RecordingTable')&&istable(B.RecordingTable), ...
        'OxygenDynamics:CompactReview','Reviewed recording inventory is missing.');
    ids=string(B.RecordingTable.RecordingID);
    assert(numel(unique(ids))==numel(ids)&&~any(ismember(ids,claimed))&&all(ismember(ids,string(S.Registry.RecordingID))), ...
        'OxygenDynamics:CompactConflict','Overlapping or foreign reviewed recording snapshots. Select one completed revision per recording.');
    claimed=[claimed;ids];S.Reviews{end+1}=R; %#ok<AGROW>
end
S.SourceDigest=boiCompactWorkbookDigest(struct('Method','boi-compact-source-binding-2', ...
    'Automatic',S.AutomaticSHA256,'Files',S.Files,'Reviews',{reviewBindings},'Metadata',S.Metadata,'Phases',S.Phases));
end
function S=readAutomatic(Source)
S=struct('Tables',struct(),'Registry',table(),'Files',struct('Path',{},'SHA256',{}),'AutomaticSHA256','');
if isstruct(Source)&&isfield(Source,'Tables')
    S.Tables=Source.Tables;S.Registry=Source.Registry;
    S.AutomaticSHA256=boiCompactWorkbookDigest(struct('Tables',S.Tables,'Registry',S.Registry));
else
    if ischar(Source)||isstring(Source)
        [~,~,ext]=fileparts(char(Source));
        if strcmpi(ext,'.xlsx'),Source=struct('Workbook',char(Source));else,Source=struct('DataOutput',char(Source));end
    end
    assert(isstruct(Source),'OxygenDynamics:CompactSource','Supply a saved automatic MAT/workbook source.');
    mat='';book='';
    if isfield(Source,'DataOutput'),mat=char(Source.DataOutput);end
    if isfield(Source,'Workbook'),book=char(Source.Workbook);end
    if isempty(book)&&~isempty(mat)
        % Native sibling filename is supplied by the caller where not standard.
        candidate=fullfile(fileparts(mat),'DataOutput.xlsx');if isfile(candidate),book=candidate;end
    end
    sheets={};
    if ~isempty(book)
        assert(isfile(book),'OxygenDynamics:CompactSource','Automatic workbook is missing.');
        sheets=cellstr(sheetnames(book));
    end
    if ~isempty(mat)
        assert(isfile(mat),'OxygenDynamics:CompactSource','Automatic MAT is missing.');
        workbookSubstitutions={};
        % The completed batch handoff supplies a receipt-validated pair.
        % Keep all other bounded MAT values and the MAT's review binding.
        if isfield(Source,'UseWorkbookBurdenTables')&&isequal(Source.UseWorkbookBurdenTables,true)
            pairs=burdenSheetPairs();
            if all(ismember(pairs(:,2),sheets)),workbookSubstitutions={'HypoxicBurden'};end
        end
        S.Files=addFile(S.Files,mat);S.AutomaticSHA256=S.Files(end).SHA256;
        M=smallMAT(mat,{'RecordingRegistry','HypoxicBurden','StatsInfo','RecordingWindowMetrics', ...
            'SurgeRecordingWindowMetrics','WindowFrameIngredients','SurgeWindowFrameIngredients','EventMeasurementQC','EventBaselineStatusCounts', ...
            'NumOngoingOxysinks','NumOngoingOxysinksPerMm2','NumOngoingOxysurges'},workbookSubstitutions);
        if isfield(M,'RecordingRegistry'),S.Registry=M.RecordingRegistry;end
        names=fieldnames(M);for i=1:numel(names)
            if istable(M.(names{i}))||startsWith(names{i},'NumOngoing'),S.Tables.(names{i})=M.(names{i});end
        end
        if isfield(M,'HypoxicBurden'),S.Tables=burdenTables(S.Tables,M.HypoxicBurden);end
    end
    if ~isempty(book)
        S.Files=addFile(S.Files,book);if isempty(S.AutomaticSHA256),S.AutomaticSHA256=S.Files(end).SHA256;end
        allowed={'RecordingRegistry','OxySinkEvents','OxySurgeEvents','HypoxicBurden_EventBased','HypoxicBurden_ByRecording', ...
            'HypoxicBurden_TimeSeries','HypoxicBurden_Basis','HypoxicBurden_ReferencePolicy','Burden_PreEpisodePolicy','Burden_SelectionPolicy', ...
            'RecordingWindowMetrics','SurgeRecordingWindowMetrics','WindowFrameIngredients','SurgeWindowFrameIngredients', ...
            'EventMeasurementQC','EventBaselineStatusCounts','MetricDefinitions','NormalizationGuide'};
        for i=1:numel(allowed)
            if ~ismember(allowed{i},sheets),continue;end
            opt=detectImportOptions(book,'Sheet',allowed{i},'VariableNamingRule','preserve');
            text=intersect(opt.VariableNames,{'RecordingID','Experiment','Mouse','SessionID','Session','Condition','DrugID','Genotype','Promoter','PuffStim','BatchRowID','FieldOfViewID','ControlRecordingID'});
            if ~isempty(text),opt=setvartype(opt,text,'string');end
            T=readtable(book,opt);
            if isfield(S.Tables,allowed{i})&&istable(S.Tables.(allowed{i}))
                compatibleTables(S.Tables.(allowed{i}),T,allowed{i});
            end
            S.Tables.(allowed{i})=T;
        end
        if isfield(S.Tables,'RecordingRegistry'),S.Registry=S.Tables.RecordingRegistry;end
    end
end
assert(istable(S.Registry)&&ismember('RecordingID',S.Registry.Properties.VariableNames), ...
    'OxygenDynamics:CompactRegistry','A saved independent recording registry is required.');
S.Registry.RecordingID=string(S.Registry.RecordingID);
assert(all(strlength(S.Registry.RecordingID)>0)&&numel(unique(S.Registry.RecordingID))==height(S.Registry), ...
    'OxygenDynamics:CompactIdentity','Recording IDs are empty or duplicated.');
if ~isfield(S.Tables,'OxySinkEvents')&&isfield(S.Tables,'HypoxicBurden_EventBased')
    S.Tables.OxySinkEvents=S.Tables.HypoxicBurden_EventBased;
end
end
function T=burdenTables(T,B)
pairs=burdenSheetPairs();
for i=1:size(pairs,1),if isfield(B,pairs{i,1})&&istable(B.(pairs{i,1})),T.(pairs{i,2})=B.(pairs{i,1});end,end
end
function pairs=burdenSheetPairs()
pairs={'EventTable','HypoxicBurden_EventBased';'RecordingTable','HypoxicBurden_ByRecording'; ...
    'TimeSeriesTable','HypoxicBurden_TimeSeries';'SelectionPolicy','Burden_SelectionPolicy'; ...
    'ReferencePolicy','HypoxicBurden_ReferencePolicy';'MetricBasis','HypoxicBurden_Basis'};
end
function M=smallMAT(path,allowed,workbookSubstitutions)
if nargin<3,workbookSubstitutions={};end
assert(isfile(path),'OxygenDynamics:CompactSource','Missing saved MAT: %s',path);
w=whos('-file',path);names=intersect({w.name},allowed,'stable');
for i=1:numel(w)
    if ~ismember(w(i).name,names)||w(i).bytes<=64*1024^2,continue;end
    assert(ismember(w(i).name,workbookSubstitutions),'OxygenDynamics:CompactSourceSize', ...
        'Small-table read boundary exceeded: %s. Supply its saved workbook tables.',w(i).name);
    names(strcmp(names,w(i).name))=[];
end
M=struct();if ~isempty(names),M=load(path,names{:});end
end
function F=addFile(F,path)
p=char(java.io.File(char(path)).getCanonicalPath());
F(end+1)=struct('Path',p,'SHA256',oxygenFileSHA256(p));
end

function compatibleTables(A,B,label)
assert(height(A)==height(B),'OxygenDynamics:CompactConflict','MAT/workbook inventories conflict: %s.',label);
for f=intersect(A.Properties.VariableNames,B.Properties.VariableNames,'stable')
    a=A.(f{1});b=B.(f{1});
    if size(a,2)~=1||size(b,2)~=1,continue;end
    if isnumeric(a)||islogical(a)
        if ~isnumeric(b)&&~islogical(b),v=lower(string(b));v(v=="false")="0";v(v=="true")="1";b=str2double(v);end
        assert(isequal(isnan(double(a)),isnan(double(b)))&&all(abs(double(a(isfinite(a)))-double(b(isfinite(a))))<=1e-10*max(1,abs(double(a(isfinite(a)))))), ...
            'OxygenDynamics:CompactConflict','MAT/workbook values conflict: %s.%s.',label,f{1});
    elseif isstring(a)||iscellstr(a)
        a=string(a);b=string(b);a(ismissing(a))="";b(ismissing(b))="";
        assert(isequal(a,b),'OxygenDynamics:CompactConflict','MAT/workbook identities conflict: %s.%s.',label,f{1});
    end
end
end
function v=policyVersion(S,name)
v="";if isfield(S,name)&&istable(S.(name))&&ismember('Version',S.(name).Properties.VariableNames)&&height(S.(name))==1,v=string(S.(name).Version);end
end
