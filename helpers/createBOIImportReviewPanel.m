function Panel=createBOIImportReviewPanel(Parent)
%CREATEBOIIMPORTREVIEWPANEL Select a recording to read source/tissue evidence.
Grid=uigridlayout(Parent,[3 1]);Grid.RowHeight={28,90,'1x'};Grid.Padding=[8 8 8 8];
Header=uigridlayout(Grid,[1 2]);Header.ColumnWidth={'1x',150};Header.Padding=[0 0 0 0];
uilabel(Header,'Text','Input readiness is not scientific acceptance. Select a recording for evidence and actions.', ...
    'WordWrap','on','FontWeight','bold');
OpenButton=uibutton(Header,'Text','Open full review','Enable','off','ButtonPushedFcn',@openFullReview);
Summary=uitable(Grid,'Data',cell(0,6),'ColumnName', ...
    {'Record','Mouse as supplied','Input status','Sampling','Tissue support','Scientific eligibility'}, ...
    'ColumnWidth',{55,225,175,190,230,160},'RowName',{},'CellSelectionCallback',@selectRecording);
Detail=uitextarea(Grid,'Editable','off','Value',{'Run verification to inspect BOI source and tissue evidence.'});
AllDetails={};
Panel=struct('Grid',Grid,'Summary',Summary,'Detail',Detail,'OpenButton',OpenButton,'Update',@update);
    function update(Report)
        if isempty(Report)
            Summary.Data=cell(0,6);AllDetails={};
            OpenButton.Enable='off';
            Detail.Value={'Run verification to inspect BOI source and tissue evidence.'};return
        end
        [Summary.Data,AllDetails]=buildBOIImportReviewRows(Report.BOIImportReviews,Report.SummaryTable.Mouse);
        if ~isempty(AllDetails),Detail.Value=AllDetails{1};OpenButton.Enable='on';end
    end
    function selectRecording(~,Event)
        if ~isempty(Event.Indices),Detail.Value=AllDetails{Event.Indices(1,1)};end
    end
    function openFullReview(~,~)
        Fig=uifigure('Name','BOI input review — saved view','Position',[80 80 1000 800]);
        Layout=uigridlayout(Fig,[2 1]);Layout.RowHeight={30,'1x'};
        uilabel(Layout,'Text','Review snapshot when opened. Run verification again after changing inputs.', ...
            'FontWeight','bold');
        uitextarea(Layout,'Editable','off','Value',Detail.Value,'FontSize',13);
    end
end
