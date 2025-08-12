# mmtools - Miscellaneous Matlab Tools

A collection of free and open source Matlab tools.

Andreas Sommer, 2010-2024  
E-Mail: code@andreas-sommer.eu  

&nbsp;

### **IMPORTANT**:  Mathworks File Exchange renders Github links in a wrong way (August 2024).  
[**--> Open this README on Github <--**](https://github.com/andreassommer/mmtools/?tab=readme-ov-file#readme)  



# List of Tools

Tools marked with ⭐ might be especially worth a look.  

* [ADLER32](#ADLER32)           - Compute Adler32 hash                                      [[->code]](/ADLER32.m)
* [condSet](#condSet)           - Conditionally set values in (cell) array/matrix/vector    [[->code]](/condSet.m)
* [DEBUGME](#DEBUGME)           - Debug marker/helper for changed values                    [[->code]](/DEBUGME.m)
* [execWSL](#execWSL)           - Execute command in WSL (Windows Subsystem for Linux)      [[->code]](/execWSL.m)
* [filecopy](#filecopy)         - Copy individual files                                     [[->code]](/filecopy.m)
* [findfield](#findfield)       - Find field in struct by regular expressions               [[->code]](/findfield.m)
* [findFirstGreater](#findFirstGreater)  - Finds first array entry greater than given value [[->code]](/findFirstGreater.m)
* [getCaller](#getCaller)       - Retrieve calling function, file, line number              [[->code]](/getCaller.m)
* [getParentFigure](#getParentFigure)           - Retrieve figure containing given handle   [[->code]](/getCaller.m)
* [getWorkspaceVariable](#getWorkspaceVariable) - Retrieve variable from other workspace    [[->code]](/getWorkspaceVariable.m)
* [hornereval](#hornereval)     - Evaluate 1d polynomial using Horner's scheme              [[->code]](/hornereval.m)
* [hornereval2D](#hornereval2D) - Evaluate 2d polynomial using Horner's scheme              [[->code]](/hornereval2D.m)
* [integrate_with_restarts⭐](#integrate_with_restarts) - Integrade implicitly switched ODE with state jumps [[->code]](/integrate_with_restarts.m)
* [isfigure](#isfigure)         - Check if variable is handle to a figure                   [[->code]](/isfigure.m)
* [istext](#istext)             - Check if variable is a char array or a string             [[->code]](/istext.m)
* [makeClosure](#makeClosure)   - Mimick pass-by-reference via closure                      [[->code]](/makeClosure.m)
* [makeMessage](#makeMessage)   - Message generating with preponed Caller                   [[->code]](/makeMessage.m)
* [msession⭐](#msession)       - Store and retrieve Matlab sessions (open files, work space variables, etc.) [[->code]](/msession.m)
* [optionlists⭐](#optionlists) - Handle name-value pairs                                   [[->code]](/olGetOption.m)
* [pointpicker](#pointpicker)   - Pick and collect coordinates by clicking in figure        [[->code]](/pointpicker.m)
* [roundto](#roundto)           - Rounds values to nearest divisor value                    [[->code]](/roundto.m)
* [stopOnKeyPress](#stopOnKeyPress)   - displays a stop figure that reacts on key press     [[->code]](/stopOnKeyPress.m)
* [sviz](#sviz)                       - Simple visualizer                                         [[->code]](/sviz.m)
* [whichToolboxFor](#whichToolboxFor) - Investigate toolbox dependency of code              [[->code]](/whichToolboxFor.m)

Documentation is provided inside the code and thus available using Matlab's help system via `help` and `doc`.



---
---



<a name="ADLER32"></a>
<a id="ADLER32"></a>
## ADLER32   [[see code]](/ADLER32.m)

Computes the Adler32 hash of a given char array.

[Return to list of tools](#list-of-tools)



<a name="condSet"></a>
<a id="condSet"></a>
## condSet   [[see code]](/condSet.m)

Conditionally sets values in (cell) array/matrix/vector.
Can also evaluate function on the elements of a given (cell) array/matrix/vector at places where 
the specified condition is true or false.

```matlab
% EXAMPLE CALLS:
M = magic(5); R = -rand(5);         % matrices for testing
z = condSet(M>10, 1, 5)             % --> matrix of size(M) with 1 where M>10, and 5 otherwise
z = condSet(M>10, 1, 5, {})         % --> cell array of size(M) with 1 where M>10, and 5 otherwise
z = condSet(M>10, '2BIG')           % --> cell array of size(M) with '2BIG' where M>10
z = condSet(M>10, 10, M)            % --> copy of M with value 10 where M>10
z = condSet(M>10, @(x) x^2, -1, M)  % --> copy of M with squared entries where M>10, and -1 otherwise
z = condSet(M>10, R, {}, M)         % --> copy of M with values from R where M>10
```

[Return to list of tools](#list-of-tools)



<a name="DEBUGME"></a>
<a id="DEBUGME"></a>
## DEBUGME   [[see code]](/DEBUGME.m)

Debug helper for changed valued. It transparently returns the new value while displaying as message about that.  
The message can be freely configurated. Helpful to not forget to undo test changes.  
`var = sin(x + 0.5); `  -- original code to be modified  
`var = sin(x + DEBUGME(1.5)); ` -- delivers value 1.5 and displays  standard debug marker message  
`var = sin(x + DEBUGME(1.5, 'SIN offset changed to %g')); ` -- delivers 1.5 and displays individual message

Special command initiated with `#` allow configuration of debug output.
- The printer for the debug message can be chosen via special command `#printer` and set to any function handle
  that can parse fprintf like input, e.g. `@fprintf` or `@warning`
- Quick reset can be done using special command `#reset`
- See code for details.

[Return to list of tools](#list-of-tools)



<a name="execWSL"></a>
<a id="execWSL"></a>
## execWSL   [[see code]](/execWSL.m)

Executes a command in WSL (Windows Subsystem for Linux).  
Distribution can be chosen. Dryrun and echoing supported.

[Return to list of tools](#list-of-tools)



<a name="filecopy"></a>
<a id="filecopy"></a>
## filecopy   [[see code]](/filecopy.m)

Copy individual files in an operating system independent way.
In contrast to Matlab's copyfile(), this filecopy() does not transfer permissions from the source
but creates the destination file with the current user's permission set.

[Return to list of tools](#list-of-tools)



<a name="findfield"></a>
<a id="findfield"></a>
## findfield   [[see code]](/findfield.m)

In a struct with many (several hundreds) of fields, finding the correct field name can be cumbersome.
The findfield() function allows to search for fieldnames by string patters or regular expressions,
and also provides information if an exact match is found.

[Return to list of tools](#list-of-tools)



<a name="findFirstGreater"></a>
<a id="findFirstGreater"></a>
## findFirstGreater   [[see code]](/findFirstGreater.m)

Firns first entry in array that is greater than a specified value.
Optionally starts search at given index.

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



<a name="getCaller"></a>
<a id="getCaller"></a>
## getCaller   [[see code]](/getCaller.m)

Retrieve calling function, optionally with file name and line number.
Relies on Matlab's dbstack.

[Return to list of tools](#list-of-tools)



<a name="getParentFigure"></a>
<a id="getParentFigure"></a>
## getParentFigure   [[see code]](/getParentFigure.m)

Retrieve the handle of the figure that contains the specified graphics handle.

[Return to list of tools](#list-of-tools)



<a name="getWorkspaceVariable"></a>
<a id="getWorkspaceVariable"></a>
## getWorkspaceVariable   [[see code]](/getWorkspaceVariable.m)

Retrieve a variable from other workspace (base or caller), with optional not-found value and error signaling capability.

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



<a name="makeMessage"></a>
<a id="makeMessage"></a>
## makeMessage   [[see code]](/makeMessage.m)

Display or generate message and prepone the calling function. 
makeMessage is a wrapper around Matlab's *printf functions, but accepts also other
printer functions that follow the sprintf or fprintf API.

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
  - querying arguments by name:       `olGetOption`
  - checking for present arguments:   `olHasOption`
  - generation of option lists:       `olSetOption`
  - removing from option lists:       `olRemoveOption`
  - rename existing options:          `olRenameOption`
  - checking validity:                `olIsOptionlist`
  - checking validity with assertion: `olAssertOptionlist` 
  - retrieving list of all names:     `olCollectOptionNames`
  - retrieving list of all values:    `olCollectOptionValues`
  - warn upon unprocessed arguments:  `olWarnIfNotEmpty`

### Documentation

For details, see, `help olGetOption`, etc.

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
    if olHasOption(varargin, 'age'    ),     age = olGetOption(varargin, 'age'    );  end
    if olHasOption(varargin, 'numbers'), numbers = olGetOption(varargin, 'numbers');  end

    % Alternatively, default arguments can be specified in olGetOption directly if key is not found:
    name = olGetOption(varargin, 'name', '[UNKNOWN-PERSON]');
   
    % Program code 
    % ...
end    
```
The syntax `[value, remainingOptions] = olGetOption(options, key)` can be used to remove `key`
from the optionlist. This is useful to check if there are some options left after processing
using `olWarnIfNotEmpty`.

[Return to list of tools](#list-of-tools)




<a id="pointpicker"></a>
<a name="pointpicker"></a>
## pointpicker   [[see code]](/pointpicker.m)

This tool is intended to collect point coordinated from a matlab figure, and pick and collect points by clicking.
Register to the current axis using `pointpicker(gca())`.

The pointpicker may be registered to multiple figures/axes, but only collects points from the currently active one.
By pressing key 'a' while in the registered axis, the mouse changes to a crosshairs and multiple points can be collected;
the last one picked can be deleted by pressing 'd'. Collection is ended by pressing 'x'.
Collected points may be retrieved into a variable by `points = pointpicker('#GET')` or saved to file.

[Return to list of tools](#list-of-tools)




<a id="roundto"></a>
<a name="roundto"></a>
## roundto   [[see code]](/roundto.m)

Rounds values to the nearest divisor value.
See roundto_example.m for an example.

[Return to list of tools](#list-of-tools)




<a name="stopOnKeyPress"></a>
<a id="stopOnKeyPress"></a>
# stopOnKeyPress   [[see code]](/stopOnKeyPress.m)

Opens a figure that listens to key pressed and checks if a stop key is hit.
The figure can also display a message, some progress information, or an updating counter.
See the code for a detailed usage with example.

[Return to list of tools](#list-of-tools)




<a name="sviz"></a>
<a id="sviz"></a>
# sviz   [[see code]](/sviz.m)

Simple visualization tool. 

[Return to list of tools](#list-of-tools)




<a name="whichToolboxFor"></a>
<a id="whichToolboxFor"></a>
## whichToolboxFor   [[see code]](/whichToolboxFor.m)

Retrieves the required Matlab Toolboxes for specified mfile.
Also inspects all files invoked by mfile and checks their dependency.
Additionaly prints for every used toolbox the list of files that actually require them.

[Return to list of tools](#list-of-tools)
