n = 100;
x = cumsum(abs(rand(1, n)));   % sorted array

runs = 10000;
query = floor(0.5*(n/2));     % x(end) is around n/2
start = 10;



disp('findFirstGreater');
tic
idxsum = 0;
for i = 1:runs
   idx = findFirstGreater(x, query, start);
   idxsum = idxsum + idx;
end
toc
disp(idxsum);  % to avoid optimization due to not used value


disp('findFirstGreater - noCall');
tic
idxsum = 0;
for i = 1:runs
   for k = start:(numel(x))
      if x(k) > query, idxsum = idxsum + k; break; end
   end
end
toc
disp(idxsum);


disp('find')
idxsum = 0;
tic
for i = 1:runs
   idx = find(x(start:end)>query, 1);
   idxsum = idxsum + idx + (start-1);     % find sees less entries: add start
end
toc
disp(idxsum);

