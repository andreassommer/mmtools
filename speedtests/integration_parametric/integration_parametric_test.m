% This script tests diverse methods for parametric integration in Matlab.
%
% Variants - see code
%
%
% Andreas Sommer, 2023
% code@andreas-sommer.eu
%


% integrator settings
integrator = @ode23;  options = odeset('RelTol', 1e-08, 'AbsTol', 1e-14);  % lots of function evaluations (more @-overhead)
%integrator = @ode45;  options = odeset('RelTol', 1e-12, 'AbsTol', 1e-14);  % fewer function evaluations (less @-overhead)
%integrator = @ode15s;  options = odeset('RelTol', 1e-08, 'AbsTol', 1e-14); %

t0 = 0;
tf = 1;
x0 = [1, 1, 1];

% for time measurements: repetitions
repetitions = 100;

% value generator:
% rng(123); fprintf('%g  ',round(5*(randn(1,15)-0.5),2))

% parameter vector and cell array - DO NOT CHANGE!           MUST BE SAME AS IN RHS_HARDCODED !!
paramVECTOR = [-7.95  -2.34  0.26  3  5.22  -2.07  -9.96  -6.21  -7.81  9.25  -5.58  1.24  -3.46  1.94  -6.32];
paramCELL   = num2cell(paramVECTOR);

% transfer to individual variables
[a1, a2, a3, a4, a5, b1, b2, b3, b4, b5, c1, c2, c3, c4, c5] = deal(paramCELL{:});

% transfer to struct
paramSTRUCT = struct('a1',a1,'a2',a2,'a3',a3,'a4',a4,'a5',a5, ...
                     'b1',b1,'b2',b2,'b3',b3,'b4',b4,'b5',b5, ...
                     'c1',c1,'c2',c2,'c3',c3,'c4',c4,'c5',c5);

% create handle class 
paramCLASS  = integration_parametric_dataclass(a1,a2,a3,a4,a5,b1,b2,b3,b4,b5,c1,c2,c3,c4,c5);

% globalize variables (copy them, to avoid clashes)
global ga1 ga2 ga3 ga4 ga5 gb1 gb2 gb3 gb4 gb5 gc1 gc2 gc3 gc4 gc5 
global gparamVECTOR gparamSTRUCT gparamCLASS
gparamVECTOR = paramVECTOR;
gparamSTRUCT = paramSTRUCT;
gparamCLASS  = integration_parametric_dataclass(a1,a2,a3,a4,a5,b1,b2,b3,b4,b5,c1,c2,c3,c4,c5);
[ga1,ga2,ga3,ga4,ga5,gb1,gb2,gb3,gb4,gb5,gc1,gc2,gc3,gc4,gc5] = deal(a1,a2,a3,a4,a5,b1,b2,b3,b4,b5,c1,c2,c3,c4,c5);

% stored anonymous functions -> signature @(t,x) explicitly known!
rhs_hardcoded_direct_stor    = @(t,x) integration_parametric_rhs_hardcoded_direct(t,x);
rhs_param_single_class_stor  = @(t,x) integration_parametric_rhs_param_single_structORclass(t,x,paramCLASS);
rhs_param_single_struct_stor = @(t,x) integration_parametric_rhs_param_single_structORclass(t,x,paramSTRUCT);
rhs_persistent_single_stor   = @(t,x) integration_parametric_rhs_persistent_single(t,x);

% preparations
variants = {};
rhs      = {};
                   
% standard variants
variants{end+1} = 'HARDCODED-NAMED';           rhs{end+1} = @integration_parametric_rhs_hardcoded_named;
variants{end+1} = 'HARDCODED-NAMED-@';         rhs{end+1} = @(t,x) integration_parametric_rhs_hardcoded_named(t,x);
variants{end+1} = 'HARDCODED-DIRECT';          rhs{end+1} = @integration_parametric_rhs_hardcoded_direct;
variants{end+1} = 'HARDCODED-DIRECT-@';        rhs{end+1} = @(t,x) integration_parametric_rhs_hardcoded_named(t,x);
variants{end+1} = 'HARDCODED-DIRECT-@STOR';    rhs{end+1} = rhs_hardcoded_direct_stor;
variants{end+1} = 'PARAM-MULTI-@';             rhs{end+1} = @(t,x) integration_parametric_rhs_param_multi(t,x,a1,a2,a3,a4,a5,b1,b2,b3,b4,b5,c1,c2,c3,c4,c5);
variants{end+1} = 'PARAM-SINGLE-VECTOR-@';     rhs{end+1} = @(t,x) integration_parametric_rhs_param_single_vector(t,x,paramVECTOR);
variants{end+1} = 'PARAM-SINGLE-CLASS-@';      rhs{end+1} = @(t,x) integration_parametric_rhs_param_single_structORclass(t,x,paramCLASS);
variants{end+1} = 'PARAM-SINGLE-CLASS-@STOR';  rhs{end+1} = rhs_param_single_class_stor;
variants{end+1} = 'PARAM-SINGLE-STRUCT-@';     rhs{end+1} = @(t,x) integration_parametric_rhs_param_single_structORclass(t,x,paramSTRUCT);
variants{end+1} = 'PARAM-SINGLE-STRUCT-@STOR'; rhs{end+1} = rhs_param_single_struct_stor;
variants{end+1} = 'GLOBAL-SINGLE';             rhs{end+1} = @integration_parametric_rhs_global_single;
variants{end+1} = 'GLOBAL-SINGLE-@';           rhs{end+1} = @(t,x) integration_parametric_rhs_global_single(t,x);
variants{end+1} = 'GLOBAL-MULTI';              rhs{end+1} = @integration_parametric_rhs_global_multi;   % VERY SLOW!!!
variants{end+1} = 'GLOBAL-MULTI-@';            rhs{end+1} = @(t,x) integration_parametric_rhs_global_multi(t,x);   % VERY SLOW!!!
variants{end+1} = 'GLOBAL-STRUCT';             rhs{end+1} = @integration_parametric_rhs_global_struct;
variants{end+1} = 'GLOBAL-STRUCT-@';           rhs{end+1} = @(t,x) integration_parametric_rhs_global_struct(t,x);
variants{end+1} = 'GLOBAL-CLASS';              rhs{end+1} = @integration_parametric_rhs_global_class;
variants{end+1} = 'GLOBAL-CLASS-@';            rhs{end+1} = @(t,x) integration_parametric_rhs_global_class(t,x);

% more fancy
integration_parametric_rhs_persistent_multi('init', paramVECTOR);  % initialize persistent values
variants{end+1} = 'PERSISTENT-MULTI';          rhs{end+1} = @integration_parametric_rhs_persistent_multi;
variants{end+1} = 'PERSISTENT-MULTI-@';        rhs{end+1} = @(t,x) integration_parametric_rhs_persistent_multi(t,x);
integration_parametric_rhs_persistent_single('init', paramVECTOR);  % initialize persistent values
variants{end+1} = 'PERSISTENT-SINGLE';         rhs{end+1} = @integration_parametric_rhs_persistent_single;
variants{end+1} = 'PERSISTENT-SINGLE-@';       rhs{end+1} = @(t,x) integration_parametric_rhs_persistent_single(t,x);
variants{end+1} = 'PERSISTENT-SINGLE-@STOR';   rhs{end+1} = rhs_persistent_single_stor;


% list all variants (for easy selection)
%fprintf('Listing variants:\n');
%for i = 1:length(variants)
%   fprintf('Variant #%2d: %s \n', i, variants{i});
%end
%fprintf('\n');

% selection of variants
selected = 1:length(variants);
excluded = {};
%excluded = {'GLOBAL'};
%excluded = {'GLOBAL','PARAM','MULTI','@STOR'};
%excluded = {'GLOBAL', 'STRUCT', 'CLASS'};
silentexclude = true;



% run through variants
clear results;
for i = 1:length(variants)
   if ~ismember(i, selected) || contains(variants{i}, excluded)
      if ~silentexclude
         fprintf('\nVariant #%2d: %-25s  -- SKIPPED', i, variants{i});
      end
      continue
   end
   fprintf('\nVariant #%2d: %-25s  ', i, variants{i});
   results(i) = doTest(variants{i}, rhs{i}, repetitions, x0, t0, tf, integrator, options); %#ok<SAGROW>
   fprintf('  mean time: %8.5f   ',   mean(results(i).times));
   fprintf('  median time: %8.5f   ', median(results(i).times));
   % evaluate solution once and cross-check compare to solution (all solutions must be idential!)
   if ~( all(results(i).sol.x == results(1).sol.x)  &&  all(results(i).sol.y == results(1).sol.y, 'all') )
      fprintf('  --> ERROR! Solution not identica!. Coding problem?\n');
   end
end

% evaluate results
% for i = 1:length(results)
%    fprintf('\n');
%    fprintf('Variant #%2d: %s \n', i, results(i).variant);
%    fprintf('  mean time: %g \n',   mean(results(i).times));
%    fprintf('median time: %g \n', median(results(i).times));
%    % evaluate solution once and cross-check compare to solution (all solutions must be idential!)
%    if ~( all(results(i).sol.x == results(1).sol.x)  &&  all(results(i).sol.y == results(1).sol.y, 'all') )
%       fprintf('  --> ERROR! Solution not identica!. Coding problem?');
%    end
% end

% finito
fprintf('\n');
return




% HELPERS


% execute simulation test
function result = doTest(variant, rhs, rounds, x0, t0, tf, integrator, options)
   result.variant = variant;
   result.times = zeros(1, rounds);
   for k = 1:rounds
      tic();
      sol = integrator(rhs, [t0 tf], x0, options);
      result.times(k) = toc();
   end
   result.sol = sol;  
end



