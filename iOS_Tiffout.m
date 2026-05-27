%% Legacy script shim for intrinsic optical signal TIFF export
% The maintained implementation lives in runiOSTiffout.m.

setupOxygenDynamicsPath();

TiffoutContext = struct();
if exist('SFs','var')
    TiffoutContext.SFs = SFs;
end
if exist('PiSz','var')
    TiffoutContext.PiSz = PiSz;
end
if exist('strOW','var')
    TiffoutContext.strOW = strOW;
end

TiffoutOutput = runiOSTiffout(pwd,TiffoutContext);
Tifffiles = TiffoutOutput.Tifffiles;
RecDur = TiffoutOutput.RecDur;
OutputFolders = TiffoutOutput.OutputFolders;
AnalysisInfo = TiffoutOutput.AnalysisInfo;
DatafileID = TiffoutOutput.DatafileID;
