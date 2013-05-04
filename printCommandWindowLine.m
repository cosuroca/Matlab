function printCommandWindowLine()
% PRINTCOMMANDWINDOWLINE
%
%   Print line in Command Window
%

%% AUTHOR    : Sebastian Eicke (sebastian.eicke@gmail.com)
%% DATE      : 28. January 2012
%% DEVELOPED : 8.1.0.604 (R2013a)
%% FILENAME  : printCommandWindowLine.m

cws = get(0, 'CommandWindowSize');
fprintf(strcat(char(ones(1,cws(1)).*45),'\n'));