function renderOxygenDetectorComparison(R,L,X,OutputFile)
% Descriptive side-by-side native masks. Neither detector is reference truth.
f=figure('Visible','off','Color','w','Position',[100 100 1250 460]); clean=onCleanup(@()close(f));
tiledlayout(1,3,'Padding','compact');
base=mat2gray(median(double(R.Intensity),3,'omitnan')); shape=size(base);
nexttile; imagesc(base); colormap(gray); axis image; title('Preserved temporal median'); xlabel('X pixel'); ylabel('Y pixel');
results={L,X}; labels={'Legacy native event support','eventFirst candidate support'};
for k=1:2
    Y=results{k}; rgb=repmat(base,1,1,3);
    for kind=["sink","surge"]
        ids=Y.Events.EventID(string(Y.Events.EventType)==kind); mask=false(shape);
        selected=find(ismember(string(Y.EventFrameMasks.EventID),string(ids)));
        for j=selected(:)', mask(Y.EventFrameMasks.PixelIdxList{j})=true; end
        color=[0 .6 1]; if kind=="surge", color=[1 .3 0]; end
        for ch=1:3, p=rgb(:,:,ch); p(mask)=.3*p(mask)+.7*color(ch); rgb(:,:,ch)=p; end
    end
    nexttile; imagesc(rgb); axis image; xlabel('X pixel'); ylabel('Y pixel');
    title(sprintf('%s (%d)',labels{k},height(Y.Events)));
end
sgtitle('Descriptive comparison: sink blue / surge orange; neither detector is ground truth');
exportgraphics(f,OutputFile,'Resolution',130);
end
