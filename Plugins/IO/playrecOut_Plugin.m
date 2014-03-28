function this = playrecOut_Plugin(strName) %#ok% Author: Jan Willhaus <mail@janwillhaus.de> (c) applied licence see EOF% Version History:% Ver. 0.01 initial create                                  25-Mar-2014     JW% Ver. 0.1  first functioning release                       25-Mar-2014     JW% Ver. 0.11  BlockSettingsIn = [] removed                   27-Mar-2014  	SFglobal AlgoCom; this = struct; vars = struct; %#ok%% add plugin-properties herestDevices = playrec('getDevices');setVar('Device', 'a', {stDevices([stDevices.outputChans] > 0).name});%% add local plugin-variables hereprevPlaybackPage= [];playbackPage    = [];%% public and necessary functions    function [BlockSettings] = init(BlockSettings) %#ok        if ~strcmp(BlockSettings.domain, 'time')            pic_message('Plugin expect time domain signal', 'error');        end                % Get the requested Device ID        szDevice = getVar('Device');        iOutputDevice = stDevices(strcmpi({stDevices.name}, szDevice)).deviceID;        iOutputDevice = iOutputDevice(1);                % Reset Playrec if it is still initialised        if playrec('isInitialised')            playrec('reset');        end                % Initialise Playrec        playrec('init',             ...            BlockSettings.fs,       ... % Sampling Rate            iOutputDevice,          ... % Output Device            -1,                     ... % Input Device      (disabled)            BlockSettings.channels, ... % Nchan of output            [],                     ... % Nchan of input    (disabled)            BlockSettings.blocklen);    % Blocksize                BlockSettingsIn = BlockSettings;            end    function preprocess() %#ok    end    function [out] = process(in) %#ok        if size(in, 1) == BlockSettingsIn.blocklen                        % Put the previous page into its variable (ringbuffer)            prevPlaybackPage = playbackPage;                        % Send a new page to the interface            playbackPage = playrec('play', in, 1:BlockSettingsIn.channels);                        % Block further execution until previous page is finished            playrec('block', prevPlaybackPage);                    end        AlgoCom.debug.signal = in;        out = in;    end    function postprocess() %#ok        if playrec('isInitialised')            playrec('reset');        end    end%%------------------------ Licence ----------------------------------------% Copyright (c) <2014> Jan Willhaus%% Permission is hereby granted, free of charge, to any person obtaining% a copy of this software and associated documentation files% (the "Software"), to deal in the Software without restriction, including% without limitation the rights to use, copy, modify, merge, publish,% distribute, sublicense, and/or sell copies of the Software, and to% permit persons to whom the Software is furnished to do so, subject% to the following conditions:%% The above copyright notice and this permission notice shall be included% in all copies or substantial portions of the Software.%% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,% EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES% OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.% IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY% CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,end