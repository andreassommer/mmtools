function z = hornereval2D(p,x,y)
% Evaluation of 2D polynomial according to Horner's method.
% 
% INPUT:  p --> matrix of polynomial coefficients
% 
%         x --> x values to evaluate (scalar or vector)
%         x --> y values to evaluate (same size as x)
% 
% OUTPUT: z --> evaluated 2D polynomial
%               z = sum_(i=0)^(nx) sum_(j=0)^(ny)  p(i,j) * x^i * y^j
%                 = sum_(i=0)^(nx) x^i * sum_(j=0)^(ny) p(i,j) * y^j
%                                        |-------- = ki -----------|
%                 = sum_(i=0)^(nx) x^i * ki
%
% Horner's method is used to speedup and stabilize the evaluation.
%
% Andreas Sommer, Jun2016
% code@andreas-sommer.eu
%

% number of coefficients of p 
[npx, npy] = size(p);

% scalar or vectorized 2D Horner method
if isscalar(x) 
   
   % SCALAR x and y

   k = zeros(npx, 1);
   for i = 1:npx
      % CALCULATE: k(i) = hornereval(p(i,:), y);
      ki = p(i,1);
      for j = 2:npy
         ki = y * ki + p(i,j);
      end
      k(i) = ki;
   end
   % CALCULATE: z = hornereval(k, x);
   z = k(1);
   for i = 2:npx
      z = x .* z + k(i);
   end

   return


else
   
   % VECTORIZED x and y
   
   npoints = numel(x);
   k = zeros(npx, npoints);
   for i = 1:npx
      % CALCULATE:  k(i,:) = hornereval(p(i,:), y);
      ki = zeros(npoints, 1);
      ki(:) = p(i,1);
      for j = 2:npy
         ki = y .* ki + p(i,j);
      end
      k(i,:) = ki;
   end
   z = zeros(1, npoints);
   for l = 1:npoints
      % CALCULATE:  z(l) = hornereval(k(:,l), x(l));
      zl = k(1,l);
      for i = 2:npx
         zl = x(l) .* zl + k(i,l);
      end
      z(l) = zl;
   end
   % return same dimension as input
   z = reshape(z, size(x));
   return

end

% CANNOT REACH THIS POINT !
% --> early return!


%    % VERY SLOW
%    tic
%    %x = reshape(x, [], 1);
%    %y = reshape(y, 1, []);
%    powersX = x .^ reshape(0:(npx-1), [], 1);
%    powersY = y .^ reshape(0:(npy-1), 1, []);
%    zz = sum(flip(p) .* (powersX * powersY));
%    toc
% 
%    z
%    zz
%    z - zz

end