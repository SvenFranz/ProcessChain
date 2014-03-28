function [out1 out2] = process_subplugs(chain, in1, in2)
% Author: S. Franz (c) ITAS/IHA @ Jade Hochschule applied licence see EOF 
% Version History:
% Ver. 0.01 initial create 20-Mar-2014 			 SF

if nargin > 1
    out1 = in1;
else
    out1 = [];
end
if nargin > 2
    out2 = in2;
else
    out2 = [];
end

stack = dbstack;
if isstruct(chain) && ~isempty(fieldnames(chain)) && length(stack) > 1 && ~isempty(strfind(stack(2).name, '/'))
    if strcmp(stack(2).name(end-4 : end), '/init')
        [out1] = chain_init(chain, in1);
    elseif strcmp(stack(2).name(end-10 : end), '/preprocess')
        chain_preprocess(chain);
    elseif strcmp(stack(2).name(end-7 : end), '/process')
        [out1] = chain_process(chain, in1);
    elseif strcmp(stack(2).name(end-11 : end), '/postprocess')
        chain_postprocess(chain);
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