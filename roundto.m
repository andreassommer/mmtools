function rounded = roundto(values, divisor, direction)
% rounded = roundto(value, divisor)
%
% Rounds values to the nearest divisor value.
%
% INPUT:      value --> value(s) to be rounded
%           divisor --> rounding divisor, any integer
%         direction --> -inf: round towards -oo
%                          0: round towards 0
%                       +inf: round towards +oo
%                         +1: round towards nearest divisor
%                         -1: round away from 0 (slow!)
%
% OUTPUT:   rounded --> rounded values
%
% NOTE: Rounding aways from 0 (direction=-1) is 6 times slower
%       than the other rounding options.
%
% Andreas Sommer, Apr2024
% code@andreas-sommer.eu
%

% no direction specified? use 0
if (nargin < 3), direction = 0; end

switch direction
   case -inf
      quotients = values ./ divisor;
      rounded = floor(quotients) .* divisor;

   case 0
      quotients = values ./ divisor;
      rounded = fix(quotients) .* divisor;

   case +inf
      quotients = values ./ divisor;
      rounded = ceil(quotients) .* divisor;

   case +1
      quotients = values ./ divisor;
      rounded = round(quotients) .* divisor;

   case -1
      quotients = values ./ divisor;
      idxneg = (quotients<0);
      idxpos = ~idxneg;
      rounded = zeros(size(values));
      rounded(idxneg) = floor(quotients(idxneg));
      rounded(idxpos) =  ceil(quotients(idxpos));
      rounded = rounded .* divisor;


   otherwise
      error('ROUNDTO: cannot interpret direction "%g"', direction);
end




end % of function


%% HELPERS