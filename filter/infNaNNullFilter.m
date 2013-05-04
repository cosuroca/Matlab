function [ x, y ] = infNaNNullFilter( x, y )
% INFNANNULLFILTER
%
%   Filters Inf, NaN and NULL values out of y
%
%   Inputs:
%     x        corresponding x values
%     y        y values
%
%   Outputs:
%     xe       corresponding x values
%     ye       filtered y values
%

%% AUTHOR    : Sebastian Eicke (sebastian.eicke@gmail.com)
%% DATE      : 26. November 2009
%% DEVELOPED : 8.1.0.604 (R2013a)
%% FILENAME  : infNaNNullFilter.m

if length(x) ~= length(y(:, 1))
    error('vectors have not the same length');
end

indexinfs = find(isinf(y(:, 1)) == 1);
x(indexinfs) = [];
y(indexinfs,:) = [];

indexnans = find(isnan(y(:, 1)) == 1);
x(indexnans) = [];
y(indexnans,:) = [];

indexnulls = find(y(:, 1) == 0);
x(indexnulls) = [];
y(indexnulls,:) = [];