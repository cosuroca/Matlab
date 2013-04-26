%% startup.m Matlab startup file
%
%  Author:   Sebastian Eicke (sebastian.eicke@gmail.com)
%  Date:     24. April 2013
%  Version:  13.04.24.19
%
%% Code
close all;
clear all;
clc;

homeDir = '.';

if ismac
    [rep, macName] = system('HOSTNAME');
    macName = deblank(macName);
    
    if strcmp(macName, 'seiBook.local')		% Macbook
		homeDir = '/Users/seicke/Dropbox/Code/Matlab/'
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
		homeDir = 'D:/Dropbox/Uni/Postdoc/';
    end
end

cd(homeDir)
clear all;