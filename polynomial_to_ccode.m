function polynomial_to_ccode(varargin)
% polynomial_to_ccode(key-value-pairs)
%
% Generates C code from a (possibly centered and normalized) polynomial.
%
% INPUT:  key-value-pairs with keys:
%           coeffs --> polynomial coefficients
%             mean --> mean value for centering                                    [ default: 0 ]
%            scale --> scaling factor                                              [ default: 1 ]
%             name --> name infix for C code variables (e.g. poly_name_coeffs)     [ default: %prefix%poly%timestamp% ]
%          funname --> name of the created polynomial function                     [ default: %name%_eval             ]
%                      if explicitly set to empty, no function is added
%          comment --> comment that will be put in first line                      [ optional ]
%        addDefine --> add a #define line for checking with #ifdef                 [ default: true ]
%                      can also specify a full string that is used for the define
%        addHorner --> adds a local horner scheme polynomial evaluator             [ default: true ]
%       addExternC --> wraps the generated code in an 'extern "C" {...}" block     [ default: false ]
%        evaluator --> name of function that evaluates the polynomial              [ default: %prefix%%name%_horner ]
%          outfile --> output file name (will be overwritten) or fileID 
%         includes --> cell string of files to be included                         [ optional ]
%                      for each string, a #include "file" line is added
%        namespace --> the whole code will be put in specified namespace           [ optional ]
%                      set to '{}' for wrapping the code in {...}
%   messageprinter --> fprintf-interface for printing (debug) messages
%        varprefix --> variable prefix string                                      [ default: poly_ ]
%
% OUTPUT:   none
%
% Andreas Sommer, Apr2026
% code@andreas-sommer.eu
%

% timestamp
timestamp = string(datetime('now', 'format', 'yyyyMMddhhmmss'));

% input args
args = varargin;
[coeffs        , args] = olGetOption(args, 'coeffs'        , []                               );
[scaleval      , args] = olGetOption(args, 'scale'         , []                               );
[meanval       , args] = olGetOption(args, 'mean'          , []                               );
[comment       , args] = olGetOption(args, 'comment'       , ''                               );
[varprefix     , args] = olGetOption(args, 'varprefix'     , 'poly_'                          );
[name          , args] = olGetOption(args, 'name'          , sprintf('poly%s', timestamp)     );
[funname       , args] = olGetOption(args, 'funname'       , sprintf('%s_eval', name)         );
[evaluator     , args] = olGetOption(args, 'evaluator'     , []                               );
[outfile       , args] = olGetOption(args, 'outfile'       , ''                               );
[includes      , args] = olGetOption(args, 'includes'      , {}                               );
[addDefine     , args] = olGetOption(args, 'adddefine'     , true                             );
[addHorner     , args] = olGetOption(args, 'addhorner'     , true                             );
[addExternC    , args] = olGetOption(args, 'addexternc'    , true                             );
[namespace     , args] = olGetOption(args, 'namespace'     , ''                               );
[messageprinter, args] = olGetOption(args, 'messageprinter', @(varargin) fprintf(varargin{:}) );
olWarnIfNotEmpty(args, false, sprintf('%s::unknown-arguments', mfilename()));  % done again at end

% open output file
closefile = false;
if isempty(outfile)
   fid = 1;  % stdout
elseif isnumeric(outfile)
   fid = outfile;
else 
   fid = fopen(outfile, 'w');
   closefile = true;
end

% helper
function val = condval(tf, tval, fval)
   if (tf), val = tval; else, val = fval; end
end

% variable names
varname_ncoeffs  = sprintf('%s%s_NCOEFFS'   , varprefix, name);
varname_coeffs   = sprintf('%s%s_COEFFS'    , varprefix, name);
varname_mean     = sprintf('%s%s_MEAN'      , varprefix, name);
varname_scale    = sprintf('%s%s_SCALE'     , varprefix, name);
funname_eval     = funname;
funname_horner   = sprintf('%s%s_HORNEREVAL', varprefix, name);
funname_polyeval = condval(isempty(evaluator), funname_horner, evaluator);


% double format
dformat = '%.16g ';


% first line: comment
if ~isempty(comment)
   fprintf(fid, '// %s\n', comment);
end


% define for use with #ifdef
if addDefine
   if islogical(addDefine) || isnumeric(addDefine)
      fprintf(fid, '#define %s%s\n\n', upper(varprefix), upper(name));
   else
      fprintf(fid, '#define %s\n', addDefine);
   end
end


% add includes
if ~iscell(includes), includes = {includes}; end
if ~isempty(includes) 
   for i = 1:length(includes)
      fprintf(fid, '#include "%s"\n', includes{i});
   end
end


% namespace open
if ~isempty(namespace)
   if ~strcmp(namespace, '{}')
      fprintf(fid, '#ifdef __cplusplus\n');
      fprintf(fid, 'namespace %s \n', namespace);
      fprintf(fid, '#endif\n');
   end
   fprintf(fid, '{ // local code or namespace\n\n');
end


% add extern "C" for unmangling for C++ names
if addExternC
   fprintf(fid, '#ifdef __cplusplus\n');
   fprintf(fid, 'extern "C" {\n');
   fprintf(fid, '#endif\n\n');
end


% size and content of array of coefficients
if true
   fprintf(fid, 'static const double %s[] = {\n'  , varname_coeffs );
   coefstring = strjoin(compose(dformat, coeffs), ', ');
   fprintf(fid, '   %s\n', coefstring);
   fprintf(fid, '};\n');
   fprintf(fid, 'static const int    %s = sizeof(%s)/sizeof(double);\n', varname_ncoeffs, varname_coeffs);
end

% if mean and/or scale is given, add it to the code
mean_given  = ~isempty(meanval)  && ( meanval ~= 0);
scale_given = ~isempty(scaleval) && (scaleval ~= 1);
if mean_given
   fprintf(fid, 'static const double %s = %s;\n', varname_mean,  sprintf(dformat, meanval));
end
if scale_given
   fprintf(fid, 'static const double %s = %s;\n', varname_scale, sprintf(dformat, scaleval));
end


% some space
if true
   fprintf(fid, '\n');
end


% add horner polynomial evaluator
if addHorner
   fprintf(fid, 'double %s(int degree, const double p[], double x) {\n', funname_horner);
   fprintf(fid, '   double y = p[0];\n');
   fprintf(fid, '   for (int i = 1; i <= degree; ++i)\n');
   fprintf(fid, '      y = x * y + p[i];\n');
   fprintf(fid, '   return y;\n');
   fprintf(fid, '}\n');
   fprintf(fid, '\n');
end


% add evaler
if ~isempty(funname)
   fprintf(fid, 'double %s(double x) {\n', funname_eval); 
  if (mean_given && scale_given)
   fprintf(fid, '   x = (x - %s) / %s;\n', varname_mean, varname_scale);
  elseif (mean_given)
   fprintf(fid, '   x = x - %s;\n', varname_mean);
  elseif (scale_given)
   fprintf(fid, '   x = x / %s;\n', varname_scale);
  end
   fprintf(fid, '   double val = %s(%s-1, %s, x);\n' , funname_polyeval, varname_ncoeffs, varname_coeffs);
   fprintf(fid, '   return val;\n');
   fprintf(fid, '}\n');
   fprintf(fid, '\n');
end


% close extern "C" block if added
if addExternC
   fprintf(fid, '#ifdef __cplusplus\n');
   fprintf(fid, '} // extern "C" block\n');
   fprintf(fid, '#endif\n');
   fprintf(fid, '\n');
end


% namespace close
if ~isempty(namespace)
   fprintf(fid, '\n} // local block or namespace %s\n', namespace);
   fprintf(fid, '\n');
end



% close output file
if (closefile)
   fclose(fid);
   messageprinter('Wrote file %s.\n', outfile);
else
   messageprinter('NOTE: fid specified, not closing file.\n');
end


% warn if there are arguments left
olWarnIfNotEmpty(args, false, sprintf('%s::unknown-arguments', mfilename()));


end