function pic_message(strpic_message, type)
% Author: S. Franz (c) ITAS/IHA @ Jade Hochschule applied licence see EOF 
% Version History:
% Ver. 0.01 initial create 20-Mar-2014 			 SF

global InfoBrowser;
if nargin < 2
    type = '';
end
stack = dbstack;
strpic_message = [strpic_message ' (in ==> <a href="matlab: opentoline(''' findFile(stack(2).file, ['.' filesep 'Plugins']) ''',' num2str(stack(2).line) ', 0)">' strrep(stack(2).name, '/', '>') ' at ' num2str(stack(2).line) '</a>)'];
if strcmpi(type, 'error')
    strpic_message = ['<font color="red">ERROR: ' strpic_message '</font>'];
    if exist(['Temp' filesep 'temp.cfg'], 'file')
        delete(['Temp' filesep 'temp.cfg'])
    end
    error('');
end    
if ~isempty(InfoBrowser) && ishandle(InfoBrowser)
    currentpic_message = char(InfoBrowser.getHtmlText());
    idx = strfind(currentpic_message, '</html>');
    if ~isempty(currentpic_message)
        currentpic_message = currentpic_message(1 : idx -1);
        currentpic_message = strrep(currentpic_message, '<script type="text/javascript">window.scrollTo(0,document.body.scrollHeight);</script>', '');
    else
        currentpic_message = '<html>';
    end
    InfoBrowser.setHtmlText([strtrim([currentpic_message strpic_message]) '<br /><script type="text/javascript">window.scrollTo(0,document.body.scrollHeight);</script></html>']);
else
    disp(strpic_message);
end
drawnow;
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