function [value, found] = getWorkspaceVariable( varname, notfoundvalue, workspace )
% [value, found] = getWorkspaceVariable(varname, notfoundvalue, workspace)
%
% Retrieves variable from a different workspace. 
% May signal an error or return a specified value if variable does not exist.
%
% INPUT:    varname --> variable name to be retrieved
%     notfoundvalue --> value to be returned if variable is not found              (optional, default: []     )
%                       if set to '@ERROR', an error is raised
%         workspace --> workspace to look for the variable in, 'base' or 'caller'  (optional, default: 'base' )
% 
% OUTPUT: value --> content of specified variable or notfoundvalue, if variable was not found
%         found --> boolean flag indicating if variable was found in specified workspace
%
% Andreas Sommer, Aug2024
% code@andreas-sommer.eu
%

% process input args
if (nargin < 2), notfoundvalue = []; end
if (nargin < 3),     workspace = []; end

% process workspace argument
if isempty(workspace), workspace = 'base'; end
if ~( strcmpi(workspace, 'base') || strcmpi(workspace, 'caller') )
   error('Invalid workspace: %s', workspace);
end

% check if variable exists
command = sprintf('exist(''%s'',''var'')', varname);
found = evalin(workspace, command);

% if found, retrieve its value (i.e. evaluate its name in main workspace)
if found
   value = evalin(workspace, varname);
else  % if not found, return default value
   if strcmp(notfoundvalue, '@ERROR')
      error('Variable "%s" does not exist in %s workspace.', varname, workspace);
   end
   value = notfoundvalue;
end


end % of function


%% HELPERS