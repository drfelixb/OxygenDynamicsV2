function profile=getBOISupportProfile(Info)
% Absence identifies historical whole-image outputs; never infer from a mask.
profile='whole-image';
if isfield(Info,'BOISupportProfile'),profile=Info.BOISupportProfile;end
assert((ischar(profile)&&isrow(profile))||(isstring(profile)&&isscalar(profile)), ...
    'OxygenDynamics:InvalidSupportProfile','Supply an exact BOI support profile name.');
profile=char(profile);
assert(any(strcmp(profile,{'whole-image','craniotomy-roi-1'})), ...
    'OxygenDynamics:InvalidSupportProfile','Unknown BOI support profile: %s.',profile);
end
