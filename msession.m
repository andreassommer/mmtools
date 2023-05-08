function varargout = msession(command, filename, selection, silent)
% MSESSION('load', filename)
% MSESSION('load', filename, selection)
% MSESSION('load', filename, selection, silent)
% MSESSION('save', ...)
% X = MSESSION('dump', ...)
%
% Store and restore open editor files and workspace variables.
% All variables from "base" workspace are (re)stored, also globals,
% as well as all open editor files.
%
% MSESSION('load', filename) 
%   restores all content from specified file. 
%   If filename does not exist, the default file 'msession' is used.
% MSESSION('load', filename, selection) 
%   restores selected contents from file
%   selection:  'files' --> reopen the editor files
%                'vars' --> load the variables (may overwrite existing ones!)
%                'path' --> restore matlab search path
%             'session' --> combination of 'files' and 'vars'
%          'everything' --> restore everything
%                 'all' --> same as 'everything'
% MSESSION('save', filename)
%   stores all content into file
% MSESSION('save', filename, selection)
%   stores selected contents into file; see above for description of 'selection'
% MSESSION('save', filename, selection, silent)
%   silent --> true|false : set to true to disable text output [default: false]
% X = MSESSION('dump',...) 
%   dumps the contents to structure X instead writing to file
%
% Andreas Sommer, Mar2023
% code@andreas-sommer.eu


% little error check
if ~(ischar(command) || isstring(command))
   error('First argument (command) must be a character array or a string.')
end

% defaults
if (nargin < 2),  filename = 'msession';  end
if (nargin < 3), selection = 'session';   end
if (nargin < 4),    silent = false;       end

% choose what to do
switch lower(command)

   case {'load'}
      restore_MSESSION_from_file(filename, selection);

   case {'save'}
      save_MSESSION_to_file(filename, selection)

   case {'dump'}
      varargout{1} = save_MSESSION_to_var(selection);
     
   otherwise
      error('Unknown command: %s', command);

end % of switch


% finito
return

function showMessage(varargin)
   if ~silent
      fprintf(varargin{:});
   end
end

function showError(ME, varargin)
   errmsg = sprintf(varargin{:});
   fprintf('\n### %s', errmsg);
   if ~isempty(ME)
      fprintf('--- ERROR: %s\n', ME.identifier)
   end
   fprintf('\n')
end




%% HELPERS

function save_MSESSION_to_file(filespec, selection)
   filespec = ensureExtension(filespec);
   showMessage('*** Saving MSESSION to file %s\n', filespec)
   MSESSION = save_MSESSION_to_var(selection);
   save(filespec, 'MSESSION', '-mat')
end


function MSESSION = load_MSESSION_from_file(filespec)
   filespec = ensureExtension(filespec);
   showMessage('*** Loading MSESSION from file: %s\n', filespec)
   try
      C = load(filespec, '-mat');
      if ~isfield(C, 'MSESSION')
         error('MSESSION:InvalidFileFormat', 'File %s does not look like an MSESSION file.', filespec)
      end
      MSESSION = C.MSESSION;
   catch ME
      showError(ME, 'Error loading MSESSION file.')
      MSESSION = [];
   end
end


function restore_MSESSION_from_file(filespec, selection)
   MSESSION = load_MSESSION_from_file(filespec);
   restore_MSESSION(MSESSION, selection)
end


function filespec = ensureExtension(filespec)
% ensures that filespec has appropriate extension
   extension = '.msession';
   if ~endsWith(filespec, extension)
      filespec = strcat(filespec, extension);
   end
end


function restore_MSESSION(MSESSION, selection)
% restores specified things from MSESSION structure
   showMessage('*** MSESSION restore started.\n')
   switch lower(selection)
      case {'everything', 'all'}
         restorePath(MSESSION)
         restoreEditorFiles(MSESSION)
         restoreVariables(MSESSION);
      case 'session'
         restoreEditorFiles(MSESSION)
         restoreVariables(MSESSION);
      case 'variables'
         restoreVariables(MSESSION);
      case 'files'
         restoreEditorFiles(MSESSION)
      case {'path','paths'}
         restorePath(MSESSION)
      otherwise
         error('MSESSION:unknownSelection', 'Unknown selection: %s', selection);
   end
   showMessage('*** MSESSION restore finished.\n')
end

function MSESSION = save_MSESSION_to_var(selection)
% saves specified things to MSESSION structure
   showMessage('*** MSESSION store started.\n')
   switch lower(selection)
      case {'everything', 'all'}
         MSESSION.path        = retrievePath();
         MSESSION.editorfiles = retrieveOpenEditorFiles();
         MSESSION.variables   = retrieveAllVariables();
      case 'session'
         MSESSION.editorfiles = retrieveOpenEditorFiles();
         MSESSION.variables   = retrieveAllVariables();
      case 'variables'
         MSESSION.variables   = retrieveAllVariables();
      case 'files'
         MSESSION.editorfiles = retrieveOpenEditorFiles();
      case 'path'
         MSESSION.path        = retrievePath();
      otherwise 
         error('Unknown selection: %s', selection)
   end
   showMessage('*** MSESSION store finished.\n')
end





function restorePath(MSESSION)
   if isfield(MSESSION, 'path')
      showMessage('Restoring path.')
      path(MSESSION.path);
      showMessage(' Done.\n')
   else
      showMessage('No path data found. Skipping.\n')
   end
end

function pathstr = retrievePath()
   showMessage('Retrieving path.');
   pathstr = path();
   showMessage(' Done.\n');
end


function document = openEditorFile(filespec)
   if exist(filespec, 'file')
      document = matlab.desktop.editor.openDocument(filespec);
   else
      msg = sprintf('MISSING FILE: %s', filespec);
      document = matlab.desktop.editor.newDocument(msg);
   end
end

function restoreEditorFiles(MSESSION)
   if isfield(MSESSION, 'editorfiles')
      showMessage('Restoring open editor files.')
      editorfiles = MSESSION.editorfiles;
      for k = 1:length(editorfiles)
         document = openEditorFile(editorfiles(k).Filename);
         document.Selection = editorfiles(k).Selection;
         showMessage('.')
      end
      showMessage(' Done.\n')
   else
      showMessage('No editor files data found. Skipping.\n')
   end
end




function editorfiles = retrieveOpenEditorFiles()
   showMessage('Retrieving open editor files.')
   % list of all files (also unsaved!)
   docs = matlab.desktop.editor.getAll;  % document array
   % walk through files, save modified, and save unsaved to temporary
   for k = 1:length(docs)
      showMessage('.')
      try
         % check if stored to file, if not, store to temporary
         if exist(docs(k).Filename, 'file')
            docs(k).save()
         else
            tmpfilename = fullfile(tempdir(), docs(k).Filename);
            docs(k).saveAs(tmpfilename);
         end
      catch
         error('Error while handling editor file %s. Skipping.', docs(k).Filename)
      end
   end
   % build result: store file names and selections
   editorfiles = cell2struct({docs.Filename ; docs.Selection}, ...
                             {   'Filename' , 'Selection'   });
   showMessage(' Done.\n')
end



function restoreVariables(MSESSION)
   if isfield(MSESSION, 'variables')
      showMessage('Restoring variables.')
      % restore non-global base-only variables
      showMessage(' base.')
      for k = 1:length(MSESSION.variables.names.baseonly)
         showMessage('.')
         v = MSESSION.variables.names.baseonly{k};
         restoreVariable(v, MSESSION.variables.content.baseonly.(v), 'baseonly');
      end
      % restore global vars that are accessible from base
      showMessage(' globals.')
      for k = 1:length(MSESSION.variables.names.baseglobal)
         showMessage('.')
         v = MSESSION.variables.names.baseglobal{k};
         restoreVariable(v, MSESSION.variables.content.baseglobal.(v), 'baseglobal');
      end
      % restore global vars that are inaccessible from base
      for k = 1:length(MSESSION.variables.names.globalonly)
         showMessage('.')
         v = MSESSION.variables.names.globalonly{k};
         restoreVariable(v, MSESSION.variables.content.globalonly.(v), 'globalonly');
      end
      showMessage(' Done.\n')
   else
      showMessage('No variables found. Skipping.\n')
   end
end



function restoreVariable(varname, content, target)
   try
      switch target
         case 'baseonly'  , restoreVar_baseonly(varname, content);
         case 'baseglobal', restoreVar_baseglobal(varname, content);
         case 'globalonly', restoreVar_globalonly(varname, content);
         otherwise
            error('Unknown target')  % should never be reached
      end
   catch ME
      showError(ME, 'Error while restoring variable %s', varname);
   end
end



function varcontent = getVarFromBase(varname)
   varcontent = evalin('base', varname);
end


function restoreVar_baseonly(varname, content)
   assignin('base', varname, content);
end

function restoreVar_baseglobal(varname, content)
   cmd = sprintf('global %s', varname);
   evalin('base', cmd);
   assignin('base', varname, content);
end

% prefix MSESSION__ avoids clashing with variable names in global context
function restoreVar_globalonly(MSESSION__varname, MSESSION__content)
   MSESSION__cmd = sprintf('global %s', MSESSION__varname);  % make accessible
   [~] = evalc(MSESSION__cmd);                               % ignore evaluation output
   MSESSION__contentprovider = @() MSESSION__content;        %#ok - it is used in eval
   MSESSION__cmd = sprintf('%s = MSESSION__contentprovider();', MSESSION__varname);
   eval(MSESSION__cmd);                                      % transfer content
   MSESSION__cmd = sprintf('clear %s', MSESSION__varname);   % make unaccessible again
   eval(MSESSION__cmd);
end



function variables = retrieveAllVariables()
   showMessage('Retrieving variables...\n');
   showMessage('---');
   variables.names = getAllVariableNames();   % get names of variables, structured by accesibility
   showMessage('---base only       : ')
   variables.content.baseonly   = retrieveVariables(variables.names.baseonly);   % get the directly accessible variables
   showMessage('---globals(base)   : ')
   variables.content.baseglobal = retrieveVariables(variables.names.baseglobal); % get the globals that are accessible from base
   showMessage('---globals(nonbase): ')
   variables.content.globalonly = retrieveVariables(variables.names.globalonly); % get the globals that are inaccessible from base
   showMessage('Done.\n')
end


function varnames = getAllVariableNames()
   showMessage('Retrieving variable names.');
   varnames.base       = evalin('base', 'who()');
   varnames.global     = evalin('base', "who('global')");
   varnames.baseonly   = setdiff(varnames.base, varnames.global);
   varnames.globalonly = setdiff(varnames.global, varnames.base);
   varnames.baseglobal = intersect(varnames.base, varnames.global);
   showMessage(' Done.\n');
end


function x = ensureCell(x)
   if ~iscell(x), x = {x}; end
end


function content = retrieveVariables(varnames)
% returns the requested variables als field of content structure
   varnames = ensureCell(varnames);
   if isempty(varnames)
      content = []; 
      showMessage('No variables present. Done.\n');
      return;
   else
      showMessage('Retrieving variable contents.');
      for k = 1:length(varnames)
         showMessage('.');
         v = varnames{k};
         [content.(v), errorflag] = retrieveVariable(v);
         if errorflag
            showError([], 'Error retrieving %s', v);
         end
      end
      showMessage(' Done.\n');
   end
end
  

function [content, errorflag] = retrieveVariable(varname)
   % check if variable exists in work space
   errorflag = false;
   if accessibleInBase(varname)
      content = getVarFromBase(varname);
   elseif existsInGlobal(varname)
      content = getVarFromGlobal(varname);
   else
      errorflag = true;
   end
end





function res = accessibleInBase(varname)
   cmd = sprintf("exist('%s', 'var')", varname);
   res = evalin('base', cmd);
end

function res = existsInGlobal(varname)
   globals = evalin('base', "who('global')");
   if ismember(varname, globals)
      res = true;
   else
      res = false;
   end
end



% end of msession function
end




% MUST NOT BE A NESTED FUNCTION !  (cannot add variables to static workspace!)
% prefix MSESSION__ avoids clashing with variable names in global context
function MSESSION__MSESSION = getVarFromGlobal(MSESSION__varname)
   MSESSION__cmd = sprintf('global %s', MSESSION__varname);  % make accessible
   eval(MSESSION__cmd);
   MSESSION__MSESSION   = eval(MSESSION__varname);                  % retrieve content
   MSESSION__cmd = sprintf('clear %s', MSESSION__varname);   % make unaccessible again
   eval(MSESSION__cmd);
end