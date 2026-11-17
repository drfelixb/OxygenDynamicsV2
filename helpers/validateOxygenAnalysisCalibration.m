function validateOxygenAnalysisCalibration(Info,Metadata)
% Cached physical measurements must use the calibration of their master run.
assert(isfield(Info,'AnalysisParams'),'OxygenDynamics:MissingSavedCalibration','Saved calibration is missing. Rerun the master.');
P=Info.AnalysisParams;
pairs={'fs','SampleF';'PixelSize','PixelSize'};
for i=1:size(pairs,1)
    if ~isfield(P,pairs{i,1})
        error('OxygenDynamics:MissingSavedCalibration','Saved calibration is incomplete. Rerun the master.');
    end
    old=P.(pairs{i,1});new=Metadata.(pairs{i,2});
    valid=isnumeric(old)&&isscalar(old)&&isfinite(old)&&old>0 && ...
        isnumeric(new)&&isscalar(new)&&isfinite(new)&&new>0;
    if ~valid || abs(old-new)>1e-9*max(abs([old,new]))
        error('OxygenDynamics:CalibrationMismatch', ...
            'CSV %s differs from the saved master calibration. Rerun the master with the intended calibration before statistics.',pairs{i,2});
    end
end
end
