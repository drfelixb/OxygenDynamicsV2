function saveiOSTiffoutStacks(OutputFolders,DatafileID,IM_Notrend_dFoF_global, ...
    IM_Raw_dFoF_global,IM_Zframetime_Conv_smoothed)
%SAVEIOSTIFFOUTSTACKS Save processed iOS TIFF-output stacks.

SaveOptions = struct();
SaveOptions.overwrite = true;

saveastiff(scaleStackToUint16(IM_Notrend_dFoF_global), ...
    fullfile(OutputFolders.ImagesProcessedPath,['IM_Notrend_dFoF',DatafileID,'.tif']),SaveOptions);
saveastiff(scaleStackToUint16(IM_Raw_dFoF_global), ...
    fullfile(OutputFolders.ImagesProcessedPath,['IM_Raw_dFoF',DatafileID,'.tif']),SaveOptions);
saveastiff(scaleStackToUint16(IM_Zframetime_Conv_smoothed), ...
    fullfile(OutputFolders.ImagesProcessedPath,['IM_Conv',DatafileID,'.tif']),SaveOptions);

end
