function T=exportBOIMultichannelComparison(files,workbook)
% Combine saved paired recordings; no TIFF reads or repeated event detection.
if nargin==0
    files=strings(0,1);
    while true
        [f,p]=uigetfile('*.mat','Add a Multichannel.mat (Cancel finishes selection)');
        if isequal(f,0), break; end
        files(end+1)=fullfile(p,f); %#ok<AGROW>
    end
    if isempty(files), T=table(); return; end
    [f,p]=uiputfile('*.xlsx','New comparison workbook','Paired_recordings.xlsx');
    if isequal(f,0), T=table(); return; end
    workbook=fullfile(p,f);
end
assert(~isfile(workbook),'BOIPair:Destination','Choose a new workbook name.');
files=string(files); files=files(:); assert(~isempty(files),'BOIPair:Selection','Select a completed paired recording.');
comparisons=cell(size(files)); summaries=cell(size(files)); events=cell(size(files)); links=cell(size(files)); ids=strings(size(files)); channels=cell(size(files));
software=cell(size(files)); exporter=getOxygenPipelineVersion();
for k=1:numel(files)
    P=loadBOIMultichannel(files(k)); ids(k)=P.Options.RecordingID;
    assert(~any(ids(1:k-1)==ids(k)),'BOIPair:Duplicate','Recording selected twice: %s',ids(k));
    row=oxygenSoftwareProvenanceTable(P,exporter);
    row.RecordingID=ids(k);software{k}=row;
    comparisons{k}=P.Comparisons; summaries{k}=P.Summary; events{k}=P.Events; channels{k}=P.Channels; links{k}=P.Links;
end
T=sortrows(vertcat(comparisons{:}),{'Comparison','RecordingID','Sign'});
E=vertcat(events{:}); S=vertcat(summaries{:}); C=vertcat(channels{:});
parent=fileparts(char(workbook)); if isempty(parent), parent=pwd; end
stage=[tempname(parent) '.xlsx']; clean=onCleanup(@()discard(stage));
writeBOIPairedSheet(T,stage,'Paired differences'); writeBOIPairedSheet(S,stage,'Recording summaries');
writeBOIPairedSheet(C,stage,'Channels'); writeBOIPairedSheet(vertcat(links{:}),stage,'Candidate sink links');
writeBOIPairedSheet(E(E.Sign=="sink",:),stage,'Sinks'); writeBOIPairedSheet(E(E.Sign=="surge",:),stage,'Surges');
writeBOIPairedSheet(vertcat(software{:}),stage,'SoftwareProvenance');
java.nio.file.Files.move(java.io.File(stage).toPath(),java.io.File(char(workbook)).toPath(), ...
    javaArray('java.nio.file.CopyOption',0));
end
function discard(path)
if isfile(path), delete(path); end
end
