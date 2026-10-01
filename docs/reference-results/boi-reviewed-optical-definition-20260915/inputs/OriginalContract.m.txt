function C=oxygenPipelineContract(profile)
if nargin<1,profile='whole-image';end
profile=getBOISupportProfile(struct('BOISupportProfile',profile));
% Bump the relevant identity whenever a calculation or detection rule changes.
C=struct('Schema','3.0-dev','Detector','existing-v2-surge-shape-continuity-5', ...
    'Measurement','event-footprint-contact-ledger-7','Statistics','mouse-strict-contact-qc-8', ...
    'Normalization','spatial-sd_then_temporal-sd');
if strcmp(profile,'craniotomy-roi-1')
    C.Schema='3.1-roi-dev';
    C.Detector='existing-v2-surge-shape-continuity-5_roi-candidates-1';
    C.Normalization='roi-spatial-sd_temporal-sd_weighted-neighbors-1';
end
end
