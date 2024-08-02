# mmtools - Miscellaneous Matlab Tools

A collection of free and open source Matlab tools.

Andreas Sommer, 2010-2024  
E-Mail: code@andreas-sommer.eu  

&nbsp;

### **IMPORTANT**:  Mathworks File Exchange renders Github links in a wrong way (August 2024).  
[**--> Open this README on Github <--**](https://github.com/andreassommer/mmtools/blob/main/README.md)  



# List of Tools

Tools marked with ⭐ might be especially worth a look.  

* [ADLER32](#adler32)           - Compute Adler32 hash                                   [[->code]](/ADLER32.m)
* [execWSL](#execWSL)           - Execute command in WSL (Windows Subsystem for Linux)   [[->code]](/execWSL.m)
* [hornereval](#hornereval)     - Evaluate 1d polynomial using Horner's scheme           [[->code]](/hornereval.m)
* [hornereval2D](#hornereval2D) - Evaluate 2d polynomial using Horner's scheme           [[->code]](/hornereval2D.m)
* [integrate_with_restarts⭐](#integrate_with_restarts) - Integrade implicitly switched ODE with state jumps [[->code]](/integrate_with_restarts.m)
* [isfigure](#isfigure)         - Check if variable is handle to a figure                [[->code]](/isfigure.m)
* [istext](#istext)             - Check if variable is a char array or a string          [[->code]](/istext.m)
* [makeClosure](#makeClosure)   - Mimick pass-by-reference via closure                   [[->code]](/makeClosure.m)
* [msession⭐](#msession)       - Store and retrieve Matlab sessions (open files, work space variables, etc.) [[->code]](/msession.m)
* [optionlists⭐](#optionlists) - Handle name-value pairs                                [[->code]](/olGetOption.m)
* [roundto](#roundto)           - Rounds values to nearest divisor value                 [[->code]](/roundto.m)
* [sviz](#sviz)                 - Simple visualizer                                      [[->code]](/sviz.m)
* [whichToolboxFor](#whichToolboxFor) - Investigate toolbox dependency of code           [[->code]](/whichToolboxFor.m)

Documentation is provided inside the code and thus available using Matlab's help system via `help` and `doc`.



---
---



<a name="adler32"></a>
<a id="adler32"></a>
## ADLER32   [[see code]](/ADLER32.m)

Computes the Adler32 hash of a given char array.

[Return to list of tools](#list-of-tools)



<a name="execWSL"></a>
<a id="execWSL"></a>
## execWSL   [[see code]](/execWSL.m)

Executes a command in WSL (Windows Subsystem for Linux).  
Distribution can be chosen. Dryrun and echoing supported.

[Return to list of tools](#list-of-tools)



<a name="hornereval"></a>
<a id="hornereval"></a>
## hornereval   [[see code]](/hornereval.m)

Evaluation of 1d polynomials using Horner's scheme.

[Return to list of tools](#list-of-tools)


<a name="hornereval2D"></a>
<a id="hornereval2D"></a>
## hornereval2D   [[see code]](/hornereval2D.m)

Evaluation of 2d polynomials using Horner's scheme.

[Return to list of tools](#list-of-tools)



<a name="integrate_with_restarts"></a>
<a id="integrate_with_restarts"></a>
## integrate_with_restarts⭐   [[see code]](/integrate_with_restarts.m)

A Matlab tool for integration of switched ODEs, with implicit (state-dependent) model and state changes.  
Only integration is supported.  
The tool [*IFDIFF*](https://andreassommer.github.io/ifdiff/) is much more sophisticated. 
It generates switching functions automatically from existing code with IF statements and can also compute forward sensitivities.

[Return to list of tools](#list-of-tools)



<a name="isfigure"></a>
<a id="isfigure"></a>
## isfigure   [[see code]](/isfigure.m)

Queries if specified handle refers to a (valid) figure.

[Return to list of tools](#list-of-tools)



<a name="istext"></a>
<a id="istext"></a>
## istext   [[see code]](/istext.m)

Checks if specified object is a char array or a string

[Return to list of tools](#list-of-tools)



<a name="makeClosure"></a>
<a id="makeClosure"></a>
## makeClosure   [[see code]](/makeClosure.m)

Generates a closure to mimick pass-by-reference style of programming.

[Return to list of tools](#list-of-tools)




<a name="msession"></a>
<a id="msession"></a>
# msession⭐   [[see code]](/msession.m)

Stores a whole Matlab work session in a file, and restores it upon request.
The user can select what to be stored:
  - open files
  - main work space variables
  - global variables

[Return to list of tools](#list-of-tools)




<a id="optionlists"></a>
<a name="optionlists"></a>
# optionlists⭐   [[see code]](/olGetOption.m)

Matlab tools for handling name-value pairs, especially in function calls.
  - querying arguments by name:     `olGetOption`
  - checking for present arguments: `olHasOption`
  - generation of option lists:     `olSetOption`
  - removing from option lists:     `olRemoveOption`
  - checking validity:              `olIsOptionlist`, `olAssertOptionlist` 

### Documentation

For details, see, `help olGetOption`.

### Example

Call: 
```matlab 
  val = f(a,b,'name','test','age',35,'numbers',{1,7,2})
```

Function code:
```matlab
function val = f(a,b,varargin)
    % a and b are normal position-dependent arguments.
    % Further arguments are (usually) optional and initialized by default values.
  
    % Set default values
    name    = 'defaultname';
    age     = 0;
    numbers = {1,2,3,4,5};
    
    % Query optional arguments:
    if olHasOption(varargin, 'name'   ),    name = olGetOption(varargin, 'name'   );  end
    if olHasOption(varargin, 'age'    ),     age = olGetOption(varargin, 'age'    );  end
    if olHasOption(varargin, 'numbers'), numbers = olGetOption(varargin, 'numbers');  end
    
    % program code 
    % ...
end    
``` 

[Return to list of tools](#list-of-tools)




<a id="roundto"></a>
<a name="roundto"></a>
## roundto   [[see code]](/roundto.m)

Rounds values to the nearest divisor value.
See roundto_example.m for an example.

[Return to list of tools](#list-of-tools)




<a name="sviz"></a>
<a id="sviz"></a>
# sviz   [[see code]](/sviz.m)

Simple viszalization tool.

[Return to list of tools](#list-of-tools)




<a name="whichToolboxFor"></a>
<a id="whichToolboxFor"></a>
## whichToolboxFor   [[see code]](/whichToolboxFor.m)

Retrieves the required Matlab Toolboxes for specified mfile.
Also inspects all files invoked by mfile and checks their dependency.
Additionaly prints for every used toolbox the list of files that actually require them.

[Return to list of tools](#list-of-tools)
