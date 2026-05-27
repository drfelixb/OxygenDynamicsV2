function destination = getWrapperEmailDestination(RunConfig)
%GETWRAPPEREMAILDESTINATION Resolve optional wrapper email recipient.

if RunConfig.interactive && RunConfig.sendEmailAlerts
    prompt = {'Enter email alerts recipient:'};
    dlgtitle = 'Input';
    dims = [1 35];
    definput = {RunConfig.emailRecipient};
    answer = inputdlg(prompt,dlgtitle,dims,definput);

    if isempty(answer)
        destination = RunConfig.emailRecipient;
    else
        destination = answer{1};
    end
else
    destination = RunConfig.emailRecipient;
end

end
