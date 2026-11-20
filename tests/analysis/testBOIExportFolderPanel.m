function tests=testBOIExportFolderPanel
tests=functiontests(localfunctions);
end
function setupOnce(~)
setupOxygenDynamicsPath;
end
function [fig,p,root]=fixture()
root=tempname;mkdir(root);fig=uifigure('Visible','off');p=createBOIExportFolderPanel(fig);
end
function testInitiallyDisabled(t)
[fig,p,root]=fixture();cleanup=onCleanup(@()dispose(fig,root));
verifyEmpty(t,p.Folder());verifyEqual(t,p.OpenButton.Enable,matlab.lang.OnOffSwitchState.off);
verifyEqual(t,p.CopyButton.Enable,matlab.lang.OnOffSwitchState.off);
verifyError(t,@()p.Open(),'OxygenDynamics:ExportFolderMissing');
end
function testCancellationNeverWrites(t)
[fig,p,root]=fixture();cleanup=onCleanup(@()dispose(fig,root));
r=p.ChooseAndExport(@writeExport,root,'event_',0);verifyEmpty(t,r);
verifyEmpty(t,p.Folder());verifyEqual(t,numel(dir(root)),2);
verifyEqual(t,p.OpenButton.Enable,matlab.lang.OnOffSwitchState.off);
verifyTrue(t,contains(p.Message.Text,'cancelled'));
end
function testSuccessfulPathPersistsAndCopies(t)
[fig,p,root]=fixture();cleanup=onCleanup(@()dispose(fig,root));
oldClipboard=clipboard('paste');restore=onCleanup(@()clipboard('copy',oldClipboard));
target=fullfile(root,'export with spaces and ''quote'' $literal');p.ExportTo(@writeExport,target);
verifyEqual(t,p.Folder(),target);verifyEqual(t,p.Path.Value,{target});verifyEqual(t,p.Path.Editable,matlab.lang.OnOffSwitchState.off);
verifyEqual(t,p.Copy(),target);verifyEqual(t,clipboard('paste'),target);
verifyEqual(t,p.OpenButton.Enable,matlab.lang.OnOffSwitchState.on);
end
function testFailedIncompleteExportDoesNotEnableControls(t)
[fig,p,root]=fixture();cleanup=onCleanup(@()dispose(fig,root));target=fullfile(root,'incomplete');
verifyError(t,@()p.ExportTo(@writeFailure,target),'OxygenDynamics:PlannedExportFailure');
verifyTrue(t,isfolder(target));verifyEmpty(t,p.Folder());
verifyEqual(t,p.OpenButton.Enable,matlab.lang.OnOffSwitchState.off);
verifyEqual(t,p.CopyButton.Enable,matlab.lang.OnOffSwitchState.off);
verifyTrue(t,contains(p.Message.Text,'failed'));
end
function testFailureOrCancelKeepsPreviousSuccess(t)
[fig,p,root]=fixture();cleanup=onCleanup(@()dispose(fig,root));target=fullfile(root,'complete');
p.ExportTo(@writeExport,target);p.ChooseAndExport(@writeExport,root,'event_',0);
verifyEqual(t,p.Folder(),target);verifyEqual(t,p.Path.Value,{target});
verifyError(t,@()p.ExportTo(@writeFailure,fullfile(root,'incomplete')),'OxygenDynamics:PlannedExportFailure');
verifyEqual(t,p.Folder(),target);verifyEqual(t,p.Path.Value,{target});
verifyEqual(t,p.OpenButton.Enable,matlab.lang.OnOffSwitchState.on);
end
function testExistingDestinationRemainsProtected(t)
[fig,p,root]=fixture();cleanup=onCleanup(@()dispose(fig,root));target=fullfile(root,'old');
mkdir(target);verifyError(t,@()p.ExportTo(@writeExport,target),'OxygenDynamics:ExportExists');
verifyEmpty(t,p.Folder());verifyEqual(t,p.OpenButton.Enable,matlab.lang.OnOffSwitchState.off);
end
function Receipt=writeExport(folder)
assert(~isfolder(folder),'OxygenDynamics:ExportExists','Previous export is preserved.');
mkdir(folder);Receipt=struct('Folder',folder);
end
function Receipt=writeFailure(folder)
mkdir(folder);error('OxygenDynamics:PlannedExportFailure','Intentional partial export for feedback check.');
Receipt=[]; %#ok<UNRCH>
end
function dispose(fig,root)
if isgraphics(fig),delete(fig);end
if isfolder(root),rmdir(root,'s');end
end
