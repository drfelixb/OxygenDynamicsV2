function next02Inventory(Root)
% Ingredient inventory only; no comparison with expected/calculated outputs.
folder=fullfile(Root,'reference-validation','software-next02-calculations-20261004');
p=fullfile(Root,'reference-validation','software-g2-workflow-20260923','gui-run','statistics','Stats_Output_20260923T102730','DataOutput.mat');
L=load(p,'Table_OxygenSinks_OutCombo','Table_OxygenSurges_OutCombo', ...
    'Table_OxygenSinkEvents_OutCombo','Table_OxygenSurgeEvents_OutCombo','RecordingRegistry','BOIInputContracts');
I.Source=p;I.Registry=table2struct(L.RecordingRegistry);I.Contract=L.BOIInputContracts{1};
% Do not copy the full contract/snapshot; only numerical source ingredients.
I.Contract=struct('SampleHz',I.Contract.SampleHz,'NFrames',I.Contract.NFrames,'PixelSizeUm',I.Contract.PixelSizeUm, ...
    'SinkSupportPixels',numel(I.Contract.SinkEligibleTissuePixels),'SurgeSupportPixels',numel(I.Contract.SurgeEligibleTissuePixels));
for kind=["sink","surge"]
    if kind=="sink",S=L.Table_OxygenSinks_OutCombo;E=L.Table_OxygenSinkEvents_OutCombo;id='SinkID';start='Start';dur='Duration';
    else,S=L.Table_OxygenSurges_OutCombo;E=L.Table_OxygenSurgeEvents_OutCombo;id='SurgeID';start='Start_Surge';dur='Duration_Surge';end
    A=struct;A.EventIngredients=table2struct(E(:,{'RecordingID',id,'EventID','StartFrame','EndFrame','NativeStartFrame','NativeEndFrame'}));
    A.NativePixelCounts=cell(height(E),1);
    for e=1:height(E)
        s=E.(id)(e);P=S.FramePixels{s};frames=E.NativeStartFrame(e):E.NativeEndFrame(e);
        A.NativePixelCounts{e}=cellfun(@numel,P(frames));
    end
    % Union native pixel IDs, then intersect saved sign-specific support.
    A.UnionPixelCounts=zeros(1,I.Contract.NFrames);
    for t=1:I.Contract.NFrames
        p=[];for s=1:height(S),P=S.FramePixels{s};p=[p;P{t}(:)];end %#ok<AGROW>
        A.UnionPixelCounts(t)=numel(intersect(unique(p),unique(S.EligibleTissuePixels{1})));
    end
    A.SiteStarts=S.(start);A.SiteDurations=S.(dur);
    I.(char(kind))=A;
end
f=fopen(fullfile(folder,'saved-ingredients.json'),'w');assert(f>=0);c=onCleanup(@()fclose(f));fprintf(f,'%s\n',jsonencode(I,'PrettyPrint',true));
end
