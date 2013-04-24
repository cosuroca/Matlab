%% pt100.m
%
%  Author:   Sebastian Eicke (sebastianeicke@web.de)
%  Date:     10. October 2009
%  Version:  09.10.10.21
%
%  Description: Calculate the temperature out of a specified resistance of a Pt100 element
%
%% Input
%	 m    mass of [Ru(bpy)_2(OSO)]PF_6 pulver (mg)
%	 V    volume of solvent (ml)
%
%% Output:
%    c    concentration of the solution (mol/l)
%    dc   concentration error
%
%% Code
function [ T ] = pt100( R )

A = 3.9083E-3;
B = -5.775E-7;
R0 = 100;          % resistance at 0°C

T = ((-A*R0)+(sqrt(((A*R0)*(A*R0))-(4*B*R0*(R0-R)))))./(2*B*R0);

if (isscalar(R) && (T < -50 || T > 300))
    disp('Temperaturberechnung nicht mehr ausreichend genau!');
end
