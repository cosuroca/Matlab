%% FigureStyleModification Modifies the FigureStyle.mat
%  This file is part of FigureStyle.
%
%  Author:   Sebastian Eicke (sebastianeicke@web.de)
%  Date:     17. April 2012
%  Version:  12.04.17.14
%

%% Code
clear all;
close all;
clc;

%% default
default.line = struct('LineWidth', {1},...
                      'MarkerSize', {6});
default.figure = struct('PaperPositionMode', 'auto');

%% disputation
disse.axes = struct('Units', 'centimeters', ...
                    'Position', [1 1 6 6], ...
                    'TickLength', [0.2 0.2], ...
                    'FontName', 'Times', ...
                    'FontSize', 12, ...
                    'LineWidth', 1, ...
                    'XMinorTick', 'on', ...
                    'YMinorTick', 'on');
disse.figure = struct('Units', 'centimeters', ...
                      'Position', [], ...
                      'PaperPositionMode', 'auto');
disse.legend = struct('Units', 'centimeters', ...
                      'FontName', 'Times', ...
                      'FontSize', 12, ...
                      'LineWidth', 1, ...
                      'Box', 'off');
disse.text = struct('FontName', 'Times', ...
                    'FontSize', 12);
disse.line = struct('LineWidth', 1, ...
                    'MarkerSize', 6);

%% paper/article
paper.axes = struct('Units', 'centimeters', ...
                    'Position', [1 1 6 6], ...
                    'TickLength', [0.2 0.2], ...
                    'FontName', 'Times', ...
                    'FontSize', 10, ...
                    'LineWidth', 1, ...
                    'XMinorTick', 'on', ...
                    'YMinorTick', 'on');
paper.figure = struct('Units', 'centimeters', ...
                      'Position', [], ...
                      'PaperPositionMode', 'auto');
paper.legend = struct('Units', 'centimeters', ...
                      'FontName', 'Times', ...
                      'FontSize', 10, ...
                      'LineWidth', 1, ...
                      'Box', 'off');
paper.line = struct('LineWidth', 1, ...
                    'MarkerSize', 6);
paper.text = struct('FontName', 'Times', ...
                    'FontSize', 10);

%% beamer
beamer.axes = struct('FontName', 'Helvetica', ...
                    'FontSize', 10.91, ...
                    'Units', 'centimeters', ...
                    'Position', [1 1 6 6], ...
                    'TickLength', [0.2 0.2], ...
                    'LineWidth', 1, ...
                    'XMinorTick', 'on', ...
                    'YMinorTick', 'on');
beamer.figure = struct('Units', 'centimeters', ...
                       'Position', [], ...
                       'PaperPositionMode', 'auto');
beamer.legend = struct('Units', 'centimeters', ...
                       'FontName', 'Helvetica', ...
                       'FontSize', 10.91, ...
                       'LineWidth', 1, ...
                       'Box', 'off');
beamer.line = struct('LineWidth', 1, ...
                     'MarkerSize', 6);
beamer.text = struct('FontName', 'Helvetica', ...
                     'FontSize', 10.91);

%% poster
poster.axes = struct('FontName', 'Helvetica', ...
                     'FontSize', 12, ...
                     'Units', 'centimeters', ...
                     'Position', [1 1 6 6], ...
                     'TickLength', [0.2 0.2], ...
                     'LineWidth', 1, ...
                     'XMinorTick', 'on', ...
                     'YMinorTick', 'on');
poster.figure = struct('Units', 'centimeters', ...
                       'Position', [], ...
                       'PaperPositionMode', 'auto');
poster.legend = struct('Units', 'centimeters', ...
                       'FontName', 'Helvetica', ...
                       'FontSize', 12, ...
                       'LineWidth', 1, ...
                       'Box', 'off');
poster.line = struct('LineWidth', 1, ...
                     'MarkerSize', 6);
poster.text = struct('FontName', 'Helvetica', ...
                     'FontSize', 12);

%% save
save('figureStyle.mat');