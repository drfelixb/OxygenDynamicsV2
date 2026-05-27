function [Arteries,Veins,AnnotationFiles] = loadVascularAnnotationMasks(recordingFolder)
%LOADVASCULARANNOTATIONMASKS Load artery and vein annotation PNG masks.

ArteriesPath = findFilesMatchingName(recordingFolder,'Arteries','label','Arteries annotation');
VeinsPath = findFilesMatchingName(recordingFolder,'Veins','label','Veins annotation');

AnnotationFiles = struct();
AnnotationFiles.Arteries = ArteriesPath{1};
AnnotationFiles.Veins = VeinsPath{1};

Arteries = imageToMask(imread(AnnotationFiles.Arteries));
Veins = imageToMask(imread(AnnotationFiles.Veins));

end

function Mask = imageToMask(ImageData)

if ndims(ImageData)==3
    ImageData = rgb2gray(ImageData);
end
Mask = logical(ImageData);

end
