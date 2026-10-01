function Report=runBOIBaselineTimingChallenge(outputDir,planPath)
% Fixed R2 measurement challenge, with supplied masks; never run detection.
% The frozen recipe is mandatory. Outputs go to a new directory.
project=fileparts(fileparts(fileparts(mfilename('fullpath'))));
if nargin<2,planPath=fullfile(project,'docs','planning','boi-baseline-timing-20260912.json');end
assert(~isfolder(outputDir),'OxygenDynamics:ExistingEvidence','Use a new output directory.');
mkdir(outputDir);setupOxygenDynamicsPath;
copyfile(planPath,fullfile(outputDir,'executed-plan.json'));
P=jsondecode(fileread(planPath));clockStart=tic;
Report=struct('DecisionID',P.decision_id,'Status','running');
try
    A=createOxygenMasterParams(1,1);
    assert(A.quantBaselineWindowSec==20 && A.surgeBaselineWindowSec==20 ...
        && A.eventBaselineReturnTolerance==.015 && A.sinkTimingMaxExtensionSec==20, ...
        'OxygenDynamics:ChallengeSettings','Current settings differ from the frozen recipe.');
    assert(P.settings.fs_hz==1 && P.settings.baseline_seconds==20 ...
        && P.settings.sink_return_tolerance==.015 && P.settings.sink_max_extension_seconds==20 ...
        && P.settings.frames==100 && isequal(P.settings.frame_shape(:)',[4 4]) ...
        && P.settings.pixel_size_um==1);
    manifest=createOxygenRegressionCodeManifest(project);
    writetable(manifest,fullfile(outputDir,'code-manifest.csv'));
    results=cell(0,1);traces=cell(0,1);audits=cell(0,1);fixtures=cell(0,1);
    for sign=["sink","surge"]
        for j=1:numel(P.amplitude_cases)
            id=string(P.amplitude_cases(j).id);
            [S,E,px,other,raw,imposed,X]=amplitudeFixture(id,sign);
            native=find(~cellfun(@isempty,px(1,:)));
            native=native(native>=X.NativeStart & native<=X.NativeEnd);
            before=[E.StartFrame E.EndFrame E.EventID];
            [S,E]=finalizeOxygenEventMeasurements(S,E,px,raw,1,1,0,id,sign,20,other,0);
            O=table({other},'VariableNames',{'FramePixels'});
            [audit,trace]=auditOxygenEventFootprints(S,E,O,raw,20,sign);
            amp=E.(char("NormOxy"+capitalize(sign)+"Amp"));
            passed=all(audit.MeasurementMatches) && isequal(before,[E.StartFrame E.EndFrame E.EventID]) ...
                && E.BaselineStatus==X.Status && E.BaselineValidSamples==X.Clean ...
                && equalNumber(E.BaselineValue,X.Baseline) && equalNumber(amp,X.Amplitude) ...
                && equalNumber(E.SignedTraceAUC_sec,X.Integral);
            r=struct('CaseID',id,'Sign',sign,'EventID',E.EventID, ...
                'NativeStartFrame',native(1),'NativeEndFrame',native(end), ...
                'MeasurementStartFrame',E.StartFrame,'MeasurementEndFrame',E.EndFrame, ...
                'NativeDurationSec',numel(native),'MeasurementDurationSec',E.DurationSec, ...
                'FootprintPixels',audit.FootprintPixels,'BaselineValue',E.BaselineValue, ...
                'ExpectedBaseline',X.Baseline,'BaselineStatus',E.BaselineStatus,'ExpectedStatus',X.Status, ...
                'CleanSamples',E.BaselineValidSamples,'ExpectedCleanSamples',X.Clean, ...
                'OverlapExcludedFrames',audit.OverlapExcludedFrames,'NonfiniteBaselineFrames',audit.NonfiniteBaselineFrames, ...
                'TruncatedBaseline',audit.TruncatedBaseline,'MeasuredPeakFraction',amp, ...
                'ExpectedPeakFraction',X.Amplitude,'SignedIntegralSec',E.SignedTraceAUC_sec, ...
                'ExpectedSignedIntegralSec',X.Integral,'ImposedFixedFootprintPeakFraction',X.FixedPeak, ...
                'ImposedActivePixelPeakFraction',X.LocalPeak, ...
                'DifferenceFromImposedFixedPeak',amp-X.FixedPeak, ...
                'IndependentAuditMatches',audit.MeasurementMatches,'Passed',passed);
            results{end+1}=struct2table(r); %#ok<AGROW>
            f=trace{1}.Footprint;flat=reshape(imposed,[],100);
            frame=(1:100)';chosen=false(100,1);chosen(trace{1}.CleanBaselineFrames)=true;
            n=false(100,1);n(native)=true;m=false(100,1);m(E.StartFrame:E.EndFrame)=true;
            traces{end+1}=table(repmat(id,100,1),repmat(sign,100,1),frame,frame-1, ...
                trace{1}.Raw(:),mean(flat(f,:),1)',chosen,n,m, ...
                'VariableNames',{'CaseID','Sign','Frame','StartSec','RawFixedFootprintMean', ...
                'ImposedFixedFootprintMean','CleanBaseline','NativeSupport','MeasurementSupport'}); %#ok<AGROW>
            audit.CaseID=repmat(id,height(audit),1);audits{end+1}=audit; %#ok<AGROW>
            fixtures{end+1}=struct('CaseID',id,'Sign',sign,'Sites',S,'Events',E, ...
                'OtherPixels',{other},'Raw',raw,'Imposed',imposed,'Expected',X); %#ok<AGROW>
        end
    end
    Amplitude=vertcat(results{:});Traces=vertcat(traces{:});Audits=vertcat(audits{:});
    timing=cell(numel(P.timing_cases),1);timingTraces=cell(size(timing));
    for j=1:numel(timing)
        c=P.timing_cases(j);id=string(c.id);x=.1*ones(1,100);x(36:50)=-.1;
        native=41:45;limits=[1 100];
        switch id
            case 'connected'
            case 'weak_below_tolerance',x(36:50)=-.01;
            case 'extension_limit',x(:)=-.1;
            case 'recording_boundary',x(:)=.1;x(1:10)=-.1;native=1:5;
            case 'missing_search',x(38)=NaN;
            case 'missing_seed',x(41)=NaN;
            case 'native_crossing',x(43)=.1;
            case 'neighbor_partition',limits=[39 47];
            case 'crossing_at_limit',x(21:65)=-.1;
            case 'opposite_excursion',x(25:70)=-.1;x([38 48])=.1;
            otherwise,error('OxygenDynamics:UnknownChallengeCase','Unknown timing recipe %s',id);
        end
        t=resolveSinkEventTiming(native,x,zeros(size(x)),A.eventBaselineReturnTolerance, ...
            A.sinkTimingMaxExtensionSec,limits(1),limits(2));
        t.CaseID=id;t.ExpectedStartFrame=c.bounds(1);t.ExpectedEndFrame=c.bounds(2);
        t.ExpectedStartStatus=string(c.statuses{1});t.ExpectedEndStatus=string(c.statuses{2});
        t.ExpectedResolved=c.resolved;
        t.Passed=isequal([t.StartFrame t.EndFrame],c.bounds(:)') ...
            && t.StartBoundaryStatus==t.ExpectedStartStatus && t.EndBoundaryStatus==t.ExpectedEndStatus ...
            && t.TimingResolved==c.resolved;
        timing{j}=struct2table(t);frame=(1:100)';n=false(100,1);n(native)=true;
        timingTraces{j}=table(repmat(id,100,1),frame,x(:),n,repmat(limits(1),100,1),repmat(limits(2),100,1), ...
            'VariableNames',{'CaseID','Frame','Residual','NativeSupport','LeftLimit','RightLimit'});
    end
    Timing=vertcat(timing{:});TimingTraces=vertcat(timingTraces{:});
    writetable(Amplitude,fullfile(outputDir,'amplitude-results.csv'));
    writetable(Traces,fullfile(outputDir,'amplitude-traces.csv'));
    writetable(Audits,fullfile(outputDir,'independent-footprint-audit.csv'));
    writetable(Timing,fullfile(outputDir,'timing-results.csv'));
    writetable(TimingTraces,fullfile(outputDir,'timing-traces.csv'));
    save(fullfile(outputDir,'Challenge.mat'),'Amplitude','Traces','Audits','Timing','TimingTraces','fixtures','A','P');
    assert(height(Amplitude)==34 && height(Timing)==10 && all(Amplitude.Passed) && all(Timing.Passed), ...
        'OxygenDynamics:MeasurementChallengeFailed','Fixed challenge disagrees; preserve outputs and investigate.');
    files={'testEventAmplitudeAudit.m','testLocalSinkTiming.m','testSurgeAmplitudeCounterfactual.m'};
    tests=runtests(fullfile(project,'tests','analysis',files));
    writetable(table(tests),fullfile(outputDir,'regression-tests.csv'));save(fullfile(outputDir,'regression-tests.mat'),'tests');
    assert(all([tests.Passed]),'OxygenDynamics:ChallengeRegression','Existing regression failed.');
    Report.Status='passed';Report.AmplitudeCases=height(Amplitude);Report.TimingCases=height(Timing);
    Report.RegressionTestsPassed=sum([tests.Passed]);Report.FiniteAmplitudes=sum(isfinite(Amplitude.MeasuredPeakFraction));
    Report.NegativeFiniteAmplitudes=sum(Amplitude.MeasuredPeakFraction<0);
    Report.UnavailableAmplitudes=sum(~isfinite(Amplitude.MeasuredPeakFraction));
    Report.RuntimeSeconds=toc(clockStart);Report.SourceStacksRead=0;Report.DetectorRuns=0;
    Report.ScientificAcceptance='Not established; analytical measurement/support challenge only.';
    writeJSON(fullfile(outputDir,'verification-report.json'),Report);
catch exception
    Report.Status='failed';Report.ErrorID=exception.identifier;Report.Message=exception.message;
    Report.RuntimeSeconds=toc(clockStart);writeJSON(fullfile(outputDir,'failure-report.json'),Report);
    rethrow(exception);
end
end

function [S,E,px,other,raw,imposed,X]=amplitudeFixture(id,kind)
direction=1;if kind=="sink",direction=-1;end
raw=100*ones(4,4,100);imposed=zeros(size(raw));px=cell(1,100);other=cell(1,100);
first=41;last=45;measureFirst=first;measureLast=last;k=1;level=20;
switch id
    case 'flat_zero',level=0;
    case 'weak_brief',level=2;last=41;measureLast=last;
    case 'strong_sustained',level=40;last=60;measureLast=last;
    case 'early_start',first=10;last=14;measureFirst=first;measureLast=last;
    case 'refined_interval',measureFirst=36;measureLast=50;
end
px(first:last)={1};imposed(1,1,first:last)=direction*level;
if id=="moving_footprint"
    imposed(:)=0;
    for f=first:last,p=1+mod(f-first,2);px{f}=p;imposed(p,1,f)=direction*level;end
end
if id=="refined_interval",imposed(1,1,[36:40 46:50])=direction*5;end
raw=raw+imposed;
X=struct('Status',"valid",'Clean',20,'Baseline',100,'Amplitude',level/100, ...
    'Integral',direction*level/100*(last-first+1),'FixedPeak',level/100, ...
    'LocalPeak',level/100,'NativeStart',first,'NativeEnd',last);
switch id
    case {'clean','flat_zero','weak_brief','strong_sustained'}
    case 'same_sign_prior',px{25}=1;k=2;raw(1,1,25)=100+direction*20;X.Clean=19;
    case 'opposite_sign_prior',other{25}=1;raw(1,1,25)=100-direction*20;X.Clean=19;
    case 'disjoint_prior',other{25}=2;raw(2,1,25)=100-direction*20;
    case 'early_start',X.Clean=9;
    case 'missing_baseline',raw(1,1,25)=NaN;X.Clean=19;
    case 'missing_event',raw(1,1,43)=NaN;X.Status="nonpositive_baseline_or_missing_event_signal";
    case 'nonpositive_baseline',raw(1,1,21:40)=0;X.Baseline=0;X.Status="nonpositive_baseline_or_missing_event_signal";
    case {'unmarked_same_tail','unmarked_opposite_tail'}
        tailDirection=direction;if id=="unmarked_opposite_tail",tailDirection=-direction;end
        raw(1,1,37:40)=100+tailDirection*20;X.Baseline=100+tailDirection*4;
        X.Amplitude=direction*(100+direction*20-X.Baseline)/X.Baseline;
        X.Integral=direction*X.Amplitude*5;
    case 'linear_drift'
        raw=raw+reshape(.2*(0:99),1,1,100);X.Baseline=105.9;
        peakBackground=108;if direction==1,peakBackground=108.8;end
        X.Amplitude=direction*(peakBackground+direction*20-X.Baseline)/X.Baseline;
        X.Integral=5*(108.4+direction*20-X.Baseline)/X.Baseline;
    case 'global_step'
        raw(:,:,41:end)=raw(:,:,41:end)-30;
        X.Amplitude=direction*(direction*20-30)/100;X.Integral=5*(direction*20-30)/100;
    case 'moving_footprint',X.FixedPeak=.1;X.Amplitude=.1;X.Integral=direction*.5;
    case 'refined_interval',X.Integral=direction*1.5;
    otherwise,error('OxygenDynamics:UnknownChallengeCase','Unknown amplitude recipe %s',id);
end
if X.Clean<20,X.Status="insufficient_clean_prebaseline";X.Baseline=NaN;end
if X.Status~="valid",X.Amplitude=NaN;X.Integral=NaN;end
prefix=char("MeanOxy"+capitalize(kind));amp=char("NormOxy"+capitalize(kind)+"Amp");
area='RecAreaSize';if kind=="surge",area='RecAreaSize_Surge';end
S=table({nan(1,k)},{16},'VariableNames',{amp,area});
E=table(1,k,measureFirst,measureLast,0,0,0,0,'VariableNames', ...
    {char(capitalize(kind)+"ID"),'EventID','StartFrame','EndFrame', ...
    [prefix 'Area_um'],[prefix 'FilledArea_um'],[prefix 'Diameter_um'],[prefix 'Perimeter_um']});
end
function s=capitalize(s),s=upper(extractBefore(s,2))+extractAfter(s,1);end
function yes=equalNumber(a,b)
yes=(isnan(a)&&isnan(b)) || (isfinite(a)&&isfinite(b)&&abs(a-b)<=1e-10*max(1,abs(b)));
end
function writeJSON(path,value)
f=fopen(path,'w');assert(f>=0);c=onCleanup(@()fclose(f));fprintf(f,'%s\n',jsonencode(value,PrettyPrint=true));
end
