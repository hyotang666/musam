(in-package :cl-user)
(defpackage :musam-design(:use :cl :jingoh))
(in-package :musam-design)

(setup :musam)

(musam:enable)

#|
Musam provides #` dispatch macro feature which inspired by LOL.
#` is expanded into lambda form.
|#
#? '#`()
=> (LAMBDA()())
, :test equal

#|
Inside #`, symbol which has #\$ prefix is treated as argument.
|#
#? '#`(print $arg)
=> (LAMBDA($ARG)(PRINT $ARG))
, :test equal

#|
We can use some anaphoric arguments.
But does not support any lambda list keyword.
|#
#? '#`(+ $0 $1 $2)
=> (LAMBDA($0 $1 $2)(+ $0 $1 $2))
, :test equal

#|
NOTE! - anaphric symbol's order is not able to bespecified.
just founded order.
|#
#? (funcall #`(+ $1 (parse-integer $0)) "1" 1)
:signals error
, :lazy t

#|
In such case, you need to binds.
|#
#?(funcall #`(let((a0 $1)
		  (a1 $0))
	       (+ a1 (parse-integer a0)))
	   "1" 1)
=> 2

#|
anaphoric mark #\$ is popular to represents something.
It may conflicts.
In such case, we can specify another mark character.
|#
#? '#`@(print @it)
=> (LAMBDA(@IT)(PRINT @IT))
, :test equal
, :ignore-warning T
, :lazy T

#|
The feature above is very flexible.
But it becomes a probrem espcially when you specify atom as body.
|#
#? (let((it 0))
      (declare(ignore it))
      '#`it)
=> (LAMBDA()T)
, :test equal
, :ignore-warning t
, :lazy t

#|
In case above, musam interprets character #\i is marking prefix.
So you need specify dummy marking character.
|#
#? (let((it 0))
      (declare(ignore it))
      '#`$it)
=> (LAMBDA()IT)
, :test equal
, :ignore-warning t
, :lazy t

#|
The character #\( is only treated as special.
So you can use any other characters as marker, even if it is macro character.
But anaphric marking must be prefix of symbol-name.
|#
#? '#`'(print 'arg) ; bad case
=> (LAMBDA()(PRINT 'ARG))
, :test equal

#? '#`'(print |'arg|) ; good case
=> (LAMBDA(|'arg|)(PRINT |'arg|))
, :test equal

#|
NOTE! - You should not use backquote with MUSAM.
Because it is not portable, especially SBCL.
|#
#? '#`$`((,$arg)) => #.implementation-dependent
;; may be (lambda($arg)`((,$arg)))
;; but in sbcl (lambda()`((,$arg)))

#|
NOTE! - when nested musam is confused.
|#
#? '#`(string= "foo" (remove-if #`(find $c "abc") $arg))
=> (LAMBDA ($C $ARG) ; <= causes error.
     (STRING= "foo" (REMOVE-IF (LAMBDA ($C) (FIND $C "abc")) $ARG)))
, :test equal

#|
In such case, you need to specify another anaphoric maker.
|#
#? '#`(string= "foo" (remove-if #`@(find @c "abc") $arg))
=> (LAMBDA($ARG) ; <= good.
     (STRING= "foo" (REMOVE-IF (LAMBDA(@C)(FIND @C "abc")) $ARG)))
, :test equal
