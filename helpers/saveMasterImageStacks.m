function saveMasterImageStacks(OutputFolders,DatafileID,IM_Notrend,IM_Zframetime_smoothed,IM_OxySinks_BW,IM_OxySurges_BW)
%SAVEMASTERIMAGESTACKS Save common processed master-analysis TIFF stacks.

SaveOptions = struct();
SaveOptions.overwrite = true;

saveastiff(scaleStackToLegacyUint16(IM_Notrend), ...
    fullfile(OutputFolders.ImagesProcessedPath,['IM_Notrend',DatafileID,'.tif']),SaveOptions);

saveastiff(scaleStackToLegacyUint16(IM_Zframetime_smoothed), ...
    fullfile(OutputFolders.ImagesProcessedPath,['IM_Conv',DatafileID,'.tif']),SaveOptions);

saveastiff(uint16(IM_OxySinks_BW), ...
    fullfile(OutputFolders.OxySinksPath,['IM_OxySinks_BW',DatafileID,'.tif']),SaveOptions);

saveastiff(uint16(IM_OxySurges_BW), ...
    fullfile(OutputFolders.OxySurgesPath,['IM_OxySurges_BW',DatafileID,'.tif']),SaveOptions);

end

function StackOut = scaleStackToLegacyUint16(StackIn)

StackOut = uint16(single(scaleStackToUint8(StackIn)) / single(intmax('uint8')) * single(intmax('uint16')));

end
