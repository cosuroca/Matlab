%% ShimadzuData.m 
%  Author:   Sebastian Eicke (sebastianeicke@web.de)
%  Date:     24. April 2013
%  Version:  13.04.24.20
%
%  Description: Load and process transmission data from Shimadzu UVProbe data files
%
%% Code
classdef ShimadzuData < handle
    properties (Access = public)
        wavelength;
        transmission;
        absorption;
        repititionMeausrement;
        repititionNumber;
        repititionTimes;
    end

    methods

        %% constructor
        function ShimadzuData = ShimadzuData(fileName, thickness, dt)
            if nargin < 3
                dt = 100;
            end
            
            if nargin < 2
                thickness = 1;
            end
            
            file = importdata(fileName);
            if isstruct(file)                                                   % data file has headlines
                fileData = file.data;
            else
                fileData = file;
            end
            
            ShimadzuData.wavelength = fileData(:,1);
            ShimadzuData.transmission = fileData(:,2:end);
            ShimadzuData.absorption = real(-1./thickness * log(ShimadzuData.transmission ./100));
            ShimadzuData.absorption(find(ShimadzuData.absorption < 0)) = 0;
            
            [rows cols] = size(ShimadzuData.transmission);
            ShimadzuData.repititionNumber = cols;
            
            if cols == 1                                                        % no repetition meausrement
                ShimadzuData.repititionMeausrement = false;
                ShimadzuData.repititionTimes = 0;
            elseif cols > 1                                                     % repetition meausrement
                ShimadzuData.repititionMeausrement = true;
                ShimadzuData.repititionTimes = 0:dt:(ShimadzuData.repititionNumber-1)*dt;
            end
        end

        %% destructor
        function delete(ShimadzuData)
        end

        function wavelengthVector = getWavelength(ShimadzuData)
            wavelengthVector = ShimadzuData.wavelength;
        end

        function transmissionMatrix = getTransmission(ShimadzuData)
            transmissionMatrix = ShimadzuData.transmission;
        end

        function absorptionMatrix = getAborption(ShimadzuData)
            absorptionMatrix = ShimadzuData.absorption;
        end
        
        function absorption = getAborptionForWavelength(ShimadzuData, lambda)
            absorption = ShimadzuData.getAbsorption();
            absorption = absorption(find(ShimadzuData.getWavelength() == lambda), :)';
        end

        function boolean = isRepititionMeausrement(ShimadzuData)
            boolean = ShimadzuData.repititionMeausrement;
        end

        function repNumber = getRepititionNumber(ShimadzuData)
            repNumber = ShimadzuData.repititionNumber;
        end

        function repTimes = getRepititionTimes(ShimadzuData)
            repTimes = ShimadzuData.repititionTimes;
        end
        
        function [WAVELENGTH, TIMES, ABS] = get3DAbs(ShimadzuData)
            if ~ShimadzuData.isRepititionMeausrement()
                error('no 3D data available');
            end
            
            [WAVELENGTH TIMES] = meshgrid(ShimadzuData.getWavelength, ShimadzuData.getRepititionTimes);
            ABS = ShimadzuData.getAborption';
        end
        
        function expand(ShimadzuData, fileName, thickness, dt, t0)
            
            file = importdata(fileName);
            if isstruct(file)                                                   % Keine WDH Messung
                fileData = file.data;
            else                                                                % WDH Messung
                fileData = file;
            end
            
            if (length(ShimadzuData.wavelength) ~= length(fileData(:,1))   && ...% Wellenlängenvektoren gleich?
                ShimadzuData.wavelength(1) ~= fileData(1,1)        && ...
                ShimadzuData.wavelength(end) ~= fileData(end,1))
                error('wavelength vectors have not the same length');
            end
            
            if ShimadzuData.isRepititionMeausrement
                if nargin < 5
                    t0 = 0;
                end
                if nargin < 4
                    dt = ShimadzuData.repititionTimes(2)-ShimadzuData.repititionTimes(1);
                end
                if nargin < 3
                    thickness = 1;
                end
                
                [rows cols] = size(fileData(:,2:end));
                ShimadzuData.repititionNumber = ShimadzuData.repititionNumber + cols;
                
                ShimadzuData.repititionTimes = [ShimadzuData.repititionTimes (ShimadzuData.repititionTimes(end)+t0):dt:(t0+ShimadzuData.repititionTimes(end)+(cols-1)*dt)];
            end
            
            ShimadzuData.transmission = [ShimadzuData.transmission fileData(:,2:end)];
            ShimadzuData.absorption = [ShimadzuData.transmission real(-1./thickness * log(ShimadzuData.transmission ./100))];
            ShimadzuData.absorption(find(ShimadzuData.absorption < 0)) = 0;
        end
    end

    methods(Access = private)

        function [xData yData] = InfNaNNullFilter (ShimadzuData, xData, yData)
            indexinfs = find(isinf(yData(:, 1)) == 1);
            xData(indexinfs) = [];
            yData(indexinfs,:) = [];

            indexnans = find(isnan(yData(:, 1)) == 1);
            xData(indexnans) = [];
            yData(indexnans,:) = [];

            indexnulls = find(yData(:, 1) == 0);
            xData(indexnulls) = [];
            yData(indexnulls,:) = [];
        end
    end
end