% Author: S. Franz (c) ITAS/IHA @ Jade Hochschule applied licence see EOF 
% Version History:
% Ver. 0.01 initial create 20-Mar-2014 			 SF

clear; close all; clc;
szPath = mfilename('fullpath');
addpath([szPath(1:end-length(mfilename)) filesep 'Runtime']);
initRuntime();

mychain = struct();
mychain.init = init_Plugin;
mychain.init.plugins.FileInput = FileInput_Plugin;
mychain.init.plugins.ola = ola_Plugin;
mychain.init.plugins.ola.plugins.fft = fft_Plugin;
mychain.init.plugins.ola.plugins.fft.plugins.fftRectFilt = fftRectFilt_Plugin;
mychain.init.plugins.playrecOut = playrecOut_Plugin;

mychain.init.plugins.FileInput.setVar('filename', ['Audiofiles' filesep 'Noise.wav']);
mychain.init.plugins.ola.plugins.fft.plugins.fftRectFilt.setVar('f_u', 1000);
mychain.init.plugins.ola.plugins.fft.plugins.fftRectFilt.setVar('f_o', 4000);
process(mychain);

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