function Proposal = reviewBOITissueSupport(RecordingFolder,Mask,OutputFolder)
%REVIEWBOITISSUESUPPORT Preview a proposed native logical mask without adopting it.
% Mask must be in decoded TIFF row/column coordinates. Registration is never
% inferred. Three source frames illustrate alignment, not full temporal QC.
setupOxygenDynamicsPath;
assert(~isfolder(OutputFolder)&&~isfile(OutputFolder),'OxygenDynamics:ReviewOutputExists', ...
    'Use a new proposal folder so earlier review evidence is preserved.');
files=inspectOxygenTiffs(RecordingFolder);
assert(numel(files.RawFiles)==1,'OxygenDynamics:InvalidTissueSupport','Exactly one original TIFF is required.');
file=fullfile(files.RawFiles(1).folder,files.RawFiles(1).name);
info=imfinfo(file);shape=[info(1).Height info(1).Width];
assert(islogical(Mask)&&isequal(size(Mask),shape)&&any(Mask(:)), ...
    'OxygenDynamics:InvalidTissueSupport','Supply a nonempty logical mask matching native TIFF dimensions. No thresholding or resizing is applied.');
Proposal=struct('Schema','boi-tissue-proposal-1','Status','proposed_not_adopted', ...
    'RawFileName',files.RawFiles(1).name,'RawSHA256',oxygenFileSHA256(file), ...
    'FrameSize',shape,'PreviewFrames',unique([1 ceil(numel(info)/2) numel(info)]), ...
    'MaskFile','ProposedMask.mat','MaskFileSHA256','');
frames=zeros([shape numel(Proposal.PreviewFrames)]);
tif=Tiff(file,'r');cleanup=onCleanup(@()close(tif));
for i=1:numel(Proposal.PreviewFrames)
    setDirectory(tif,Proposal.PreviewFrames(i));frames(:,:,i)=double(read(tif));
end
clear cleanup
mkdir(OutputFolder);save(fullfile(OutputFolder,Proposal.MaskFile),'Mask');
Proposal.MaskFileSHA256=oxygenFileSHA256(fullfile(OutputFolder,Proposal.MaskFile));
limits=[min(frames(:)),max(frames(:))];if limits(1)==limits(2),limits(2)=limits(1)+1;end
fig=figure('Visible','off','Color','w','Position',[50 50 1400 560]);cleanup=onCleanup(@()close(fig));
tiledlayout(1,numel(Proposal.PreviewFrames),'Padding','compact');
boundaries=bwboundaries(Mask);
for i=1:numel(Proposal.PreviewFrames)
    nexttile;imagesc(frames(:,:,i),limits);axis image;colormap gray;hold on
    for k=1:numel(boundaries),plot(boundaries{k}(:,2),boundaries{k}(:,1),'g','LineWidth',1);end
    title(sprintf('Source frame %d | proposed support in green',Proposal.PreviewFrames(i)));
    xlabel('Native column');ylabel('Native row');
end
sgtitle({'Proposed static BOI support — not adopted', ...
    'Shared source intensity scale. Three frames do not establish anatomy, alignment or validity throughout time.'});
exportgraphics(fig,fullfile(OutputFolder,'TissueSupportPreview.png'),'Resolution',140);clear cleanup
fid=fopen(fullfile(OutputFolder,'Proposal.json'),'w');assert(fid>=0);cleanup=onCleanup(@()fclose(fid));
fprintf(fid,'%s\n',jsonencode(Proposal,'PrettyPrint',true));clear cleanup
fprintf('Proposal only: %s\nReview supporting anatomy, registration and motion before recording a decision.\n',OutputFolder);
end
