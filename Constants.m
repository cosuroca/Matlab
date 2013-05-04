classdef Constants < handle
% CONSTANTS
%
%   Physical, chemical constant

%% AUTHOR    : Sebastian Eicke (sebastian.eicke@gmail.com)
%% DATE      : 04. May 2013 20:13:54
%% DEVELOPED : 8.1.0.604 (R2013a)
%% FILENAME  : Constants.m

    properties (Constant)
        c      = 299792458;           % Speed of light (m/s)
        G      = 6.67384e-11;         % Gravitational constant (m^3/ (kg s^2))
        h      = 6.62606957e-34;      % Planck constant (J s)
        h_eV   = 4.135667516;         % Planck constant (eV s)
        e      = 1.602176565e-19;     % Elementary charge (C)
        
        NA     = 6.02214129e23;       % Avogardo's number (1/mol)
        kb     = 1.3806488;           % Boltzmann constant (J/K)
        kb_eVK = 8.6173324e-5;        % Boltzmann constant (eV/K)
    end
end