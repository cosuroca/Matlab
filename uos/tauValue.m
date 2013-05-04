function [ tau ] = tauValue( EA, Z, T )
% TAUVALUE
% 
%   Calculates tau value from activation energy and frequency factor and
%   temperature (Arrhenius law)
%
%   Inputs:
%	  EA     activation energy (eV)
%	  Z      frequency factor (Hz)
%     T      temperature (K)
%
%   Outputs:
%	  tau    characteristic time constant (s)

%% AUTHOR    : Sebastian Eicke (sebastian.eicke@gmail.com)
%% DATE      : 10. October 2009
%% DEVELOPED : 8.1.0.604 (R2013a)
%% FILENAME  : tauValue.m

kb=8.617343e-5; % Boltzmann constant (eV/K)
tau=1/Z.*exp(EA./(kb.*(T)));

end
