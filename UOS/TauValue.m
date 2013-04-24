%% Pt100.m
%
%  Author:   Sebastian Eicke (sebastianeicke@web.de)
%  Date:     10. October 2009
%  Version:  10.10.10.21
%
%  Description: Calculate tau value from activation energy, frequency
%  factor and temperature
%
%% Input
%	 EA     activation energy (eV)
%	 Z      frequency factor (Hz)
%    T      temperature (K)
%
%% Output:
%    tau    tau value (s)
%
%% Code
function [ tau ] = TauValue( EA, Z, T )

kb=8.617343e-5; % Boltzmann constant (eV/K)
tau=1/Z.*exp(EA./(kb.*(T)));

end
