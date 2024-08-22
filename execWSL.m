function [status, cmdout] = execWSL(wslcommand, comment)
% [status, cmdout] = execWSL(wslcommand)
% [status, cmdout] = execWSL(wslcommand, comment)
% [status, cmdout] = execWSL(icommand, iarg)
%
% Executes a command in WSL. 
% Before execution, the comment and the command is displayed (if not too long).
% Displays output if successful or halts with warning on failure.
%
% NOTE: Escaping of & ; > < | is automatically done!
%
% INPUT:    wslcommand --> command to be executed in WSL
%              comment --> comment to be displayed before executing if verbosity is enabled
%       -OR-
%             icommand --> internal command starting with #
%                 iarg --> argument to internal comand
%
% OUTPUT:   status --> exit code as returned from command
%           cmdout --> output generated to stdout by command
%
% Internal commands:
%      #setdistro     --> set the wsl distro to be used ('' for default)
%                         Example:  execWSL('#setdistro', 'Debian')
%      #getdistro     --> retrieves currently selected distro (empty means default distro)
%                         Example:  currentdistro = execWSL('#getdistro')
%      #verbose       --> enable/disable verbosity mode
%                         Example:  execWSL('#verbose', true);
%      #dryrun        --> enable/disable dryrun mode
%                         If set to true, WSL command will be displayed but not executed.
%                         Always returns with status 0 and empty cmdout.
%                         Example:  execWSL('#dryrun', true);
%      #shutdown      --> Invokes shutdown request for WSL, terminating all distributions and WSL itself
%                         Example:  execWSL('#shutdown')
%      #terminate     --> Invokes terminate request for the specified distribution
%                         Example:  execWSL('#terminate', 'Debian')
%      #haltonerror   --> Invokes the debugger if WSL call fails (default: true)
%      #showinternals --> Lists internal variables and their content
%      #raw           --> Invokes verbatim command in iarg with wsl
%      #silentmode    --> Enable/disable silent mode (screen output)
%                         Example:  execWSL('#silentmode', true);
%
% Andreas Sommer, Jul2024
% code@andreas-sommer.eu
%

persistent WSLdistro verbose haltOnError dryrun silentmode

% init persistent variables
if isempty(verbose)    ,     verbose = true ; end
if isempty(haltOnError), haltOnError = true ; end
if isempty(dryrun)     ,      dryrun = false; end

% ensure comment is accessible
if (nargin<2), comment = ''; end

% process internal commands
% NOTE: the variable "comment" contains the argument
if ( wslcommand(1)=='#' )
   iarg = comment;
   switch lower(wslcommand(2:end))
      case {'setdistro','distro'}
         WSLdistro = iarg;
      case 'getdistro'
         if (nargout==0)
            fprintf('Selected distro: "%s"\n', WSLdistro)
         end
         status = WSLdistro;
      case 'verbose'
         verbose = iarg;
      case 'dryrun'
         dryrun = iarg;
      case {'haldonerror','keyboardonerror'}
         haltOnError = iarg;
      case 'silentmode'
         silentmode = iarg;
      case 'showinternals'
         fprintf('%s persistent variables:\n', mfilename())
         fprintf('- WSLdistro: %s\n', WSLdistro);
         fprintf('- verbose        :   %s\n', tf_to_string(verbose));
         fprintf('- dryrun         :   %s\n', tf_to_string(dryrun));
         fprintf('- keyboardOnError:   %s\n', tf_to_string(haltOnError));
      case 'terminate'
         distro = comment; 
         if isempty(distro), distro = WSLdistro; end
         shutdownCommand = sprintf('--terminate %s', distro);
         [status, cmdout] = raw_WSL_call(shutdownCommand);      
      case 'shutdown'
         shutdownCommand = sprintf('--shutdown ');
         [status, cmdout] = raw_WSL_call(shutdownCommand);
      case 'raw'
         [status, cmdout] = raw_WSL_call(comment);
      otherwise
         error('%s: Unknown internal command!', mfilename());
   end
   return
end

% pre-execution output
if ~isempty(comment) && ~silentmode
   disp(comment)
end

% execute
[status, cmdout] = execute_in_WSL(wslcommand, WSLdistro);

% finito
return



%% HELPERS
function displayWSLcommand(cmd)
   if silentmode, return; end
   maxLen = 1000;
   if (length(cmd) > maxLen)
      msg = sprintf('INVOKING: %s...\n', cmd(1:maxLen-3));
   else
      msg = sprintf('INVOKING: %s\n', cmd);
   end
   fprintf(msg);
end


function [status, cmdout] = raw_WSL_call(argString)
   % raw call to WSL command
   argString  = escapeForCMD(argString);
   callString = sprintf('wsl %s', argString);
   if dryrun
      displayWSLcommand(callString);
      status = 0;
      cmdout = '---dryrun---';
   else
      if verbose
         displayWSLcommand(callString);
      end
      [status, cmdout] = system(callString);
   end
end


function callStr = add_distro_option(callStr, distro)
   if ~isempty(distro)
      callStr = sprintf('--distribution %s %s', distro, callStr);
   end
end


function [status, cmdout] = execute_in_WSL(command, distro)
   % execute something within WSL
   wslArgString = sprintf('-- %s', command);
   if (nargin >= 2) && ~isempty(distro)
      wslArgString = add_distro_option(wslArgString, distro);
   end
   [status, cmdout] = raw_WSL_call(wslArgString);
   if (status~=0)
      warning('WSL command failed with status code %d! ', status);
      disp(cmdout);
      keyboard
   else
      disp('== WSL output:');
      disp(cmdout);
      disp('== ');
      disp('WSL command returned successful.');
   end
end


function str = tf_to_string(tf)
   if (isempty(tf)) || (tf==false)
      str = 'false';
   else
      str = 'true';
   end
end

end % of function


function wslcommand = escapeForCMD(wslcommand)
   wslcommand = strrep(wslcommand, '&', '^&');
   wslcommand = strrep(wslcommand, '>', '^>');
   wslcommand = strrep(wslcommand, '<', '^<');
   wslcommand = strrep(wslcommand, ';', '^;');
   wslcommand = strrep(wslcommand, '|', '^|');
end