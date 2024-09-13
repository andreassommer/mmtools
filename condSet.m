function z = condSet(condition, valTrue, valFalse, z)
% z = condSet(condition, valTrue, valFalse, z)
%
% Conditionally sets values in array z
%
% INPUT:    condition --> array of true/false entries
%             valTrue --> values to be set where condition is true
%            valFalse --> values to be set where condition is false
%                   z --> array to be modified  [optional]
%
% OUTPUT:           z --> array with new values
%
% REMARKS:
%
% * If valTrue/valFalse is {}, then z will not be modified on places where condition is true/false
%   Use {{}} if you want to set it to the empty set.
%
% * If valTrue/valFalse is an array of same size as condition, the respective
%   z(condition) will be set to valTrue(condition), and to valFalse(~condition) on the other places
%
% * If valTrue/valFalse is non-numeric and scalar, it will be evaluated with the current value of z
%   Evaluation is done element-wise.
%
% * If no initial z is given, and valTrue/valFalse are numeric, z will also be numeric.
%   A cell output can be forced by giving suitable initial z: 
%       z = condSet(condition, 1, 5, {})
%
% EXAMPLE CALLS:
%   M = magic(5); R = -rand(5);         % matrices for testing
%   z = condSet(M>10, 1, 5)             % --> matrix of size(M) with 1 where M>10, and 5 otherwise
%   z = condSet(M>10, 1, 5, {})         % --> cell array of size(M) with 1 where M>10, and 5 otherwise
%   z = condSet(M>10, '2BIG')           % --> cell array of size(M) with 'TOOBIG' where M>10
%   z = condSet(M>10, 10, M)            % --> copy of M with value 10 where previously M>10
%   z = condSet(M>10, @(x) x^2, -1, M)  % --> copy of M with squared entries where M>10, and -1 otherwise
%   z = condSet(M>10, R, {}, M)         % --> copy of M with values from R where M>10
%
% Andreas Sommer, Sep2024
% code@andreas-sommer.eu
%

% if only valTrue is specified, probably the user dont want to do assignments if cond is false
if (nargin <= 2), valFalse = {}; end

% check if target is a cell array (either if z is cell, or valTrue or valFalse is not numeric)
if ( (nargin >=4 && iscell(z)) || ~isnumeric(valTrue) || ~isnumeric(valFalse) )
   targetIsCell = true;
else 
   targetIsCell = false;
end

% if no initial data z is given, use zero or empty cell
if (nargin < 4) || isempty(z)
   if targetIsCell
      z = cell(size(condition));
   else
      z = zeros(size(condition));
   end
end

% figure out if we shall or shall not modify on true or false condition
[set_valTrue , valTrue ] = shallWeSet(valTrue );
[set_valFalse, valFalse] = shallWeSet(valFalse);

% set the values
if set_valTrue , z = setValues(z,  condition, valTrue) ; end
if set_valFalse, z = setValues(z, ~condition, valFalse); end
   
end % of function



%% HELPERS
function [set_valTF, valTF] = shallWeSet(valTF)
   set_valTF = true;
   if iscell(valTF)         % cell arrays might indicate special cases
      if isempty(valTF)         % special case {} - indicates to not modify values
         set_valTF = false;
      elseif numel(valTF)==1    % special case { {} } - indicates to set values to {}
         valTF = valTF{1};
      end
   end
end

function z = setValues(z, condition, thing)
   if isscalar(thing) || ischar(thing)
      if isnumeric(thing) || islogical(thing) || ischar(thing) || isstring(thing)
         z = setEntriesToScalarValue(z, condition, thing);
      else % try to evaluate it at all indices
         idx = find(condition);
         newzvals = arrayfun(@(i) thing(z(i)), idx);
         z = setEntriesToScalarValue(z, idx, newzvals);
      end
   else
      z(condition) = thing(condition); % copy the elements
   end
end

function z = setEntriesToScalarValue(z, indices, value)
   if iscell(z)
      [z{indices}] = deal(value);
   else
      z(indices) = value;
   end
end

