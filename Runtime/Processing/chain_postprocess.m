function chain_postprocess(chain)
% Author: S. Franz (c) ITAS/IHA @ Jade Hochschule applied licence see EOF 
% Version History:
% Ver. 0.01 initial create 20-Mar-2014 			 SF

global AlgoCom;
global Debug;
plugins = fieldnames(chain);
for count = 1 : length(plugins)
    plugin = chain.(char(plugins(count)));
%     if plugin.getVar('Enabled')
        AlgoCom.debug = struct;
        plugin.postprocess();
        if isfield(AlgoCom, 'debug') && plugin.getVar('Debug')
            Debug.(char(plugins(count))) = AlgoCom.debug;
        end
        AlgoCom.debug = struct;
        drawnow;
%     end
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