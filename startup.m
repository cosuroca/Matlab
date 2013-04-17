%% startup.m Matlab startup file
%  Author:   Sebastian Eicke
%  Date:     22. February 2013
%  Version:  13.02.22.14
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
end

if ispc
	pcName = getenv('COMPUTERNAME');
	
	if strcmp(pcName, 'SEWORK')		% Rechner @Work
		homeDir = 'D:/Dropbox/Uni/Postdoc/';
    end
end

cd(homeDir)
clear all;