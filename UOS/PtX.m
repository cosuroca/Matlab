%% PtX.m
%
%  Author:   Sebastian Eicke (sebastianeicke@web.de)
%  Date:     13. April 2010
%  Version:  10.04.13.12
%
%  Description: Calculate temperature out of specified resistance of each PtX element
%
%% Input
%    R   resistance of a PtX element (ohm)
%    RO  X=100 or 1000, addicted to the PtX element
%
%% Output:
%    c    concentration of the solution (mol/l)
%    dc   concentration error
%
%% Code
function [T] = PtX(R, R0)

if R>R0
    A = 3.9083E-3;  % 1/°C
    B = -5.775E-7;  % 1/°C^2

    T = ((-A*R0)+(sqrt(((A*R0)*(A*R0))-(4*B*R0*(R0-R)))))./(2*B*R0);
else
    a =  3.9083E-3; % 1/°C
    b = -5.775E-7;  % 1/°C^2
    c = -4.183E-12; % 1/°C^4

    T =  -273.15:0.01:0.01;
    RC = R0.*(1+a.*T + b.*(T.^2)+c.*(T-100).*(T.^3));
    
    i1 = find(RC<R);
    i2 = find(RC>R);
    
    T1 = T(i1(end));
    T2 = T(i2(1));
    
    R1 = RC(i1(end));
    R2 = RC(i2(1));
    
    %disp(char(strcat(num2str(RC(i1(end))),{' Ohm --> '},num2str(T(i1(end))),{' °C'})));
    %disp(char(strcat(num2str(RC(i2(1))),{' Ohm --> '},num2str(T(i2(1))),{' °C'})));
    
    T = T1+(T2-T1)/(R2-R1)*(R-R1);
end