% POPULATIONDECAY
%

%% AUTHOR    : Sebastian Eicke (sebastian.eicke@gmail.com)
%% DATE      : 22. March 2011
%% DEVELOPED : 8.1.0.604 (R2013a)
%% FILENAME  : populationDecay.m

clc;
clear all;
close all;

%% Vars
filePath = 'C:\Users\AGPhotonik\Documents\Messdaten\sbock\20120614_LangePop_Zerfall_30C\';

waitForTemperatureTime = 10 * 60;
timeBeforePump = 30;

d1 = 'Pump Ref';
d2 = 'Pump';
d3 = 'Probe Ref';
d4 = 'Probe';

s1 = 'PumpShutter (ON)';
s2 = 'ProbeShutter (ON)';

header = char(strcat('time (s)', {' \t '}, ...
                     shutter1, {' \t '}, shutter2, {' \t '}, ...
                     d1, {' \t '}, d2, {' \t '}, d3, {' \t '}, d4, {' \t '}, ...
                     'temperature\n'));

%% Requests
filename = input('Filename? ', 's');
dataFilename = strcat(filePath, datestr(now, 'yyyymmdd'),'_',filename,'.dat');

fprintf(' --> %s\n\n',dataFilename);

waitForTemperature = input('Wait for constant temperatur ? \n (0 = no, 1 = yes) ');

timePump = input('Measuring excition for t = (s) ? ');
temperaturePump = input('Temperature for exciation (°C) ? ');

timeAfterPump = input('Meausring decay for t = ? ');
temperatureAfterPump = input('Temperature for decay (°C) ? ');

%% Initial procedure  
foto = fotometer('COM1', 4);
foto.init(4);

tempControl = pro8000(2);
tempControl.init(1);

if ~exist(filePath)
    mkdir(filePath)
end
file = fopen(dataFilename, 'w');
fprintf(file, header);

%% Before Measurement
clc;

pump = 0; probe = 0;
tempControl.setTemp(temperaturePump);
tempControl.on();

pause(10);

time = tic;
if waitForTemperature
    fprintf(char(strcat(datestr(now, 'HH:MM:SS'), {'Wait for const. temperature (%2.1f °C) (~ %1.0f min)\n\n'})), temperaturePump, waitForTemperatureTime/60);
    while toc(time) < waitForTemperatureTime
        fprintf(char(strcat(datestr(now, 'HH:MM:SS'), {' current temperature: %2.1f °C\n'})), tempControl.getTemp());
        pause(10);
    end
end

%% Measurement
clc;
beginningTime = tic;

while toc(beginningTime) < timeBeforePump
    if probe == 0
        fprintf(char(strcat(datestr(now, 'HH:MM:SS'), {'Probe laser on! (~ %2.0f s)\n'})), timeBeforePump);
    end
    foto.setShutter(2, 0);
    pump = 0; probe = 1; 
    diodeValues = foto.readDiodes();
    temp = tempControl.getTemp();
    fprintf(file, '%e\t%i\t%i\t%e\t%e\t%e\t%e\t%e\n', toc(beginningTime), pump, probe, diodeValues(1), diodeValues(2), diodeValues(3), diodeValues(4), temp);
end

while toc(beginningTime) < (timeBeforePump + timePump)
    if pump == 0
        fprintf(char(strcat(datestr(now, 'HH:MM:SS'), {'Pump laser on! (~ %2.1f min)\n'})), timePump/60);
    end
    foto.setShutter(1, 0)
    pump = 1; probe = 1;
    diodeValues = foto.readDiodes();
    temp = tempControl.getTemp();
    fprintf(file, '%e\t%i\t%i\t%e\t%e\t%e\t%e\t%e\n', toc(beginningTime), pump, probe, diodeValues(1), diodeValues(2), diodeValues(3), diodeValues(4), temp);
end

while toc(beginningTime) < (timeBeforePump + timePump + timeAfterPump)
    if pump == 1
        fprintf(char(strcat(datestr(now, 'HH:MM:SS'), {'Pump laser off! (~ %3.1f min)\n'})), timeAfterPump/60);
        tempControl.setTemp(temperatureAfterPump);
    end
    foto.setShutter(1, 1)
    pump = 0; probe = 1;
    diodeValues = foto.readDiodes();
    temp = tempControl.getTemp();
    fprintf(file, '%e\t%i\t%i\t%e\t%e\t%e\t%e\t%e\n', toc(beginningTime), pump, probe, diodeValues(1), diodeValues(2), diodeValues(3), diodeValues(4), temp);
end

%% Ending procedure
foto.delete();
tempControl.delete();

fclose(file);