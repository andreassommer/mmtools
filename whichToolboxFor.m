function dependencies = whichToolboxFor(mfile)
% dep = whichToolboxFor(mfile)
%
% Retrieves the required Matlab Toolboxes for specified mfile.
% Also inspects all files invoked by mfile and checks their dependency.
%
% INP    mfile --> file to be scanned
%
% OUTPUT:  dep --> structure containing scanned dependency data
%
% NOTE: This function will output two lists:
%       1)  FILE:  mfile   -> lists all required toolboxes for specified mfile
%       2)  TOOLBOX:  tb   -> for every required toolbox, a list of files that 
%                             requires them is printed
%
% Andreas Sommer, Jul2024
% code@andreas-sommer.eu
%

% little error check
if ~exist(mfile, 'file')
   error('m file %s not found.', mfile);
end

% Retrieve data
fprintf('Retrieving dependencies of %s...', mfile);
[fList       , pList       ] = matlab.codetools.requiredFilesAndProducts(mfile); 
[fList_direct, pList_direct] = matlab.codetools.requiredFilesAndProducts(mfile, 'toponly'); 
filecount = length(fList);
fprintf('Done.\n')

% for every file, get the direct dependencies
fprintf('Retrieving dependencies of %d called files', filecount);
fl = cell(filecount, 1);
pl = cell(filecount, 1);
for i=1:filecount
   filename = fList{i};
   [fl{i}, pl{i}] = matlab.codetools.requiredFilesAndProducts(filename, 'toponly');
   fl{i} = reshape(fl{i}, [], 1);
   fprintf('.');
end
fprintf('Done!\n\n');

% assemble output
dependencies.fList        = fList;
dependencies.pList        = pList;
dependencies.fList_direct = fList_direct;
dependencies.pList_direct = pList_direct;
dependencies.fl = fl;
dependencies.pl = pl; 


% List of dependencies
tbNames        = {pList(:).Name};         % overall
tbNames_direct = {pList_direct(:).Name};  % direct

% display needed products for mfile
fprintf('FILE: %s\n', mfile)
for i=1:length(tbNames)
   tbname = tbNames{i};
   fprintf('  ->  %s ', tbname);
   if ismember(tbname, tbNames_direct)
      fprintf('(direct)');
   end
   fprintf('\n');
end

fprintf('\n');

% for every found product, list the files that require it
for i = 1:length(tbNames)
   tbname = tbNames{i};
   if strcmpi(tbname, 'MATLAB'), continue; end   % skip Matlab dependency
   fprintf('TOOLBOX: %s\n', tbname);
   % walk through every file dependency list and check if file needs that toolbox
   for j = 1:length(fl)
      tmp_tbNames = {pl{j}.Name};
      if ismember(tbname, tmp_tbNames)
         fprintf(' -->  %s\n', fList{j});
      end
   end
   fprintf('\n');
end


end % of function