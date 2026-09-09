function auditSurgeShapeSupportScores(root,priorRoot)
% Independently flatten both movie masks into space-time sets for all 32 scores.
R=readtable(fullfile(root,'shape-support-results.csv'),'TextType','string');assert(height(R)==32);
for r=1:height(R)
 name=R.Case(r);control=startsWith(name,'control_for_');if control,name=extractAfter(name,'control_for_');end
 rec=fullfile(root,R.Session(r),name);M=jsondecode(fileread(fullfile(rec,'challenge-manifest.json')));
 if control,rec=fullfile(priorRoot,R.Session(r),'control');end
 k=1;folder='OxygenSinks_Output';pattern='*Urefined*.mat';id='SinkID';
 if R.EventType(r)=="surge",k=2;folder='OxygenSurges_Output';pattern='*.mat';id='SurgeID';end
 f=dir(fullfile(rec,folder,pattern));assert(isscalar(f));D=load(fullfile(f.folder,f.name));
 if k==1,S=D.Table_OxygenSinks_Out;E=D.Table_OxygenSinkEvents_Out;else,S=D.Table_OxygenSurges_Out;E=D.Table_OxygenSurgeEvents_Out;end
 [y,x]=ndgrid(1:M.Height,1:M.Width);npx=M.Height*M.Width;truth=[];
 for t=101:160
  mask=(x-M.CentersXY(k,1)).^2+(y-M.CentersXY(k,2)).^2<=(M.RadiusUmByFrame(t)/M.SourceProfile.PixelSize)^2;
  truth=[truth;find(mask)+npx*(t-1)]; %#ok<AGROW>
 end
 scores=zeros(height(E),1);hits=0;
 for e=1:height(E)
  cells=S.FramePixels{E.(id)(e)};active=find(~cellfun(@isempty,cells));starts=active([true diff(active)>1]);ends=active([diff(active)>1 true]);j=E.EventID(e);v=[];
  assert(E.NativeStartFrame(e)==starts(j)&&E.NativeEndFrame(e)==ends(j));
  for t=starts(j):ends(j),v=[v;cells{t}(:)+npx*(t-1)];end %#ok<AGROW>
  n=numel(intersect(truth,v));hits=hits+(n>0);scores(e)=n/numel(union(truth,v));
 end
 best=max([0;scores]);assert(abs(best-R.BestNativeSpacetimeIoU(r))<1e-12&&hits==R.IntersectingEvents(r));
 assert(height(E)==R.TotalRetainedEvents(r)&&height(S)==R.TotalRecurringSites(r));
 if best>0,assert(R.BestEventRow(r)==find(scores==best,1));else,assert(R.BestEventRow(r)==0);end
end
f=fopen(fullfile(root,'score-verification.json'),'w');assert(f>=0);fprintf(f,'%s\n',jsonencode(struct('SupportRowsVerified',height(R),'IndependentSpacetimeSetScoresMatch',true,'ControlMasksRescoredAtIdenticalPrescribedGeometry',true),'PrettyPrint',true));fclose(f);
end
