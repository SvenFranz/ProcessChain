function saveSettings(filename, chainData)
% Author: S. Franz (c) ITAS/IHA @ Jade Hochschule applied licence see EOF 
% Version History:
% Ver. 0.01 initial create 20-Mar-2014 			 SF

if ~isdir('Settings')
    mkdir('Settings');
end

strValue = '';
strValue = [strValue; '%% Plugins %%' char(13)];
strValue = createPluginList(chainData, strValue, '');
strValue = [strValue char(13) '%% Settings %%' char(13)];
strValue = createValueList(chainData, strValue, '');

file = fopen(['Settings' filesep filename '.cfg'], 'w');
fwrite(file, strValue);
fclose(file);

    function value = createPluginList(Data, value, chain)
        plugins = fieldnames(Data);
        for count = 1 : length(plugins)
            plugin = char(plugins(count));
            value = [value chain plugin ' = ' Data.(plugin).plugin ';' char(13)];
            if isfield(Data.(plugin), 'plugins')
                value = createPluginList(Data.(plugin).plugins, value, [chain plugin '.']);
            end
        end
    end

    function value = createValueList(Data, value, chain)
        plugins = fieldnames(Data);
        for count = 1 : length(plugins)
            plugin = char(plugins(count));
            value = [value '% ' chain plugin ' (' Data.(plugin).plugin ') %' char(13)];
            vars = Data.(plugin).varnames();
            for valCount = 1 : length(vars)
                var = char(vars(valCount));
                if strcmp(Data.(plugin).getType(var), 'string') || strcmp(Data.(plugin).getType(var), 'list')
                    value = [value chain plugin '.' var ' = ''' Data.(plugin).getVar(var) ''';' char(13)];
                elseif strcmp(Data.(plugin).getType(var), 'numeric') || strcmp(Data.(plugin).getType(var), 'integer') || strcmp(Data.(plugin).getType(var), 'bool')
                    value = [value chain plugin '.' var ' = ' num2str(Data.(plugin).getVar(var)) ';' char(13)];
                elseif strcmp(Data.(plugin).getType(var), 'colVec') || strcmp(Data.(plugin).getType(var), 'rowVec') || strcmp(Data.(plugin).getType(var), 'matrix')
                    value = [value chain plugin '.' var ' = ' mat2str(Data.(plugin).getVar(var)) ';' char(13)];
                end
            end
            if isfield(Data.(plugin), 'plugins')
                value = createValueList(Data.(plugin).plugins, value, [chain plugin '.']);
            end
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