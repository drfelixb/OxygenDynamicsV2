function Audit=auditOxygenSinkAmplitudeSource(sinksInput,varargin)
%AUDITOXYGENSINKAMPLITUDESOURCE Audit current sink event footprints and clean baselines.
% Both saved signs and the checksum-matched preserved-input TIFF are required.
% Whole-site traces and post-event fallback baselines are not measurement inputs.
if nargin<1||isempty(sinksInput),sinksInput=pwd;end
p=inputParser;p.addParameter('writeXlsx',false,@islogical);
p.addParameter('outputXlsx','',@(x)ischar(x)||isstring(x));p.parse(varargin{:});
root=char(sinksInput);
if isfile(root),root=fileparts(root);end
[~,leaf]=fileparts(root);
if startsWith(leaf,'OxygenSinks_Output'),root=fileparts(root);end
Audit=auditOxygenEventAmplitudeSource(root);Audit=Audit(Audit.EventType=="sink",:);
if p.Results.writeXlsx
    target=p.Results.outputXlsx;
    if strlength(string(target))==0,target=fullfile(root,'SinkEventAmplitudeAudit.xlsx');end
    assert(~isfile(target),'OxygenDynamics:AuditOutputExists','Use a new workbook path.');
    writetable(Audit,target,'Sheet','AmplitudeSourceAudit');
end
end
