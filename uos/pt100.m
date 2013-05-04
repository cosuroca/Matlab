function [ T ] = pt100( R )
% PT100
% 
%   Calculates the temperature out of a specified resistance of a Pt100 element
%
%   Inputs:
%     R   resistance of a Pt100 element (ohm)
%
%   Outputs:
%	  T    temperature (°C)

%% AUTHOR    : Sebastian Eicke (sebastian.eicke@gmail.com)
%% DATE      : 10. October 2009
%% DEVELOPED : 8.1.0.604 (R2013a)
%% FILENAME  : pt100.m

A = 3.9083E-3;
B = -5.775E-7;
R0 = 100;          % resistance at 0°C

T = ((-A*R0)+(sqrt(((A*R0)*(A*R0))-(4*B*R0*(R0-R)))))./(2*B*R0);

if (isscalar(R) && (T < -50 || T > 300))
    disp('Temperaturberechnung nicht mehr ausreichend genau!');
end
