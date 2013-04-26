%% printCommandWindowLine.m Print line in Command Window
%
%  Author:   Sebastian Eicke (sebastian.eicke@gmail.com)
%  Date:     28. January 2012
%  Version:  12.01.28.16
%
%% Code
function [] = printCommandWindowLine()

cws = get(0, 'CommandWindowSize');
fprintf(strcat(char(ones(1,cws(1)).*45),'\n'));