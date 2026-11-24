function Pair = runBOIMultichannel(Options,progress)
% Run RC1 independently on oxygen channels, then extract paired measurements.
if nargin<2, progress = @(message)fprintf('%s\n',message); end
O = prepareBOIMultichannel(Options);
out = O.OutputFolder;
[ok,message,id] = mkdir(out);
assert(ok && isempty(id),'BOIPair:Destination','Cannot claim a new folder: %s',message);
statusFile = fullfile(out,'PairStatus.json');
status = struct('Schema','boi-pair-status-1','Status','running','Stage','staging','RecordingID',char(O.RecordingID));
status.CalculationSoftware=getOxygenPipelineVersion();
writeBOIRunJSON(statusFile,status);
try
    sources = strings(1,2); rawHash = strings(1,2); denoisedHash = strings(1,2);
    channelRuns = strings(1,2); evidence = cell(1,2);
    nOxygen = 1 + double(O.Mode=="dual-bli");
    letters='AB';
    for c = 1:2
        announce('staging',sprintf('Channel %s (%s)  ·  Copying and checking the input movies',letters(c),O.Sensors(c)));
        folder = fullfile(out,'Inputs',sprintf('Channel%d',c));
        mkdir(folder);
        sources(c) = fullfile(folder,'preserved.tif');
        rawHash(c) = copyChecked(O.RawFiles(c),sources(c));
        if O.DenoisedFiles(c)~=""
            denoisedHash(c) = copyChecked(O.DenoisedFiles(c),fullfile(folder,'denoised.tif'));
        end
    end
    % Declarations are attached by raw source digest, including in shared folders.
    profiles = repmat("whole-image",1,nOxygen);
    for c = 1:nOxygen
        original = fileparts(O.RawFiles(c));
        for name = ["BOIInputMetadata.json","BOITissueSupport.json"]
            sidecar = fullfile(original,name);
            if ~isfile(sidecar), continue; end
            declaration = jsondecode(fileread(sidecar));
            assert(isfield(declaration,'RawSHA256') && any(rawHash==string(declaration.RawSHA256)), ...
                'BOIPair:Declaration','Source declaration does not match either selected movie: %s',sidecar);
            if rawHash(c)==string(declaration.RawSHA256)
                copyChecked(sidecar,fullfile(fileparts(sources(c)),name));
                if name=="BOITissueSupport.json", profiles(c)="craniotomy-roi-1"; end
            end
        end
    end
    for c = 1:nOxygen
        announce(sprintf('RC1 channel %d (%s)',c,O.Sensors(c)),boiPairChannelStage(c,O.Sensors(c),'preflight'));
        channelRuns(c) = fullfile("Runs",sprintf('Channel%d',c));
        options = struct('RecordingFolder',char(fileparts(sources(c))), ...
            'OutputFolder',fullfile(out,char(channelRuns(c))),'SampleHz',O.SampleHz, ...
            'PixelSizeUm',O.PixelSizeUm,'Mouse',char(O.RecordingID),'Promoter',char(O.Promoters(c)), ...
            'SupportProfile',char(profiles(c)));
        for field = ["Mouse","Condition","Genotype","DrugID"]
            if isfield(O,field) && strlength(string(O.(field)))>0, options.(field)=char(O.(field)); end
        end
        request = prepareBOIRecordingRequest(options);
        run = runBOIRecordingWorkflow(request,@(child,~)progress(boiPairChannelStage(c,O.Sensors(c),child.Stage)));
        assert(string(run.SourceSHA256)==rawHash(c),'BOIPair:Source','Independent run used a different source.');
        announce('channel evidence',boiPairChannelStage(c,O.Sensors(c),'evidence'));
        evidence{c} = pairEvidence(run);
    end
    announce('paired measurements','Comparing the channels and extracting same-footprint traces');
    Pair = buildBOIMultichannelResult(O,evidence,sources);
    Pair.CalculationSoftware=status.CalculationSoftware;
    Pair.RawSHA256 = rawHash; Pair.DenoisedSHA256 = denoisedHash; Pair.ChannelRuns = channelRuns;
    Pair.Channels.PreservedSHA256=rawHash(:); Pair.Channels.DenoisedSHA256=denoisedHash(:);
    Pair.Channels.SampleHz=repmat(O.SampleHz,2,1); Pair.Channels.PixelSizeUm=repmat(O.PixelSizeUm,2,1);
    Pair.Channels.RC1Run=channelRuns(:);
    announce('verifying sources','Verifying the preserved movies');
    for c = 1:2
        assert(string(oxygenFileSHA256(sources(c)))==rawHash(c),'BOIPair:Source','Staged movie changed during measurement.');
    end
    announce('writing workbook','Writing the paired Excel workbook');
    workbook = fullfile(out,'Multichannel.xlsx');
    writeBOIPairedSheet(Pair.Channels,workbook,'Channels');
    writeBOIPairedSheet(Pair.Summary,workbook,'Recording summary');
    writeBOIPairedSheet(Pair.Events(Pair.Events.Sign=="sink",:),workbook,'Sinks');
    writeBOIPairedSheet(Pair.Events(Pair.Events.Sign=="surge",:),workbook,'Surges');
    writeBOIPairedSheet(Pair.Links,workbook,'Candidate sink links');
    writeBOIPairedSheet(Pair.Comparisons,workbook,'Paired differences');
    writeBOIPairedSheet(oxygenSoftwareProvenanceTable(Pair),workbook,'SoftwareProvenance');
    announce('saving result','Saving and verifying the paired MATLAB result');
    save(fullfile(out,'Multichannel.mat'),'Pair','-v7.3');
    status.ResultSHA256 = oxygenFileSHA256(fullfile(out,'Multichannel.mat'));
    status.WorkbookSHA256 = oxygenFileSHA256(workbook);
    status.Status = 'complete'; announce('complete','Complete  ·  Paired results saved');
catch err
    status.Status = 'failed'; status.Error = err.message;
    writeBOIRunJSON(statusFile,status); rethrow(err)
end
    function announce(stage,message)
        status.Stage=stage; status.DisplayStage=message;
        writeBOIRunJSON(statusFile,status);
        try
            progress(message);
        catch displayError
            warning('BOIPair:ProgressDisplay','Stage saved; the progress display could not update: %s',displayError.message);
        end
    end
end

function digest = copyChecked(source,destination)
digest = string(oxygenFileSHA256(source));
[ok,message] = copyfile(source,destination);
assert(ok,'BOIPair:Copy','%s',message);
assert(string(oxygenFileSHA256(destination))==digest,'BOIPair:Copy','Source changed during copy: %s',source);
end

function D = pairEvidence(run)
audit = load(run.Paths.EventAudit,'Audit','Traces','AnalysisInfo');
D = audit;
% Keep RC1 native per-frame support for coincident-pixel checks and native area.
D.Native = cell(height(D.Audit),1); D.MeanArea = nan(height(D.Audit),1);
for kind = ["Sink","Surge"]
    siteName = "Table_Oxygen"+kind+"s_Out"; eventName = "Table_Oxygen"+kind+"Events_Out";
    master = load(run.Paths.(kind+"Master"),siteName,eventName);
    sites = master.(siteName); events = master.(eventName);
    indices = find(D.Audit.EventType==lower(kind));
    if kind=="Sink"
        saved = events(D.Audit.EventRow(indices),:);
        D.Sinks = saved(:,{'EventReferenceKind','EventReferenceStatus','EventReferenceNeedsReview', ...
            'EventReferenceStartFrame','EventReferenceEndFrame','EventReferenceFiniteSamples','EventAmplitudeNegative'});
        D.Sinks.Depth = getBOISinkBurdenAmplitude(saved,D.AnalysisInfo.BurdenSelectionPolicy);
    end
    for e = indices'
        a = D.Audit(e,:); row = a.EventRow;
        assert(events.(kind+"ID")(row)==a.SiteID && events.EventID(row)==a.EventID ...
            && string(events.RecordingID(row))==a.RecordingID,'BOIPair:Identity','Event provenance mismatch.');
        native = sites.FramePixels{a.SiteID};
        D.Native{e} = native(D.Traces{e}.DetectedFrames);
        D.MeanArea(e) = events.EventArea_um2(row);
    end
end
end
