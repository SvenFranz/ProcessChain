function msg = process(chain, blnDebug, optionalCallbackAfterInit)
% Author: S. Franz (c) ITAS/IHA @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create 20-Mar-2014 			 SF

global AlgoCom;
global Debug;
global VersionHasErrors;
if ~isempty(VersionHasErrors) && VersionHasErrors
    return;
end

msg = '';
Debug = struct;
AlgoCom = struct;
if nargin < 2
    blnDebug = false;
end
if ischar(chain) && exist(['Settings' filesep chain '.cfg'], 'file')
    chain = loadSettings(chain);
end
if ~exist(['Temp' filesep 'temp.cfg'], 'file')
    file = fopen(['Temp' filesep 'temp.cfg'], 'w');
    fclose(file);
end
try
    if isstruct(chain) && ~isempty(fieldnames(chain))
        [~] = chain_init(chain, []);
        if exist('optionalCallbackAfterInit', 'var') && isa(optionalCallbackAfterInit, 'function_handle')
            try
            optionalCallbackAfterInit();
            catch exp
            end
        end
        chain_preprocess(chain.init.plugins);
        blnRun = true;
        signal = [];
        while blnRun && exist(['Temp' filesep 'temp.cfg'], 'file')
            AlgoCom.Debug = struct();
            [signal, blnRun] = chain_process(chain.init.plugins, signal);
            if blnDebug && isfield(AlgoCom, 'Debug')
                showDebug(Debug);
            end
        end
        chain_postprocess(chain.init.plugins);
    end
    if exist(['Temp' filesep 'temp.cfg'], 'file')
        delete(['Temp' filesep 'temp.cfg'])
    end
catch exp
    msg = exp.getReport;
    try
        idx1 = strfind(msg, '_Plugin.m');
        idx2 = strfind(msg, sprintf('\n'));
        msg = msg(1 : idx2(find(idx2 > idx1(1), 1, 'first')));
    catch exp2
        msg = exp.getReport;
    end
    idx1 = strfind(msg, '.m') + 1;
    msgTemp = msg;
    for idx = strfind(msg, [filesep 'Temp' filesep 'Plugins' filesep])
        str = msg(idx : idx1(find(idx1 > idx, 1, 'first')));
        tmpIdx = find(str == filesep, 1, 'last') + 1;
        file = str(tmpIdx : end);
        filepath = findFile(file, ['.' filesep 'Plugins']);
        if isempty(filepath)
            filepath = findFile(file, ['.' filesep 'Runtime' filesep 'PluginTemplates']);
        end
        msgTemp = strrep(msgTemp, str, filepath(2:end));
    end
    msg = strrep(msgTemp, '\', '\\');
    beep;
    if nargout < 1
        fprintf(2, msg);
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