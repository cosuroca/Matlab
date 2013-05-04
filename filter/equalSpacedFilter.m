function [xe,ye] = equalSpacedFilter(x,y,dx,dy)
% EQUALSPACEDFILTER
%
%   Sorts the pairs of (x,y) values and return only (x,y) that are nearly
%   equal distributed with distances dx on the x scale.
%   xe will consist of each first x that fullfills the rule: x(i-1)+dx<=x(i),
%   plus the lowest and the highest value of x,
%   plus every extra data pairs if abs(y(i-1)-y(i))>dy.
%
%   Inputs:
%     x        non-uniform distributed and unsorted x values
%     y        corresponding y values
%     dx       desired distance of equally distributed value pairs
%     dy       (optional) maximum distance on y-axis between two filtered data points
%
%   Outputs:
%     xe       sorted x values (asc) with at most equal distance d
%     ye       corresponding y values
%

%% AUTHOR    : Sebastian Eicke (sebastian.eicke@gmail.com)
%% DATE      : 28. January 2010
%% DEVELOPED : 8.1.0.604 (R2013a)
%% FILENAME  : equalSpacedFilter.m

if nargin<3, % too less arguments
    error('Three arguments required: x, y, dx')
end
if nargin<4, % no dy is set, then ignore it by setting it to max(y)-min(y)
    dy = max(y)-min(y);
end

[x, i] = sort(x);
y = y(i);

xe = [];
ye = [];
for i = 1:length(x),
    if (length(xe) < 1) || (x(i) >= (xe(length(xe)) + dx)) || (i == length(x)),
        xe = [xe, x(i)];
        ye = [ye, y(i)];
    end
    if (abs(ye(length(ye)) - y(i)) >= dy),
        xe = [xe, x(i)];
        ye = [ye, y(i)];
    end
end