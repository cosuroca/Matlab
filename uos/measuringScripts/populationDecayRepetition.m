%% fotometerMessTest.m
%
%  Author:   Sebastian Eicke (sebastian.eicke@gmail.com)
%  Date:     22. March 2011
%  Version:  12.03.22.12
%
%  Description:
%  Measuring procedure
%
%% Code
clc;
clear all;
close all;

%% Requests
filename = input('Messdateiname? ', 's');
filePath = 'C:\Users\AGPhotonik\Documents\Messdaten\seicke\20121017_DutyCycles_55C\';
dataFilename = strcat(filePath, datestr(now, 'yyyymmdd'),'_',filename,'.dat');

fprintf(' --> %s\n\n',dataFilename);

waitForTemperature = input('Auf konstante Temperatur warten ? \n (0 = nein, 1 = ja) ');
waitForTemperatureTime = 10 * 60;                                                            %%% Beim hohen Temp. überprüfen

cycle = 1;

timeBeforePump = 90;
timePump = 11;
temperaturePump = 55;

timeAfterPump = 7200;
temperatureAfterPump = 55;

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
header = char(strcat(material,'\n', ...
                     {'Pumplaser: '}, num2str(wavelengthPump,4), {' nm, '}, ... 
                     {'Tastlaser: '}, num2str(wavelengthProbe,4), {' nm, '}, ...
                     {'Anregungstemperatur: '}, num2str(temperaturePump,3), {' Grad C\n'}, ...
                     {'Zerfallstemperatur: '}, num2str(temperatureAfterPump,3), {' Grad C\n\n'}, ...
                     {'Zeit (s) \t Pump (ON) \t Probe (ON) \t D1 (Pump Ref) \t D2 (Probe Ref) \t D3 (Pump Signal) \t D4 (Probe Signal) \t Temperatur\n'}));
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
        foto.setShutter(2, 0);
        pump = 0;
        probe = 1; 
    end
    diodeValues = foto.readDiodes();
    temp = tempControl.getTemp();
	fprintf(file, '%e\t%i\t%i\t%e\t%e\t%e\t%e\t%e\n', toc(beginningTime), pump, probe, diodeValues(1), diodeValues(2), diodeValues(3), diodeValues(4), temp);
end

for i = 1:cycle
    while toc(beginningTime) < (timeBeforePump + i*timePump + (i-1)*timeAfterPump)
        if pump == 0
            fprintf(char(strcat(datestr(now, 'HH:MM:SS'), {' Pumplaser an! (ca. %2.1f min)\n'})), timePump/60);
            foto.setShutter(1, 0)
            pump = 1;
            probe = 1;
        end
        diodeValues = foto.readDiodes();
        temp = tempControl.getTemp();
        fprintf(file, '%e\t%i\t%i\t%e\t%e\t%e\t%e\t%e\n', toc(beginningTime), pump, probe, diodeValues(1), diodeValues(2), diodeValues(3), diodeValues(4), temp);
    end
    
    while toc(beginningTime) < (timeBeforePump + i*timePump + i*timeAfterPump)
    	if pump == 1
        	fprintf(char(strcat(datestr(now, 'HH:MM:SS'), {' Pumplaser aus! (ca. %3.1f min)\n'})), timeAfterPump/60);
            tempControl.setTemp(temperatureAfterPump);
            foto.setShutter(1, 1)
            pump = 0; 
            probe = 1;
        end
        diodeValues = foto.readDiodes();
        temp = tempControl.getTemp();
        fprintf(file, '%e\t%i\t%i\t%e\t%e\t%e\t%e\t%e\n', toc(beginningTime), pump, probe, diodeValues(1), diodeValues(2), diodeValues(3), diodeValues(4), temp);
    end
end

%% Ending procedure
foto.delete();
tempControl.delete();

fclose(file);