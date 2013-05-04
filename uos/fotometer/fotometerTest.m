%% Code
% FOTOMETERTEST
%
%    Test rountine for Fotometer
%

%% AUTHOR    : Sebastian Eicke (sebastian.eicke@gmail.com)
%% DATE      : 26. April 2013
%% DEVELOPED : 8.1.0.604 (R2013a)
%% FILENAME  : fotometerTest.m

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