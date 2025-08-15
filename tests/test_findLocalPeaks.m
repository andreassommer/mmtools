% Tester for findLocalPeaks()

% Some sine boxes
% xx = (0:0.1:6*pi)';
% yy = floor(6*sin(xx)); 
% fh = figure(fignum); fh.Name = figname; clf; hold('on');
% plot(xx,yy, 'b.-')

% Extreme case:  piecewise constant
% xx = (0:0.1:6*pi)';
% yy = floor(1*sin(xx)); 
% fh = figure(fignum); fh.Name = figname; clf; hold('on');
% plot(xx,yy, 'b.-')
% [idx vals] = findLocalPeaks(yy, 0, 'xvals', 1:length(xx), 'onlyStrict', true);


%% Example from Matlab's findpeak help
xx = linspace(0,1,1000);
% xx = linspace(0,0.25,1000);
% xx = linspace(0,0.25,30);
% xx = 0.075 : 0.001 : 0.1;

%% gaussian - all extrema
fignum = 1001; figname = 'gaussian - all extrema';
yy = getGaussian(xx);
[idx, vals] = findLocalPeaks(yy, 0, 'xvals', 1:length(xx), 'onlyStrict', true);
fh = figure(fignum); fh.Name = figname; clf; hold('on');
plot(xx, yy, 'b.-', xx(idx), yy(idx), 'ro')

%% quantised gaussian - only strict extrema
fignum = 1002; figname = 'quantised gaussian - only strict extrema';
yy = floor(getGaussian(xx));
[idx, vals] = findLocalPeaks(yy, 0, 'xvals', 1:length(xx), 'onlyStrict', true);
fh = figure(fignum); fh.Name = figname; clf; hold('on');
plot(xx, yy, 'b.-', xx(idx), yy(idx), 'ro')

%% quantised gaussian -- all extrema
fignum = 1003; figname = 'quantised gaussian - all extrema';
yy = floor(getGaussian(xx));
[idx, vals] = findLocalPeaks(yy, 0, 'xvals', 1:length(xx), 'onlyStrict', false);
fh = figure(fignum); fh.Name = figname; clf; hold('on');
plot(xx, yy, 'b.-', xx(idx), yy(idx), 'ro')

%% noise -- all extrema
fignum = 1003; figname = 'quantised gaussian - all extrema -- noisy';
yy = rand(size(xx)) + 1;
[idx, vals] = findLocalPeaks(yy, 0, 'xvals', 1:length(xx), 'onlyStrict', false);
tic; [idxP, valsP] = findLocalPeaks(yy, +1, 'xvals', 1:length(xx), 'onlyStrict', false); toc
tic; [pks, loc] = findpeaks(yy, xx); toc
fh = figure(fignum); fh.Name = figname; clf; hold('on');
plot(xx, yy, 'b.-', xx(idx), yy(idx), 'ro')

%% special test -- all extrema
fignum = 1003; figname = 'special - all extrema';
xx = [0.336 0.337 0.338 0.339 0.340 0.341 0.342 0.343 0.344 0.345 0.346 0.347 0.348 0.349 0.350];
yy = [1.197 1.111 1.297 1.396 1.421 1.311 1.694 1.092 1.402 1.295 1.306 1.106 1.594 1.283 1.155];
tic; [idx , vals ] = findLocalPeaks(yy,  0, 'xvals', 1:length(xx), 'onlyStrict', false); toc
fh = figure(fignum); fh.Name = figname; clf; hold('on');
plot(xx, yy, 'b.-', xx(idx), yy(idx), 'ro')


%% FINITO
return


%% HELPERS
function [yy, xx] = getGaussian(xx)
   if (nargin < 1), xx = linspace(0,1,1000); end
   Pos = [1 2 3 5 7 8]/10;
   Hgt = [3 4 4 2 2 3];
   Wdt = [2 6 3 3 4 6]/100;
   yy = zeros(length(Pos), length(xx));
   for n = 1:length(Pos)
      yy(n,:) = Hgt(n)*exp(-((xx - Pos(n))/Wdt(n)).^2);
   end
   yy = sum(yy);
end