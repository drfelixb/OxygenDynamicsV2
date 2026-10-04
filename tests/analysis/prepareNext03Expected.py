"""Freeze six input fixtures and two saved cases using independent arithmetic."""
from pathlib import Path
import json, math, statistics, hashlib, datetime
import openpyxl
root=Path(__file__).resolve().parents[3]
folder=root/'reference-validation/software-next03-calculations-20261004'

def finite(v): return v is not None and math.isfinite(v)
def strict_sum(v):return sum(v) if all(finite(x) for x in v) else None
def mean(v):v=[x for x in v if finite(x)];return sum(v)/len(v) if v else None
def median(v):v=[x for x in v if finite(x)];return statistics.median(v) if v else None
def scale(v,f):return v*f if finite(v) and finite(f) else None

def calculate(events,registry):
    enriched=[]
    for e in events:
        v=e['AmplitudePercent'];v=-v if finite(v) and e.get('SignConvention')=='negative_drop_percent' else v
        v=v if finite(v) and v>=0 else None
        a=e['AreaUm2'];d=e['DurationSec'];c=v*a*d if all(finite(x) for x in [v,a,d]) else None
        enriched.append({**e,'Amplitude':v,'Area':a,'Duration':d,'Contribution':c,
            'PerMm2':scale(c,1e6/e['RecordingAreaUm2']),
            'PerSec':scale(c,1/e['RecordingDurationSec']),
            'PerMin':scale(c,60/e['RecordingDurationSec']),
            'PerMm2Sec':scale(c,1e6/e['RecordingAreaUm2']/e['RecordingDurationSec']),
            'PerMm2Min':scale(c,1e6/e['RecordingAreaUm2']/e['RecordingDurationSec']*60)})
    recording=[]
    for r in registry:
        es=[e for e in enriched if e['RecordingID']==r['RecordingID']];c=[e['Contribution'] for e in es]
        total=strict_sum(c);A=r['RecordingAreaUm2'];T=r['RecordingDurationSec']
        row={**r,'NumEvents':len(es),'NumSites':len(set(e['SiteID'] for e in es)),
             'ValidContributions':sum(finite(x) for x in c),'Total':total,'PerMm2':scale(total,1e6/A),
             'PerSec':scale(total,1/T),'PerMin':scale(total,60/T),'PerMm2Sec':scale(total,1e6/A/T),'PerMm2Min':scale(total,1e6/A/T*60),
             'MeanContribution':mean(c),'MedianContribution':median(c),'MeanPerMm2Contribution':mean([e['PerMm2'] for e in es]),
             'MeanAmplitude':mean([e['Amplitude'] for e in es]),'MeanArea':mean([e['Area'] for e in es]),'MeanDuration':mean([e['Duration'] for e in es]),
             'Contributors':{'Contribution':sum(finite(x) for x in c),'Amplitude':sum(finite(e['Amplitude']) for e in es),'Area':sum(finite(e['Area']) for e in es),'Duration':sum(finite(e['Duration']) for e in es)}}
        recording.append(row)
    groups={}
    metrics=['Total','PerMm2','PerSec','PerMin','PerMm2Sec','PerMm2Min','MeanAmplitude','MeanArea','MeanDuration']
    mice=sorted(set(r['Mouse'] for r in registry))
    for metric in metrics:
        values=[];byMouse=[]
        for m in mice:
            rows=[r for r in recording if r['Mouse']==m];v=[r[metric] for r in rows]
            mv=sum(v)/len(v) if all(finite(x) for x in v) else None
            byMouse.append({'Mouse':m,'Value':mv,'ContributingRecordings':sum(finite(x) for x in v),'TotalRecordings':len(v)})
            if finite(mv):values.append(mv)
        groups[metric]={'Mean':mean(values),'SEM':statistics.stdev(values)/math.sqrt(len(values)) if len(values)>1 else None,'ValidMice':len(values),'TotalMice':len(mice),'WithinMouse':byMouse}
    return {'Events':enriched,'Recordings':recording,'Group':groups}

def R(ids,mice,area=1e6,T=10,fs=1):
    return [{'RecordingID':i,'Mouse':m,'RecordingAreaUm2':area,'RecordingDurationSec':T,'SampleHz':fs,'NFrames':round(T*fs)} for i,m in zip(ids,mice)]
def E(reg,rec,amp,area=1,duration=1,site=1,event=1):
    r=next(x for x in reg if x['RecordingID']==rec)
    return {'RecordingID':rec,'Mouse':r['Mouse'],'SiteID':site,'EventID':event,'AmplitudePercent':amp,'AreaUm2':area,'DurationSec':duration,'StartFrame':2+event-1,'EndFrame':2+event-1+round((duration if duration is not None else 1)*r['SampleHz'])-1,'RecordingAreaUm2':r['RecordingAreaUm2'],'RecordingDurationSec':r['RecordingDurationSec'],'SampleHz':r['SampleHz']}
fixtures=[]
for k in range(1,7):
    raw=[100,100,80,90,110,120] if k==1 else [100,100,80,90,100,90]
    reg=R(['r1'],['m1'],2e6,4,2);events=[E(reg,'r1',20,4,2)]
    if k==3:
        reg=R(['r1','r2','r3'],['m1','m1','m2']);events=[E(reg,'r1',10)]+[E(reg,'r2',20,site=j,event=1) for j in [1,2]]+[E(reg,'r3',100,site=1 if j<5 else 2,event=j if j<5 else 1) for j in range(1,6)]
    elif k==4:
        reg=R(['r1','r2','r3'],['m1','m1','m2']);events=[E(reg,'r1',10,event=1),E(reg,'r1',None,event=2),E(reg,'r1',20,area=None,event=3),E(reg,'r1',30,duration=None,event=4),E(reg,'r1',-5,event=5),E(reg,'r2',40),E(reg,'r3',50)]
    elif k==5:reg=R(['r1','r2','r3'],['m1','m1','m2']);events=[]
    elif k==6:
        reg=R(['r1'],['m1'],250000,30,2);events=[E(reg,'r1',-10,2,2),E(reg,'r1',0,2,1,event=2)]
        for e in events:e['SignConvention']='negative_drop_percent'
    c={'ID':f'F{k:02d}','Name':['signed cancellation','negative integral and explicit conversion','unequal events and recordings per mouse','missing contributions and strict mouse completeness','zero-event recordings retained','explicit older sign provenance and original version unknown'][k-1],'Registry':reg,'Events':events,'Expected':calculate(events,reg)}
    if k in [1,2]:c['Trace']={'Raw':raw,'ReferenceFrames':[1,2],'MeasurementStartFrame':3,'MeasurementEndFrame':6,'SampleHz':2,'ExpectedFractionSec':sum((v-100)/100 for v in raw[2:])/2,'ExpectedPercentSec':100*sum((v-100)/100 for v in raw[2:])/2}
    c['ExpectedOriginalSoftware']='1.01' if k==2 else 'unknown'
    fixtures.append(c)
(folder/'cases.json').write_text(json.dumps({'FrozenUTC':datetime.datetime.now(datetime.timezone.utc).isoformat(),'Cases':fixtures},indent=2)+'\n')

def sheet(w,name):
    it=iter(w[name].values);h=next(it);return [dict(zip(h,r)) for r in it]
paths=['software-g2-workflow-20260923/gui-run/statistics/Stats_Output_20260923T102730','boi-c02-strict-roi-20260912/run-01/statistics/Stats_Output_20260912T155949']
saved=[]
for k,spec in enumerate(paths,1):
    p=root/'reference-validation'/spec;w=openpyxl.load_workbook(p/'FilteredData_input.xlsx',read_only=True,data_only=True);I=json.loads((folder/f'saved-{k:02d}-ingredients.json').read_text())
    registry=[{'RecordingID':r['RecordingID'],'Mouse':r['Mouse'],'RecordingAreaUm2':r['RecordingArea_um2'],'RecordingDurationSec':r['RecordingDuration_sec'],'SampleHz':r['SampleF'],'NFrames':r['NFrames']} for r in sheet(w,'RecordingRegistry')]
    specific={(r['RecordingID'],r['SinkID'],r['EventIndex']):r['Area_um'] for r in I['EventSpecificAreaIngredients']}
    originals=sheet(w,'OxySinkEvents');events=[]
    for e in originals:
        key=(e['RecordingID'],e['SinkID'],e['EventID']);area=specific[key] if key in specific else e['EventArea_um2']
        events.append({'RecordingID':e['RecordingID'],'Mouse':e['Mouse'],'SiteID':e['SinkID'],'EventID':e['EventID'],'AmplitudePercent':e['NormOxySinkAmpPercent'],'AreaUm2':area,'DurationSec':e['DurationSec'],'StartFrame':e['StartFrame'],'EndFrame':e['EndFrame'],'RecordingAreaUm2':e['RecAreaSize'],'RecordingDurationSec':e['RecDuration'],'SampleHz':e['SampleF'],'SignConvention':e['AmplitudeSignConvention']})
    signed=[]
    for sign in ['sink','surge']:
        table=sheet(w,'Oxy'+sign.title()+'Events')
        for e in table:
            a=[a for a in I['AuditRows'] if a['EventType']==sign and a['SiteID']==e[sign.title()+'ID'] and a['EventID']==e['EventID']]
            assert len(a)==1
            a=a[0];assert a['StartFrame']==e['StartFrame'] and a['EndFrame']==e['EndFrame']
            refs=a['ReferenceValues'];refs=refs if isinstance(refs,list) else [refs];values=a['MeasurementValues'];values=values if isinstance(values,list) else [values]
            B=mean(refs);q=None
            if e['BaselineStatus']=='valid' and a['RecomputedStatus']=='valid' and finite(B) and B>0 and len(refs)==a['RequiredReferenceSamples'] and all(finite(v) for v in values):q=[(v-B)/B for v in values]
            signed.append({'EventType':sign,'SiteID':e[sign.title()+'ID'],'EventID':e['EventID'],'FractionSec':sum(q)/registry[0]['SampleHz'] if q is not None else None,'OriginalSignedTraceAUC_sec':e['SignedTraceAUC_sec'],'ReferenceMean':B if q is not None else None,'ReferenceValues':refs if q is not None else [],'MeasurementValues':values if q is not None else [],'StartFrame':e['StartFrame'],'EndFrame':e['EndFrame']})
    answer={'ID':f'S{k:02d}','StatisticsPath':str(p/'DataOutput.mat'),'SourceSHA256':hashlib.sha256((p/'DataOutput.mat').read_bytes()).hexdigest(),'ExpectedOriginalSoftware':'unknown','SavedContract':I['StatsInfo']['PipelineContract'],'Registry':registry,'Expected':calculate(events,registry),'SignedIntegrals':signed,'WorkbookRecordingRows':sheet(w,'HypoxicBurden_ByRecording'),'WorkbookGroupRows':sheet(w,'HypoxicBurden_GroupSummary')}
    saved.append(answer)
    ex=answer['Expected']['Recordings'][0];first=next(x for x in signed if finite(x['FractionSec']))
    print(answer['ID'],{x:ex[x] for x in ['NumEvents','ValidContributions','Total','MeanContribution','MeanAmplitude']},'first finite signed integral', {x:first[x] for x in ['EventType','SiteID','EventID','FractionSec']})
(folder/'saved-expected.json').write_text(json.dumps({'SavedCases':saved},indent=2)+'\n')
