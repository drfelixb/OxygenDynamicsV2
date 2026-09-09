function runSurgeOnsetTracePanel(cacheRoot,outputRoot)
% Conditional mean-trace timing panel; no movie detection or statistics.
setupOxygenDynamicsPath;assert(~isfolder(outputRoot));mkdir(outputRoot);
Code=createOxygenRegressionCodeManifest();writetable(Code,fullfile(outputRoot,'code-manifest.csv'));
Inputs=table();Backgrounds=table();records=cell(11040,1);controls=cell(230,1);nr=0;nc=0;
for session=["M400-01-baseline-awake","M401-01-baseline-awake","FB2312-baseline-awake","FB2411"]
 folder=fullfile(cacheRoot,session,'growing_clean');
 for name=["audit-inputs.mat","support-results.csv","provenance.json"]
  path=string(fullfile(folder,name));Inputs=[Inputs;table(path,string(oxygenFileSHA256(path)), ...
   'VariableNames',{'Path','SHA256'})]; %#ok<AGROW>
 end
 C=load(fullfile(folder,'audit-inputs.mat'));T=readtable(fullfile(folder,'support-results.csv'),'TextType','string');
 M=jsondecode(fileread(fullfile(folder,'provenance.json')));assert(M.SampleHz==1&&M.BaselineFrames==20);
 T=T(T.Support=="full_event",:);n=M.Frames;
 for e=1:height(T)
  q=T(e,:);i=q.LocalRow;x=C.XTrace(i,:);native=q.StartFrame:q.EndFrame;px=C.Pixels{i};blocked=false(1,n);
  for f=1:n,blocked(f)=any(ismember(px,C.AllDetectedPixels{f}));end
  Backgrounds=[Backgrounds;table(session,q.EventRow,i,n,native(1),native(end),q.SupportPixels,q.EligibleSupportFraction, ...
   'VariableNames',{'Session','EventRow','LocalRow','Frames','NativeStartFrame','NativeEndFrame','SupportPixels','EligibleSupportFraction'})]; %#ok<AGROW>
  for context=["fixed","available"]
   control=estimateSurgeLocalOnset(x,native,1,blocked,context);nc=nc+1;
   base=control;base.Session=session;base.EventRow=q.EventRow;base.LocalRow=i;base.Context=context;
   base.NativeStartFrame=native(1);base.NativeEndFrame=native(end);controls{nc}=base;
   for amplitude=[.02 .05 .10 .20]
    for rise=[5 15 30]
     for shape=["linear","sine_squared"]
      for delay=[10 25]
       onset=native(1)-delay;constructible=onset>20&&all(isfinite(x)&x>0);
       if constructible
        env=surgeTracePanelEnvelope(n,onset,rise,shape);y=x.*(1+amplitude*env);
        R=estimateSurgeLocalOnset(y,native,1,blocked,context);
       else
        R=control;fields=fieldnames(R);
        for k=1:numel(fields),if isnumeric(R.(fields{k})),R.(fields{k})=NaN;end,end
        R.Status="construction_unavailable";R.BaselineStatus="construction_unavailable";y=[];env=[];
       end
       R.Session=session;R.EventRow=q.EventRow;R.LocalRow=i;R.Context=context;
       R.NativeStartFrame=native(1);R.NativeEndFrame=native(end);
       R.AmplitudeFraction=amplitude;R.RiseFrames=rise;R.Shape=shape;R.DelayFrames=delay;R.TruthOnsetFrame=onset;
       R.Constructible=constructible;R.PulseTruncated=onset+2*rise+19>n;
       R.ControlResolved=control.Status=="resolved";R.ControlOnsetFrame=control.OnsetFrame;
       R.OnsetErrorSec=NaN;R.WithinFiveSec=false;R.SameOnsetAsControl=false;R.ShiftFromControlSec=NaN;
       R.NativeBaselineImposedFraction=NaN;R.NativeBaselineEffectPP=NaN;
       R.ProposedBaselineImposedFraction=NaN;R.BaselineEffectPP=NaN;R.PositiveBaselineFrames=NaN;
       R.BaselineUnderOnePercent=false;
       if constructible
        pre=native(1)-20:native(1)-1;bx=mean(x(pre));by=mean(y(pre));peak=max(y(native));
        R.NativeBaselineImposedFraction=by/bx-1;R.NativeBaselineEffectPP=100*(peak/by-peak/bx);
        if R.Status=="resolved"
         R.OnsetErrorSec=R.OnsetFrame-onset;R.WithinFiveSec=abs(R.OnsetErrorSec)<=5;
         if R.ControlResolved
          R.ShiftFromControlSec=R.OnsetFrame-control.OnsetFrame;R.SameOnsetAsControl=R.ShiftFromControlSec==0;
         end
         pre=R.BaselineStartFrame:R.BaselineEndFrame;bx=mean(x(pre));by=mean(y(pre));
         R.ProposedBaselineImposedFraction=by/bx-1;R.BaselineEffectPP=100*(peak/by-peak/bx);
         R.PositiveBaselineFrames=nnz(env(pre)>0);R.BaselineUnderOnePercent=R.ProposedBaselineImposedFraction<=.01;
        end
       end
       nr=nr+1;records{nr}=R;
      end
     end
    end
   end
  end
 end
 fprintf('COMPLETED ONSET TRACE PANEL %s: %d supports\n',session,height(T));
end
assert(nr==11040&&nc==230&&height(Backgrounds)==115);
Results=struct2table(vertcat(records{:}));Controls=struct2table(vertcat(controls{:}));
writetable(Results,fullfile(outputRoot,'panel-results.csv'));writetable(Controls,fullfile(outputRoot,'source-controls.csv'));
writetable(Backgrounds,fullfile(outputRoot,'backgrounds.csv'));writetable(Inputs,fullfile(outputRoot,'input-manifest.csv'));
Final=createOxygenRegressionCodeManifest();assert(isequal(Code(:,{'RelativePath','SHA256'}),Final(:,{'RelativePath','SHA256'})));
for j=1:height(Inputs),assert(string(oxygenFileSHA256(Inputs.Path(j)))==Inputs.SHA256(j));end
writeJSON(fullfile(outputRoot,'completion.json'),struct('SourceRecordings',4,'FixedSupports',115, ...
 'RecipesPerSupport',48,'PlannedConstructedTraces',5520,'ConstructibleTraces',nnz(Results.Constructible)/2, ...
 'PlannedConstructedEvaluations',nr,'ConstructedFitsRun',nnz(Results.Constructible),'SourceFitsRun',nc, ...
 'CodeAndInputFreezeVerified',true,'ProductionChanged',false,'NewDetectionOrMasterRuns',0));
end
function writeJSON(path,value)
f=fopen(path,'w');assert(f>=0);clean=onCleanup(@()fclose(f));fprintf(f,'%s\n',jsonencode(value,'PrettyPrint',true));
end
