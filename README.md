# mmtools - Miscellaneous Matlab Tools

A collection of free and open source Matlab tools.

(c) Andreas Sommer, 2010-2024  
E-Mail: code@andreas-sommer.eu


# List of Tools

Tools marked with ⭐ might be especially worth a look.  

* [ADLER32](#ADLER32) - Compute Adler32 hash
* [hornereval](#hornereval) - Evaluate 1d polynomial using Horner's scheme
* [hornereval2D](#hornereval2D) - Evaluate 2d polynomial using Horner's scheme
* [integrate_with_restarts⭐](#integrate_with_restarts⭐) - Integrade implicitly switched ODE with state jumps
* [isfigure](#isfigure) - Check if variable is handle to a figure
* [istext](#istext) - Check if variable is a char array or a string
* [makeClosure](/makeClosure) - Mimick pass-by-reference via closure
* [msession⭐](#msession⭐) - Store and retrieve Matlab sessions (open files, work space variables, etc.)
* [optionlists⭐](#optionlists⭐) - Handle name-value pairs
* [roundto](#roundto) - Rounds values to nearest divisor value
* [sviz](#sviz) - Simple visualizer

Documentation is provided inside the code and thus available using Matlab's help system via `help` and `doc`.  



---
---


## ADLER32

Computes the Adler32 hash of a given char array.

[Return to list of tools](#list-of-tools)




## hornereval, hornereval2D

Evaluation of 1d and 2d polynomials using Horner's scheme.

[Return to list of tools](#list-of-tools)




## integrate_with_restarts⭐

A Matlab tool for integration of switched ODEs, with implicit (state-dependent) model and state changes.  
Only integration is supported.  
The tool [*IFDIFF*](https://andreassommer.github.io/ifdiff/) is much more sophisticated. 
It generates switching functions automatically from existing code with IF statements and can also compute forward sensitivities.




## isfigure

Queries if specified handle refers to a (valid) figure.



## istext

Checks if specified object is a char array or a string

[Return to list of tools](#list-of-tools)




## makeClosure

Generates a closure to mimick pass-by-reference style of programming.

[Return to list of tools](#list-of-tools)




# msession⭐

Stores a whole Matlab work session in a file, and restores it upon request.
The user can select what to be stored:
  - open files
  - main work space variables
  - global variables

[Return to list of tools](#list-of-tools)




# optionlists⭐

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




## roundto

Rounds values to the nearest divisor value.
See roundto_example.m for an example.

[Return to list of tools](#list-of-tools)




# svis

Simple viszalization tool.

[Return to list of tools](#list-of-tools)



