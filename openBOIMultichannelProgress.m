function fig=openBOIMultichannelProgress(folder,recordingID)
% Show live stages for an existing paired run by reading its status records.
% This window can run in a separate MATLAB session while the owner is busy.
setupOxygenDynamicsPath;
if nargin<1
    folder=uigetdir(pwd,'Select the Multichannel result folder to follow');
    if isequal(folder,0), fig=[]; return; end
end
pairFile=fullfile(folder,'PairStatus.json');
assert(isfile(pairFile),'BOIPair:Status','Choose the result folder containing PairStatus.json.');
if nargin<2, [~,recordingID]=fileparts(folder); end
fig=uifigure('Name','Multichannel run progress','Position',[130 170 650 155]);
g=uigridlayout(fig,[3 1]); g.RowHeight={28,'1x',25}; g.Padding=[16 12 16 12];
titleLabel=uilabel(g,'Text',char(recordingID),'Interpreter','none','FontSize',17,'FontWeight','bold');
stageLabel=uilabel(g,'Text','Reading run status…','Tag','PairStage','Interpreter','none','FontSize',15,'WordWrap','on');
updated=uilabel(g,'Text','','Interpreter','none');
poll=timer('ExecutionMode','fixedSpacing','Period',2,'BusyMode','drop','TimerFcn',@refresh);
fig.DeleteFcn=@release;
start(poll); refresh();
    function refresh(~,~)
        pair=readStatus(pairFile);
        if isempty(pair)
            updated.Text='Waiting for the next readable update…'; return
        end
        if isfield(pair,'RecordingID'), titleLabel.Text=char(pair.RecordingID); end
        done=strcmp(pair.Status,'complete') || strcmp(pair.Status,'failed');
        if strcmp(pair.Status,'complete')
            message='Complete  ·  Paired results saved';
        elseif strcmp(pair.Status,'failed')
            message=['Failed during ' char(pair.Stage)];
            if isfield(pair,'Error'), message=[message '  ·  ' char(pair.Error)]; end
        else
            token=regexp(pair.Stage,'^RC1 channel ([12]) \((.*)\)$','tokens','once');
            if ~isempty(token)
                c=str2double(token{1}); code='preflight';
                channelFile=fullfile(folder,'Runs',sprintf('Channel%d',c),'RunStatus.json');
                if isfile(channelFile)
                    child=readStatus(channelFile);
                    if isempty(child), updated.Text='Waiting for the next readable update…'; return; end
                    code=child.Stage;
                    if strcmp(child.Status,'failed'), code=['Failed during ' char(code)]; end
                end
                message=boiPairChannelStage(c,token{2},code);
            elseif isfield(pair,'DisplayStage')
                message=pair.DisplayStage;
            elseif strcmp(pair.Stage,'staging')
                message='Preparing the paired input movies';
            elseif strcmp(pair.Stage,'paired measurements')
                message='Comparing the channels and saving paired results';
            else
                message=pair.Stage;
            end
        end
        stageLabel.Text=char(message);
        updated.Text=['Checked at ' char(datetime('now','Format','HH:mm:ss'))];
        if done && strcmp(poll.Running,'on'), stop(poll); end
    end
    function release(~,~)
        if isvalid(poll), stop(poll); delete(poll); end
    end
end

function s=readStatus(path)
% A writer may be replacing JSON contents between polls.
s=[];
try
    value=jsondecode(fileread(path));
    if isstruct(value) && isscalar(value) && all(isfield(value,{'Stage','Status'}))
        s=value;
    end
catch
    % Keep the preceding display while the file or sync volume is unavailable.
end
end
