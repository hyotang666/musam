(in-package :cl-user)
(defpackage :musam(:use :cl :named-readtables)
  (:import-from :trestrul #:dotree)
  (:export
    #:enable
    #:|#`reader|
    #:*anaphora-marker*

    ;;;; readtable
    #:syntax
    ))
(in-package :musam)

(defmacro enable()
  (let((var(gensym "IT")))
    `(EVAL-WHEN(:COMPILE-TOPLEVEL :LOAD-TOPLEVEL :EXECUTE)
       (LET((,var(GET-DISPATCH-MACRO-CHARACTER #\# #\`)))
	 (IF ,var ; somebody use it.
	   (IF (EQ '|#`reader| (MILLET:FUNCTION-NAME ,var)) ; its me!
	     #0=(SET-DISPATCH-MACRO-CHARACTER #\# #\` #'|#`reader|)
	     (RESTART-CASE(ERROR"Dispatch macro #` is used. ~S",var)
	       (REPLACE()#0#)))
	 #0#)))))

(defparameter *anaphora-marker* #\$)

(defun |#`reader|(stream character number)
  (declare(ignore character number))
  (let((char(let((temp(read-char stream t t t)))
	      (if(char= #\( temp)
		(progn(unread-char temp stream) *anaphora-marker*)
		temp)))
       (form(read stream t t t)))
    `(LAMBDA,(lambda-list form char)
       ,form)))

(defun lambda-list(form char)
  (let(acc)
    (labels((REC(tree)
	      (dotree(v tree)
		(cond
		  #+sbcl
		  ((sb-int:comma-p v) (ENTRY-POINT(sb-int:comma-expr v)))
		  ((ANAPHORIC-SYMBOLP v)(pushnew v acc)))))
	    (ANAPHORIC-SYMBOLP(arg)
	      (and (symbolp arg)
		   (char= char (char(symbol-name arg)0))))
	    (ENTRY-POINT(form)
	      (if(atom form)
		(when(ANAPHORIC-SYMBOLP form)
		  (pushnew form acc))
		(REC form)))
	    )
      (ENTRY-POINT form))
    (nreverse acc)))

(defreadtable syntax
  (:merge :standard)
  (:dispatch-macro-char #\# #\` #'|#`reader|))
