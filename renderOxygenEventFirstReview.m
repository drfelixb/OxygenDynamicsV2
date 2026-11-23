function renderOxygenEventFirstReview(R,X,OutputFile)
% Static review artifact; Y downward, full-frame X/Y coordinates.
f=figure('Visible','off','Color','w','Position',[50 50 1200 800]); clean=onCleanup(@()close(f));
tiledlayout(2,2,'Padding','compact');
nexttile; imagesc(median(double(R.Intensity),3,'omitnan')); axis image; colormap(gray); colorbar;
title('Preserved temporal median; full-frame pixels'); xlabel('X pixel'); ylabel('Y pixel');
nexttile;
base=mat2gray(median(double(R.Intensity),3,'omitnan')); rgb=repmat(base,1,1,3);
for kind=["sink","surge"]
    mask=false(X.FrameSize); ids=X.Events.EventID(X.Events.EventType==kind);
    selected=find(ismember(X.EventFrameMasks.EventID,ids));
    for j=selected(:)', mask(X.EventFrameMasks.PixelIdxList{j})=true; end
    color=[0 .6 1]; if kind=="surge", color=[1 .3 0]; end
    for ch=1:3
        plane=rgb(:,:,ch); plane(mask)=.3*plane(mask)+.7*color(ch); rgb(:,:,ch)=plane;
    end
end
imagesc(rgb); axis image;
title('Candidate union overlay: sink blue / surge orange'); xlabel('X pixel'); ylabel('Y pixel');
nexttile; plot(X.TimeSeries.StartSec,X.TimeSeries.GlobalPreservedBLI,'k'); grid on;
xlabel('Seconds from first exposure'); ylabel('Preserved BLI intensity'); title('Global response retained');
nexttile; hold on;
eligible=find(isfinite(X.Events.PeakRelativeBLI));
for k=eligible(1:min(8,numel(eligible)))' 
    plot(X.TimeSeries.StartSec,X.EventTraces{k}.SignedRelativeBLI);
end
xlabel('Seconds from first exposure'); ylabel('Signed relative BLI (fraction)'); grid on;
title('First 8 candidates with valid pre-event relative BLI');
sgtitle(sprintf('%s | %d candidates | exploratory, unvalidated',R.RecordingID,height(X.Events)),'Interpreter','none');
exportgraphics(f,OutputFile,'Resolution',130);
end
