function showDebug(debugData, blnClose, bringToFront)
% Author: S. Franz (c) ITAS/IHA @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create 20-Mar-2014 			 SF

if nargin < 2
    blnClose = false;
end
if nargin < 3
    bringToFront = false;
end
figures = get(0, 'children');
this.handles.figure = 0;
for ii = 1 : length(figures)
    if strcmp(get(figures(ii), 'Tag'), 'debug')
        this.handles.figure = figures(ii);
    elseif strcmp(get(figures(ii), 'Tag'), 'main')
        this.handles.Mainfigure = figures(ii);
    end
end
if ~blnClose
    if ~this.handles.figure
        this.handles.figure = figure('Units', 'normalized', 'MenuBar', 'none', 'ToolBar', 'figure', 'Tag', 'debug', 'Name', 'Debug');
        this.handles.listbox = uicontrol('Parent', this.handles.figure, 'Style', 'listbox', 'FontSize', 10, 'Units', 'normalized', 'position', [0 0 .33 1]);
        this.handles.panel = uipanel('Parent', this.handles.figure, 'Title', '', 'FontSize', 10, 'Units', 'normalized', 'position', [.33 0 .67 1]);
        this.handles.myAxes = [];
        this.updateData = @updateData;
        set(this.handles.figure, 'UserData', this)
        figure(this.handles.Mainfigure);
    else
        this = get(this.handles.figure, 'UserData');
%         figure(this.handles.Mainfigure);
    end
end
if blnClose
    if ishandle(this.handles.figure) && this.handles.figure > 0
        delete(this.handles.figure);
    end
elseif bringToFront
%     figure(this.handles.figure);
else
    this.updateData(debugData);
end

    function updateData(debugData)
        plugins = fieldnames(debugData);
        list = {};
        plotNames = {};
        myAxes = {};
        for countPlugins = length(plugins) : -1 : 1
            plugin = debugData.(char(plugins(countPlugins)));
            fields = fieldnames(plugin);
            for countFields = 1 : length(fields)
                data = plugin.(char(fields(countFields)));
                if ischar(data)
                    list{length(list) + 1} = [char(plugins(countPlugins)) '.' char(fields(countFields)) ' = '];
                    list{length(list) + 1} = ['  ''' data ''''];
                elseif isnumeric(data)
                    if max(size(data)) <= 5
                        list{length(list) + 1} = [char(plugins(countPlugins)) '.' char(fields(countFields)) ' = '];
                        if max(size(data)) == 1
                            list{length(list) + 1} = ['  ' num2str(data)];
                        else
                            list{length(list) + 1} = ['  ' mat2str(data)];
                        end
                    else
                        plotNames{length(plotNames) + 1} = [char(plugins(countPlugins)) '.' char(fields(countFields))];
                        myAxes{length(myAxes) + 1} = data;
                    end
                end
            end
        end
        if length(plotNames) ~= length(this.handles.myAxes)
            delete(get(this.handles.panel, 'children'));
            this.handles.myAxes = [];
            yCount = ceil(sqrt(length(plotNames)));
            xCount = ceil(length(plotNames) / yCount);
            for y = 1 : yCount
                for x = 1 : xCount
                    this.handles.myAxes(length(this.handles.myAxes) + 1) = axes('parent', this.handles.panel, 'outerposition', [(x-1)/xCount; 1-y/yCount; 1/xCount; 1/yCount]);
                end
            end
            delete(this.handles.myAxes(length(myAxes) + 1 : end));
            this.handles.myAxes(length(myAxes) + 1 : end) = [];
        end
        for count = 1 : length(myAxes)
            data = cell2mat(myAxes(count));
            if min(size(data)) > 12
                h = imagesc(data, 'parent', this.handles.myAxes(count));
                %xlim(h, [.5 size(data, 2)+.5]);
                %ylim(h, [.5 size(data, 1)+.5]);
            else
                minMax = get(this.handles.myAxes(count), 'UserData');
                if isempty(minMax)
                    minMax(1) = min(min(data));
                    minMax(2) = max(max(data));
                else
                    minMax(1) = min(minMax(1), min(min(data)));
                    minMax(2) = max(minMax(2), max(max(data)));
                end
                plot(data, 'parent', this.handles.myAxes(count));
                ylim(this.handles.myAxes(count), minMax);
                xlim(this.handles.myAxes(count), [1 size(data, 1)]);
                set(this.handles.myAxes(count), 'UserData', minMax);
            end
            title(this.handles.myAxes(count), char(plotNames{count}));
        end
        set(this.handles.listbox, 'Value', max(1, min(length(list), get(this.handles.listbox, 'Value'))));
        set(this.handles.listbox, 'String', list);
        
        %         plot(this.handles.axes(1), debugData.test.spec);
        drawnow;
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