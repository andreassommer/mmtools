function fh = getParentFigure(axh)
% fh = getParentFigure(axh)
%
% Retrieves the parent figure of specified handle.
%
% INPUT:   axh --> graphics handle (e.g. axis handle)
%
% OUTPUT:   fh --> handle of parent figure
%
%
% Andreas Sommer, Aug2023
% code@andreas-sommer.eu
%   handle = axh.Parent;

% if no graphics handle specified, return empty
if ~ishandle(axh)
   fh = []; 
   return; 
end

% try to get parent object
fh = axh.Parent;
if isempty(fh), return; end

% if parent object is found, go up until figure is found
while ~( ishandle(fh) && strcmp(get(fh, 'type'), 'figure') )
   fh = fh.Parent;
end

end % of function
