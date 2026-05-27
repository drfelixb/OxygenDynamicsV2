function sendolmail(to,subject,body,attachments)
%SENDOLMAIL Send email using Microsoft Outlook.
%
% The wrapper scripts keep email alerts optional through RunConfig. This
% helper centralizes the Outlook call used by both wrappers.

h = actxserver('outlook.Application');
mail = h.CreateItem('olMail');
mail.Subject = subject;
mail.To = to;
mail.BodyFormat = 'olFormatHTML';
mail.HTMLBody = body;

if nargin == 4
    for i = 1:length(attachments)
        mail.attachments.Add(attachments{i});
    end
end

mail.Send;
h.release;

end
