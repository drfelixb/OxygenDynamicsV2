function Failures = handleWrapperFailure(Failures,fileName,ME,scriptName,subject,sendEmailAlerts,emailRecipient,interactiveMode)
%HANDLEWRAPPERFAILURE Shared wrapper catch-block bookkeeping.

errorMessage = sprintf('Error in %s.\nThe error reported by MATLAB is:\n\n%s',scriptName,ME.message);

if sendEmailAlerts
    sendolmail(emailRecipient,subject,errorMessage);
end

Failures = appendFailure(Failures,fileName,getReport(ME),ME.message);

if interactiveMode
    uiwait(warndlg(errorMessage));
else
    fprintf('%s\n',errorMessage);
end

end
