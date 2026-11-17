function saveStatsMATFile(OutputPath,Data,Fields)
%SAVESTATSMATFILE Preserve legacy MAT variables, including large batch tables.
% Keep the ordinary v7 representation for small exports. MATLAB v7 silently
% omits a variable above its 2 GiB limit, so large exports use compressed v7.3.
if nargin<3,Fields=fieldnames(Data);end
format='-v7';
for k=1:numel(Fields)
    value=Data.(Fields{k});info=whos('value'); %#ok<NASGU>
    if info.bytes>=2^31-2^20,format='-v7.3';break;end
end
save(OutputPath,'-struct','Data',Fields{:},format);
saved=whos('-file',OutputPath);
assert(all(ismember(Fields,{saved.name})), ...
    'OxygenDynamics:StatsSaveIncomplete','A required variable was omitted from %s.',OutputPath);
end
