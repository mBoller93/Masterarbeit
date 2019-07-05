function logString(string, mode)
%LOGSTRING Summary of this function goes here
%   Detailed explanation goes here
if(nargin < 2)
    mode = 'a';
end
fileID = fopen( [getRootDir() '/Results/log/logging.txt'], mode);
fprintf(fileID, string);
fclose(fileID);
end

