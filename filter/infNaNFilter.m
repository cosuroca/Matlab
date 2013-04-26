%% infNaNFilter.m
%
%  Author:   Sebastian Eicke (sebastian.eicke@gmail.com)
%  Date:     26. November 2009
%  Version:  09.11.26.13
%
%  Description: Filter for Inf- and NaN Values
%
%% Code
function [ x, y ] = infNaNFilter( x, y )

if length(x) ~= length(y(:, 1))
    error('vectors have not the same length');
end

indexinfs = find(isinf(y(:, 1)) == 1);
x(indexinfs) = [];
y(indexinfs,:) = [];

indexnans = find(isnan(y(:, 1)) == 1);
x(indexnans) = [];
y(indexnans,:) = [];