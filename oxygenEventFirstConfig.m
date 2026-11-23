function C = oxygenEventFirstConfig(Overrides)
%OXYGENEVENTFIRSTCONFIG Exploratory defaults; scores are not probabilities.
C = struct('Version',"eventFirst-0.1.0",'BaselineWindowSec',60, ...
    'BaselineIterations',3,'RecoveryPaddingSec',2,'SeedSD',5,'GrowSD',2.5, ...
    'MinDurationSec',2,'MinAreaUm2',0,'SpatialScalesUm',[0 5], ...
    'NoiseMethod',"residualMAD",'MinNoiseSD',1e-8, ...
    'DetectionSource',"preserved",'PreEventSec',10,'MinBaselineSamples',3, ...
    'MinBaselineFraction',0.5,'MaxExcludedFraction',0.4, ...
    'SiteMinIoU',0.25,'AnalysisRunID',"",'SaveDiagnostics',false,'Verbose',false);
if nargin
    names = fieldnames(Overrides);
    for k=1:numel(names)
        assert(isfield(C,names{k}),'eventFirst:Config','Unknown option: %s',names{k});
        C.(names{k})=Overrides.(names{k});
    end
end
positive={'BaselineWindowSec','SeedSD','GrowSD','MinNoiseSD','PreEventSec'};
nonnegative={'RecoveryPaddingSec','MinDurationSec','MinAreaUm2'};
for name=positive, validateattributes(C.(name{1}),{'numeric'},{'scalar','real','finite','positive'}); end
for name=nonnegative, validateattributes(C.(name{1}),{'numeric'},{'scalar','real','finite','nonnegative'}); end
for name={'BaselineIterations','MinBaselineSamples'}
    validateattributes(C.(name{1}),{'numeric'},{'scalar','integer','positive'});
end
for name={'MinBaselineFraction','MaxExcludedFraction','SiteMinIoU'}
    validateattributes(C.(name{1}),{'numeric'},{'scalar','real','finite','>',0,'<=',1});
end
validateattributes(C.SpatialScalesUm,{'numeric'},{'vector','real','finite','nonnegative','nonempty'});
assert(C.SeedSD>C.GrowSD,'eventFirst:Config','SeedSD must exceed GrowSD.');
assert(ismember(string(C.NoiseMethod),["residualMAD","intensityBinnedMAD"]),'eventFirst:Config','Unsupported noise method.');
assert(ismember(string(C.DetectionSource),["preserved","denoised"]),'eventFirst:Config','Unsupported detection source.');
assert(string(C.Version)=="eventFirst-0.1.0",'eventFirst:Config','Version is fixed by implementation.');
C.Version=string(C.Version); C.AnalysisRunID=string(C.AnalysisRunID);
assert(isscalar(C.AnalysisRunID),'eventFirst:Config','AnalysisRunID must be scalar.');
end
