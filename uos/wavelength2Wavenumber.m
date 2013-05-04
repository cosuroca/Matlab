function [nu] = wavelength2Wavenumber(lambda)
% WAVELENGTH2WAVENUMBER
%
%   Inputs:
%     lambda  Wavelength (nm)
%
%   Outputs:
%     nu      Wavenumber (cm^-1)
%

%% AUTHOR    : Sebastian Eicke (sebastian.eicke@gmail.com)
%% DATE      : 06. July 2011
%% DEVELOPED : 8.1.0.604 (R2013a)
%% FILENAME  : wavenumber2Wavelength.m


nu = 1./(lambda.*1e-9.*100);