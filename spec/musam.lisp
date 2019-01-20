(defpackage :musam.spec (:use :cl :jingoh :musam)
  (:shadowing-import-from :musam #:enable #:syntax))
(in-package :musam.spec)
(setup :musam)

(requirements-about ENABLE :around (let((*readtable*(copy-readtable nil)))
				     (call-body)))

;;;; Description:
; Enable dispatch macro `#\``.
#?(values (get-dispatch-macro-character #\# #\`)
	  (enable)
	  (get-dispatch-macro-character #\# #\`))
:multiple-value-satisfies
#`(& (null $1)
     (not(null $2))
     (not(null $3)))

#+syntax
(ENABLE) ; => result

;;;; Arguments and Values:

; result := implementation dependent.
#?(enable) => implementation-dependent

;;;; Affected By:
; none

;;;; Side-Effects:
; Modify `*readtable*` state.

;;;; Notes:

;;;; Exceptional-Situations:

(requirements-about |#`reader|
		    :around (let((*readtable* (copy-readtable nil)))
			      (enable)
			      (call-body))
		    :test equal)

;;;; Description:
; reader for "#`" printed notation.

#+syntax
(|#`reader| stream character number) ; => result

;;;; Arguments and Values:

; stream := file input stream.

; character := character
; ignored.

; number := (or null (integer 0 *))
; ignored.

; result := lisp form.

;;;; Affected By:
; stream contents.

;;;; Side-Effects:
; Consume stream contents.

;;;; Notes:

;;;; Exceptional-Situations:

;;;; Example:
;;; standard usage.
; "#`" expanded to lambda form.
#?(read-from-string "#`(print :hoge)")
=> (LAMBDA()(PRINT :HOGE))

; The variable which starts "$" is treated lambda argument, if any.
#?(read-from-string "#`(1+ $1)")
=> (lambda($1)
     (1+ $1))

; $vars are interpreted depth first order.
#?(read-from-string "#`(+ $2 (- $1))")
=> (LAMBDA($2 $1)
     (+ $2 (- $1)))

;;; corner cases.
; You can change argument marker temporarily.
#?(read-from-string "#`&(print &hoge)")
=> (LAMBDA(&HOGE)
     (PRINT &HOGE))

; *note!* - The feature above becomes pitfall especially when you specify atom as body.
#?(read-from-string "(let((it 0))#`it)")
=> (let((it 0))
     (lambda()T))

; in the example above, musam interpret "i" is a marker.
; If you want to specify atom as its body, you need to specify marker too.
#?(read-from-string "(let((it 0))#`$it)")
=> (let((it 0))
     (lambda()it))

; The character #\( is only treated as special. (i.e. never be the marker)
; So you can use any other characters as marker, even if it is macro character.
; But anaphric marking must be prefix of symbol-name.
#?(read-from-string "#`'(print 'hoge)") ; bad example.
=> (lambda()
     (print 'hoge))
#?(read-from-string "#`'(print |'hoge|)") ; good example.
=> (lambda(|'hoge|)
     (print |'hoge|))

; *NOTE!* - when nested musam is confused.
#?(read-from-string "#`(string= \"foo\" (remove-if #`(find $c \"abc\") $arg))")
=> (LAMBDA ($C $ARG) ; <= causes error.
     (STRING= "foo" (REMOVE-IF (LAMBDA ($C) (FIND $C "abc")) $ARG)))

; In such case, you need to specify another marker.
#?(read-from-string
    "#`(string= \"foo\" (remove-if #`@(find @c \"abc\") $arg))")
=> (LAMBDA($ARG) ; <= good.
     (STRING= "foo" (REMOVE-IF (LAMBDA(@C)(FIND @C "abc")) $ARG)))

; *NOTE!* - when use with backquote, you need to specify marker.
#?(read-from-string "#``(,$hoge)") ; bad example
:signals error
; In case above, musam interprets #\` is marker,
; and lisp implementation claims comma outside of backquote is illigal.

#?(read-from-string "#`$`(,$hoge)") ; good example
=> (lambda($hoge)`(,$hoge))
,:test equalp ; <--- override default test (i.e. equal), for sbcl which represents `,$hoge` as structure.

; *NOTE!* - All marked symbol is treated as argument, even if it is quoted.
#?(read-from-string "#`(list '$hoge)") ; bad example
=> (lambda($hoge) ; <--- Causes error.
     (list '$hoge))

; In such case, you need to specify another mark.
#?(read-from-string "#`&(list '$hoge)") ; good example
=> (lambda()
     (list '$hoge))

(requirements-about *ANAPHORA-MARKER*)

;;;; Description:
; Contains character which refered as default anaphora marker.

;;;; Value type is STANDARD-CHAR
#? *ANAPHORA-MARKER* :be-the character

; Initial value is #\$

;;;; Affected By:
; none

;;;; Notes:
