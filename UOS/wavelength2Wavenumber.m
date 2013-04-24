%% wavelength2Wavenumber.m
%
%  Author:   Sebastian Eicke (sebastianeicke@web.de)
%  Date:     06. July 2011
%  Version:  11.07.06.16
%
%% Input
%	 lambda  Wavelength (nm)
%
%% Output:
%    nu      Wavenumber (cm^-1)
%
%% Code
function [nu] = wavelength2Wavenumber(lambda)

nu = 1./(lambda.*1e-9.*100);