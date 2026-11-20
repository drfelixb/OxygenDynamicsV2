function [Plan,Prepared]=prepareBOICompactWorkbook(Source,ReviewPaths,OutputFile,Options)
%PREPAREBOICOMPACTWORKBOOK Preview a saved-value compact export, without writing.
setupOxygenDynamicsPath;
if nargin<2,ReviewPaths={};end
if nargin<4,Options=struct();end
assert(ischar(OutputFile)||(isstring(OutputFile)&&isscalar(OutputFile)), ...
    'OxygenDynamics:CompactDestination','Choose one new XLSX filename.');
p=char(java.io.File(char(OutputFile)).getCanonicalPath());[parent,~,ext]=fileparts(p);
assert(strcmpi(ext,'.xlsx')&&isfolder(parent)&&~isfile(p)&&~isfolder(p)&&~isfile([p '.receipt.json']), ...
    'OxygenDynamics:CompactDestination','Choose a NEW .xlsx file in an existing folder. Existing outputs are preserved.');
S=loadBOICompactWorkbookSources(Source,ReviewPaths,Options);D=createBOICompactWorkbookData(S);
sheets={'Events','Recordings','Sites','TimeSeries','Availability','Definitions'};
if ~isempty(D.Phases),sheets{end+1}='Phases';end
for i=1:numel(sheets)
    T=D.(sheets{i});assert(height(T)<1048576&&width(T)<=16384,'OxygenDynamics:CompactExcelSize','Excel size limit exceeded.');
    for f=string(T.Properties.VariableNames)
        a=T.(f);assert(size(a,2)==1&&(isnumeric(a)||islogical(a)||isstring(a)||iscellstr(a)), ...
            'OxygenDynamics:CompactScalar','Only flat scalar data can be exported: %s.%s.',sheets{i},f);
        if isnumeric(a),assert(~any(isinf(a)),'OxygenDynamics:CompactNumeric','Infinite source value: %s.%s.',sheets{i},f);end
        if isstring(a)||iscellstr(a),assert(all(ismissing(string(a))|strlength(string(a))<=32767),'OxygenDynamics:CompactExcelSize','Excel cell text limit exceeded.');end
    end
end
counts=struct();for i=1:numel(sheets),counts.(sheets{i})=height(D.(sheets{i}));end
Plan=struct('Schema','boi-compact-workbook-plan-2','OutputFile',p,'SourceDigest',S.SourceDigest, ...
    'AutomaticSHA256',S.AutomaticSHA256,'SourceFiles',S.Files,'Sheets',{sheets},'Counts',counts, ...
    'ReviewedSnapshots',numel(S.Reviews),'DataDigest',boiCompactWorkbookDigest(D), ...
    'ScientificCalculations',0,'OriginalResultsChanged',false);
Plan.AvailabilityLayoutVersion='boi-availability-summary-1';Plan.DigestMethod='boi-compact-table-digest-1';
Plan.ProjectionSHA256=struct('Projector',oxygenFileSHA256(which('createBOICompactWorkbookData')), ...
    'Summary',oxygenFileSHA256(which('createBOICompactAvailabilitySummary')),'Digest',oxygenFileSHA256(which('boiCompactWorkbookDigest')));
Plan.Digest=boiBatchQueueDigest(Plan);Prepared=struct('Source',S,'Data',D);
end
