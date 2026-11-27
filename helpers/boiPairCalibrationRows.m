function P=boiPairCalibrationRows(P)
% Also supply explicit uncorrected provenance when opening a legacy pair.
for channel=1:2
    letters='AB'; suffix=letters(channel); offset=boiPairCameraOffset(P.Options,channel);
    ref=P.Events.(['ReferenceMean' suffix]);
    [~,blocked]=boiIntensityDenominator(ref,offset);
    calibration=boiIntensityCalibration(offset);
    calibration.ReferencesAtOrBelowOffset=nnz(blocked);
    calibrationRow=boiIntensityRows(table(1,'VariableNames',{'Index'}),calibration);
    for key=string(calibrationRow.Properties.VariableNames(2:end))
        value=calibrationRow.(key);
        if ~ismember(key,P.Channels.Properties.VariableNames)
            P.Channels.(key)=repmat(value,height(P.Channels),1);
        end
        P.Channels.(key)(channel)=value;
        for field=["Events","Comparisons","Summary"]
            P.(field).(key+suffix)=repmat(value,height(P.(field)),1);
        end
    end
    status=repmat("available",height(P.Events),1);
    status(~isfinite(ref))="reference_unavailable";
    status(blocked)="reference_at_or_below_camera_offset";
    P.Events.(['RatioReferenceStatus' suffix])=status;
end
end
