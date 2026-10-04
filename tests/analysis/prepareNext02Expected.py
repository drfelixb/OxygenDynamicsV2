from pathlib import Path
import json,csv,openpyxl,hashlib,datetime
root=Path(__file__).resolve().parents[3];folder=root/'reference-validation/software-next02-calculations-20261004'
# Explicit fixture specification; no production helper is invoked here.
base={'NFrames':4,'SampleHz':1,'PixelSizeUm':2,'SinkSupport':[1,2,3,4],'SurgeSupport':list(range(1,9)),'Window':[0,4]}
specs=[
 {'ID':'F01','Name':'single frame at 2 Hz','SampleHz':2,'Window':[0,2],'Pixels':[[[],[1],[],[]]],'SinkBounds':[[2,2]],'SurgeBounds':[[2,2]]},
 {'ID':'F02','Name':'native area and distinct refined sink duration','Pixels':[[[1,2],[2,3],[],[]]],'SinkBounds':[[1,3]],'SurgeBounds':[[1,2]]},
 {'ID':'F03','Name':'overlapping native masks count pixels once','Pixels':[[[1,2],[2,3],[],[]],[[],[3,4],[],[]]],'SinkBounds':[[1,2],[2,2]],'SurgeBounds':[[1,2],[2,2]]},
 {'ID':'F04','Name':'fractional window edges','Window':[.5,2.5],'Pixels':[[[1,2],[2,3],[],[]],[[],[3,4],[],[]]],'SinkBounds':[[1,2],[2,2]],'SurgeBounds':[[1,2],[2,2]]},
 {'ID':'F05','Name':'ongoing event and onset at excluded window end','Window':[1,3],'Pixels':[[[1,2],[1,2],[1,2],[]],[[],[],[],[3]]],'SinkBounds':[[1,3],[4,4]],'SurgeBounds':[[1,3],[4,4]]},
 {'ID':'F06','Name':'empty analyzed events with valid support','Pixels':[],'SinkBounds':[],'SurgeBounds':[]},
 {'ID':'F07','Name':'missing calibration unavailable not zero','PixelSizeUm':None,'Pixels':[[[],[1,2],[1,2],[]]],'SinkBounds':[[2,3]],'SurgeBounds':[[2,3]]},
 {'ID':'F08','Name':'invalid clock blocked not zero','SampleHz':0,'Pixels':[[[],[1],[],[]]],'SinkBounds':[[2,2]],'SurgeBounds':[[2,2]]}
]
cases=[]
for spec in specs:
 c={**base,**spec};fs=c['SampleHz'];px=c['PixelSizeUm'];a,b=c['Window'];T=b-a
 if fs<=0:
  c['Expected']={'Error':'OxygenDynamics:InvalidExposure','FinalizerError':'OxygenDynamics:InvalidQuantificationScale'};cases.append(c);continue
 dt=[max(0,min((t+1)/fs,b)-max(t/fs,a)) for t in range(4)]
 expected={}
 for sign in ['sink','surge']:
  bounds=c[sign.title()+'Bounds'];support=c[sign.title()+'Support'];area=None if px is None else len(support)*px**2
  eventdur=[(v-u+1)/fs for u,v in bounds];native=[[t+1 for t,p in enumerate(site) if p] for site in c['Pixels']]
  eventarea=None if px is None else [sum(len(c['Pixels'][i][t-1]) for t in fr)/len(fr)*px**2 for i,fr in enumerate(native)]
  counts=[sum(u<=t+1<=v for u,v in bounds) for t in range(4)]
  union=[len(set().union(*(set(site[t]) for site in c['Pixels'])).intersection(support)) for t in range(4)]
  areas=None if px is None else [n*px**2 for n in union]
  n=sum(a<=(u-1)/fs<b for u,v in bounds);active=sum(max(0,min(v/fs,b)-max((u-1)/fs,a)) for u,v in bounds)
  covered=None if px is None else sum(ar*d for ar,d in zip(areas,dt));den=None if area is None else area*T
  expected[sign]={'EventDurationSec':eventdur,'EventAreaUm2':eventarea,'CountSeries':counts,'OccupiedAreaUm2':areas,'AreaUm2':area,'WindowOverlapSec':dt,'EventOnsets':n,'ActiveEventSeconds':active,'CoveredAreaTime':covered,'TissueTime':den,'Occupancy':None if den is None else covered/den,'OnsetRate':None if den is None else n*60e6/den,'ConcurrentDensity':None if den is None else active*1e6/den,'AcquisitionStartOnsetsCounted':sum(a<=(u-1)/fs<b and u==1 for u,v in bounds),'OngoingAtWindowStart':sum((u-1)/fs<a<v/fs for u,v in bounds)}
 c['Expected']=expected;cases.append(c)
(folder/'cases.json').write_text(json.dumps({'FrozenUTC':datetime.datetime.now(datetime.timezone.utc).isoformat(),'Cases':cases,'IndependentWriter':'Python explicit frame arithmetic and set union; no MATLAB calculation helper'},indent=2)+'\n')
# Independent saved expected answers from ingredient inventory + original exports.
I=json.loads((folder/'saved-ingredients.json').read_text());px=I['Contract']['PixelSizeUm'];fs=I['Contract']['SampleHz'];N=I['Contract']['NFrames']
saved=root/'reference-validation/software-g2-workflow-20260923/gui-run/statistics/Stats_Output_20260923T102730'
w=openpyxl.load_workbook(saved/'FilteredData_input.xlsx',read_only=True,data_only=True)
def rows(name):
 it=iter(w[name].values);h=next(it);return [dict(zip(h,r)) for r in it]
answers={'ID':'S01','SourceSHA256':hashlib.sha256((saved/'DataOutput.mat').read_bytes()).hexdigest(),'fs':fs,'px':px,'N':N,'Expected':{}}
for sign in ['sink','surge']:
 d=I[sign];events=d['EventIngredients'];nativecounts=d['NativePixelCounts']
 nativecounts=[x if isinstance(x,list) else [x] for x in nativecounts]
 durations=[(e['EndFrame']-e['StartFrame']+1)/fs for e in events]
 area=[sum(x)/len(x)*px**2 for x in nativecounts]
 support=I['Contract'][sign.title()+'SupportPixels'];A=support*px**2;covered=sum(d['UnionPixelCounts'])*px**2/fs;seconds=sum(durations);onsets=len(events);den=A*N/fs
 exported=rows('Oxy'+sign.title()+'Events')
 # Freeze original exported values alongside independent answers for later comparisons.
 answers['Expected'][sign]={'DurationSec':durations,'EventAreaUm2':area,'AreaUm2':A,'CoveredAreaTime':covered,'TissueTime':den,'EventOnsets':onsets,'ActiveEventSeconds':seconds,'Occupancy':covered/den,'OnsetRate':onsets*60e6/den,'ConcurrentDensity':seconds*1e6/den,'UnionAreaSeries':[x*px**2 for x in d['UnionPixelCounts']],'WorkbookEventDuration':[e['DurationSec'] for e in exported],'WorkbookEventArea':[e['EventArea_um2'] for e in exported],'FirstEvent':{**events[0],'DurationSec':durations[0],'NativePixelCounts':nativecounts[0],'EventAreaUm2':area[0]},'BoundaryCount':sum(e['StartFrame']==1 for e in events)}
(folder/'saved-expected.json').write_text(json.dumps(answers,indent=2)+'\n')
print('Frozen saved numerical examples:')
for sign,x in answers['Expected'].items():print(sign,{k:x[k] for k in ['AreaUm2','CoveredAreaTime','EventOnsets','ActiveEventSeconds','Occupancy','OnsetRate','ConcurrentDensity','FirstEvent']})
