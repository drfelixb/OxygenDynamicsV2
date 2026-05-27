function Failures = appendFailure(Failures,fileName,errorReport,message)
%APPENDFAILURE Append one standardized wrapper failure record.

FailureRow = numel(Failures)+1;
Failures(FailureRow).FileName = fileName;
Failures(FailureRow).ERROR = errorReport;
Failures(FailureRow).MESSAGE = message;

end
