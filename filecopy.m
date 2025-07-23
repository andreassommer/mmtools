function [success, message] = filecopy(source, destination, chunksize, useRecycler)
% [success, message] = filecopy(source, destination, chunksize, useRecycler)
%
% Copies source to destination. Overwrites if destination if it exists.
% If the path of destination does not exist, it is created.
%
% INPUT:      source --> source file
%        destination --> target
%          chunksize --> amount of bytes to be copied at once                                   [default: 16384]
%        useRecycler --> flag to indicate if existing destination shall be deleted or recycled  [default:  true]
%
% OUTPUT:    success --> true on success, false on failure
%            message --> messages in human readable format
%
%
% NOTES:
%   1) In contrast to Matlab's copyfile(), this filecopy() does not maintain the 
%      source's permissions but uses the current user's permission for the destination file.
%   2) Wildcards * and ? are NOT SUPPORTED
%
% Andreas Sommer, Jul2025
% code@andreas-sommer.eu
%

% output variables
success = false;     %#ok<NASGU> 
message = '';

% defaults
if (nargin < 3), chunksize   = 16384; end   % byte size for transfer
if (nargin < 4), useRecycler =  true; end   % delete or recycle?

% set useRecycler to appropriate string
if (useRecycler)
   useRecycler = 'on'; 
else 
   useRecycler = 'off';
end

% check for wildcards
if contains(source, '*') || contains(source, '?') || contains(destination, '*') || contains(destination, '?')
   message = addMessage(message, 'Wildcards not yet supported');
   success = false;
   return
end

% dissect destination; if it is a folder, add 
[destinationPath, destinationFile] = fileparts(destination);
if isempty(destinationFile)
   [~, sourceFile] = fileparts(source);
   destination = fullfile(destinationPath, sourceFile);
end

% check existence of source (note: isfile only exists from R2017b on)
if ~exist(source, 'file')
   success = false;
   message = addMessage(message, 'Source file %s does not exist', source);
   return
end

% if destination exists, delete it (move it into recycler)
if exist(destination, 'file')
   recyclestate = recycle(useRecycler);
   try
      delete(destination);
      if useRecycler
         message = addMessage(message, 'Moved existing destination file %s to recycle bin', destination);
      end
   catch
      success = false;
      message = addMessage(message, 'Failed to delete existing destination file %s', destination);
      recycle(recyclestate); % switch back to previous recycle state
      return   
   end
   recycle(recyclestate); % switch back to previous recycle state
end

% ensure path to destination exists
if ~isempty(destinationPath)
   if ~exist(destinationPath, 'dir')
      [success, ~] = mkdir(destinationPath);
      if success
         message = addMessage(message, 'Created destination directory %s', destinationPath);
      else
         message = addMessage(message, 'Cannot create destination path %s', destinationPath);
         return;
      end
   end
end


% Checks done, now do the work

% open files
fIDsource      = fopen(source, 'r');
fIDdestination = fopen(destination, 'w');

% check files
if (fIDsource      < 0), success = false; message = addMessage(message, 'Failed to open source file %s'     , source     ); return; end
if (fIDdestination < 0), success = false; message = addMessage(message, 'Failed to open destination file %s', destination); return; end

% transfer contents
[success, totalbytes] = copyContents(fIDsource, fIDdestination, chunksize);
if ~success
   message = addMessage(message, 'Error while copying file %s to %s around position %d', source, destination, totalbytes); 
   return; 
end

% close files
try
   status = fclose(fIDsource);       if (status~=0), error('Error while closing source file');      end
   status = fclose(fIDdestination);  if (status~=0), error('Error while closing destination file'); end
catch ME
   success = false;
   message = addMessage(message, ME.message);
   return
end

% report success
success = true;
message = addMessage(message, 'OK');


end % of function




%% HELPERS

function [success, totalbytes] = copyContents(fIDsrc, fIDdest, chunksize)
   totalbytes = 0;
   try
      bytecount = 1;
      while (bytecount > 0)
         [data, bytecount] = fread(fIDsrc, chunksize);
         fwrite(fIDdest, data);
         totalbytes = totalbytes + bytecount;
      end
      success = true;
   catch
      success = false;
   end
end


function msg = addMessage(msg, fmt, varargin)
   newmsg = sprintf(fmt, varargin{:});
   if isempty(msg)
      msg = newmsg;
   else
      msg = sprintf('%s | %s', newmsg, msg);
   end
end
