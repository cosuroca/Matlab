%% Fotometer.m
%
%  Author:   Sebastian Eicke (sebastianeicke@web.de)
%            Volker Dieckmann
%  Date:     26.04.2013
%  Version:  2013.04.26.15
%
%  Description: Object for handling the fotometer by Elektronikwerkstatt Osnabrueck
%
%% Input for constructor
%    com            COM port, e.g. 'COM1'
%    diodes         number of diode slots the fotometer is equiped with, in most cases 4
%    verbose        (optional) verbose commands read or written on serial port
%
%% Code
classdef Fotometer < handle
    properties (Access = private)
        ser;
        diodeRanges;
        diodeNumber;
        verbose;
        shutters;
        ttls;
    end
   
    methods

        function fotometer = Fotometer(com, diodes,verbose)
            if nargin < 3
                verbose = false;
            end
            fotometer.verbose = verbose;
            fotometer.ser = serial(com);
            fotometer.ser.Terminator = 'CR';
            fotometer.ser.BaudRate = 19200;
            fotometer.ser.DataBits = 8;
            fotometer.ser.Parity = 'n';
            fotometer.ser.Stopbits = 1;
            fotometer.ser.FlowControl = 'none';
            fopen(fotometer.ser);
            fotometer.init(diodes);
            if fotometer.verbose
                disp(strcat({'Fotometer initialized on '}, com, '.'));
            end
        end
        
        function delete(fotometer)
            fotometer.setShutters(ones(4,1));
            fotometer.setTTLs(zeros(8,1));
            com = get(fotometer.ser, 'port');
            fclose(fotometer.ser);
            if fotometer.verbose
                disp(strcat({'Fotometer connection closed on '}, com, '.'));
            end
        end
       
%% Initialize
        function init(fotometer, diodes)
            fotometer.diodeNumber = diodes;
            fotometer.diodeRanges = 9*ones(fotometer.diodeNumber,1);
            fotometer.shutters = ones(4,1);
            fotometer.ttls = zeros(8,1);
            
            %% Init read diodes
            fotometer.readDiodes();
            
            %% Init diode range
            fotometer.setRanges(fotometer.diodeRanges);

            %% Init shutter (off, off, off, off)
            fotometer.setShutters(fotometer.shutters);
            
            %% Init TTLs off
            fotometer.setTTLs(fotometer.ttls);

        end

%% Function to set a diode range up
        function setRangeUp(fotometer, diode)
            if (diode < 1 || diode > fotometer.diodeNumber)
                error(strcat('Wrong diode number (only 1-', num2str(fotometer.diodeNumber), ')'));
            end
            fotometer.setRange(fotometer.diodeRanges(diode)+1, diode);
        end

%% Function to set a diode range down
        function setRangeDown(fotometer, diode)
            if (diode < 1 || diode > fotometer.diodeNumber)
                error(strcat('Wrong diode number (only 1-', num2str(fotometer.diodeNumber), ')'));
            end
            fotometer.setRange(fotometer.diodeRanges(diode)-1, diode);
        end

%% Function to set a diode range
        function setRange(fotometer, range, diode)
            if (diode < 1 || diode > fotometer.diodeNumber)
                error(strcat('Wrong diode number (only 1-', num2str(fotometer.diodeNumber), ')'));
            end
            
            %% Write command, read command
            fotometer.write(fotometer.getRangeCMD(range, diode));

            fotometer.diodeRanges(diode) = range;
        end

%% Function to set a diode ranges
        function setRanges(fotometer, ranges)
            if length(ranges) ~= fotometer.diodeNumber
                error('Number of ranges must match number of diodes!');
            end
            
            for diode = 1:fotometer.diodeNumber,
                fotometer.setRange(ranges(diode), diode);
            end
        end
        
%% Set diode range to manual
        function setRangeManual(fotometer, diode)
            fotometer.setRange(0, diode);
        end

%% Function to get range-change-cmd
        function [cmd] = getRangeCMD(fotometer, range, diode)
            switch range
                case 3
                    cmd = char(strcat({'b 125 '}, num2str(diode)));
                case 4
                    cmd = char(strcat({'b 123 '}, num2str(diode)));
                case 5
                    cmd = char(strcat({'b 119 '}, num2str(diode)));
                case 6
                    cmd = char(strcat({'b 111 '}, num2str(diode)));
                case 7
                    cmd = char(strcat({'b 95 '}, num2str(diode)));
                case 8
                    cmd = char(strcat({'b 63 '}, num2str(diode)));
                case 9
                    cmd = char(strcat({'b 126 '}, num2str(diode)));
                otherwise
                    cmd = char(strcat({'b 255 '}, num2str(diode)));
            end
        end
        
%% Set only one shutter
        function setShutter(fotometer, shutter, state)
            if (shutter < 1 || shutter > 4)
                error('Wrong shutter number (only 1-4)');
            end
            s = fotometer.shutters;
            s(shutter) = state;
            fotometer.setShutters(s);
        end
        
%% Function to set the shutters
        function setShutters(fotometer, s)
            if length(s) < 4
                error('Wrong number of shutters (4 needed)!');
            end
                   
            %% Calculate integer value for shutter cmd
            val = 0;
            if s(1); val = bitor(val, 1);
            else val = bitand(val, 254);
            end
            if s(2); val = bitor(val, 2);
            else val = bitand(val, 253);
            end
            if s(3); val = bitor(val, 4);
            else val = bitand(val, 251);
            end
            if s(4); val = bitor(val, 8);
            else val = bitand(val, 247);
            end
            
            %% Write command, read command
            fotometer.write(char(strcat({'c '},num2str(val), {' 5'})));
            fotometer.shutters = s;
        end

%% Function to read diode values from the 'Fotometer'
        function [diodeValues] = readDiodes(fotometer)
            %% Write command, read command
            fotometer.write('a 9 9');

            dv = zeros(fotometer.diodeNumber, 1);
            for i = 1:4 % read 4 diodes everytime (NOT only the number of diodes installed)
                s = fotometer.read();
                if i <= fotometer.diodeNumber
                    dv(i) = str2num(s);
                end
            end

            for i = 1:fotometer.diodeNumber,
                if (dv(i) > 4000 && fotometer.diodeRanges(i) > 3)
                    fotometer.setRangeDown(i);
                    dv(i) = 0;
                elseif (dv(i) < 350 && fotometer.diodeRanges(i) < 9)
                    fotometer.setRangeUp(i);
                    dv(i) = 0;
                end
            end

            %% Calculate diode values
            diodeValues = dv./4096 .*10.^(-fotometer.diodeRanges);
        end
        
%% Set TTL outputs
        function setTTL(fotometer, ttl, state)
            t = fotometer.ttls;
            t(ttl) = state;
            fotometer.setTTLs(t);
        end;
        
%% Set TTL outputs
        function setTTLs(fotometer, t)
            if length(t) < 8
                error('Wrong number of TTLs (8 needed)!');
            end
            
            val = 0;
            if t(1); val = bitor(val, 1);
            else val = bitand(val, 254);
            end
            if t(2); val = bitor(val, 2);
            else val = bitand(val, 253);
            end
            if t(3); val = bitor(val, 4);
            else val = bitand(val, 251);
            end
            if t(4); val = bitor(val, 8);
            else val = bitand(val, 247);
            end
            if t(5); val = bitor(val, 16);
            else val = bitand(val, 239);
            end
            if t(6); val = bitor(val, 32);
            else val = bitand(val, 223);
            end
            if t(7); val = bitor(val, 64);
            else val = bitand(val, 191);
            end
            if t(8); val = bitor(val, 128);
            else val = bitand(val, 127);
            end
            
            fotometer.write(char(strcat({'t '},num2str(val), {' 6'})));
            fotometer.ttls = t;
        end

%% Read pA-Meter
        function val = readCurrent(fotometer)
            fotometer.write('p');
            
            s = strtrim(fotometer.read());
            v = str2num(strcat(s(1), '1')); % get sign
            val = v*hex2dec(s(2:end)); % calculate value
        end

%% Read command
        function cmd = read(fotometer)
            cmd = fscanf(fotometer.ser);
            if fotometer.verbose
                disp(strcat('Read:', {' '}, cmd));
            end
        end
        
%% Write command
        function write(fotometer, cmd)
            if fotometer.verbose
                disp(strcat('Write:', {' '}, cmd));
            end
            fprintf(fotometer.ser, cmd);

            % Read command echo
            for i = 1:2
                fotometer.read();
            end
        end
        
    end
end
