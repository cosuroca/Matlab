% STARTUP
%
%   Matlab startup file
%

%% AUTHOR    : Sebastian Eicke (sebastian.eicke@gmail.com)
%% DATE      : 24. April 2013
%% DEVELOPED : 8.1.0.604 (R2013a)
%% FILENAME  : startup.m

close all;
clear all;
clc;

homeDir = '.';

if ismac
    [rep, macName] = system('HOSTNAME');
    macName = deblank(macName);
    
    if strcmp(macName, 'seiBook.local')		% Macbook
		homeDir = '/Users/seicke/Dropbox/Code/Matlab/';
	end
	
	if strcmp(macName, 'seiMac.local')		% iMac
        homeDir = '/Users/seicke/Dropbox/Code/Matlab/';
    end
    addpath(genpath(homeDir));
    rmpath(fullfile(homeDir, 'tests'));
    rmpath(genpath(fullfile(homeDir, '.git')));
end

if ispc
	pcName = getenv('COMPUTERNAME');
	
	if strcmp(pcName, 'SEWORK')		% @Work
		homeDir = 'C:/Users/Sebastian Eicke/Dropbox/Code/Matlab';
    end
end

cd(homeDir)
clear all;