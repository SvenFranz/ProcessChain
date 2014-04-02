function pluginGui(chain)
% Author: S. Franz (c) ITAS/IHA @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create 20-Mar-2014              SF
% Ver. 0.1  Tooltips added                          SF
%           Menubar added

initRuntime();
global InfoBrowser VersionHasErrors;
if ~isempty(VersionHasErrors) && VersionHasErrors
    return;
end

clc; close all;
FileName = '';
hasChanges = false;
rootFolder = pwd;
% breakpointsBuffer = {};
blnIsRunning = false;
blnMouseDown = false;
tempChain = [];

if (nargin > 0 && ischar(chain)) || (nargin == 0 && exist(['Runtime' filesep 'RecentFiles.mat'], 'file'))
    if nargin == 0 && exist(['Runtime' filesep 'RecentFiles.mat'], 'file')
        chain = [];
        tmp = load(['Runtime' filesep 'RecentFiles.mat']);
        if ~isempty(tmp.RecentFiles)
            chain = char(tmp.RecentFiles{1});
        end
        clear('tmp');
    end
    if ~isempty(strfind(chain, '.cfg'))
        chain = chain(1 : strfind(chain, '.cfg') - 1);
    end
    if exist(['Settings' filesep chain '.cfg'], 'file')
        FileName = chain;
        chain = loadSettings(FileName);
    end
end
if ~exist('chain', 'var') || isempty(chain)
    chain = struct;
    chain.init = init_Plugin;
end

load GUI_controls.mat
handles.figure = figure('Units', 'normalized', 'position', [.15 .2 .7 .6], 'CloseRequestFcn', @CloseReq, 'tag', 'main', 'WindowButtonUpFcn', @WindowButtonUpFcn);
set(handles.figure, 'MenuBar', 'none');

handles.menubar(1) = uimenu('Parent', handles.figure, 'Label', 'File', 'Tag','uimenubar1');
handles.uimenuItem(1) = uimenu('Parent', handles.menubar(1), 'Label', 'New', 'Callback', @new, 'Accelerator', 'N');
handles.uimenuItem(2) = uimenu('Parent', handles.menubar(1), 'Label', 'Open...', 'Callback', @open_file, 'Accelerator', 'O');
handles.uimenuItem(3) = uimenu('Parent', handles.menubar(1), 'Label', 'Save', 'Callback', @saveConfig, 'Separator', 'on', 'Accelerator', 'S');
handles.uimenuItem(4) = uimenu('Parent', handles.menubar(1), 'Label', 'Save as...', 'Callback', @saveAs);
handles.uimenuItem(5) = uimenu('Parent', handles.menubar(1), 'Label', 'Quit', 'Callback', @CloseReq, 'Separator', 'on', 'Accelerator', 'Q');
handles.menubar(2) = uimenu('Parent', handles.figure, 'Label', 'Plugins', 'Tag','uimenubar2');
handles.uimenuItem(6) = uimenu('Parent', handles.menubar(2), 'Label', 'Add Plugin', 'Callback', @changePlug, 'Tag', 'add');
handles.uimenuItem(7) = uimenu('Parent', handles.menubar(2), 'Label', 'Remove Plugin', 'Callback', @changePlug, 'Tag', 'rem');
handles.uimenuItem(8) = uimenu('Parent', handles.menubar(2), 'Label', 'Up', 'Callback', @changePlug, 'Tag', 'up');
handles.uimenuItem(9) = uimenu('Parent', handles.menubar(2), 'Label', 'Down', 'Callback', @changePlug, 'Tag', 'down');
handles.uimenuItem(14) = uimenu('Parent', handles.menubar(2), 'Label', 'Selected Plugin','Tag', 'down', 'Separator','on');
handles.uimenuItem(15) = uimenu('Parent', handles.uimenuItem(14), 'Label', 'Edit Sourcecode', 'Callback', @editSourcecode, 'Tag', 'down');
handles.uimenuItem(16) = uimenu('Parent', handles.uimenuItem(14), 'Label', 'Edit merged Sourcecode', 'Callback', @editMergedSourcecode, 'Tag', 'down');
handles.uimenuItem(17) = uimenu('Parent', handles.uimenuItem(14), 'Label', 'Reset Parameters', 'Callback', @ResetParameters, 'Tag', 'down', 'Separator','on');
handles.menubar(3) = uimenu('Parent', handles.figure, 'Label', 'Run/Debug', 'Tag','uimenubar3');
handles.uimenuItem(10) = uimenu('Parent', handles.menubar(3), 'Label', 'Run', 'Callback', @run, 'Tag', 'run', 'Accelerator', 'R');
handles.uimenuItem(11) = uimenu('Parent', handles.menubar(3), 'Label', 'Stop', 'Callback', @run, 'Tag', 'stop', 'visible', 'off', 'Accelerator', 'R');
handles.uimenuItem(12) = uimenu('Parent', handles.menubar(3), 'Label', 'Debug', 'Callback', @run, 'Tag', 'debug', 'Accelerator', 'D');
handles.menubar(4) = uimenu('Parent', handles.figure, 'Label', 'Configs', 'Tag','uimenubar3');
handles.RecentFiles = [];
handles.menubar(5) = uimenu('Parent', handles.figure, 'Label', 'Help', 'Tag','uimenubar3');
handles.uimenuItem(13) = uimenu('Parent', handles.menubar(5), 'Label', 'About ProcessChain', 'Callback', @VersionInfo);

RecentFiles = [];
updateRecentFiles(FileName)

handles.uitoolbar = uitoolbar('Parent', handles.figure, 'Tag','uitoolbar1');
handles.toolbarItem(1) = uipushtool('Parent', handles.uitoolbar, 'ClickedCallback', @new, 'CData', mat{1}, 'Tooltip', 'New');
handles.toolbarItem(2) = uipushtool('Parent', handles.uitoolbar, 'ClickedCallback', @open_file, 'CData', mat{2}, 'Tooltip', 'Open...');
handles.toolbarItem(3) = uipushtool('Parent', handles.uitoolbar, 'ClickedCallback', @saveConfig, 'CData', mat{3}, 'Tooltip', 'Save');
handles.toolbarItem(4) = uipushtool('Parent', handles.uitoolbar, 'ClickedCallback', @saveAs, 'CData', mat{4}, 'Tooltip', 'Save As...');
handles.toolbarItem(5) = uipushtool('Parent', handles.uitoolbar, 'ClickedCallback', @changePlug, 'CData',mat{5}, 'Separator','on', 'Tag', 'add', 'Tooltip', 'Add Plugin');
handles.toolbarItem(6) = uipushtool('Parent', handles.uitoolbar, 'ClickedCallback', @changePlug, 'CData',mat{6}, 'Tag', 'rem', 'Tooltip', 'Remove Plugin');
handles.toolbarItem(7) = uipushtool('Parent', handles.uitoolbar, 'ClickedCallback', @changePlug, 'CData',mat{7}, 'Tag', 'up', 'Tooltip', 'Up');
handles.toolbarItem(8) = uipushtool('Parent', handles.uitoolbar, 'ClickedCallback', @changePlug, 'CData',mat{8}, 'Tag', 'down', 'Tooltip', 'Down');
handles.toolbarItem(9) = uipushtool('Parent', handles.uitoolbar, 'ClickedCallback', @run, 'CData',mat{9}, 'Separator','on', 'Tag', 'run', 'Tooltip', 'Run');
handles.toolbarItem(10) = uipushtool('Parent', handles.uitoolbar, 'ClickedCallback', @run, 'CData',mat{10}, 'Tag', 'stop', 'visible', 'off', 'Tooltip', 'Stop');
handles.toolbarItem(11) = uipushtool('Parent', handles.uitoolbar, 'ClickedCallback', @run, 'CData',mat{11}, 'Tag', 'debug', 'Tooltip', 'Run Debug');

handles.panelChain = uipanel('Parent', handles.figure, 'Title', 'Pluginchain', 'FontSize', 10, 'Units', 'normalized', 'position', [0 .33 .45 .67]);
handles.panelSettings = uipanel('Parent', handles.figure, 'Title', 'Settings', 'FontSize', 10, 'Units', 'normalized', 'position', [.45 .33 .55 .67]);

handles.listbox = uicontrol('Parent', handles.panelChain, 'Style', 'listbox', 'FontSize', 10, 'Units', 'normalized', 'position', [0 0 1 1], 'Callback', @selectPlugin, 'FontName', 'Courier New');
ContextMenu=uicontextmenu;
uimenu('Parent', ContextMenu, 'Label', 'Edit Sourcecode', 'Callback', @editSourcecode);
uimenu('Parent', ContextMenu, 'Label', 'Edit merged Sourcecode', 'Callback', @editMergedSourcecode);
uimenu('Parent', ContextMenu, 'Label', 'Reset Parameters', 'Callback', @ResetParameters, 'Separator','on');
set(handles.listbox,'UIContextMenu',ContextMenu);

try
    handles.panelInfo = uipanel('Parent', handles.figure, 'Title', 'Information', 'FontSize', 10, 'Units', 'normalized', 'position',  [0 0 1 .33]);
    jObject = com.mathworks.mlwidgets.html.HTMLBrowserPanel;
    [InfoBrowser, handles.InfoPanel] = javacomponent(jObject, [], handles.panelInfo);
    set(handles.InfoPanel, 'Units','normalized', 'position', [0 0 1 1]);
catch exp
    if isfield(handles, 'InfoPanel') && ishandle(handles.InfoPanel); delete(handles.InfoPanel); end
    if ishandle(InfoBrowser); delete(InfoBrowser); end
    if isfield(handles, 'panel2') && ishandle(handles.panelInfo); delete(handles.panelInfo); end
    handles.InfoPanel = [];
    InfoBrowser = [];
    handles.panelInfo = [];
    set(handles.panelSettings, 'position', [.45 0 .55 1]);
    set(handles.panelChain, 'position', [0 0 .45 1]);
end

% handles.InfoPanel = uicontrol('Parent', handles.figure, 'Style', 'listbox', 'FontSize', 10, 'Units', 'normalized', 'position', [0 0 1 .33], 'Callback', '', 'FontName', 'Courier New');
selectedPlugin.plugin = [];
selectedPlugin.listIdx = 0;
selectedPlugin.chainIdx = 0;
selectedPlugin.chainString = {};
selectedPlugin.name = [];
drawnow;
loadData()
setPanelChainTitle();

    function updateRecentFiles(ConfigFile)
        if exist(['Runtime' filesep 'RecentFiles.mat'], 'file')
            tmp = load(['Runtime' filesep 'RecentFiles.mat']);
            RecentFiles = tmp.RecentFiles;
            tmpRecentFiles = {};
            if ~isempty(ConfigFile)
                tmpRecentFiles{1} = ConfigFile;
            end
            for count = 1 : length(RecentFiles)
                if exist(['Settings' filesep char(RecentFiles{count}) '.cfg'], 'file') && ~strcmp(char(RecentFiles{count}), ConfigFile)
                    tmpRecentFiles{length(tmpRecentFiles) + 1} = char(RecentFiles{count});
                end
                if length(tmpRecentFiles) == 9; break; end;
            end
            RecentFiles = tmpRecentFiles;
        elseif ~isempty(ConfigFile)
            RecentFiles{1} = ConfigFile;
        end
        save(['Runtime' filesep 'RecentFiles.mat'], 'RecentFiles');
        for count = 1 : length(handles.RecentFiles)
            if ishandle(handles.RecentFiles(count))
                delete(handles.RecentFiles)
            end
        end
        handles.RecentFiles = [];
        for count = 1 : length(RecentFiles)
            handles.RecentFiles(count) = uimenu('Parent', handles.menubar(4), 'Label', [char(RecentFiles(count)) '.cfg'], 'Callback', @loadConfig, 'Accelerator', num2str(count));
        end
    end

    function editSourcecode(hObject, ~)
        selectedPlugin.listIdx = get(handles.listbox, 'value');
        pluginlist = get(handles.listbox, 'String');
        if ~isempty(pluginlist) && selectedPlugin.listIdx > 0
            plugin = char(pluginlist{selectedPlugin.listIdx});
            plugin = strtrim(strrep(plugin(2 : end), '| ', '')); %strtrim(plugin(2 : end));
            plugin = [plugin(strfind(plugin, '(') + 1 : end -1) '_Plugin.m'];
            file = findFile(plugin, ['./' filesep 'Plugins']);
            if isempty(file)
                file = findFile(plugin, ['./' filesep 'Runtime']);
            end
            edit(file);
        end
    end

    function editMergedSourcecode(hObject, ~)
        initRuntime();
        selectedPlugin.listIdx = get(handles.listbox, 'value');
        pluginlist = get(handles.listbox, 'String');
        if ~isempty(pluginlist) && selectedPlugin.listIdx > 0
            plugin = char(pluginlist{selectedPlugin.listIdx});
            plugin = strtrim(strrep(plugin(2 : end), '| ', '')); %strtrim(plugin(2 : end));
            plugin = [plugin(strfind(plugin, '(') + 1 : end -1) '_Plugin.m'];
            edit(which(plugin));
        end
    end

    function new(hObject, ~)
        if checkHasChanges()
            if isempty(fieldnames(chain)) || strcmp(questdlg('Neue Pluginkette erstellen?', '', 'Ja', 'Nein', 'Nein'), 'Ja')
                chain = struct;
                chain.init = init_Plugin;
                FileName = '';
                setPanelChainTitle();
                tempChain = [];
                loadData();
                hasChanges = false;
                drawnow;
            end
            set(handles.figure, 'Name', FileName);
        end
    end

    function setPanelChainTitle()
        title = FileName;
        if isempty(title)
            title = 'unsaved';
        end
        set(handles.panelChain, 'Title', ['Pluginchain: ' title]);
    end

    function open_file(hObject, ~)
        if checkHasChanges()
            [File, PathName] = uigetfile('*.cfg',  'Pluginchain-files (*.cfg)', ['Settings' filesep]);
            loadConfig(File);
        end
    end

    function loadConfig(hObject, ~)
        if ishandle(hObject)
            File = get(hObject, 'Label');
            if ~checkHasChanges()
                return
            end
        else
            File = hObject;
        end
        if ~isequal(File, 0)
            chain = struct;
            tempChain = [];
            loadData();
            drawnow;
            FileName = File(1 : end - 4);
            setPanelChainTitle();
            chain = loadSettings(FileName);
            loadData();
            hasChanges = false;
            updateRecentFiles(FileName);
        end
        set(handles.figure, 'Name', FileName);
    end

    function returnValue = checkHasChanges()
        returnValue = true;
        if hasChanges
            DialogValue = questdlg('Pluginkette wurde geändert! Änderungen speichern?', '', 'Ja', 'Nein', 'Abbrechen', 'Abbrechen');
            if strcmp(DialogValue, 'Ja')
                saveConfig([], [])
            elseif strcmp(DialogValue, 'Abbrechen')
                returnValue = false;
            end
        end
    end

    function loadData()
        PluginList = addPluginsToTree({}, chain, 0);
        if ishandle(handles.listbox)
            set(handles.listbox, 'Value', max(1, min(get(handles.listbox, 'Value'), length(PluginList))));
        end
        if ishandle(handles.listbox)
            set(handles.listbox, 'String', PluginList);
        end
        selectPlugin(handles.listbox, []);
        if ishandle(handles.figure)
            set(handles.figure, 'Name', FileName);
        end
        drawnow;
    end

    function returnValue = saveConfig(hObject, ~)
        returnValue = false;
        if ~isempty(fieldnames(chain))
            if isempty(FileName) || isequal(FileName, 0)
                returnValue = saveAs(hObject, []);
            else
                saveSettings(FileName, chain);
                returnValue = true;
                hasChanges = false;
                updateRecentFiles(FileName);
            end
        end
        set(handles.figure, 'Name', FileName);
    end

    function returnValue = saveAs(hObject, ~)
        returnValue = false;
        if ~isempty(fieldnames(chain))
            [File, PathName] = uiputfile('*.cfg',  'Pluginchain-files (*.cfg)', ['Settings' filesep]);
            if ~isequal(File, 0)
                FileName = File(1 : end - 4);
                setPanelChainTitle();
                saveConfig(hObject, []);
                hasChanges = false;
                returnValue = true;
                updateRecentFiles(FileName);
            end
        end
        set(handles.figure, 'Name', FileName);
    end

    function changePlug(hObject, ~)
        tempName = selectedPlugin.name;
        if ~isempty(selectedPlugin.chainString)
            tempchain = getfield(chain, selectedPlugin.chainString{:});
        else
            tempchain = chain;
        end
        if strcmp(get(hObject, 'Tag'), 'add')
            cd(rootFolder);
            initRuntime();
            [File, PathName] = uigetfile('*_Plugin.m',  'Plugin-files (*_Plugin.m)', ['Plugins' filesep]);
            if strfind(File, '_Plugin.m')
                pluginName = inputdlg({'Name'},'',1,{strrep(File, '_Plugin.m', '')});
                if ~isempty(pluginName)
                    newChain = tempchain;
                    newChain.(selectedPlugin.name).plugins.(char(pluginName)) = eval(File(1 : end - 2));
                    tempName = char(pluginName);
                    hasChanges = true;
                else
                    msgbox(['''' File ''' is not a valid Plugin-File!']);
                end
            end
        elseif strcmp(get(hObject, 'Tag'), 'rem')
            if strcmp(questdlg('Plugin entfernen?', '', 'Ja', 'Nein', 'Nein'), 'Ja')
                plugins = fieldnames(tempchain);
                newChain = struct();
                idx = 1 : length(plugins);
                idx(selectedPlugin.chainIdx) = [];
                for count = idx
                    newChain.(char(plugins(count)))  = tempchain.(char(plugins(count)));
                end
                hasChanges = true;
            end
        elseif strcmp(get(hObject, 'Tag'), 'up')
            if selectedPlugin.chainIdx > 1
                plugins = fieldnames(tempchain);
                newChain = struct();
                for count = 1 : selectedPlugin.chainIdx - 2
                    newChain.(char(plugins(count)))  = tempchain.(char(plugins(count)));
                end
                newChain.(char(plugins(selectedPlugin.chainIdx)))  = tempchain.(char(plugins(selectedPlugin.chainIdx)));
                newChain.(char(plugins(selectedPlugin.chainIdx-1)))  = tempchain.(char(plugins(selectedPlugin.chainIdx-1)));
                for count = selectedPlugin.chainIdx + 1 : length(plugins)
                    newChain.(char(plugins(count)))  = tempchain.(char(plugins(count)));
                end
                hasChanges = true;
            end
        elseif strcmp(get(hObject, 'Tag'), 'down')
            if length(fieldnames(tempchain)) > selectedPlugin.chainIdx
                plugins = fieldnames(tempchain);
                newChain = struct();
                for count = 1 : selectedPlugin.chainIdx - 1
                    newChain.(char(plugins(count)))  = tempchain.(char(plugins(count)));
                end
                newChain.(char(plugins(selectedPlugin.chainIdx+1)))  = tempchain.(char(plugins(selectedPlugin.chainIdx+1)));
                newChain.(char(plugins(selectedPlugin.chainIdx)))  = tempchain.(char(plugins(selectedPlugin.chainIdx)));
                for count = selectedPlugin.chainIdx + 2 : length(plugins)
                    newChain.(char(plugins(count)))  = tempchain.(char(plugins(count)));
                end
                hasChanges = true;
            end
        end
        if exist('newChain', 'var')
            if ~isempty(selectedPlugin.chainString)
                chain = setfield(chain, selectedPlugin.chainString{:}, newChain);
            else
                chain = newChain;
            end
        end
        loadData();
        [~, ~ , ~, listIdx] = findPlugin(tempName, chain, 0, 0);
        set(handles.listbox, 'value', listIdx);
        selectPlugin(handles.listbox, []);
    end

    function run(hObject, ~)
        if strcmp(get(hObject, 'Tag'), 'run') || strcmp(get(hObject, 'Tag'), 'debug')
            blnIsRunning = true;
            blnDebug = strcmp(get(hObject, 'Tag'), 'debug');
            clc;
            for count = 1 : 8
                set(handles.toolbarItem(count), 'enable', 'off');
            end
            for count = 1 : 9
                set(handles.uimenuItem(count), 'enable', 'off');
            end
            for count = 1 : length(handles.RecentFiles)
                set(handles.RecentFiles(count), 'enable', 'off');
            end
            if blnDebug
                showDebug([], false, true);
                set(handles.toolbarItem(9), 'enable', 'off', 'Separator', 'on');
                set(handles.toolbarItem(10), 'visible', 'on', 'Separator', 'off');
                set(handles.toolbarItem(11), 'visible', 'off');
                set(handles.uimenuItem(10), 'enable', 'off');
                set(handles.uimenuItem(11), 'visible', 'on', 'enable', 'on', 'Accelerator', 'D');
                set(handles.uimenuItem(12), 'visible', 'off');
            else
                showDebug([], true);
                set(handles.toolbarItem(9), 'visible', 'off', 'Separator', 'off');
                set(handles.toolbarItem(10), 'visible', 'on', 'Separator', 'on');
                set(handles.toolbarItem(11), 'enable', 'off');
                set(handles.uimenuItem(10), 'visible', 'off');
                set(handles.uimenuItem(11), 'visible', 'on', 'enable', 'on', 'Accelerator', 'R');
                set(handles.uimenuItem(12), 'enable', 'off');
            end
            if ~isempty(InfoBrowser)
                InfoBrowser.setHtmlText('');
            end
            drawnow;
            cd(rootFolder);
            initRuntime();
            saveSettings(['..' filesep 'Temp' filesep 'temp'], chain);
            chain = loadSettings(['..' filesep 'Temp' filesep 'temp']);
            loadData();
            %             breakpoints = dbstatus;
            %             breakpointsBuffer = {};
            %             for count = 1 : length(breakpoints)
            %                 if ~isempty(strfind(breakpoints(count).file, [filesep 'Temp' filesep 'Plugins' filesep]))
            %                     if blnDebug == false
            %                         eval(['dbclear in ' breakpoints(count).file ';']);
            %                     end
            %                 elseif ~isempty(strfind(breakpoints(count).file, [filesep 'Plugins' filesep]))
            %                     if blnDebug
            %                         eval(['dbstop in ' strrep(breakpoints(count).file, [filesep 'Plugins' filesep], [filesep 'Temp' filesep 'Plugins' filesep]) ' at ' num2str(breakpoints(count).line) ';']);
            %                         breakpointsBuffer{length(breakpointsBuffer) + 1} = strrep(breakpoints(count).file, [filesep 'Plugins' filesep], [filesep 'Temp' filesep 'Plugins' filesep]);
            %                         edit(strrep(breakpoints(count).file, [filesep 'Plugins' filesep], [filesep 'Temp' filesep 'Plugins' filesep]));
            %                     end
            %                 end
            %             end
            myError = process(chain, blnDebug);
            if ~isempty(myError)
                appendInfoPanel(myError)
            end
        end
        if exist(['Temp' filesep 'temp.cfg'], 'file')
            delete(['Temp' filesep 'temp.cfg']);
        end
        %         breakpoints = dbstatus;
        %         for count = 1 : length(breakpointsBuffer)
        %             if sum(strcmp(char(breakpointsBuffer{count}), {breakpoints.file})) == 0
        %                 folder = fileparts(strrep(char(breakpointsBuffer{count}), [filesep 'Temp' filesep 'Plugins' filesep], [filesep 'Plugins' filesep]));
        %                 cd(folder);
        %                 eval(['dbclear in ' strrep(char(breakpointsBuffer{count}), [filesep 'Temp' filesep 'Plugins' filesep], [filesep 'Plugins' filesep]) ';']);
        %             end
        %         end
        cd(rootFolder);
        if ishandle(handles.toolbarItem(10))
            set(handles.toolbarItem(10), 'visible', 'off', 'Separator', 'off');
            set(handles.uimenuItem(11), 'visible', 'off');
        end
        if ishandle(handles.toolbarItem(9))
            set(handles.toolbarItem(9), 'visible', 'on', 'Separator', 'on', 'enable', 'on');
            set(handles.uimenuItem(10), 'visible', 'on', 'enable', 'on');
        end
        if ishandle(handles.toolbarItem(11))
            set(handles.toolbarItem(11), 'visible', 'on', 'enable', 'on');
            set(handles.uimenuItem(12), 'visible', 'on', 'enable', 'on');
        end
        for count = 1 : 8
            if ishandle(handles.toolbarItem(count))
                set(handles.toolbarItem(count), 'enable', 'on');
            end
        end
        for count = 1 : 9
            if ishandle(handles.uimenuItem(count))
                set(handles.uimenuItem(count), 'enable', 'on');
            end
        end
        for count = 1 : length(handles.RecentFiles)
            set(handles.RecentFiles(count), 'enable', 'on');
        end
        loadData();
        drawnow;
        blnIsRunning = false;
    end

    function appendInfoPanel(strpic_message)
        if ~isempty(InfoBrowser)
            currentpic_message = char(InfoBrowser.getHtmlText());
            idx = strfind(currentpic_message, '</html>');
            if ~isempty(currentpic_message)
                currentpic_message = currentpic_message(1 : idx -1);
                currentpic_message = strrep(currentpic_message, '<script type="text/javascript">window.scrollTo(0,document.body.scrollHeight);</script>', '');
            else
                currentpic_message = '<html>';
            end
            InfoBrowser.setHtmlText([currentpic_message '<font color="red">' strrep(strpic_message, sprintf('\n\n'), '<br />') '</font><script type="text/javascript">window.scrollTo(0,document.body.scrollHeight);</script></html>']);
        else
            fprintf(2, strpic_message);
        end
        drawnow;
        %         ErrorList = get(handles.InfoPanel, 'String');
        %         ErrorList{length(ErrorList) + 1} = ['<html>Error: ' strrep(strpic_message, sprintf('\n'), ' ') '</html>'];
        %         set(handles.InfoPanel, 'String', ErrorList);
        %         set(handles.InfoPanel, 'Value', length(ErrorList));
        %         set(handles.InfoPanel, 'tooltipString', ['<html>'  strrep(strpic_message, sprintf('\n'), '<br />') '</html>']);
    end

    function PluginList = addPluginsToTree(PluginList, tempChain, level)
        plugins = fieldnames(tempChain);
        for count = 1 : length(plugins)
            plugin = tempChain.(char(plugins(count)));
            strPlugin = [repmat('| ', 1 ,level * 1) char(plugins(count)) ' (' strrep(plugin.plugin, '_Plugin', '') ')'];
            if plugin.getVar('Enabled')
                strPlugin = ['+ ' strPlugin];
            else
                strPlugin = ['- ' strPlugin];
            end
            PluginList{length(PluginList) + 1} = strPlugin;
            if isfield(plugin, 'plugins')
                PluginList = addPluginsToTree(PluginList, plugin.plugins, level + 1);
            end
        end
    end

    function plugin = selectPlugin(listbox, eventData)
        plugin = [];
        pluginlist = [];
        if ishandle(handles.panelSettings)
            delete(get(handles.panelSettings, 'children'));
        end
        if ishandle(listbox)
            selectedPlugin.listIdx = get(listbox, 'value');
            pluginlist = get(listbox, 'String');
        end
        if ~isempty(pluginlist) && selectedPlugin.listIdx > 0
            plugin = char(pluginlist{selectedPlugin.listIdx});
            plugin = strtrim(strrep(plugin(2 : end), '| ', '')); %strtrim(plugin(2 : end));
            plugin = plugin(1 : strfind(plugin, '(') - 2);
            selectedPlugin.name = plugin;
            [plugin parentchain idx] = findPlugin(plugin, chain, 0, 0);
            if ~isempty(plugin)
                selectedPlugin.plugin = plugin;
                selectedPlugin.chainIdx = idx;
                selectedPlugin.chainString = parentchain;
                showSettings()
                if blnIsRunning == false && ishandle(handles.toolbarItem(5))
                    if isfield(selectedPlugin.plugin, 'plugins')
                        set(handles.toolbarItem(5), 'Enable', 'on');
                        set(handles.uimenuItem(6), 'Enable', 'on');
                    else
                        set(handles.toolbarItem(5), 'Enable', 'off');
                        set(handles.uimenuItem(6), 'Enable', 'off');
                    end
                end
                if ~isempty(selectedPlugin.chainString)
                    tempchain = getfield(chain, selectedPlugin.chainString{:});
                else
                    tempchain = chain;
                end
                if blnIsRunning == false && ishandle(handles.toolbarItem(7))
                    if selectedPlugin.chainIdx > 1
                        set(handles.toolbarItem(7), 'Enable', 'on');
                        set(handles.uimenuItem(8), 'Enable', 'on');
                    else
                        set(handles.toolbarItem(7), 'Enable', 'off');
                        set(handles.uimenuItem(8), 'Enable', 'off');
                    end
                end
                if blnIsRunning == false && ishandle(handles.toolbarItem(8))
                    if length(fieldnames(tempchain)) > selectedPlugin.chainIdx
                        set(handles.toolbarItem(8), 'Enable', 'on');
                        set(handles.uimenuItem(9), 'Enable', 'on');
                    else
                        set(handles.toolbarItem(8), 'Enable', 'off');
                        set(handles.uimenuItem(9), 'Enable', 'off');
                    end
                end
                if blnIsRunning == false && ishandle(handles.toolbarItem(6))
                    if strcmp(selectedPlugin.name, 'init')
                        set(handles.toolbarItem(6), 'Enable', 'off');
                        set(handles.uimenuItem(7), 'Enable', 'off');
                    else
                        set(handles.toolbarItem(6), 'Enable', 'on');
                        set(handles.uimenuItem(7), 'Enable', 'on');
                    end
                end
                if strcmp(get(handles.figure, 'SelectionType'), 'open')
                    field = [];
                    if strcmp(get(handles.figure,'currentModifier'), 'shift')
                        field = 'Debug';
                    elseif strcmp(get(handles.figure,'currentModifier'), 'control')
                        field = 'Enabled';
                    end
                    if ~isempty(field)
                        obj = findobj('Style', 'checkbox', '-and', 'Tag', field);
                        if plugin.getVar(field)
                            set(obj, 'Value', 0);
                        else
                            set(obj, 'Value', 1);
                        end
                        setValue(obj)
                    end
                end
            end
        end
    end

    function showSettings()
        vars = selectedPlugin.plugin.varnames();
        for count = 1 : length(vars)
            [value type myMin myMax options] = selectedPlugin.plugin.getVar(char(vars(count)));
            pos = [0 .99-(count)*0.05 .48 0.05];
            temp = selectedPlugin.plugin.getType(char(vars(count)));
            if strcmp(temp, 'numeric') || strcmp(temp, 'integer')
                temp = [' (' temp ')'];
            else
                temp = [];
            end
            uicontrol('Parent', handles.panelSettings, 'tag', char(vars(count)), 'Style', 'text', 'String', [char(vars(count)) temp], 'Units', 'normalized', 'Position', pos, 'HorizontalAlignment', 'left');
            pos([1 3]) = [.5 .48];
            if strcmp(type, 'bool')
                h = uicontrol('Parent', handles.panelSettings, 'tag', char(vars(count)), 'Style', 'checkbox', 'value', value, 'Units', 'normalized', 'Position', pos, 'HorizontalAlignment', 'left', 'Callback', @setValue);
                if strcmp(selectedPlugin.name, 'init') && (strcmp(char(vars(count)), 'Enabled') || strcmp(char(vars(count)), 'Debug'))
                    set(h, 'enable', 'off');
                end
            elseif strcmp(type, 'list')
                val = find(strcmp(options, value) == 1);
                val = min(length(options), val);
                uicontrol('Parent', handles.panelSettings, 'tag', char(vars(count)), 'Style', 'popupmenu', 'String', options, 'value', val, 'Units', 'normalized', 'Position', pos, 'HorizontalAlignment', 'left', 'Callback', @setValue, 'BackgroundColor', [1 1 1]);
            elseif strcmp(type, 'colVec') || strcmp(type, 'rowVec') || strcmp(type, 'matrix')
                uicontrol('Parent', handles.panelSettings, 'tag', char(vars(count)), 'Style', 'edit', 'String', mat2str(value), 'Units', 'normalized', 'Position', pos, 'HorizontalAlignment', 'left', 'Callback', @setValue, 'BackgroundColor', [1 1 1]);
            elseif strcmp(type, 'numeric') || strcmp(type, 'integer')
                pos([1 3]) = [.50 .42];
                h = uicontrol('Parent', handles.panelSettings, 'tag', char(vars(count)), 'Style', 'edit', 'String', value, 'Units', 'normalized', 'Position', pos, 'HorizontalAlignment', 'left', 'Callback', @setValue, 'BackgroundColor', [1 1 1]);
                myMin = max(myMin, value - 50);
                myMax = min(myMax, value + 50);
                pos([1 3]) = [.92 .07/2];
                img = mat{12};
                h1 = uicontrol('Parent', handles.panelSettings, 'tag', [char(vars(count)) '-'], 'Style', 'pushbutton', 'Units', 'normalized', 'Position', pos, 'Callback', @setSliderValue, 'UserData', h, 'CData', img, 'ButtonDownFcn', @setSliderValue, 'Enable', 'inactive');
                pos([1 3]) = [.92+pos(3) .07/2];
                h1 = uicontrol('Parent', handles.panelSettings, 'tag', [char(vars(count)) '+'], 'Style', 'pushbutton', 'Units', 'normalized', 'Position', pos, 'Callback', @setSliderValue, 'UserData', h, 'CData', img(end : -1 : 1, end : -1 : 1, :), 'SelectionHighlight', 'off', 'ButtonDownFcn', @setSliderValue, 'Enable', 'inactive');
            else
                uicontrol('Parent', handles.panelSettings, 'tag', char(vars(count)), 'Style', 'edit', 'String', value, 'Units', 'normalized', 'Position', pos, 'HorizontalAlignment', 'left', 'Callback', @setValue, 'BackgroundColor', [1 1 1]);
            end
        end
    end

    function setSliderValue(hObject, ~)
        img = get(hObject, 'CData');
        img2 = img;
        img2(img2 == 0) = .7;
        set(hObject, 'CData', img2);
        drawnow;
        blnMouseDown = true;
        var = get(hObject,'Tag');
        factor = 1;
        if strcmp(var(end), '-')
            factor = -1;
        end
        step = 1;
        var = var(1 : end - 1);
        [value , type, myMin, myMax, ~] = selectedPlugin.plugin.getVar(var);
        if strcmp(type, 'numeric')
            if ~(isinf(myMin) || isinf(myMax))
                step = (myMax - myMin) / 100;
            end            
        end
        counter = 1;
        while blnMouseDown
            value = value + factor  * step;
            set(get(hObject, 'UserData'), 'String', value);
            setValue(get(hObject, 'UserData'), []);
            pause(.1);
            if mod(counter, 20) == 0 && step <= 10000;
                step = step * 10;
            end
            counter = counter + 1;
        end
        set(hObject, 'CData', img);
        drawnow;
    end

    function setValue(hObject, ~)
        var = get(hObject, 'Tag');
        field = 'Value';
        if strcmp(get(hObject, 'Style'), 'edit')
            field = 'String';
        end
        value = get(hObject, field);
        oldVal = selectedPlugin.plugin.getVar(var);
        selectedPlugin.plugin.setVar(var, value);
        if selectedPlugin.plugin.hasChanges() || ~strcmp(mat2str(oldVal), mat2str(value))
            hasChanges = true;
        end
        value = selectedPlugin.plugin.getVar(var);
        if strcmp(get(hObject, 'Style'), 'popupmenu')
            options = selectedPlugin.plugin.getOptions(var);
            set(hObject, field, find(strcmp(options, value) == 1));
        else
            if isnumeric(value) && max(size(value)) > 1
                set(hObject, field, mat2str(value));
            else
                set(hObject, field, value);
            end
        end
        if strcmp(var, 'Enabled')
            pluginlist = get(handles.listbox, 'String');
            plugin = char(pluginlist{selectedPlugin.listIdx});
            if selectedPlugin.plugin.getVar('Enabled')
                pluginlist{selectedPlugin.listIdx} = ['+ ' plugin(3 : end)];
                selectedPlugin.plugin.UpdateVarsAfterInit();
            else
                pluginlist{selectedPlugin.listIdx} = ['- ' plugin(3 : end)];
            end
            set(handles.listbox, 'String', pluginlist);
        end
    end

    function [searchresult parentchain idx listIdx] = findPlugin(name, tempChain, level, listIdx)
        searchresult = [];
        parentchain = {};
        idx = [];
        plugins = fieldnames(tempChain);
        for count = 1 : length(plugins)
            if isempty(searchresult)
                listIdx = listIdx + 1;
                plugin = tempChain.(char(plugins(count)));
                if strcmp(char(plugins(count)), name)
                    searchresult = plugin;
                    idx = count;
                    parentchain(level * 2 + 1 : end) = [];
                elseif isfield(plugin, 'plugins')
                    [searchresult parentchain idx listIdx] = findPlugin(name, plugin.plugins, level + 1, listIdx);
                    parentchain{level * 2 + 1} = char(plugins(count));
                    parentchain{level * 2 + 2} = 'plugins';
                end
            end
        end
    end

    function ResetParameters(~,~)
        newPlug = [];
        chainStringTemp = selectedPlugin.chainString;
        chainStringTemp{length(chainStringTemp) + 1} = selectedPlugin.name;
        try
            newPlug = getfield(loadSettings(FileName), chainStringTemp{:});
        catch exp
        end
        if isempty(newPlug)
            newPlug = eval([selectedPlugin.plugin.plugin '(''' selectedPlugin.name ''')']);
            if isfield(selectedPlugin.plugin, 'plugins')
                newPlug.plugins = selectedPlugin.plugin.plugins;
            end
            appendInfoPanel(['<font color="black">Reset Parameters of Plugin ''' selectedPlugin.name ''' to default values!</font><br>']);
        else
            appendInfoPanel(['<font color="black">Reset Parameters of Plugin ''' selectedPlugin.name '''</font><br>']);
        end
        chain = setfield(chain, chainStringTemp{:}, newPlug);
        loadData();
    end

    function WindowButtonUpFcn(~,~)
        blnMouseDown = false;
        drawnow;
    end

    function CloseReq(~,~)
        try
            run(handles.toolbarItem(10), []);
            showDebug([], true);
        catch exp
        end
        if checkHasChanges()
            delete(gcf);
        end
    end

    function VersionInfo(~,~)
        VersionInfo = {'ProcessChain' ...
            ['Version ' num2str(initRuntime())] ...
            '' ...
            'Copyright (c) <2014> Sven Franz sven.franz@jade-hs.de' ...
            'Institut für Technische Assistenzsysteme' ...
            'Institute for Hearing Technology and Audiology' ...
            'Jade University of Applied Sciences' ...
            '' ...
            'Licence' ...
            'Permission is hereby granted, free of charge, to any person obtaining  a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:' ...
            'The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.' ...
            '' ...
            'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.' ...
            };
        msgbox(VersionInfo, 'About...', 'help', 'modal');
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