function [ matlabColor ] = rgb2MatlabColor( R, G, B )
% RGB2MATLABCOLOR
%
%   Convert RGB colors (values from 0 to 255) to Matlab RGB colors (from 0 to 1)
%
%   Syntax:   [ matlabColor ] = test(R, G, B)
%   Inputs:
%     R             red value
%     G             green value
%     B             blue value
%
%   Outputs:
%     matlabColor   color vector  
%

%% AUTHOR    : Sebastian Eicke (sebastian.eicke@gmail.com)
%% DATE      : 22. February 2010
%% DEVELOPED : 8.1.0.604 (R2013a)
%% FILENAME  : rgb2MatlabColor.m

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