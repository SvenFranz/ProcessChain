function chainData = loadSettings(filename)
% Author: S. Franz (c) ITAS/IHA @ Jade Hochschule applied licence see EOF 
% Version History:
% Ver. 0.01 initial create 20-Mar-2014 			 SF

chainData = struct;
plugindata = ['chainData = struct;' char(13)];
file_in = fopen(['Settings' filesep filename '.cfg']);
tline = strtrim(fgets(file_in));
while ischar(tline) && ~strcmp(strtrim(tline), '%% Settings %%')
    if ~strcmp(tline(1), '%') && ~isempty(strtrim(tline))
        tline = strrep(tline, '.', '.plugins.');
        tline = strtrim(strrep(tline, ';', ''));
        idx1 = strfind(tline, '=');
        idx2 = strfind(tline(1 : idx1), '.');
        if isempty(idx2)
            idx2 = 0;
        end
        plugindata = [plugindata 'chainData.' tline '(''' strtrim(tline(idx2(end) + 1 : idx1 - 1)) ''');' char(13)];
    end
    tline = fgets(file_in);
end

tline = fgets(file_in);
while ischar(tline)
    idx = strfind(tline, '=');
    if ~isempty(idx) && ~isempty(strtrim(tline))
        pluginString = strtrim(tline(1 : idx - 1));
        valueString = strtrim(tline(idx + 1 : end));
        valueString = valueString(1 : end - 1);
        idx = strfind(pluginString, '.');
        if length(idx) >= 1
            temp = pluginString(1 : idx(end) - 1);
            temp = strrep(temp, '.', '.plugins.');
            pluginString = [temp pluginString(idx(end) : end)];
            idx = strfind(pluginString, '.');
            plugindata = [plugindata 'chainData.' pluginString(1 : idx(end)) 'setVar(''' pluginString(idx(end) + 1 : end) ''', ' valueString ');' char(13)];
        end
    end
    tline = fgets(file_in);
end
fclose(file_in);
eval(plugindata);

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