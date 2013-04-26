%% fotometerTest.m
%
%  Author:   Sebastian Eicke (sebastianeicke@web.de)
%  Date:     26.04.2013
%  Version:  2013.04.26.15
%
%  Description: Test rountine for Fotometer
%
%% Code
clear all
close all
clc

% Initialize
foto = Fotometer('COM1', 4);
foto.init(4);

% Test shutters
for i=[0 1 0 1 0 1]
    foto.setShutter(1, i);
    pause(1)
end

% Test diodes
time = tic;
while toc(time)< 30
    diodeValues = foto.readDiodes();
    fprintf('%e\t%e\t%e\t%e\n', diodeValues(1), diodeValues(2), diodeValues(3), diodeValues(4));
end

foto.delete();