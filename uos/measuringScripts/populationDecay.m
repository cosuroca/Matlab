%% populationDecay.m
%
%  Author:   Sebastian Eicke (sebastian.eicke@gmail.com)
%  Date:     22. March 2011
%  Version:  12.03.22.12
%
%
%% Code
clc;
clear all;
close all;

%% Requests
filename = input('Filename? ', 's');
filePath = 'C:\Users\AGPhotonik\Documents\Messdaten\sbock\20120614_LangePop_Zerfall_30C\';
dataFilename = strcat(filePath, datestr(now, 'yyyymmdd'),'_',filename,'.dat');

fprintf(' --> %s\n\n',dataFilename);

waitForTemperature = input('Wait for constant temperatur ? \n (0 = no, 1 = yes) ');
waitForTemperatureTime = 10 * 60;

timeBeforePump = 30;
timePump = input('Measuring excition for t = (s) ? ');
temperaturePump = input('Temperature for exciation (°C) ? ');

timeAfterPump = input('Meausring decay for t = ? ');
temperatureAfterPump = input('Temperature for decay (°C) ? ');

wavelengthPump = 488;
wavelengthProbe = 568;

material = 'RuBIQOSOPC';
                
%% Initial procedure  
foto = fotometer('COM8', 4);
foto.init(4);

tempControl = pro8000(2);
tempControl.init(1);

% Initialize file for measured data
if ~exist(filePath)
    mkdir(filePath)
end

file = fopen(dataFilename, 'w');
header = char(strcat({'time (s) \t shutter1 (ON) \t shutter2 (ON) \t D1 \t D2 \t D3 \t D4 \t temperature\n'}));
fprintf(file, header);

%% Before Measurement
clc;

pump = 0; probe = 0;
tempControl.setTemp(temperaturePump);
tempControl.on();

pause(10);

time = tic;
if waitForTemperature
    fprintf(char(strcat(datestr(now, 'HH:MM:SS'), {' Warten auf konst. Temperatur (%2.1f Grad C) (ca. %1.0f min)\n\n'})), temperaturePump, waitForTemperatureTime/60);
    while toc(time) < waitForTemperatureTime
        fprintf(char(strcat(datestr(now, 'HH:MM:SS'), {' Temperatur: %2.1f Grad C\n'})), tempControl.getTemp());
        pause(10);
    end
end

%% Measurement
clc;
beginningTime = tic;

while toc(beginningTime) < timeBeforePump
	if probe == 0
		fprintf(char(strcat(datestr(now, 'HH:MM:SS'), {' Tastlaser an! (ca. %2.0f s)\n'})), timeBeforePump);
    end
	foto.setShutter(2, 0);
	pump = 0; probe = 1; 
	diodeValues = foto.readDiodes();
	temp = tempControl.getTemp();
	fprintf(file, '%e\t%i\t%i\t%e\t%e\t%e\t%e\t%e\n', toc(beginningTime), pump, probe, diodeValues(1), diodeValues(2), diodeValues(3), diodeValues(4), temp);
end

while toc(beginningTime) < (timeBeforePump + timePump)
	if pump == 0
		fprintf(char(strcat(datestr(now, 'HH:MM:SS'), {' Pumplaser an! (ca. %2.1f min)\n'})), timePump/60);
	end
	foto.setShutter(1, 0)
	pump = 1; probe = 1;
	diodeValues = foto.readDiodes();
    temp = tempControl.getTemp();
	fprintf(file, '%e\t%i\t%i\t%e\t%e\t%e\t%e\t%e\n', toc(beginningTime), pump, probe, diodeValues(1), diodeValues(2), diodeValues(3), diodeValues(4), temp);
end

while toc(beginningTime) < (timeBeforePump + timePump + timeAfterPump)
	if pump == 1
		fprintf(char(strcat(datestr(now, 'HH:MM:SS'), {' Pumplaser aus! (ca. %3.1f min)\n'})), timeAfterPump/60);
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