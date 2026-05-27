function WrapperRunInfo = updateWrapperRecordingInfo(WrapperRunInfo,recordingIndex,pathValue,folderValue,mouseId,condition,drugId,validation)
%UPDATEWRAPPERRECORDINGINFO Store per-recording wrapper provenance.

TiffStatus = validation.TiffStatus;
WrapperRunInfo.Recordings(recordingIndex).Path = pathValue;
WrapperRunInfo.Recordings(recordingIndex).Folder = folderValue;
WrapperRunInfo.Recordings(recordingIndex).Mouse = mouseId;
WrapperRunInfo.Recordings(recordingIndex).Condition = condition;
WrapperRunInfo.Recordings(recordingIndex).DrugID = drugId;
WrapperRunInfo.Recordings(recordingIndex).RawTiff = firstTiffName(TiffStatus.RawFiles);
WrapperRunInfo.Recordings(recordingIndex).DenoisedTiff = firstTiffName(TiffStatus.DenoisedFiles);
WrapperRunInfo.Recordings(recordingIndex).ValidationIsValid = validation.IsValid;
WrapperRunInfo.Recordings(recordingIndex).ValidationWarnings = validation.Warnings;
WrapperRunInfo.Recordings(recordingIndex).ValidationErrors = validation.Errors;

end
