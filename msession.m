function varargout = msession(command, filename, what)
% MSESSION('load', filename)
% MSESSION('load', filename, what)
% MSESSION('save', ...)
% X = MSESSION('dump', ...)
%
% Store and restore open editor files and workspace variables.
% All variables from "base" workspace are (re)stored, also globals,
% as well as all open editor files.
%
% MSESSION('load', filename) 
%   restores all content from file
% MSESSION('load', filename, what) 
%   restores selected contents from file
%   what:  'files' --> reopen the editor files
%          'vars'  --> load the variables (may overwrite existing ones!)
%          'all'   --> restore everything
% MSESSION('save', filename)
%   stores all content into file
% MSESSION('save', filename, what)
%   stores selected contents into file; see above for description of 'what'
% X = MSESSION('dump',...) 
%   dumps the contents to structure X instead writing to file
%
% Andreas Sommer, Mar2023
% code@andreas-sommer.eu


% little error check
if ~(ischar(command) || isstring(command))
   error('First argument (command) must be a character array or a string.')
end

% default: everything
if ~exist('what', 'var'), what = 'everything'; end

% what to do
switch lower(command)

   case {'load'}
      restoreMSessionFromFile(filename, what);

   case {'save'}
      saveMSessionToFile(filename, what)

   case {'dump'}
      MSESSION = saveMSessionToVar(what);
      varargout{1} = MSESSION;

   otherwise
      error('Unknown command: %s', command);

end % of switch


% finito
return

end




%% HELPERS

function saveMSessionToFile(filespec, what)
   MSESSION = saveMSessionToVar(what);
   filespec = ensureExtension(filespec);
   save(filespec, 'MSESSION', '-mat')
end


function MSESSION = loadMSessionFromFile(filespec)
   filespec = ensureExtension(filespec);
   C = load(filespec, '-mat');
   if ~isfield(C, 'MSESSION')
      error('File %s does not look like an MSESSION file.', filespec)
   end
   MSESSION = C.MSESSION;
end


function restoreMSessionFromFile(filespec, what)
   MSESSION = loadMSessionFromFile(filespec);
   restoreMSession(MSESSION, what)
end


function filespec = ensureExtension(filespec)
% ensures that filespec has appropriate extension
   extension = '.msession';
   if ~endsWith(filespec, extension)
      filespec = strcat(filespec, extension);
   end
end


function restoreMSession(MSESSION, what)
% restores specified things from MSESSION structure
   switch lower(what)
      case 'everything'
         restoreVariables(MSESSION);
         restoreEditorFiles(MSESSION)
      case 'variables'
         restoreVariables(MSESSION);
      case 'files'
         restoreEditorFiles(MSESSION)
      otherwise
         error('Unknown selection: %s', what);
   end
end

function MSESSION = saveMSessionToVar(what)
% saves specified things to MSESSION structure
   switch lower(what)
      case 'everything'
         MSESSION.variables = getAllVariables();
         MSESSION.editorfiles = getOpenEditorFiles();
      case 'variables'
         MSESSION.variables = getAllVariables();
      case 'files'
         MSESSION.editorfiles = getOpenEditorFiles();
      otherwise 
         error('Unknown selection: %s', what)
   end
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
   editorfiles = MSESSION.editorfiles;
   for k = 1:length(editorfiles)
      document = openEditorFile(editorfiles(k).Filename);
      document.Selection = editorfiles(k).Selection;
   end
end




function editorfiles = getOpenEditorFiles()
   % list of all files (also unsaved!)
   docs = matlab.desktop.editor.getAll;  % document array
   % walk through files, save modified, and save unsaved to temporary
   for k = 1:length(docs)
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
end



function restoreVariables(MSESSION)
   % restore non-global base-only variables
   for k = 1:length(MSESSION.variables.names.baseonly)
      v = MSESSION.variables.names.baseonly{k};
      restoreVariable(v, MSESSION.variables.content.baseonly.(v), 'baseonly');
   end
   % restore global vars that are accessible from base
   for k = 1:length(MSESSION.variables.names.baseglobal)
      v = MSESSION.variables.names.baseglobal{k};
      restoreVariable(v, MSESSION.variables.content.baseglobal.(v), 'baseglobal');
   end
   % restore global vars that are inaccessible from base
   for k = 1:length(MSESSION.variables.names.globalonly)
      v = MSESSION.variables.names.globalonly{k};
      restoreVariable(v, MSESSION.variables.content.globalonly.(v), 'globalonly');
   end

end



function restoreVariable(varname, content, target)
 %  try
      switch target
         case 'baseonly'  , restoreVar_baseonly(varname, content);
         case 'baseglobal', restoreVar_baseglobal(varname, content);
         case 'globalonly', restoreVar_globalonly(varname, content);
         otherwise
            error('Unknown target')  % should never be reached
      end
 %  catch ME
 %     fprintf('An error occured while restoring variable %s\n--ERROR: %s\n', varname, ME.message);
 %  end
end



function varcontent = getVarFromBase(varname)
   varcontent = evalin('base', varname);
end

% prefix MSESSION__ avoids clashing with variable names in global context
function MSESSION__MSESSION = getVarFromGlobal(MSESSION__varname)
   MSESSION__cmd = sprintf('global %s', MSESSION__varname);  % make accessible
   eval(MSESSION__cmd);
   MSESSION__MSESSION   = eval(MSESSION__varname);                  % retrieve content
   MSESSION__cmd = sprintf('clear %s', MSESSION__varname);   % make unaccessible again
   eval(MSESSION__cmd);
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



function variables = getAllVariables()
   variables.names = getAllVariableNames();                           % get names of variables
   variables.content.baseonly   = retrieveVariables(variables.names.baseonly);   % get the directly accessible variables
   variables.content.baseglobal = retrieveVariables(variables.names.baseglobal); % get the globals that are accessible from base
   variables.content.globalonly = retrieveVariables(variables.names.globalonly); % get the globals that are inaccessible from base
end


function varnames = getAllVariableNames()
   varnames.base       = evalin('base', 'who()');
   varnames.global     = evalin('base', "who('global')");
   varnames.baseonly   = setdiff(varnames.base, varnames.global);
   varnames.globalonly = setdiff(varnames.global, varnames.base);
   varnames.baseglobal = intersect(varnames.base, varnames.global);
end


function x = ensureCell(x)
   if ~iscell(x), x = {x}; end
end


function content = retrieveVariables(varnames)
% returns the requested variables als field of content structure
  varnames = ensureCell(varnames);
  if isempty(varnames), content = []; return;  end
  for k = 1:length(varnames)
     v = varnames{k};
     [content.(v), errorflag] = retrieveVariable(v);
     if errorflag
        fprintf('Error retrieving %s\n', v);
     end
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



