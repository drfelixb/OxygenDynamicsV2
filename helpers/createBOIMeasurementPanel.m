function Panel=createBOIMeasurementPanel(Parent)
%CREATEBOIMEASUREMENTPANEL Read shared definitions without source-code reading.
Grid=uigridlayout(Parent,[3 1]);Grid.RowHeight={30,42,'1x'};
Actions=uigridlayout(Grid,[1 4]);Actions.Padding=[0 0 0 0];
Actions.ColumnWidth={190,190,170,'1x'};
uibutton(Actions,'Text','Open saved dictionary','ButtonPushedFcn',@chooseDictionary);
uibutton(Actions,'Text','Show current definitions','ButtonPushedFcn',@(~,~)loadDictionary(''));
FullButton=uibutton(Actions,'Text','Open full definition','ButtonPushedFcn',@openFullDefinition);
Status=uilabel(Grid,'WordWrap','on','Interpreter','none');
Body=uigridlayout(Grid,[1 2]);Body.ColumnWidth={340,'1x'};Body.Padding=[0 0 0 0];
List=uilistbox(Body,'ValueChangedFcn',@(~,~)showDefinition());
Detail=uitextarea(Body,'Editable','off');D=table();SelectedPath='';SourcePath='';SourceSHA='';
Panel=struct('Load',@loadDictionary,'List',List,'Detail',Detail,'Status',Status,'SelectedPath',@selectedPath,'FullButton',FullButton);
loadDictionary('');
    function loadDictionary(path)
        [next,dict,source]=getBOIMeasurementDictionary(path);
        D=next;SelectedPath=path;SourcePath=source;SourceSHA=oxygenFileSHA256(source);
        List.Items=cellstr(D.MeasurementID+" — "+D.Name);
        List.ItemsData=cellstr(D.MeasurementID);List.Value=char(D.MeasurementID(1));
        role='Selected saved definitions';
        if isempty(path),role='Current definitions; not a saved run snapshot';end
        Status.Text=sprintf('%s | %s\n%s',role,dict.Version,source);showDefinition();
    end
    function path=selectedPath()
        assert(strcmp(SourceSHA,oxygenFileSHA256(SourcePath)), ...
            'OxygenDynamics:DictionaryChanged','Dictionary changed since display. Reload it before exporting.');
        path=SelectedPath;
    end
    function showDefinition()
        row=D(D.MeasurementID==string(List.Value),:);
        lines=[row.Name;"Definition version: "+row.DefinitionVersion; ...
            "Scientific eligibility is not established by numerical availability.";""];
        fields=row.Properties.VariableNames;
        for k=1:numel(fields)
            label=regexprep(fields{k},'([a-z])([A-Z])','$1 $2');
            lines=[lines;string(label)+": "+row.(fields{k});""]; %#ok<AGROW>
        end
        Detail.Value=cellstr(lines);
    end
    function chooseDictionary(~,~)
        [file,folder]=uigetfile('*.json','Choose saved BOIMeasurementDictionary.json');
        if isequal(file,0),return;end
        try,loadDictionary(fullfile(folder,file));catch err
            uialert(ancestor(Grid,'figure'),err.message,'Cannot read dictionary');
        end
    end
    function openFullDefinition(~,~)
        fig=uifigure('Name','BOI measurement definition — saved view','Position',[80 80 1000 800]);
        layout=uigridlayout(fig,[2 1]);layout.RowHeight={60,'1x'};
        uilabel(layout,'Text',['Snapshot when opened. ' Status.Text],'Interpreter','none','WordWrap','on');
        uitextarea(layout,'Value',Detail.Value,'Editable','off','FontSize',13);
    end
end
