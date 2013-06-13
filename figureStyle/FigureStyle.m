classdef FigureStyle < handle
% FIGURESTYLE
%
%   Applies a style guide to the given figure.
%   This file is part of FigureStyle.
%
%   Corrects the Ticks on linear scaled axes to have the same number of
%   significant digits for all ticks (0, 0.5, 1) -> (0.0, 0.5, 1.0)
%   Corrects digital divider from '.' to ',' if initialized with 'de' as
%   language. (Thx to Alexander Niemer)
%   Style guide is loaded from figureStyle.mat (must be in the system path)
%   (based upon FigureStyle.m from Volker Dieckmann)
%
%   Requirements:
%     FigureStyle.mat
%     eps2pdf.m by Primoz Cermelj (http://www.mathworks.com/matlabcentral/fileexchange/5782-eps2pdf)
%     fixPSlinestyle by Jiro Doke, The MathWorks (http://www.mathworks.com/matlabcentral/fileexchange/17928-fixpslinestyle)
%
%   Inputs for constructor:
%     figureHandle handle for figure to be styled
%     language     (optional) 'en' default, possible: 'de'
%     verbose      (optional) verbose commands read or written on serial port
%
%   Example:
%     fs = FigureStyle(gcf, 'de');
%     fs.setStyle('paper');
%     fs.apply(true, false, true);
%     fs.stampIt('test', 'left', 'latex');
%     fs.savePDF(fullfile('testpdf'), '', 0)  
%

%% AUTHOR    : Sebastian Eicke (sebastian.eicke@gmail.com)
%% DATE      : 17. April 2012
%% DEVELOPED : 8.1.0.604 (R2013a)
%% FILENAME  : FigureStyle.m

    properties (Access = private)
        figureHandle;
        styleList;                  % style guide
        currentStyle;
        verbose;
        language;
        originalFigurePositions;    % vector for the original figure position
        axesHandle;                 % hanlde of different axis
        hAxesNr;                    % number of axis side by side (horizontal)
        vAxesNr;                    % number of axis side by side (horizontal)
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
            
            % save original figure position
            FigureStyle.originalFigurePositions = get(figureHandle, 'Position');
            
            % load style guide
            FigureStyle.styleList = load('figureStyle.mat');
            
            % set style to default
            FigureStyle.setStyle('default');
            
            % find handles in the figure
            FigureStyle.axesHandle = findall(figureHandle, 'Type', 'axes', '-and', 'Visible', 'on', '-not', 'Tag', 'legend', '-not', 'Tag', 'Colorbar');
            % check if more than one axis is present in the figure
            if length(FigureStyle.axesHandle) > 1
                axesPos = cell2mat(get(FigureStyle.axesHandle, 'Position'));
            else
                axesPos = get(FigureStyle.axesHandle, 'Position');
            end
            FigureStyle.hAxesNr = (max(axesPos(:,1)) - min(axesPos(:,1)))/max(axesPos(:,3)) +1;     % Number of axis side by side (horizontal)
            FigureStyle.vAxesNr = (max(axesPos(:,2)) - min(axesPos(:,2)))/max(axesPos(:,4)) +1;     % Number of axis side by side (vertical)
        end
        
        %% destructor
        function delete(FigureStyle)
        end
        
        %% set number of significant digits for all ticks to be the same and convert '.' to ',' for German figures
        % (Thx to Alexander Niemer)
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
                        
                        % convert '.' to ',' (just for german figures)
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
          
        %% set current style to specified style
        function setStyle(FigureStyle, typeString)
             FigureStyle.currentStyle = FigureStyle.getStyle(typeString);
        end
          
        %% get current style guide
        function s = getCurrentStyle(FigureStyle)
            s = FigureStyle.getStyle('current');
        end
          
        %% get style guide for specified style
        function style = getStyle(FigureStyle, type)
        
            if strcmpi(type, 'current')
                style = FigureStyle.currentStyle;
            elseif isfield(FigureStyle.styleList, type)
                style = getfield(FigureStyle.styleList, type);
            else % specified style can not be found
                fprintf('Style %s not found, use one of the following:\n', type);
                fieldNamesOfStyleList = sort(fieldnames(FigureStyle.styleList));
                % list possible styles
                for i=1:length(fieldNamesOfStyleList)
                    fprintf('%s\n', char(fieldNamesOfStyleList(i)));
                end
                % set style to default style
                style = FigureStyle.styleList.default;
                type = 'default';
            end
            
            % print status
            if FigureStyle.verbose
                disp(sprintf('Style %s has been selected.', type));
            end
        end
          
        %% apply current style to figure
        %     centerHori        center axes position horizontal (true)
        %     centerVerti       center axes position vertical (true)
        %     formatLabel       format axes label or not (true)
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
            
            fieldNamesOfStyleList = sort(fieldnames(FigureStyle.currentStyle));
            
            % run through list of field names
            for i=1:length(fieldNamesOfStyleList);
                type = fieldNamesOfStyleList{i};                    % like: axes, figure, legend, line, text
                params = getfield(FigureStyle.currentStyle, type);  % parameter field for the type
                fieldNames = fieldnames(params);                    % like: Units, Position, TickLength, FontName, FontSize
                
                % legends are axes and are tagged with 'legend'
                if strcmpi(type, 'legend')
                    handle = findall(FigureStyle.figureHandle, 'Type', 'axes', '-and', 'Tag', 'legend');
                else
                    handle = findall(FigureStyle.figureHandle, 'Type', type, '-not', 'Tag', 'legend');
                end

                for j=1:length(fieldNames)
                
                    % adjust figure position
                    if (strcmpi(type, 'figure') && strcmpi(fieldNames{j}, 'Position'))
                        % first enlarge figure relative to screensize
                        set(FigureStyle.figureHandle, 'Units', 'normalized');
                        set(FigureStyle.figureHandle, 'Position', [0.5 0.5 0.9 0.75]);
                        set(FigureStyle.figureHandle, 'Units', 'centimeters');
                        
                        % check if more than one axis is present in the figure
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
                        
                        labelCorr = 0.05;   % correction factor for label positioning, value was find by trial and error
                        for k=1:length(FigureStyle.axesHandle)
                            if centerHori % axis should be centered horizontal
                                horiPos = max([tightMax(1) tightMax(3)])+labelCorr;
                                horiWidth = 2*horiPos; 
                                if centerVerti % and vertical
                                    vertiPos = max([tightMax(2) tightMax(4)])+labelCorr;
                                    vertiHeight = 2*vertiPos;
                                else % but not vertical
                                    vertiPos = tightMax(2)+labelCorr;
                                    vertiHeight = tightMax(2)+tightMax(4)+2*labelCorr;
                                end
                            else % axis should not be centered horizontal
                                horiPos = tightMax(1)+labelCorr;
                                horiWidth = tightMax(1)+tightMax(3)+2*labelCorr;
                                if centerVerti % but vertical
                                    vertiPos = max([tightMax(2) tightMax(4)])+labelCorr;
                                    vertiHeight = 2*vertiPos;
                                else % and not vertical
                                    vertiPos = tightMax(2)+labelCorr;
                                    vertiHeight = tightMax(2)+tightMax(4)+2*labelCorr;
                                end
                            end
                            
                            % center axis
                            set(FigureStyle.axesHandle(k), 'Position', [horiPos+axesPos(k,1)-axesPosMin(1)+0.05 vertiPos+axesPos(k,2)-axesPosMin(2) axesPosMax(3) axesPosMax(4)]);
                            
                            % place x- and ylabel in figure
                            xLabelHandle = get(FigureStyle.axesHandle(k), 'XLabel');
                            yLabelHandle = get(FigureStyle.axesHandle(k), 'YLabel');
                            if ~isempty(get(xLabelHandle, 'String'))
                                set(xLabelHandle, 'Units', 'centimeters');

                                % place xLabel in the middle of the present horizontal axes
                                set(xLabelHandle, 'Position', [axesPos(k,3)*FigureStyle.hAxesNr/2 posLabX(2) 0]);
                            end
                            if ~isempty(get(yLabelHandle, 'String'))
                                set(yLabelHandle, 'Units', 'centimeters');
                                posLabY = get(yLabelHandle, 'Position');
                                % place yLabel in the middle of the present vertical axes
                                set(yLabelHandle, 'Position', [posLabY(1) axesPos(k,4)*FigureStyle.vAxesNr/2 0]);
                            end
                        end
                        
                        % search for colorbars (other kind of axes)
                        barh = findall(FigureStyle.figureHandle, 'Type', 'axes', '-and', 'Tag', 'Colorbar');
                        if isempty(barh)
                            hBarWidth = 0;
                        else
                            barPos = get(barh, 'Position');
                            barTight = get(barh, 'TightInset');
                            hBarWidth = 2*barPos(3)+barTight(3);
                        end
                        
                        % scale figure size in dependency of the included axes
                        figurePos = get(FigureStyle.figureHandle, 'Position');
                        newFigurePos = [figurePos(1) figurePos(2) FigureStyle.hAxesNr*axesPosMax(3)+horiWidth+hBarWidth FigureStyle.vAxesNr*axesPosMax(4)+vertiHeight-0.05];
                        set(FigureStyle.figureHandle, 'Position', newFigurePos);
                        
                        % center figure window on screen
                        set(FigureStyle.figureHandle, 'Units', 'pixel');            % change units of the figure to pixel for positioning
                        figurePos = get(FigureStyle.figureHandle, 'Position');      % current figure position and width
                        scrsz = get(0, 'ScreenSize');                               % current screen size
                        newFigurePos = [scrsz(3)/2-figurePos(3)/2 scrsz(4)/2-figurePos(4)/2 figurePos(3) figurePos(4)];     % positioning figure in the center of the screen
                        set(FigureStyle.figureHandle, 'Position', newFigurePos);
                        set(FigureStyle.figureHandle, 'Units', 'centimeters');      % change units of figure back to cm
                        
                    % adjust axes position
                    elseif (strcmpi(type, 'axes') && strcmpi(fieldNames{j}, 'Position'))
                            
                        % check if more than one axis is present in the figure
                        if length(FigureStyle.axesHandle) > 1
                            axesPos = cell2mat(get(FigureStyle.axesHandle, 'Position'));
                        else
                            axesPos = get(FigureStyle.axesHandle, 'Position');
                        end
                        
                        newAxesPos = getfield(params, fieldNames{j});
                        
                        % place axis
                        for k=1:length(FigureStyle.axesHandle)
                           oldPos = get(FigureStyle.axesHandle(k), 'Position');
                           hanr = (oldPos(1) - min(axesPos(:,1)))/max(axesPos(:,3));        % current horizontal axis number
                           vanr = (oldPos(2) - min(axesPos(:,2)))/max(axesPos(:,4));        % current vertical axis number
                           set(FigureStyle.axesHandle(k), 'Position', [min(axesPos(:,1))+hanr*newAxesPos(3)/FigureStyle.hAxesNr ...
                                                                        min(axesPos(:,2))+vanr*newAxesPos(4)/FigureStyle.vAxesNr ...
                                                                        newAxesPos(3)/FigureStyle.hAxesNr ...
                                                                        newAxesPos(4)/FigureStyle.vAxesNr]);
                        end
                            
                    % adjust axes ticklength in dependency of the axes size
                    elseif (strcmpi(type, 'axes') && strcmpi(fieldNames{j}, 'TickLength'))
                       for k = 1:length(FigureStyle.axesHandle)
                            pos = get(FigureStyle.axesHandle(k), 'Position');   % pos([3 4]) represents size (width and height) of the axis
                            set(FigureStyle.axesHandle(k), fieldNames{j}, getfield(params, fieldNames{j})/max(pos(3:4)));
                       end
                    % set other components of the style guide   
                    else
                        set(handle, fieldNames{j}, getfield(params, fieldNames{j}));
                    end
                end
            end
            
            % add bounding box, otherwise save routines (saveEPS, savePDF,
            % savePNG) cut off white areas --> no centered axes in the
            % figure
            FigureStyle.addBoundingBox();
            
            % print status
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
          
        %% add tag to figure, e.g. for small annotations
        % Inputs 
        %     tagString    String of the tag
        %     position     place the tag on the 'left' or 'right' bottom of the figure
        %     interpreter  interpreter for the string (e.g. 'latex');
        function stampIt(FigureStyle, tagString, position, interpreter)
            
            boundingBoxHandle = findall(FigureStyle.figureHandle, 'Type', 'axes', '-and', 'Tag', 'boundingaxes');
            
            switch position
                case 'right'
                    text(1, 0.03, tagString, 'HorizontalAlignment', 'right', 'Color', [0.6 0.6 0.6], 'Interpreter', interpreter)
                case 'left'
                    text(0, 0.03, tagString, 'HorizontalAlignment', 'left', 'Color', [0.6 0.6 0.6], 'Interpreter', interpreter)
                otherwise
                    text(0, 0.03, tagString, 'HorizontalAlignment', 'left', 'Color', [0.6 0.6 0.6], 'Interpreter', interpreter)
            end
        end
          
        %% add bounding box for figure dimensions
        function addBoundingBox(FigureStyle)
            boundingBoxHandle = axes('Units', 'normalized', 'Position', [0 0 1 1], 'Color', 'none', 'Visible', 'on', 'Tag', 'boundingaxes');
            
            set(boundingBoxHandle, 'XColor', [1 1 1]-eps);  % '-eps' because clean white [1 1 1] doesn't work, "Matlab originality"
            set(boundingBoxHandle, 'YColor', [1 1 1]-eps);
            set(boundingBoxHandle, 'XTick', []);
            set(boundingBoxHandle, 'YTick', []);
            
            % print status
            if FigureStyle.verbose
                disp('Bounding Box added..');
            end
        end
        
        %% save EPS
        function saveEPS(FigureStyle, fileName)
            set(gcf, 'PaperPositionMode', 'auto');
            
            % check if filename already has eps extension
            if ~strcmp(fileName(end-3:end), '.eps')
                fileName = strcat(fileName, '.eps');
            end
            
            % save eps file and fix the line styles
            print(FigureStyle.figureHandle, fileName, '-depsc2');
            fixPSlinestyle(fileName, fileName);
            
            % print status
            if FigureStyle.verbose
                fprintf('\n--+-- %s\n', fileNameEPS);
            end
        end
          
        %% save PDF
        %  fullGsPath (optional), orientation (optional) like in eps2pdf.m
        function savePDF(FigureStyle, fileNamePDF, fullGsPath, orientation)
            
            % check if filename already has pdf extension
            if ~strcmp(fileNamePDF(end-3:end), '.pdf')
                fileNamePDF = strcat(fileNamePDF, '.pdf');
            end
            
            fileNameEPS = strcat(fileNamePDF(1:end-4), '.eps');
            
            % save tmp eps file without verbosing
            tmpVerbose = FigureStyle.verbose;
            FigureStyle.verbose = false;
            FigureStyle.saveEPS(fileNameEPS);
            FigureStyle.verbose = tmpVerbose;
            
            % save pdf file
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
            
            % determine axes size and figure size for status message 
            boundingAxesHanlde = findall(FigureStyle.figureHandle, 'Type', 'axes', '-and', 'Tag', 'boundingaxes');
            set(boundingAxesHanlde, 'Units', 'centimeters');
            boundingAxesPos = get(boundingAxesHanlde, 'Position');
            axesPos = get(FigureStyle.axesHandle(1), 'Position');
            
            % prepare string for status message
            sizeTxt = sprintf('Size: %2.1f x %2.1f cm^2', boundingAxesPos(3), boundingAxesPos(4));                              % string for figure size
            axesTxt = sprintf('Axes: %2.1f x %2.1f cm^2', axesPos(3)*FigureStyle.hAxesNr, axesPos(4)*FigureStyle.vAxesNr);      % string for axes size
            
            maxLength = max([length(sizeTxt), length(axesTxt), length(fileNamePDF)]);   % check maximal string lengths for correct status print
            
            fTxt = sprintf(char(strcat({'-+-'}, {char(ones(1,(maxLength-length(fileNamePDF))/2).*45)}, {' %s '}, {char(ones(1,(round((maxLength-length(fileNamePDF))/2))).*45)}, '-+')), fileNamePDF);  % filename text to print
            sTxt = sprintf(char(strcat({' | '}, {char(ones(1,floor((maxLength-length(sizeTxt))/2)).*32)}, {' %s '}, {char(ones(1,(round((maxLength-length(sizeTxt))/2))).*32)}, {' | '})), sizeTxt);    % figure size text to print, floor and round in case of odd-numbered maxLength
            aTxt = sprintf(char(strcat({' | '}, {char(ones(1,floor((maxLength-length(axesTxt))/2)).*32)}, {' %s '}, {char(ones(1,(round((maxLength-length(axesTxt))/2))).*32)}, {' | '})), axesTxt);    % axes size text to print, floor and round in case of odd-numbered maxLength
            phTxt = char(strcat({' | '}, {char(ones(1,maxLength+2).*32)}, {' | '}));                                                                                                                    % place holder text to print
            eTxt = char(strcat({' +-'}, {char(ones(1,maxLength+2).*45)}, {'-+ '}));                                                                                                                     % end text to print
            
            % print status message (figure and axes information)
            disp(fTxt); disp(phTxt); disp(sTxt); disp(aTxt); disp(phTxt); disp(eTxt);
            
        end
        
        %% save PNG
        function savePNG(FigureStyle, fileNamePNG, resolution)
            
            % check if filename already has png extension
            if ~strcmp(fileNamePNG(end-3:end), '.png')
                fileNamePNG = strcat(fileNamePNG, '.png');
            end
            
            % set default resolution
            if nargin < 3
                resolution = 300;
            end
            
            % save png file
            print(FigureStyle.figureHandle, fileNamePNG, '-dpng', sprintf('-r%d', resolution));
            
            % print status
            if FigureStyle.verbose
            	fprintf('\n--+-- %s\n', fileNamePNG);
            end
        end
        
    end
end