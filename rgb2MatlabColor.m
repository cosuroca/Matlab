%% rgb2MatlabColor.m
%
%  Author:   Sebastian Eicke (sebastian.eicke@gmail.com)
%  Date:     22. February 2010
%  Version:  10.02.22.13
%
%  Description: Convert RGB colors (values from 0 to 255) to Matlab RGB colors (from 0to 1)
%
%% Code
function [matlabColor] = rgb2MatlabColor(R,G,B)

if nargin == 1
    color = R;
else
    color = [R,G,B];
end

matlabColor = (1/255).*color;
string = '';
string = strcat(string, {'R: '},num2str(matlabColor(1), 5));
string = strcat(string, {'	G: '},num2str(matlabColor(2), 5));
string = strcat(string, {'	B: '},num2str(matlabColor(3), 5));
disp(char(string));