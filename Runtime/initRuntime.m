function ChainVersion = initRuntime()
% Author: S. Franz (c) ITAS/IHA @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create 20-Mar-2014 			 SF
% Ver. 0.1  unnecessary path information removed automatically SF
%           function call 'indentcode' added
% Ver. 0.11 changes in Chain are checked        SF
clc;
ChainVersion = .16;
if nargout == 1; return; end
checkVersion(ChainVersion);

clear mex;
fclose all;
munlock;

rehash path;
szPath = mfilename('fullpath');
szPath = szPath(1:end-length(mfilename)-1);
addpath([szPath filesep 'Processing']);
folders = regexp(path, ';', 'split');
idx = strfind(folders, [pwd filesep 'Plugins']);
for currIdx = 1 : length(idx)
    if cell2mat(idx(currIdx))
        rmpath(char(folders(currIdx)));
    end
end
if ~isdir(['Temp' filesep 'Plugins'])
    mkdir(['Temp' filesep 'Plugins']);
end
currPath = ['Temp' filesep 'Plugins'];
addpath([szPath filesep '..' filesep currPath]);

breakpoints = dbstatus;
readFiles('Plugins');
readFiles(['.' filesep 'Runtime' filesep 'PluginTemplates']);
rehash path;
for idx = 1 : length(breakpoints)
    if exist(breakpoints(idx).file, 'file') && ~isempty(strfind(breakpoints(idx).file, ['Temp' filesep 'Plugins']))
        eval(['dbstop in ' breakpoints(idx).file ' at ' num2str(breakpoints(idx).line) ';']);
    end
end


%     function clearPath(myPath)
%         files = dir(myPath);
%         for fileNo = 3 : length(files)
%             file = files(fileNo).name;
%             if isdir([myPath filesep file])
%                 clearPath([myPath '\' file]);
%                 if strfind(path, [myPath '\' file])
%                     rmpath([myPath '\' file]);
%                 end
%             end
%         end
%     end

    function readFiles(myPath)
        %         if ~strcmp(myPath, 'Runtime\PluginTemplates')
        %             %currPath = ['Temp\' myPath];
        %             %addpath(currPath);
        %         else
        %             currPath = 'Temp\Plugins';
        %         end
        files = dir(myPath);
        for fileNo = 3 : length(files)
            file = files(fileNo).name;
            tmpMyNum = 0;
            if exist([currPath filesep file] ,'file')
                tempdir = dir([currPath filesep file]);
                if ~isempty(tempdir)
                    tmpMyNum = tempdir.datenum;
                end
            end
            if isdir([myPath filesep file])
                %                 if ~isdir([currPath '\' file])
                %                     mkdir([currPath '\' file]);
                %                 end
                readFiles([myPath filesep file])
            elseif length(file) > 8 && strcmp(file(end - 8 : end), '_Plugin.m')
                if tmpMyNum < files(fileNo).datenum
                    PluginsToTemp(myPath, file, currPath)
                elseif tmpMyNum > files(fileNo).datenum && ~strcmp(file, 'init_Plugin.m');
                    TempToPlugins(myPath, file, currPath)
                end
            elseif ~strcmp(file, 'newPlug.m') && isempty(strfind(file, '.asv')) && isempty(strfind(file, '.git'))
                if tmpMyNum ~= files(fileNo).datenum
                    copyfile([myPath filesep file], [currPath filesep file]);
                end
            end
        end
    end

    function TempToPlugins(myPath, file, currPath)
        disp(['TempToPlugins: ' file]);
        file_in = fopen([currPath filesep file]);
        textIn = textscan(file_in, '%s', 'Delimiter','\n');
        fclose(file_in);
        OutData = {};
        blnWrite = true;
        for count = 1 : length(textIn{1}) - 1
            if strcmp(strtrim(char(textIn{1}{count})), '%% DO NOT CHANGE %%')
                blnWrite = false;
            end
            if blnWrite
                OutData{length(OutData) + 1} = [char(textIn{1}{count}) char(13)];
            end
        end
        OutData{length(OutData) + 1} = 'end';
        OutData = cell2mat(OutData);
        try
            if exist('indentmcode', 'file')
                OutData = indentmcode(OutData);
            elseif exist('indentcode', 'file')
                OutData = indentcode(OutData, 'matlab');
            end
        catch exp
        end
        file_out = fopen([myPath filesep file], 'w');
        fwrite(file_out, OutData);
        fclose(file_out);
        java.io.File([currPath filesep file]).setLastModified(java.lang.System.currentTimeMillis);
    end

    function PluginsToTemp(myPath, file, currPath)
        disp(['PluginsToTemp: ' file]);
        file_in = fopen([myPath filesep file]);
        textIn = textscan(file_in, '%s', 'Delimiter','\n');
        fclose(file_in);
        OutData = {};
        for count = 1 : length(textIn{1}) - 1
            OutData{length(OutData) + 1} = [char(textIn{1}{count}) char(13)];
        end
        file_in = fopen(['.' filesep 'Runtime' filesep 'PluginTemplates' filesep 'newPlug.m']);
        textIn = textscan(file_in, '%s', 'Delimiter','\n');
        fclose(file_in);
        blnWrite = false;
        for count = 1 : length(textIn{1}) - 1
            if strcmp(strtrim(char(textIn{1}{count})), '%% GLOBAL END %%')
                blnWrite = false;
            end
            if blnWrite
                OutData{length(OutData) + 1} = [char(textIn{1}{count}) char(13)];
            end
            if strcmp(strtrim(char(textIn{1}{count})), '%% GLOBAL START %%')
                blnWrite = true;
            end
        end
        OutData{1} = strrep(OutData{1}, '_Plugin()', '_Plugin(strName)');
        OutData{length(OutData) + 1} = 'end';
        OutData = cell2mat(OutData);
        if isempty(strfind(OutData, 'global AlgoCom;'));
            OutData = strrep(OutData, '(strName)', ['(strName)' char(13) 'global AlgoCom;']);
        end
        try
            if exist('indentmcode', 'file')
                OutData = indentmcode(OutData);
            elseif exist('indentcode', 'file')
                OutData = indentcode(OutData, 'matlab');
            end
        catch exp
        end
        file_out = fopen([currPath filesep file], 'w');
        fwrite(file_out, OutData);
        fclose(file_out);
        java.io.File([myPath filesep file]).setLastModified(java.lang.System.currentTimeMillis);
    end
end

%--------------------Licence ---------------------------------------------
% Copyright (c) <2014> S. Franz
% Institut für Technische Assistenzsysteme
% Institute for Hearing Technology and Audiology
% Jade University of Applied Sciences
% Permission is hereby granted, free of charge, to any person obtaining
% a copy of this software and associated documentation files
% (the "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to
% permit persons to whom the Software is furnished to do so, subject
% to the following conditions:
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
% EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
% OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
% IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
% CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
% TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
% SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.