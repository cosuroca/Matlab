function  newMFile( fcnname )
% NEWMFILE 
% 
%   Creates a MATLAB function with entered filename
%
%   Inputs:
%     fcnname    name of file to create
%

%% AUTHOR    : Sebastian Eicke (sebastian.eicke@gmail.com)
%% DATE      : 03. May 2013 21:02:29
%% DEVELOPED : 8.1.0.604 (R2013a)
%% FILENAME  : newMFile.m

if nargin == 0, help(mfilename); return; end
if nargin > 1, error('  MSG: Only one Parameter accepted!'); end

extension = '.m';
filename = strcat(fcnname,extension);

ex = exist(filename, 'file');
while ex == 2
    msg = sprintf(['Function -< %s.m >- does already exist!\n','Overwrite it ?'], filename);
    action = questdlg(msg, ' Overwrite Function?', 'Yes', 'No', 'No');
    if strcmp(action,'Yes') == 1
        ex = 0;
    else
        filename = char(inputdlg('Enter new Function Name ... ', 'NEWFCN - New Name'));
        if isempty(filename) == 1
            disp('   MSG: User decided to Cancel !')
            return
        else
            if ~strcmp(filename(end-1:end), 'm')
                filename = strcat(filename, '.m');
            end
            ex = exist(filename, 'file');
        end
    end
end

fid = fopen(filename,'w');

line_1 = ['function [output_args] = ', fcnname, '(input_args)'];

h01 = ['% ', upper(fcnname), ' ...'];
h02 = '%';
h03 = '%   ...';
h04 = '%';
h05 = ['%   Syntax:   [arg2] = ', fcnname, '(arg1)'];
h06 = '%   Inputs:';
h07 = '%     arg1  ';
h08 = '%';
h09 = '%   Outputs:';
h10 = '%     arg2  ';
h11 = '%';

fprintf(fid,'%s\n',   line_1);
fprintf(fid,'%s\n',   h01);
fprintf(fid,'%s\n',   h02);
fprintf(fid,'%s\n',   h03);
fprintf(fid,'%s\n',   h04);
fprintf(fid,'%s\n',   h05);
fprintf(fid,'%s\n',   h06);
fprintf(fid,'%s\n',   h07);
fprintf(fid,'%s\n',   h08);
fprintf(fid,'%s\n',   h09);
fprintf(fid,'%s\n',   h10);
fprintf(fid,'%s\n\n', h11);

authorString   =  '%% AUTHOR    : Sebastian Eicke (sebastian.eicke@gmail.com)';
dateString     = ['%% DATE      : ', datestr(now, 'dd. mmm yyyy HH:MM:SS')];
versionString  = ['%% DEVELOPED : ', version];
filenameString = ['%% FILENAME  : ', filename];

fprintf(fid,'%s\n',   authorString);
fprintf(fid,'%s\n',   dateString);
fprintf(fid,'%s\n',   versionString);
fprintf(fid,'%s\n\n', filenameString);

fclose(fid);
matlab.desktop.editor.openAndGoToLine(which(filename), 19);