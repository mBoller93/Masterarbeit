function [ rootDir ] = getRootDir()
% GETROOTDIR Returns the root directory of the framework
currentDir = pwd;

parts = strsplit(currentDir, filesep);
rootDir = parts(1:end-1);
rootDir = strjoin(rootDir, filesep);
rootDir = [rootDir filesep];
end




