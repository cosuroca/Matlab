%% KonzOSO.m
%
%  Author:   Sebastian Eicke (sebastianeicke@web.de)
%  Date:     06. August 2010
%  Version:  10.08.06.10
%
%  Description: Calculate the concentration of a [Ru(bpy)_2(OSO)]PF_6 solution
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
function [ ] = KonzOSO( m, V )

M=741.61;       % molar mass of [Ru(bpy)_2(OSO)]PF_6 (g/mol)
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
