function y = hornereval(p,x)
% function y = HORNEREVAL(p,x)
%
% Evaluation of polynomial according to Horner's method.
% 
% INPUT:  p --> vector of polynomial coefficients (e.g. by polyfit)
%         x --> position to evaluate (scalar or vector)
% 
% OUTPUT: y --> evaluated polynomial
%               y = p(1) * x^n  +  p(2) * x^n-1  + ... +  p(n) * x  +  p(n+1)
%
% Horner's method is used to speedup and stabilize the evaluation.
%
% Andreas Sommer, Jun2016
% code@andreas-sommer.eu
%

% number of coefficients
np = numel(p);

% scalar or vectorized Horner method
if isscalar(x)
   y = p(1);
   for i = 2:np
      y = x .* y + p(i);
   end
else
   y = zeros(size(x));
   y(:) = p(1);
   for i = 2:np
      y = x .* y + p(i);
   end
end