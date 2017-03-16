# MUSAM - Shorthand for LAMBDA.

* Current lisp world
Lisp has strong first class function.

* Issues
LAMBDA is too mach long.

* Proposal
We can customize reader macro.
How about to use `#\``?

## Usage
```lisp
'#`(print $arg)
=> (LAMBDA ($ARG) (PRINT $ARG))
```

## From developer

* Product's goal - maybe already?
* License - public domain
* Developped with - CLISP
* Tested with - SBCL CCL ECL

