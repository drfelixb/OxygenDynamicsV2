function [PutativeEventMask,ForbiddenPixels] = computeFrameDifferenceEventMask(IMclip)
%COMPUTEFRAMEDIFFERENCEEVENTMASK Build iOS putative-event mask and edge pixels.

firstcolumn = 1:size(IMclip(:,:,1),1);
firstrow = 1:size(IMclip(:,:,1),1):size(IMclip(:,:,1),2) * size(IMclip(:,:,1),1);
lastrow = size(IMclip(:,:,1),1):size(IMclip(:,:,1),1):size(IMclip(:,:,1),2) * size(IMclip(:,:,1),1);
lastcolumn = (size(IMclip(:,:,1),1) - 1) * size(IMclip(:,:,1),2) + 1:size(IMclip(:,:,1),1) * size(IMclip(:,:,1),2);
ForbiddenPixels = [firstcolumn,firstrow,lastcolumn,lastrow];

frameDifferencesF = zeros(size(IMclip,1),size(IMclip,2),size(IMclip,3) - 1);
for frameIdx = 2:size(IMclip,3)
    frameDifferencesF(:,:,frameIdx - 1) = IMclip(:,:,frameIdx) - IMclip(:,:,frameIdx - 1);
end
frameDifferencesF = scaleStackToUint8(frameDifferencesF);

frameDifferencesR = zeros(size(IMclip,1),size(IMclip,2),size(IMclip,3) - 1);
for frameIdx = size(IMclip,3)-1:-1:1
    frameDifferencesR(:,:,frameIdx) = IMclip(:,:,frameIdx) - IMclip(:,:,frameIdx + 1);
end
frameDifferencesR = scaleStackToUint8(frameDifferencesR);

CombinedDifferences = max(frameDifferencesR,[],3) + max(frameDifferencesF,[],3);
PutativeEventMask = imbinarize(CombinedDifferences,graythresh(CombinedDifferences));

end
