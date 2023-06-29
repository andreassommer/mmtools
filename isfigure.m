function flag = isfigure(handle)
% function flag = isfigure(handle)
%
% Checks if specified handle is a figure.
%
% INPUT:  handle --> handle to be queried
%
% OUTPUT:   flag --> true if handle is a figure
%                    false otherwise
%
% Andreas Sommer, Mrz2023
% code@andreas-sommer.eu
%
if ishandle(handle) && strcmp(get(handle, 'type'), 'figure')
   flag = true;
else
   flag = false;
end


end