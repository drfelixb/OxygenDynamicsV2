function writeStatsPuffTraceFigures(exportTraces,behaviouralDataLogical,sampleFs,puffsFs,figuresOutputFolder)
% writeStatsPuffTraceFigures exports group-average trace figures with puff windows.

PuffRecordingIdx=find(~cellfun(@isempty,behaviouralDataLogical(:,5)),1,'first');
if isempty(PuffRecordingIdx)
    return
end

pfflogical=behaviouralDataLogical{PuffRecordingIdx,5};
puff_num=bwlabel(pfflogical);
PuffSampleF=sampleFs{PuffRecordingIdx};

for groupIdx=2:size(exportTraces,2)
    if ~strcmp(exportTraces{3,groupIdx},'With stimulation') || isnan(exportTraces{4,groupIdx}.Var1{5})
        continue
    end

    for traceIdx=4:size(exportTraces,1)
        TraceMatrix=cell2mat(exportTraces{traceIdx,groupIdx}{5:end,:});
        tracemean=mean(TraceMatrix,2);

        Figure1=figure('visible','off');
        options.handle=Figure1;
        options.color_area=hex2rgb('#BFBFBF');
        options.color_line=hex2rgb('#000000');
        options.alpha=0.7;
        options.line_width=1;
        options.error='std';
        plot_areaerrorbar(TraceMatrix',options);

        title([exportTraces{1,groupIdx},exportTraces{2,groupIdx},exportTraces{3,groupIdx},' ',exportTraces{traceIdx,1}]);
        xlabel('Time(sec)')
        ylabel('Z')
        ylim([min(tracemean)-max(tracemean)*0.1 max(tracemean)*1.1])

        hold on
        for puffIdx=1:max(puff_num)
            boxX(1:2)=(find(puff_num==puffIdx,1,'first')/puffsFs)*PuffSampleF;
            boxX(3:4)=(find(puff_num==puffIdx,1,'last')/puffsFs)*PuffSampleF;
            boxY=[min(tracemean)-max(tracemean)*0.1 max(tracemean)*1.1 max(tracemean)*1.1 min(tracemean)-max(tracemean)*0.1];
            patch(boxX,boxY,hex2rgb('#FFC20A'),'EdgeColor','none','FaceAlpha',0.3)
        end
        hold off

        exportgraphics(gcf,fullfile(figuresOutputFolder,[exportTraces{1,groupIdx}, ...
            exportTraces{2,groupIdx},exportTraces{3,groupIdx},' ',exportTraces{traceIdx,1},'.pdf']),'ContentType','vector')
        close
    end
end
end
