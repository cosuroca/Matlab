%% wavelength2Wavenumber.m
%
%  Author:   Sebastian Eicke (sebastianeicke@web.de)
%  Date:     16. July 2011
%  Version:  11.07.16.11
%
%% Input
%	 nu      Wavenumber (cm^-1)
%
%% Output:
%    lambda  Wavelength (nm)
%
%% Code
function [lambda] = wavenumber2Wavelength(nu)

lambda = 1./(nu.*1e-9.*100);