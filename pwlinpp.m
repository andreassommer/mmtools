function pp = pwlinpp(breaks, coefs)
%
% pp = PWLINPP(breaks, coefs)
%
% pp = PWLINPP(points)
%
% Convenience wrapper for Matlab's mkpp() that allows specifying 
% piecewise linear functions by their global representations (not local).
%
% INPUT:  breaks --> break points
%          coefs --> a) matrix of the form [m1, b1 ; m2, b2, ... ]
%                        where: mi is the slope of the i-th linear piece
%                               bi is the y-axis intercept of the i-th linear piece
%                    b) vector of the form [y0, m1, m2, m3, ... ]
%                       where: y0 is the value at breaks(1)
%                              mi is the slope of the i-th linear piece
%                    In b), a continuous function is generated
%         points --> matrix of the form [x1, y1 ; x2, y2 , ...]
%                    to generate a polyline through (x1,y1), (x2,y2), etc.
%
% OUTPUT:     pp --> piecewise polynomial
%
% NOTE:  Outside the specified interval, a linear interpolation is done.
%
% EXAMPLES:
%    1)  pp = pwlinpp([1 2 4 5], [1, 0; 2, 0; 3, 0])  
%        Segments consist of piecewise linear function with slopes 1, 2, 3 and y-axis-intercept all 0
%
%    2)  pp = pwlinpp([1 2 4 5], [5, -1, 2, 0])
%        Starting at point (1,5) with slope -1, and slopes 2 and 0 at the subsequent break points
%
%    3)  pp = pwlinpp([1,0; 2,1; 4,4; 5,1])
%        This creates a piecewise linear function passing through points [1,0], [2,1], [4,4] and [5,1]
%    
%
% Andreas Sommer, Jul2026
% code@andreas-sommer.eu
%

% input okay?
narginchk(1,2);

% call with several individual points
if (nargin == 1)
   points = breaks;  % "rename" argument
   [m,b] = calc_mx_plus_b( points(1:end-1, 1), points(1:end-1, 2), points(2:end, 1), points(2:end, 2));
   pp = pwlinpp(points(:,1), [ reshape(m, [], 1) , reshape(b, [], 1) ] );
   return
end

% which shape does coefs have?
if isvector(coefs)

   % initial value plus inclines
   coefs  = reshape(coefs , [], 1);
   breaks = reshape(breaks, [], 1);
   y0 = coefs(1);
   m  = coefs(2:end);       % slopes
   N  = length(m);          % number of segments
   if length(breaks) <=N    % add a final break if user did not specify it
      breaks(end+1) = (1+100*eps(1))*breaks(end);   % mkpp needs this final break point
   end
   dx = diff(breaks);       % possibly ignore if there are more breaks given
   c = [y0; y0 + cumsum( m .* dx ) ];
   coefs = [m, c(1:end-1)];

else % coefs is a matrix

   % piecewise linear with global descriptions
   m = coefs(:,1);
   b = coefs(:,2);
   breaks = reshape(breaks, [], 1);
   % re-build coeffs for Matlab's mkpp()
   coefs(:, 2) = m .* breaks(1:end-1) + b;

end

% create the pp
pp = mkpp(breaks, coefs);


end % of function

