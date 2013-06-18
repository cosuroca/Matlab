classdef ShimadzuData < handle
% SHIMADZUDATA
%
%   Loads and processes transmission data from Shimadzu UVProbe data files
%
%   Inputs for constructor:
%     filename       filename of the UV Probe data file
%     thickness      interaction length
%     dt             time base for repetition measurement
%

%% AUTHOR    : Sebastian Eicke (sebastian.eicke@gmail.com)
%% DATE      : 24. April 2013
%% DEVELOPED : 8.1.0.604 (R2013a)
%% FILENAME  : ShimadzuData.m

    properties (Access = private)
        wavelength;                     % wavelength, saved normally in (nm)
        transmission;                   % transmission (%)
        absorption;                     % absorption (cm^-1)
        repititionMeausrement;
        repititionNumber;               % number of meausurement
        repititionTimes;                % point of times
    end

    methods

        %% constructor
        %     filename       filename of the UV Probe data file
        %     thickness      interaction length
        %     dt             time base for repetition measurement
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

        %% get wavelength
        function wavelengthVector = getWavelength(ShimadzuData)
            wavelengthVector = ShimadzuData.wavelength;
        end

        %% get transmission
        function transmissionMatrix = getTransmission(ShimadzuData)
            transmissionMatrix = ShimadzuData.transmission;
        end

        %% get absorption
        function absorptionMatrix = getAbsorption(ShimadzuData)
            absorptionMatrix = ShimadzuData.absorption;
        end
        
        %% get absorption for specified wavelength
        function absorption = getAbsorptionForWavelength(ShimadzuData, wavelength)
            absorption = ShimadzuData.getAbsorption();
            absorption = absorption(find(ShimadzuData.getWavelength() == wavelength), :)';
        end

        %% 1 if data set represents a repetition meausurement, else 0
        function boolean = isRepititionMeausrement(ShimadzuData)
            boolean = ShimadzuData.repititionMeausrement;
        end

        %% get number of measurements
        function repNumber = getRepititionNumber(ShimadzuData)
            repNumber = ShimadzuData.repititionNumber;
        end

        %% get point of times for the meausurements
        function repTimes = getRepititionTimes(ShimadzuData)
            repTimes = ShimadzuData.repititionTimes;
        end
        
        %% get 3D matrix data of the absorption
        function [WAVELENGTH, TIMES, ABS] = get3DAbs(ShimadzuData)
            if ~ShimadzuData.isRepititionMeausrement()
                error('no 3D data available');
            end
            
            [WAVELENGTH, TIMES] = meshgrid(ShimadzuData.getWavelength, ShimadzuData.getRepititionTimes);
            ABS = ShimadzuData.getAbsorption';
        end
        
        %% expand data set with another data set
        %     filename       filename of the UV Probe data file
        %     thickness      interaction length
        %     dt             time base for repetition measurement
        %     d0             time offset of the original and expanded data set
        function expand(ShimadzuData, fileName, thickness, dt, t0)
            
            file = importdata(fileName);
            if isstruct(file)                                                   % No repetition measurement
                fileData = file.data;
            else                                                                % repetitioin measurement
                fileData = file;
            end
            
            if ShimadzuData.getWavelength() ~= fileData(:,1)
                error('%s has not the same wavelength range!', fileName);
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

        % Deletes Inf, NaN and Null in yData and the corrsponding elements in xData
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