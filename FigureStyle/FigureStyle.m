%% FigureStyle.m Applies a style guide to the given figure.
%  This file is part of FigureStyle.
%
%  Author:   Sebastian Eicke (sebastianeicke@web.de)
%  Date:     17. April 2012
%  Version:  12.04.17.14
%
%  Description: Corrects the Ticks on linear scaled axes to have the same number of
%               significant digits for all ticks (0, 0.5, 1) -> (0.0, 0.5, 1.0)
%
%               Corrects digital divider from '.' to ',' if initialized with 'de' as
%               language. (Thx to Alexander Niemer)
%
%               Style guide is loaded from figureStyle.mat (must be in the system path)
%
% (based upon FigureStyle.m from Volker Dieckmann)
%% Requirements
% FigureStyle.mat
% eps2pdf.m by Primoz Cermelj
%  (http://www.mathworks.com/matlabcentral/fileexchange/5782-eps2pdf)
% fixPSlinestyle by Jiro Doke, The MathWorks
%  (http://www.mathworks.com/matlabcentral/fileexchange/17928-fixpslinestyle)
%
%% Input for constructor
% figureHandle handle for figure to be styled
% language     (optional) 'en' default, possible: 'de'
% verbose      (optional) verbose commands read or written on serial port
%
%% Code
classdef FigureStyle < handle
	properties (Access = private)
        figureHandle;
        styleList;
        currentStyle;
        verbose;
        language;
        originalFigurePositions;
        axesHandle;
        hAxesNr;
        vAxesNr;
	end

	methods

        %% constructor
        function FigureStyle = FigureStyle(figureHandle, language, verbose)
            if nargin < 3
                verbose = false;
            end
            if nargin < 2
                language = 'en';
            end
            
            FigureStyle.figureHandle = figureHandle;
            FigureStyle.verbose = verbose;
            FigureStyle.language = language;
            
            FigureStyle.originalFigurePositions = get(figureHandle, 'Position');
            
            FigureStyle.styleList = load('FigureStyle.mat');
            
            % set Style to default
            FigureStyle.setStyle('default');
            
            FigureStyle.axesHandle = findall(figureHandle, 'Type', 'axes', '-and', 'Visible', 'on', '-not', 'Tag', 'legend', '-not', 'Tag', 'Colorbar');
            if length(FigureStyle.axesHandle) > 1
                axesPos = cell2mat(get(FigureStyle.axesHandle, 'Position'));
            else
                axesPos = get(FigureStyle.axesHandle, 'Position');
            end
            FigureStyle.hAxesNr = (max(axesPos(:,1)) - min(axesPos(:,1)))/max(axesPos(:,3)) +1; % Number of horizontal Axes
            FigureStyle.vAxesNr = (max(axesPos(:,2)) - min(axesPos(:,2)))/max(axesPos(:,4)) +1;     % Number of vertical Axes
        end
        
        %% destructor
        function delete(FigureStyle)
        end
        
        %% set number of significant digits for all ticks to be the same and convert '.' to ',' for German figures
        function formatLabel(FigureStyle)
            label = ['X';'Y';'Z'];
            h = findall(FigureStyle.figureHandle, 'Type', 'axes', '-not', 'Tag', 'legend', '-not', 'Tag', 'Colorbar');
            for j=1:length(h);
                for i = 1:length(label(:,1))
                    if strcmp(get(h(j),[label(i,:),'Scale']),'linear')
                        name = [label(i,:),'TickLabel'];
                        mode = strcmp(get(h(j), [label(i,:),'TickLabelMode']),'auto');
                        set(h(j), name, strrep(cellstr(get(h(j), name)), ',', '.'));
                        old_ticks = cellstr(get(h(j), name));
                        ticks = get(h(j), [label(i,:),'Tick']);
                        
                        if (length(ticks) == length(old_ticks)) && mode
                            if find((abs(ticks - str2num(char(old_ticks))')>= eps)==1)
                                warning([name 's are possibly wrong!']);
                            end;
                        end;
                        
                        % Sets ticks and axes limits to the same range
                        ticks = get(h(j), [label(i,:),'Tick']);
                        len_tick = length(ticks);
                        len_label = length(old_ticks);
                        if(len_tick ~= len_label)
                            lim = get(h(j), [label(i,:),'Lim']);
                            ticks(find(ticks < lim(1))) = [];
                            ticks(find(ticks > lim(2))) = [];
                            set(h(j), [label(i,:),'Tick'], ticks);
                        end;
                        
                        ind = strfind(old_ticks,'.');
                        t= [];
                        for k=1:length(ind)
                            if ~isempty(ind{k})
                                t(k) = length(old_ticks{k})-ind{k};
                            end
                        end
                        ticks = cellstr(get(h(j), name));
                        for k=1:length(old_ticks)
                            [val, status] = str2num(ticks{k});
                            if status
                               ticks{k} = sprintf(['%.',num2str(max(t)),'f'],val);
                            else
                                ticks{k} = sprintf(['%s'],ticks{k});
                            end
                        end
                        set(h(j), name, ticks)
                        if strcmp(FigureStyle.language,'de')
                            set(h(j), name, strrep(cellstr(get(h(j), name)), '.', ','));
                        end
                    end
                end
            end
            if FigureStyle.verbose
                disp('Labels have been corrected.');
            end
        end
          
        %% set current style to preset style
        function setStyle(FigureStyle, typeString)
             FigureStyle.currentStyle = FigureStyle.getStyle(typeString);
        end
          
        %% get current style
        function s = getCurrentStyle(FigureStyle)
        	s = FigureStyle.getStyle('current');
        end
          
        %% get preset style
        function style = getStyle(FigureStyle, type)
        
            if strcmpi(type, 'current')
            	style = FigureStyle.currentStyle;
            elseif isfield(FigureStyle.styleList, type)
            	style = getfield(FigureStyle.styleList, type);
            else
                fprintf('Style %s not found, use one of the following:\n', type);
                fieldNamesOfStyleList = sort(fieldnames(FigureStyle.styleList));
                for i=1:length(fieldNamesOfStyleList)
                    fprintf('%s\n', char(fieldNamesOfStyleList(i)));
                end
                style = FigureStyle.styleList.default;
                type = 'default';
            end
            
            if FigureStyle.verbose
                disp(sprintf('Style %s has been selected.', type));
            end
        end
          
        %% apply current style to figure
        %     centerHori          center axes position horizontal (true)
        %     centerVerti          center axes position vertical (true)
        %     formatLabel          format axes label or not (true)
        function apply(FigureStyle, centerHori, centerVerti, formatLabel)
            if nargin < 4
                formatLabel = true;
            end
            if nargin < 3
                centerVerti = true;
            end
            if nargin < 2
                centerHori = true;
            end
            if formatLabel
                FigureStyle.formatLabel();
            end
            
            fieldNamesOfStyleListe = sort(fieldnames(FigureStyle.currentStyle));
            for i=1:length(fieldNamesOfStyleListe)
                type = fieldNamesOfStyleListe{i};
                params = getfield(FigureStyle.currentStyle, type);
                
                if strcmpi(type, 'legend')
                    handle = findall(FigureStyle.figureHandle, 'Type', 'axes', '-and', 'Tag', 'legend');
                else
                    handle = findall(FigureStyle.figureHandle, 'Type', type, '-not', 'Tag', 'legend');
                end
                
                fieldNames = fieldnames(params);
                
                for j=1:length(fieldNames)
                
                    % figure position
                    if (strcmpi(type, 'figure') && strcmpi(fieldNames{j}, 'Position'))
                    	% enlarge figure relative to screensize
                        set(FigureStyle.figureHandle, 'Units', 'normalized');
                        set(FigureStyle.figureHandle, 'Position', [0.5 0.5 0.9 0.75]);
                        set(FigureStyle.figureHandle, 'Units', 'centimeters');
                        
                        if length(FigureStyle.axesHandle) > 1
                            outerPos = cell2mat(get(FigureStyle.axesHandle, 'OuterPosition'));
                            outerPos1 = min(outerPos(:,1));
                            outerPos2 = min(outerPos(:,2));
                            axesPos = cell2mat(get(FigureStyle.axesHandle, 'Position'));
                            tight = cell2mat(get(FigureStyle.axesHandle, 'TightInset'));
                            axesPosMax = max(axesPos);
                            axesPosMin = min(axesPos);
                            tightMax = max(tight);
                        else
                            outerPos = get(FigureStyle.axesHandle, 'OuterPosition');
                            outerPos1 = outerPos(1);
                            outerPos2 = outerPos(2);
                            axesPos = get(FigureStyle.axesHandle, 'Position');
                            axesPosMax = get(FigureStyle.axesHandle, 'Position');
                            axesPosMin = get(FigureStyle.axesHandle, 'Position');
                            tightMax = get(FigureStyle.axesHandle, 'TightInset');
                        end
                        
                        for k = 1:length(FigureStyle.axesHandle)
                            posTmp = get(FigureStyle.axesHandle(k), 'Position');
                            set(FigureStyle.axesHandle(k), 'Position', posTmp-[outerPos1 outerPos2 0 0]);
                        end                                  
                        
                        labelKorrektur = 0.05;
                        for k=1:length(FigureStyle.axesHandle)
                            if centerHori
                                horiPos = max([tightMax(1) tightMax(3)])+labelKorrektur;
                                horiWidth = 2*horiPos;
                                if centerVerti
                                    vertiPos = max([tightMax(2) tightMax(4)])+labelKorrektur;
                                    vertiHeight = 2*vertiPos;
                                else
                                    vertiPos = tightMax(2)+labelKorrektur;
                                    vertiHeight = tightMax(2)+tightMax(4)+2*labelKorrektur;
                                end
                            else
                                horiPos = tightMax(1)+labelKorrektur;
                                horiWidth = tightMax(1)+tightMax(3)+2*labelKorrektur;
                                if centerVerti
                                    vertiPos = max([tightMax(2) tightMax(4)])+labelKorrektur;
                                    vertiHeight = 2*vertiPos;
                                else
                                    vertiPos = tightMax(2)+labelKorrektur;
                                    vertiHeight = tightMax(2)+tightMax(4)+2*labelKorrektur;
                                end
                            end
                            
                            set(FigureStyle.axesHandle(k), 'Position', [horiPos+axesPos(k,1)-axesPosMin(1)+0.05 vertiPos+axesPos(k,2)-axesPosMin(2) axesPosMax(3) axesPosMax(4)]);
                            
                            % place x- and ylabel in figure
                            xLabelHandle = get(FigureStyle.axesHandle(k), 'XLabel');
                            yLabelHandle = get(FigureStyle.axesHandle(k), 'YLabel');
                            
                            if ~isempty(get(xLabelHandle, 'String'))
                                set(xLabelHandle, 'Units', 'centimeters');                        
                                posLabX = get(xLabelHandle, 'Position');
                                set(xLabelHandle, 'Position', [axesPos(k,3)*FigureStyle.hAxesNr/2 posLabX(2) 0]);
                            end
                            if ~isempty(get(yLabelHandle, 'String'))
                                set(yLabelHandle, 'Units', 'centimeters');
                                posLabY = get(yLabelHandle, 'Position');
                                set(yLabelHandle, 'Position', [posLabY(1) axesPos(k,4)*FigureStyle.vAxesNr/2 0]);
                            end
                        end
                        
                        barh = findall(FigureStyle.figureHandle, 'Type', 'axes', '-and', 'Tag', 'Colorbar');
                        
                        if isempty(barh)
                            hBarWidth = 0;
                        else
                            barPos = get(barh, 'Position');
                            barTight = get(barh, 'TightInset');
                            hBarWidth = 2*barPos(3)+barTight(3);
                        end
                        
                        figurePos = get(FigureStyle.figureHandle, 'Position');
                        newFigurePos = [figurePos(1) figurePos(2) FigureStyle.hAxesNr*axesPosMax(3)+horiWidth+hBarWidth FigureStyle.vAxesNr*axesPosMax(4)+vertiHeight-0.05];
                        set(FigureStyle.figureHandle, 'Position', newFigurePos);
                        
                        % center figure on screen
                        set(FigureStyle.figureHandle, 'Units', 'pixel');
                        figurePos = get(FigureStyle.figureHandle, 'Position');
                        scrsz = get(0, 'ScreenSize');
                        newFigurePos = [scrsz(3)/2-figurePos(3)/2 scrsz(4)/2-figurePos(4)/2 figurePos(3) figurePos(4)];
                        set(FigureStyle.figureHandle, 'Position', newFigurePos);
                        set(FigureStyle.figureHandle, 'Units', 'centimeters');
                        
                    % axes position
                    elseif (strcmpi(type, 'axes') && strcmpi(fieldNames{j}, 'Position'))
                            
                        if length(FigureStyle.axesHandle) > 1
                            axesPos = cell2mat(get(FigureStyle.axesHandle, 'Position'));
                        else
                            axesPos = get(FigureStyle.axesHandle, 'Position');
                        end
                        
                        newAxesPos = getfield(params, fieldNames{j});
                        
                        for k=1:length(FigureStyle.axesHandle)
                           oldPos = get(FigureStyle.axesHandle(k), 'Position');
                           hanr = (oldPos(1) - min(axesPos(:,1)))/max(axesPos(:,3));   % current horizontal axis number
                            vanr = (oldPos(2) - min(axesPos(:,2)))/max(axesPos(:,4));     % current vertical axis number
                            set(FigureStyle.axesHandle(k), 'Position', [min(axesPos(:,1))+hanr*newAxesPos(3)/FigureStyle.hAxesNr ...
                                                                        min(axesPos(:,2))+vanr*newAxesPos(4)/FigureStyle.vAxesNr ...
                                                                        newAxesPos(3)/FigureStyle.hAxesNr ...
                                                                        newAxesPos(4)/FigureStyle.vAxesNr]);
                        end
                            
                    % axes ticklength
                    elseif (strcmpi(type, 'axes') && strcmpi(fieldNames{j}, 'TickLength'))
                       for k = 1:length(FigureStyle.axesHandle)
                            pos = get(FigureStyle.axesHandle(k), 'Position');
                            set(FigureStyle.axesHandle(k), fieldNames{j}, getfield(params, fieldNames{j})/max(pos(3:4)));
                        end
                    else
                        set(handle, fieldNames{j}, getfield(params, fieldNames{j}));
                    end
                end
            end
            
            FigureStyle.addBoundingBox();
            
            if FigureStyle.verbose
                disp('Style has been applied to figure.');
            end
        end
          
        %% add or modify parameters to/in current style
        function addStyleToGroup(FigureStyle, group, param, value)
            if isfield(FigureStyle.currentStyle, lower(group))
                s = getfield(FigureStyle.currentStyle, lower(group));
                s = setfield(s, param, value);
            else
                s = struct(param, value);
            end
            
            FigureStyle.currentStyle = setfield(FigureStyle.currentStyle, lower(group), s);
        end
          
        %% Tag figure
        function stampIt(FigureStyle, tagString, position, interpreter)
            
            if nargin < 3
                [stackData tmp] = dbstack;
                string = stackData(2).file;
                interpreter = 'latex';
            end
            if nargin < 2
                [stackData tmp] = dbstack;
                string = stackData(2).file;
                position = 'right';
            end
            
            boundingBoxHandle = findall(FigureStyle.figureHandle, 'Type', 'axes', '-and', 'Tag', 'boundingaxes');
            
            switch position
                case 'right'
                    text(1, 0.03, tagString, 'HorizontalAlignment', 'right', 'Color', [0.6 0.6 0.6], 'Interpreter', interpreter)
                case 'left'
                    text(0, 0.03, tagString, 'HorizontalAlignment', 'left', 'Color', [0.6 0.6 0.6], 'Interpreter', interpreter)
            end
        end
          
        %% Add bounding box at figure dimensions
        function addBoundingBox(FigureStyle)
            boundingBoxHandle = axes('Units', 'normalized', 'Position', [0 0 1 1], 'Color', 'none', 'Visible', 'on', 'Tag', 'boundingaxes');
            
            set(boundingBoxHandle, 'XColor', [1 1 1]-eps);
            set(boundingBoxHandle, 'YColor', [1 1 1]-eps);
            set(boundingBoxHandle, 'XTick', []);
            set(boundingBoxHandle, 'YTick', []);
            
            if FigureStyle.verbose
                disp('Bounding Box added..');
            end
        end
        
        %% Save EPS
        function saveEPS(FigureStyle, fileName)
            set(gcf, 'PaperPositionMode', 'auto');
            
            if ~strcmp(fileName(end-3:end), '.eps')
                fileName = strcat(fileName, '.eps');
            end
            
            print(FigureStyle.figureHandle, fileName, '-depsc2');
            fixPSlinestyle(fileName, fileName);
            
            if FigureStyle.verbose
                fprintf('\n--+-- %s\n', fileNameEPS);
            end
        end
          
        %% Save PDF
        %  fullGsPath (optional), orientation (optional) like in eps2pdf.m
        function savePDF(FigureStyle, fileNamePDF, fullGsPath, orientation)
            if ~strcmp(fileNamePDF(end-3:end), '.pdf')
                fileNamePDF = strcat(fileNamePDF, '.pdf');
            end
            
            fileNameEPS = strcat(fileNamePDF(1:end-4), '.eps');
            
            % save tmp eps file without verbosing
            tmpVerbose = FigureStyle.verbose;
            FigureStyle.verbose = false;
            FigureStyle.saveEPS(fileNameEPS);
            FigureStyle.verbose = tmpVerbose;
            
            % print
            if nargin < 3
                [result, message] = eps2pdf(fileNameEPS);
            elseif nargin < 4
                [result, message] = eps2pdf(fileNameEPS, fullGsPath);
            else
                [result, message] = eps2pdf(fileNameEPS, fullGsPath, orientation);
            end
            if result == 0
            	delete(fileNameEPS); % delete tmp eps file
            else
            	error(message);
            end
            
            % determine axes and figure size
            boundingAxesHanlde = findall(FigureStyle.figureHandle, 'Type', 'axes', '-and', 'Tag', 'boundingaxes');
            set(boundingAxesHanlde, 'Units', 'centimeters');
            boundingAxesPos = get(boundingAxesHanlde, 'Position');
            axesPos = get(FigureStyle.axesHandle(1), 'Position');
            
            % print figure and axes information on cmd windows
            fileTxt = sprintf('-+-- %s --+', fileNamePDF);
            sizeTxt = sprintf(' |   Size: %2.1f x %2.1f cm^2', boundingAxesPos(3), boundingAxesPos(4));
            axesTxt = sprintf(' |   Axes: %2.1f x %2.1f cm^2', axesPos(3)*FigureStyle.hAxesNr, axesPos(4)*FigureStyle.vAxesNr);
            disp(fileTxt)
            disp(char(strcat(' |', {char(ones(1,length(fileTxt)-3).*32)}, '|')))
            disp(char(strcat(sizeTxt, {' '}, {char(ones(1,length(fileTxt)-length(sizeTxt)-2).*32)}, '|')))
            disp(char(strcat(axesTxt, {' '}, {char(ones(1,length(fileTxt)-length(axesTxt)-2).*32)}, '|')))
            disp(char(strcat(' |', {char(ones(1,length(fileTxt)-3).*32)}, '|')))
            disp(strcat(' +',char(ones(1,length(fileTxt)-3).*45), '+'))
            
        end
        
        %% Save PNG
        function savePNG(FigureStyle, fileNamePNG, resolution)
            
            if ~strcmp(fileNamePNG(end-3:end), '.png')
                fileNamePNG = strcat(fileNamePNG, '.png');
            end
            if nargin < 3
                resolution = 300;
            end
            
            print(FigureStyle.figureHandle, fileNamePNG, '-dpng', sprintf('-r%d', resolution));
            
            if FigureStyle.verbose
            	fprintf('\n--+-- %s\n', fileNamePNG);
            end
        end
        
    end
end