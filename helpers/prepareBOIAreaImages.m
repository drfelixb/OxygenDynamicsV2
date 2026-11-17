function Cache=prepareBOIAreaImages(D,R,OutputRoot)
% One bounded source read; only display crops are retained in memory.
validateBOIAreaReview(D);C=D.Context;frames=unique([C.ReferenceFrames(:);C.Frames(:);C.RecoveredFrames(:)])';
assert(numel(frames)<=83,'OxygenDynamics:AreaImageBudget','This area-review increment permits at most 83 frames per source.');
sz=C.FrameSize(:)';[r,c]=ind2sub(sz,C.FixedFootprint);box=[max(1,min(r)-60) min(sz(1),max(r)+60) max(1,min(c)-60) min(sz(2),max(c)+60)];
rows=box(1):box(2);cols=box(3):box(4);local=sub2ind([numel(rows),numel(cols)],r-box(1)+1,c-box(3)+1);
assert(strcmp(oxygenFileSHA256(C.RawFile),C.RawSourceSHA256)&&strcmp(oxygenFileSHA256(C.DenoisedFile),C.DenoisedSHA256),'OxygenDynamics:AreaImageSource','Image source checksum differs.');
[raw,rawBackground]=readCrop(C.RawFile);[denoised,denoisedBackground]=readCrop(C.DenoisedFile);
checks=zeros(numel(frames),1);
for k=1:numel(frames)
    plane=raw(:,:,k);checks(k)=mean(double(plane(local)));
end
expected=double(R.Traces{C.AuditRow}.Raw(frames));expected=expected(:);
assert(max(abs(checks-expected))<1e-9,'OxygenDynamics:AreaImageSource','Raw crops do not match the exact approved footprint trace.');
native=load(C.NativeMasterPath,'Table_OxygenSinks_Out');S=native.Table_OxygenSinks_Out;
j=find(string(S.RecordingID)==string(C.RecordingID)&S.SiteID==C.SiteID);assert(isscalar(j));
all=S.FramePixels{j};suggestions=all(C.Frames);suggestions=cellfun(@(p)sort(double(p(:))),suggestions,'UniformOutput',false);
Cache=struct('ContextSHA256',D.ContextSHA256,'Frames',frames,'Rows',rows,'Columns',cols, ...
    'Raw',raw,'Denoised',denoised,'RawBackground',rawBackground,'DenoisedBackground',denoisedBackground, ...
    'GrayLimits',[prctile(double(raw(:)),[1 99]);prctile(double(denoised(:)),[1 99])], ...
    'Suggestions',{suggestions});
writeBOIRunJSON(fullfile(OutputRoot,'ImagePreparation.json'),struct('Status','source_verified_crops_cached', ...
    'ContextSHA256',D.ContextSHA256,'Frames',frames,'FramesReadPerSource',numel(frames),'TotalFramesRead',2*numel(frames), ...
    'CropRowsColumns',box,'RawFootprintMeans',checks,'SourceImagesCopied',false,'SourceImagesModified',false, ...
    'MaskSuggestionsAccepted',false,'RawSHA256',C.RawSourceSHA256,'DenoisedSHA256',C.DenoisedSHA256));
    function [images,background]=readCrop(path)
        before=dir(path);t=Tiff(path,'r');closeTiff=onCleanup(@()close(t));images=[];background=zeros(numel(rows),numel(cols));
        warningRestore=[];
        for n=1:numel(frames)
            lastwarn('');setDirectory(t,frames(n));plane=read(t);
            assert(isequal(size(plane),sz),'OxygenDynamics:AreaImageSource','Unexpected image grid.');
            [msg,wid]=lastwarn;
            if isempty(warningRestore)&&~isempty(wid)&&contains(msg,'Unknown field with tag 51123')
                state=warning('off',wid);warningRestore=onCleanup(@()warning(state));
            end
            crop=plane(rows,cols);if isempty(images),images=zeros([size(crop) numel(frames)],'like',crop);end
            images(:,:,n)=crop;
            if ismember(frames(n),C.ReferenceFrames),background=background+double(crop)/numel(C.ReferenceFrames);end
        end
        clear closeTiff warningRestore;after=dir(path);
        assert(before.bytes==after.bytes&&before.datenum==after.datenum,'OxygenDynamics:AreaImageSource','Source changed during reading.');
    end
end
