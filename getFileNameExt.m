function fn = getFileNameExt(filespec)
% fn = getFileNameExt(filespec)
%
% Retrieves file name with extension from filespec.
%
% INPUT:    filespec --> file specification 
%
% OUTPUT:         fn --> file name with extension
%
%
% Andreas Sommer, Jul2024
% code@andreas-sommer.eu
%

   [~, filename, ext] = fileparts(filespec);
   fn = [filename ext];
end
