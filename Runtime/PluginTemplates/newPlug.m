function this = newPlug(strName)
global AlgoCom; this = struct; vars = struct;
this.plugins = struct; % uncomment only when subplugins are needed

%% add plugin-properties here
% setVar('text', 'this is a string', 'string');
% setVar('c', 1, 'bool');
% setVar('a', .1, 'numeric');
% setVar('b', 5, 'integer');
% setVar('d', [1 2 3; 4 5 6], 'matrix');
% setVar('e', 'a', {'a' 'b' 'c'});
% setVar('a', .1, 'numeric', 0, 1);
% setVar('b', 5, 'integer', 0, 100);
% setVar('d', [1 2 3; 4 5 6], 'matrix', -inf, inf);
% setVar('e', 'a', {'a' 'b' 'c'});

%% add local plugin-variables here
% data = [];

%% public and nessesarry functions

    function [BlockSettings] = init(BlockSettings)
        BlockSettingsIn = BlockSettings;
        [BlockSettings] = process_subplugs(this.plugins, BlockSettings);
        BlockSettingsOut = BlockSettings;
    end

    function preprocess()
        process_subplugs(this.plugins);
    end

    function [out] = process(in)
        out = in;
        [out] = process_subplugs(this.plugins, out);
    end

    function postprocess()
        process_subplugs(this.plugins);
    end

    function VarUpdated(Varname)
    end

%% GLOBAL START %%
%% DO NOT CHANGE %%
this.plugin = mfilename();
% this.plugins = struct;
this.init = @init;
this.UpdateVarsAfterInit = @UpdateVarsAfterInit;
this.hasChanges = @hasChanges;
this.preprocess = @preprocess;
this.process = @process;
this.postprocess = @postprocess;
this.setVar = @setVar;
this.getVar = @getVar;
this.getType = @getType;
this.showVar = @showVar;
this.getMin = @getMin;
this.getMax = @getMax;
this.getOptions = @getOptions;
this.varnames = @varnames;
this.setPlugins = @setPlugins;
setVar('Enabled', 1, 'bool');
setVar('Debug', 1, 'bool');
BlockSettingsIn = struct;
BlockSettingsOut = struct;
blnHasChanges = false;

    function val = setVar(varName, varValue, varType, minVar, maxVar)
        temp = [];
        if nargin > 3
            temp = varType;
        end
        if isfield(vars, varName) && isfield(vars.(varName), 'type')
            temp = vars.(varName).type;
        end
        if ~isempty(temp) && (strcmp(temp, 'numeric') || strcmp(temp, 'integer') || strcmp(temp, 'bool')) && ischar(varValue)
            if isempty(varValue)
                varValue = vars.(varName).value;
            else
                varValue = str2num(varValue);
            end
        end
        oldVal = [];
        if isfield(vars, varName)
            oldVal = vars.(varName).value;
        end
        vars.(varName).value = varValue;
        if nargin >= 4
            vars.(varName).min = minVar;
        elseif ~isfield(vars.(varName), 'min')
            vars.(varName).min = -inf;
        end
        if nargin >= 5
            vars.(varName).max = maxVar;
        elseif ~isfield(vars.(varName), 'max')
            vars.(varName).max = inf;
        end
        if nargin >= 3
            if iscell(varType)
                vars.(varName).type = 'list';
                vars.(varName).options = {};
                if min(size(varType)) == 1
                    vars.(varName).options = varType;
                end
            elseif sum(strcmp(varType, {'string', 'bool', 'numeric', 'integer', 'matrix'})) == 0
                error(['Type ''' varType ''' unknown! {string, bool, numeric, integer, matrix}']);
            else
                vars.(varName).type = varType;
            end
        elseif ~isfield(vars.(varName), 'type')
            if isnumeric(varValue) && size(varValue, 1) == 1 && size(varValue, 2) > 1
                vars.(varName).type = 'colVec';
            elseif isnumeric(varValue) && size(varValue, 2) == 1 && size(varValue, 1) > 1
                vars.(varName).type = 'rowVec';
            elseif isnumeric(varValue) && size(varValue, 2) > 1 && size(varValue, 1) > 1
                vars.(varName).type = 'matrix';
            elseif isinteger(varValue)
                vars.(varName).type = 'integer';
            elseif isnumeric(varValue)
                vars.(varName).type = 'numeric';
            elseif ischar(varValue)
                vars.(varName).type = 'string';
            end
        end
        if isfield(vars.(varName), 'type') && strcmp(vars.(varName).type, 'list')
            vars.(varName).value = [];
            if isnumeric(varValue)
                if varValue >= 1 && varValue <= length(vars.(varName).options)
                    vars.(varName).value = char(vars.(varName).options(varValue));
                end
            elseif sum(strcmp(vars.(varName).options, varValue)) == 1
                vars.(varName).value = varValue;
            end
        elseif ~isfield(vars.(varName), 'type') || ~strcmp(vars.(varName).type, 'string')
            if isfield(vars.(varName), 'type') && strcmp(vars.(varName).type, 'bool')
                vars.(varName).value = min(1, max(0, round(vars.(varName).value)));
            elseif isfield(vars.(varName), 'type') && strcmp(vars.(varName).type, 'integer')
                vars.(varName).value = round(vars.(varName).value);
            elseif ischar(vars.(varName).value) && isfield(vars.(varName), 'type') && (strcmp(vars.(varName).type, 'matrix') || strcmp(vars.(varName).type, 'colVec') || strcmp(vars.(varName).type, 'rowVec'))
                vars.(varName).value = eval(vars.(varName).value);
            end
            vars.(varName).value(vars.(varName).value < vars.(varName).min) = vars.(varName).min;
            vars.(varName).value(vars.(varName).value > vars.(varName).max) = vars.(varName).max;
        end
        val = vars.(varName).value;
        if ~isempty(which('VarUpdated')) && exist('BlockSettingsIn', 'var') && ~isempty(fieldnames(BlockSettingsIn))
            if ~strcmp(mat2str(oldVal), mat2str(val))
                blnHasChanges = true;
                if ~(strcmp(varName, 'Enabled') || strcmp(varName, 'Debug'))
                    VarUpdated(varName);
                end
            end
        end
    end

    function bln = hasChanges()
        bln = blnHasChanges;
    end

    function UpdateVarsAfterInit()
        if ~isempty(which('VarUpdated'))
            varnames = sort(fieldnames(vars));
            for count = 1 : length(varnames)
                varName = char(varnames(count));
                if ~(strcmp(varName, 'Enabled') || strcmp(varName, 'Debug'))
                    VarUpdated(varName);
                end
            end
        end
    end

    function val = setvar(varName, varValue, varType, minVar, maxVar)
        val = setVar(varName, varValue, varType, minVar, maxVar);
    end

    function [val type min max options] = getVar(varName)
        val = vars.(varName).value;
        type = getType(varName);
        min = getMin(varName);
        max = getMax(varName);
        options = getOptions(varName);
        if strcmp(type, 'list')
            if isempty(options)
                options{1} = 'none';
            end
            if isempty(val) || sum(strcmp(options, val)) == 0
                val = char(options{1});
            end
        end
    end

    function [val type min max options] = getvar(varName)
        [val type min max options] = getVar(varName);
    end

    function val = getType(varName)
        val = vars.(varName).type;
    end

    function val = getMin(varName)
        val = vars.(varName).min;
    end

    function val = getMax(varName)
        val = vars.(varName).max;
    end

    function val = getOptions(varName)
        val = [];
        if isfield(vars.(varName), 'options')
            val = vars.(varName).options;
        end
    end

    function val = varnames()
        val = sort(fieldnames(vars));
    end

    function showVar(varName)
        if nargin < 1
            varName = [];
        end
        varnames = sort(fieldnames(vars));
        for count = 1 : length(varnames)
            currVar = char(varnames(count));
            if isempty(varName) || strcmp(currVar, varName)
                if strcmp(vars.(currVar).type, 'list')
                    myString = [currVar ' (list, ['];
                    options = '';
                    for kk = 1 : length(vars.(currVar).options)
                        options = [options char(vars.(currVar).options(kk)) ', '];
                    end
                    if length(options) > 2
                        options = options(1 : end - 2);
                    end
                    myString = [myString options ']):\t' vars.(currVar).value];
                    disp(sprintf(myString));
                elseif strcmp(vars.(currVar).type, 'bool')
                    if vars.(currVar).value == 1
                        disp(sprintf('%s (%s):\tTrue', currVar, vars.(currVar).type));
                    else
                        disp(sprintf('%s (%s):\tFalse', currVar, vars.(currVar).type));
                    end
                elseif strcmp(vars.(currVar).type, 'string')
                    disp(sprintf('%s (%s):\t%s', currVar, vars.(currVar).type, vars.(currVar).value));
                elseif strcmp(vars.(currVar).type, 'colVec') || strcmp(vars.(currVar).type, 'rowVec') || strcmp(vars.(currVar).type, 'matrix')
                    disp(sprintf('%s (%s, [%d, %d]):', currVar, vars.(currVar).type, vars.(currVar).min, vars.(currVar).max));
                    disp(vars.(currVar).value);
                elseif strcmp(vars.(currVar).type, 'integer')
                    disp(sprintf('%s (%s, [%d, %d]):\t%d', currVar, vars.(currVar).type, vars.(currVar).min, vars.(currVar).max, vars.(currVar).value));
                elseif strcmp(vars.(currVar).type, 'numeric')
                    disp(sprintf('%s (%s, [%f, %f]):\t%f', currVar, vars.(currVar).type, vars.(currVar).min, vars.(currVar).max, vars.(currVar).value));
                end
            end
        end
    end

    function setPlugins(subPlugins)
        if isfield(this, 'plugins')
            this.plugins = subPlugins;
        else
            error(sprintf('Plugin: %s\n\t%s', this.plugin, 'No subplugs allowed!!!'));
        end
    end
%% GLOBAL END %%
end