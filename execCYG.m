function [status, cmdout] = execCYG(cygcommand, comment)
% [status, cmdout] = execCYG(cygcommand)
% [status, cmdout] = execCYG(cygcommand, comment)
% [status, cmdout] = execCYG(icommand, iarg)
%
% Executes a command in CYGWIN. 
% Before execution, the comment and the command is displayed (if not too long).
% Displays output if successful or halts with warning on failure.
%
% NOTE: Escaping of & ; > < | is automatically done!
%
% INPUT:    cygcommand --> command to be executed in CYGWIN
%              comment --> comment to be displayed before executing if verbosity is enabled
%       -OR-
%             icommand --> internal command starting with #
%                 iarg --> argument to internal comand
%
% OUTPUT:   status --> exit code as returned from command
%           cmdout --> output generated to stdout by command
%
% Internal commands:
%      #setdistro     --> set the CYGWIN distro to be used ('' for default in C:\cygwin64)
%                         Example:  execCYG('#setdistro', 'F:\cygwin')
%      #getdistro     --> retrieves currently selected distro (empty means default distro)
%                         Example:  currentdistro = execCYG('#getdistro')
%      #verbose       --> enable/disable verbosity mode
%                         Example:  execCYG('#verbose', true);
%      #dryrun        --> enable/disable dryrun mode
%                         If set to true, the command will be displayed but not executed.
%                         Always returns with status 0 and empty cmdout.
%                         Example:  execCYG('#dryrun', true);
%      #haltonerror   --> Invokes the debugger if call fails                  (default: true)
%      #showinternals --> Lists internal variables and their content
%      #raw           --> Invokes verbatim command in iarg with CYGWIN's bash
%      #silentmode    --> Enable/disable silent mode (screen output)
%                         Example:  execCYG('#silentmode', true);             (default: false)
%      #showoutput    --> Enable/disable displaying output generated by CYGWIN command
%                         Example:  execCYG('#showoutput', false);            (default: true)
%
% Andreas Sommer, Mar2025
% code@andreas-sommer.eu
%

persistent CYGdistro verbose haltOnError dryrun silentmode showOutput

% init persistent variables
if isempty(verbose)      ,       verbose = true ; end
if isempty(haltOnError)  ,   haltOnError = true ; end
if isempty(dryrun)       ,        dryrun = false; end
if isempty(silentmode)   ,    silentmode = false; end
if isempty(showOutput)   ,    showOutput = true ; end

% ensure comment is accessible
if (nargin<2), comment = ''; end

% no argument call - display hint
if (nargin==0)
   status = -1; 
   cmdout = 'no call specified';
   return
end

% process internal commands
% NOTE: the variable "comment" contains the argument
if ( cygcommand(1)=='#' )
   iarg = comment;
   switch lower(cygcommand(2:end))
      case {'setdistro','distro'}
         CYGdistro = iarg;
      case 'getdistro'
         if (nargout==0)
            fprintf('Selected distro: "%s"\n', CYGdistro)
         end
         status = CYGdistro;
      case 'verbose'
         verbose = iarg;
      case 'dryrun'
         dryrun = iarg;
      case {'haltonerror','keyboardonerror'}
         haltOnError = iarg;
      case 'silentmode'
         silentmode = iarg;
         if silentmode, showOutput = false; end
      case 'showoutput'
         showOutput = iarg;
      case 'showinternals'
         fprintf('%s persistent variables:\n', mfilename())
         fprintf('- CYGdistro   :   %s\n', CYGdistro);
         fprintf('- verbose     :   %s\n', tf_to_string(verbose));
         fprintf('- dryrun      :   %s\n', tf_to_string(dryrun));
         fprintf('- haltOnError :   %s\n', tf_to_string(haltOnError));
         fprintf('- silentmode  :   %s\n', tf_to_string(silentmode));
         fprintf('- showOutput  :   %s\n', tf_to_string(showOutput));
      case {'raw', 'bash'}
         [status, cmdout] = bash_call(comment);
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
[status, cmdout] = execute_in_CYGWIN(cygcommand);

% finito
return



%% HELPERS
function displayCommand(cmd)
   if silentmode, return; end
   maxLen = 1000;
   if (length(cmd) > maxLen)
      msg = sprintf('INVOKING: %s...\n', cmd(1:maxLen-3));
   else
      msg = sprintf('INVOKING: %s\n', cmd);
   end
   fprintf('%s', msg);
end


function bash = getBash()
   distro = CYGdistro;
   if isempty(distro), distro = 'C:\cygwin64'; end
   bash = fullfile(distro, 'bin', 'bash.exe');
   if ~exist(bash, 'file')
      error('No bash.exe found in %s -- Abort!', distro);
   end 
   return
end


function [status, cmdout] = bash_call(argString)
   bash = getBash();
   callString = sprintf('%s --login -c "%s"', bash, argString);
   if dryrun
      displayCommand(callString);
      status = 0;
      cmdout = '---dryrun---';
   else
      if verbose
         displayCommand(callString);
      end
      callString = replaceBackslash(callString)
      [status, cmdout] = system(callString);
   end
end


function str = replaceBackslash(str)
   str = strrep(str, '\', '/');
end



function [status, cmdout] = execute_in_CYGWIN(command)
   [status, cmdout] = bash_call(command);
   if (status~=0)
      warning('Command failed with status code %d! ', status);
      disp(cmdout);
      if haltOnError, keyboard(); end
   else
      if (showOutput)
         disp('== Output:');
         disp(cmdout);
         disp('== ');
      end
      if (~silentmode)
         disp('Command returned successfully.');
      end
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


