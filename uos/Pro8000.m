classdef Pro8000 < handle
% PRO8000
%
%   Object for handling the Pro8000 temperature control
%
%   Inputs for constructor:
%     gpibAdress     GPIB adress, e.g. 2
%     verbose        (optional) verbose commands read or written on serial port
%

%% AUTHOR    : Sebastian Eicke (sebastian.eicke@gmail.com)
%% DATE      : 17. April 2012
%% DEVELOPED : 8.1.0.604 (R2013a)
%% FILENAME  : Pro8000.m

    properties (Access = private)
        gpibPort;
        slot;
        verbose;
    end
   
    methods

        function pro8000 = pro8000(gpibAdress, verbose)
            if nargin < 2
                verbose = false;
            end
            pro8000.verbose = verbose;
            pro8000.gpibPort = instrfind('Type', 'gpib', 'BoardIndex', 0, 'PrimaryAddress', gpibAdress, 'Tag', '');
            
            if isempty(pro8000.gpibPort)
                pro8000.gpibPort = gpib('NI', 0, gpibAdress);
            else
                fclose(pro8000.gpibPort);
                pro8000.gpibPort = pro8000.gpibPort(1);
            end
            
            fopen(pro8000.gpibPort);
            
            if pro8000.verbose
                disp(strcat({'Pro8000 initialized on GPIB Adress'}, num2str(gpibAdress), '.'));
            end
        end
        
        function delete(pro8000)
            fclose(pro8000.gpibPort);
            if pro8000.verbose
                disp(strcat({'Pro8000 connection closed on GPIB Adress'}, num2str(gpibAdress), '.'));
            end
        end
       
%% Initialize
        function init(pro8000, slot)
            fprintf(pro8000.gpibPort, char(strcat({':SLOT '}, num2str(slot))));
        end

%% Function to set temperature
        function setTemp(pro8000, temp)
            fprintf(pro8000.gpibPort, char(strcat({':TEMP:SET '}, num2str(temp))));
        end
        
%% Function to get temperature
        function temp = getTemp(pro8000)
            fprintf(pro8000.gpibPort, ':TEMP:Act?');
            temp_string = fscanf(pro8000.gpibPort);
            temp = str2double(temp_string(11:end));
        end

 %% Function to turn temperature control on
        function on(pro8000)
            fprintf(pro8000.gpibPort, ':TEC ON');
        end       

 %% Function to turn temperature control off
        function off(pro8000)
            fprintf(pro8000.gpibPort, ':TEC OFF');
        end

    end
end
