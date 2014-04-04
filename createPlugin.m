function createPlugin(pluginname, hasSubplugs)
% Author: S. Franz (c) ITAS/IHA @ Jade Hochschule applied licence see EOF 
% Version History:
% Ver. 0.01 initial create 20-Mar-2014 			 SF

clc;
if nargin < 1
    pluginname = input('Pluginname: ', 's');
end
if nargin < 2 
    hasSubplugs = false;
    allowSubplugs = input('Unterplugins erlauben (j/n)? ', 's');
    if strcmp(allowSubplugs, 'j')
        hasSubplugs = true;
    end
end

if ~isempty(pluginname)
    pluginname = [pluginname '_Plugin'];
    file_in = fopen(fullfile('.', 'Runtime', 'PluginTemplates', 'newPlug.m'));
    file_out = fopen(fullfile('.', 'Plugins', [pluginname '.m']), 'w');
    tline = fgets(file_in);
    fwrite(file_out, replaceStrings(tline));
    addData = true;
    while ischar(tline)
        tline = fgets(file_in);
        if ischar(tline)
            if strcmp(strtrim(tline), '%% GLOBAL START %%')
                addData = false;
            end
            if addData
                saveline = true;
                if hasSubplugs == false
                    if ~isempty(strfind(tline, 'this.plugins = struct;')) || ~isempty(strfind(tline, 'process_subplugs(this.plugins'))
                        saveline = false;
                    end
                end
                if saveline
                    fwrite(file_out, replaceStrings(tline));
                end
            end
            if strcmp(strtrim(tline), '%% GLOBAL END %%')
                addData = true;
            end
        end
    end
    fclose(file_in);
    fclose(file_out);
    szPath = mfilename('fullpath');
    addpath([szPath(1:end-length(mfilename)) filesep 'Runtime']);
    initRuntime();
    disp('new plugin generated!');
else
    disp('Pluginname is empty!');
end
    function out = replaceStrings(in)
        out = '';
        if ischar(in)
            out = strrep(in, 'newPlug', pluginname);
        end
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