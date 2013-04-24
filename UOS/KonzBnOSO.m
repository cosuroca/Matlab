%% KonzBnOSO.m
%
%  Author:   Sebastian Eicke (sebastianeicke@web.de)
%  Date:     23. February 2010
%  Version:  10.02.23.13
%
%  Description: Calculate the concentration of a [Ru(bpy)(biq)(OSO)]PF_6 solution
%               [Ru(N_2C_10H_8)(N_2C_18H_12)(SOCH_3)(C_6H_4CO_2)]PF_6
%               [Ru N_4 C_36 H_27 SO_3 PF_6
%
%% Input
%	 m    mass of [Ru(bpy)(biq)(OSO)]PF_6 pulver (mg)
%	 V    volume of solvent (ml)
%
%% Output:
%    c    concentration of the solution (mol/l)
%    dc   concentration error
%
%% Code
function [ ] = KonzBnOSO( m, V )

M=817.7;       % molar mass of [Ru(bpy)_2(BnOSO)]PF_6 (g/mol)
deltam = 0.1;   % (mg)
deltaV = 0.1;   % (ml)

disp(char(strcat({'Masse an [Ru(bpy)_2(OSO)]PF_6 Pulver: '},num2str(m,2),' mg')));
disp(char(strcat({'Volumen an Lösungsmittel: '},num2str(V,2),' ml')));
disp(' ');

m=m*1e-3;       % mass of [Ru(bpy)_2(OSO)]PF_6 pulver (g)
V=V*1e-3;       % volume of the solvent (l)
deltaV = deltaV*1e-3; %(l)
deltam = deltam*1e-3; %(g)

c=m/(M*V);
deltac=1/(M*V)*deltam+m/(M*V^2)*deltaV;

disp(char(strcat({'Lösungskonzentration: '},num2str(c*1000,4),' mmol/l')));
disp(char(strcat({'Fehler Lösungskonzentration: '},num2str(deltac*1000,3),' mmol/l')));
disp(' ');
disp(char(strcat({'( '},num2str(c*1000,5),{' +- '},num2str(deltac*1000,5),{' ) mmol/l'})));

end
