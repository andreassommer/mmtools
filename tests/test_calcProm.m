% tester for prominence calculation using a damped sine signal

% data: damped sine signal with increasing frequency
x = 0:0.1:10;
y = sin(x.^(1+x/20)) ./ (x+1);


% get local minima/maxima
[idxMax, valMax] = findLocalPeaks(y, +1, 'xvals', x, 'onlyStrict', true);
[idxMin, valMin] = findLocalPeaks(y, -1, 'xvals', x, 'onlyStrict', true);
idxExt = union(idxMin, idxMax);  % all found extrema

% plot
figure(9183); clf; axh=gca(); hold(axh, 'on');
plot(axh, x        ,      y, 'r.-', 'DisplayName', 'signal');
plot(axh, x(idxMax), valMax, 'mo' , 'DisplayName', 'Maxima');
plot(axh, x(idxMin), valMin, 'co' , 'DisplayName', 'Minima');
plot(axh, x        ,     -y, 'y.-', 'DisplayName', 'signal');
legend(axh, 'show', 'Location', 'best')
title('signal')



fprintf('Prominence of maxima\n');
[proms, promsIdx] = calcProm(x, y, idxMax, [], +1); % determine them all at once
for i = 1:length(idxMax)
   [prom, promIdx] = calcProm(x, y, idxMax(i), [], +1);
   yyp = nan(); yypi = nan(); xxp = nan(); xxpi = nan();
   if (promIdx     > 0), yyp  = y(promIdx    ); xxp  = x(promIdx    ); end
   if (promsIdx(i) > 0), yypi = y(promsIdx(i)); xxpi = x(promsIdx(i)); end
   fprintf('Prominence(%2d): %12.8f   at x(%4d)=%g with value %12.8f\n', i, prom    , promIdx    , xxp , yyp );
   fprintf(' -onerun- (%2d): %12.8f   at x(%4d)=%g with value %12.8f\n', i, proms(i), promsIdx(i), xxpi, yypi);
   fprintf('\n')
end


fprintf('Prominence of minima (direction reversed)\n');
[proms, promsIdx] = calcProm(x, y, idxMin, [], -1); % determine them all at once
for i = 1:length(idxMin)
   [prom, promIdx] = calcProm(x, y, idxMin(i), [], -1);
   yyp = nan(); yypi = nan(); xxp = nan(); xxpi = nan();
   if (promIdx     > 0), yyp  = y(promIdx    ); xxp  = x(promIdx    ); end
   if (promsIdx(i) > 0), yypi = y(promsIdx(i)); xxpi = x(promsIdx(i)); end
   fprintf('Prominence(%2d): %12.8f   at x(%4d)=%g with value %12.8f\n', i, prom    , promIdx    , xxp , yyp );
   fprintf(' -onerun- (%2d): %12.8f   at x(%4d)=%g with value %12.8f\n', i, proms(i), promsIdx(i), xxpi, yypi);
   fprintf('\n')
end


% let findLocalPeaks do the full job
[idxMax, valMax] = findLocalPeaks(y, +1, 'xvals', x, 'onlyStrict', true, 'includeBoundary', false, 'minProm', 1.4);
[idxMin, valMin] = findLocalPeaks(y, -1, 'xvals', x, 'onlyStrict', true, 'includeBoundary', false, 'minProm', 1.4);
[idxExt, valExt] = findLocalPeaks(y,  0, 'xvals', x, 'onlyStrict', true, 'includeBoundary', false, 'minProm', 1.4);
printPeaks(x,y,idxMax,'max');
printPeaks(x,y,idxMin,'min');
printPeaks(x,y,idxExt,'ext');
function printPeaks(x,y,idx,msg)
   for i = 1:length(idx)
      fprintf('%s peak %2d:  x(%2d) = %12.8f  @  y = %12.8f\n', msg, i, idx(i), x(idx(i)), y(idx(i)))
   end
end
