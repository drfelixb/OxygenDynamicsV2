function Review = reviewBOIRecordingInput(RecordingFolder,SampleHz,PixelSizeUm)
%REVIEWBOIRECORDINGINPUT Read-only import review before the BOI master.
% Technical readability, unsupported inputs and scientific review are distinct.
setupOxygenDynamicsPath;
Validation=validateOxygenRecording(RecordingFolder,SampleHz,PixelSizeUm,false,struct());
Review=createBOIImportReview(Validation,SampleHz,PixelSizeUm);
fprintf('BOI input status: %s\n',Review.Status);
disp(Review.QC(:,{'Disposition','AffectedMeasurements','Message','Action'}));
end
