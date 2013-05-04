function [lambda] = wavenumber2Wavelength(nu)
% WAVENUMBER2WAVELENGTH
%
%   Inputs:
%     nu      Wavenumber (cm^-1)
%
%   Outputs:
%     lambda  Wavelength (nm)
%

%% AUTHOR    : Sebastian Eicke (sebastian.eicke@gmail.com)
%% DATE      : 16. July 2011
%% DEVELOPED : 8.1.0.604 (R2013a)
%% FILENAME  : wavelength2Wavenumber.m

lambda = 1./(nu.*1e-9.*100);