# mmtools - Miscellaneous Matlab Tools

(c) Andreas Sommer, 2016
    code@andreas-sommer.eu


# roundto

Rounds values to the nearest divisor value.
See roundto_example.m for an example.



# ADLER32

Commputes the Adler32 hash of a given char array.



# hornereval, hornereval2D

Evaluation of 1d and 2d polynomials using Horner's scheme.



# isfigure

Queries if specified handle refers to a (valid) figure.



# istext

Checks if specified object is a char array or a string



# makeClosure

Generates a closure to mimick pass-by-reference style of programming.



# svis

Simple viszalization tool.



# msession

Stores a whole Matlab work session in a file, and restores it upon request.
The user can select what to be stored:
  - open files
  - main work space variables
  - global variables



# optionlists

Matlab tools for handling name-value pairs in function calls:
  - querying arguments by name:     `olGetOption`
  - checking for present arguments: `olHasOption`
  - generation of option lists:     `olSetOption`
  - removing from option lists:     `olRemoveOption`
  - checking validity:              `olIsOptionlist`, `olAssertOptionlist` 

## Documentation

Documentation is provided inside the code and thus available using Matlab's help system via `help` and `doc`, e.g. `help getOption`.


## Example

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
