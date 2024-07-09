function tf = istext(thing)
% function tf = istext(thing)
%
% Checks if thing is either a char array or a string
%
% INPUT:    thing --> object to be checked
%
% OUTPUT:      tf --> true if thing is a char array or a string
%                     false otherwise
%
% Andreas Sommer, Jul2024
% code@andreas-sommer.eu
%

if ( ischar(thing) || isstring(thing) )
   tf = true;
else
   tf = false;
end

end % of function

