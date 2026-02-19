function status = findNearestNeighbor_tester()
% Tests findNearestNeighbor()



% problem setup
xmax = 10; % MUST BE INTEGER
x  = 1:xmax;
xq = [ 0.9 1.0 1.1 1.9 5.1 9.6 10.0 10.1 ] * (xmax/10);  % query values
rng(42);
xperm  = randperm(length(x));      % random sort order for x
xqperm = randperm(length(xq));     % random sort order for xq

ASCENDING  = +1;     xASCENDING  = sort(x, 'ascend');  xqASCENDING  = sort(xq,'ascend');
DESCENDING = -1;     xDESCENDING = flip(xASCENDING);   xqDESCENDING = flip(xqASCENDING);
UNSORTED   =  0;     xUNSORTED   = x(xperm);           xqUNSORTED   = xq(xqperm);

searchdirlist = {+1 -1 0};


for cornermatch = [true false]

   fprintf('\n\n============\n\n')

   performSearch(xASCENDING  , xqASCENDING ,  ASCENDING , ASCENDING , cornermatch, searchdirlist);
   performSearch(xASCENDING  , xqDESCENDING,  ASCENDING , DESCENDING, cornermatch, searchdirlist);
   performSearch(xASCENDING  , xqUNSORTED  ,  ASCENDING , UNSORTED  , cornermatch, searchdirlist);

   performSearch(xDESCENDING , xqASCENDING ,  DESCENDING, ASCENDING , cornermatch, searchdirlist);
   performSearch(xDESCENDING , xqDESCENDING,  DESCENDING, DESCENDING, cornermatch, searchdirlist);
   performSearch(xDESCENDING , xqUNSORTED  ,  DESCENDING, UNSORTED  , cornermatch, searchdirlist);

   performSearch(xUNSORTED   , xqASCENDING ,  UNSORTED  , ASCENDING , cornermatch, searchdirlist);
   performSearch(xUNSORTED   , xqDESCENDING,  UNSORTED  , DESCENDING, cornermatch, searchdirlist);
   performSearch(xUNSORTED   , xqUNSORTED  ,  UNSORTED  , UNSORTED  , cornermatch, searchdirlist);

end



% runtime test

nx = 1e6;   x  = 100 * randn(nx, 1);
nq = 1e3;   xq = 100 * randn(nq, 1);  % query values
searchdir = +1;

sortflag_x  = +1;
sortflag_xq = +1;
cornermatch = false;

if     (sortflag_x  == +1), x  = sort( x, 'ascend'); 
elseif (sortflag_x  == -1), x  = sort( x, 'descend');
end
if     (sortflag_xq == +1), xq = sort(xq, 'ascend');
elseif (sortflag_xq == -1), xq = sort(xq, 'descend');
end

tic
[idx_v, val_v] = findNearestNeighbor(x, xq, searchdir, sortflag_x, sortflag_xq, cornermatch);
time_vector = toc();
fprintf('VECTOR: Time for searching %d neighbors in array with %d elements: %gs\n', nq, nx, time_vector);

tic
idx_s = zeros(nq, 1);
val_s = zeros(nq, 1);
for i = 1:nq
   [idx_s(i), val_s(i)] = findNearestNeighbor(x, xq(i), searchdir, sortflag_x, sortflag_xq, cornermatch);
end
time_single = toc();
fprintf('SINGLE: Time for searching %d neighbors in array with %d elements: %gs\n', nq, nx, time_single);

for i = 1:nq
   if ~isequal(idx_s(i), idx_v(i)) || ~isequal(val_s(i), val_v(i)) 
      fprintf('Diff @%7d:  idx_s = %-10g  idx_v = %-10g   val_s = %-10g  val_v = %-10g\n', idx_s(i), idx_v(i), val_s(i), val_v(i));
   end
end

% finito
return

end




% print helpers
function printHeader(xsortdir, xqsortdir, cornermatch, searchdirlist)
   if     (xsortdir >= +1), xsorttext = 'ASCENDING';
   elseif (xsortdir <= -1), xsorttext = 'DESCENDING';
   else                   , xsorttext = 'UNSORTED';
   end
   if     (xqsortdir >= +1), xqsorttext = 'ASCENDING';
   elseif (xqsortdir <= -1), xqsorttext = 'DESCENDING';
   else                    , xqsorttext = 'UNSORTED';
   end
   fprintf('x is %s  ---  xq is %s  ---  cornermatch = %d  ---  search order +1/-1/0\n', xsorttext, xqsorttext, cornermatch);
   fprintf('      ');
   for i=1:length(searchdirlist)
      fprintf(' --single------vector-- ');
   end
   fprintf('\n');
   fprintf('  xq    ');
   for i=1:length(searchdirlist)
      fprintf(' %1$s   val    %1$s   val   ', getDirStr(searchdirlist{i}));
   end
   fprintf('\n');
   return
   function s = getDirStr(dir)
      if     (dir >= +1), s = '+1';
      elseif (dir <= -1), s = '-1';
      elseif (dir ==  0), s = '00';
      else   s = 'xx';
      end
   end
end


% helper for showing results
function performSearch(xx, xq, sortflag_x, sortflag_xq, cornermatch, searchdirlist)
   xformat = '%5.1f  ';
   iformat = '%4d ';
   % IMPORTANT: cell array order is always [+1 -1 0]
   printHeader(sortflag_x, sortflag_xq, cornermatch, searchdirlist);
   idxv = num2cell(nan(length(xq), length(searchdirlist)));
   valv = num2cell(nan(length(xq), length(searchdirlist)));
   % do vector-based search first
   for i = 1:length(searchdirlist)
      [idxv{i}, valv{i}] = findNearestNeighbor(xx, xq, searchdirlist{i}, sortflag_x, sortflag_xq, cornermatch);
   end
   % do single xq search and display results
   for k = 1:length(xq)
      fprintf(xformat, xq(k));
      for i = 1:length(searchdirlist)
         [idx, val] = findNearestNeighbor(xx, xq(k), searchdirlist{i}, sortflag_x, sortflag_xq, cornermatch);
         fprintf(iformat, idx       ); fprintf(xformat, val       ); % scalar search result
         fprintf(iformat, idxv{i}(k)); fprintf(xformat, valv{i}(k)); % vector search result
         if     ~isequal(idx, idxv{i}(k)), fprintf('<-- XXXXX ');   % isequal can compare inf
         elseif ~isequal(val, valv{i}(k)), fprintf('<-- VVVVV ');   % isequal can compare inf
         end
      end
      fprintf('\n');
   end
   if (numel(xx) <= 20)
      fprintf('\nx = '); fprintf(xformat, xx); fprintf(''); 
   end
   if (numel(xq) <= 20)
      fprintf('\nxq= '); fprintf(xformat', xq); fprintf('\n\n\n'); 
   end
end




%{

 xq   x ASCENDING       searchdir
       1 2 3 4 5       +1   -1   0
 0.9   o                1   --   1
 1.0   o                1    1   1
 1.1     o              2    1   1
 1.9     o              2    1   2
 4.9           o        5    4   5
 5.0           o        5    5   5
 5.1             -     --    5   5
     o marks x(i) >= xq


 xq   x DESCENDING       searchdir
       5 4 3 2 1       +1   -1   0
 0.9             -      5   --   5
 1.0           o        5    5   5
 1.1           o        4    5   5
 1.9           o        4    5   4
 4.9     o              1    2   1
 5.0   o                1    1   1
 5.1   o               --    1   1
     o marks x(i) <= xq


%}


