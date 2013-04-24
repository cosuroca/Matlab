%% concOSOSugar.m
%
%  Author:   Sebastian Eicke (sebastianeicke@web.de)
%  Date:     27. May 2011
%  Version:  11.05.26.15
%
%  Description: Calculate the concentration of a [Ru(bpy)_2(OSO)]PF_6 in a sugar glass
%
%% Input
%    m            mass of [Ru(bpy)_2(OSO)]PF_6 pulver (mg)
%    m_sugar      mass of sugar (mg)
%    m_trehalose  mass of trehalose (mg)
%
%% Output:
%    c    concentration of the solution (mol/l)
%    dc   concentration error
%
%% Code
function [ ] = concOSOSugar( m, m_trehalose, m_sugar )

M = 741.61;     % molar mass of [Ru(bpy)_2(OSO)]PF_6 (g/mol)
deltam = 0.1;   % (mg)

rho_sugar = 1.6;        % density of sugar (g/cm3)
rho_trehalose = 1.58;   % density of trehalose (g/cm3)

disp(char(strcat({'Masse an [Ru(bpy)_2(OSO)]PF_6 Pulver: '},num2str(m,2),' mg')));
disp(char(strcat({'Masse an Trehalose: '},num2str(m_trehalose,4),' mg')));
disp(char(strcat({'Masse an Zucker: '},num2str(m_sugar,5),' mg')));

m = m * 1e-3;                       % mass of [Ru(bpy)_2(OSO)]PF_6 pulver (g)
m_sugar = m_sugar * 1e-3;           % mass of sugar (g)
m_trehalose = m_trehalose * 1e-3;   % mass of trehalose (g)
dm = deltam*1e-3;                   %(g)

v_sugar = m_sugar / rho_sugar;              % volume of sugar (ml)
v_trehalose = m_trehalose / rho_trehalose;  % volumne of trehalose (ml)
V = v_sugar + v_trehalose;                  % volume of sugar mixture (ml)
V = V * 1e-3;                               % volume of sugar mixture (l)

disp(char(strcat({'Zuckervolumen: '},num2str(V*1000,5),' ml')));
disp(' ');

c = m/(M*V);
dc = 1/(M*V)*dm + ...
     m * rho_sugar*1000 * (rho_trehalose*1000)^2 / (M*(m_sugar*rho_trehalose*1000+m_trehalose*rho_sugar*1000)^2)*dm + ...
     m * (rho_sugar*1000)^2 * rho_trehalose*1000 / (M*(m_sugar*rho_trehalose*1000+m_trehalose*rho_sugar*1000)^2)*dm;

disp(char(strcat({'Lösungskonzentration: '},num2str(c*1000,4),' mmol/l')));
disp(char(strcat({'Fehler Lösungsconcentration: '},num2str(dc*1000,3),' mmol/l')));
disp(' ');
disp(char(strcat({'( '},num2str(c*1000,5),{' +- '},num2str(dc*1000,5),{' ) mmol/l'})));

end
