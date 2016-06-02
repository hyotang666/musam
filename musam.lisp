(in-package :cl-user)
(defpackage :musam(:use :cl :alexandria :named-readtables)
  (:export
    #:enable
    #:|#`reader|
    #:*anaphora-marker*

    ;;;; readtable
    #:syntax
    ))
(in-package :musam)

(eval-when(:compile-toplevel :load-toplevel)
  (defun doc (system namestring)
    (uiop:read-file-string
      (uiop:subpathname(asdf:system-source-directory(asdf:find-system system))
	namestring))))

(defmacro enable()
  #.(doc :musam "doc/enable.M.md")
  (let((var(gensym "IT")))
    `(EVAL-WHEN(:COMPILE-TOPLEVEL :LOAD-TOPLEVEL :EXECUTE)
       (LET((,var(GET-DISPATCH-MACRO-CHARACTER #\# #\`)))
	 (IF ,var ; somebody use it.
	   (IF (EQ '|#`reader| (MILLET:FUNCTION-NAME ,var)) ; its me!
	     #0=(SET-DISPATCH-MACRO-CHARACTER #\# #\` #'|#`reader|)
	     (RESTART-CASE(ERROR"Dispatch macro #` is used. ~S",var)
	       (REPLACE()#0#)))
	 #0#)))))

(defparameter *anaphora-marker* #\$
  #.(doc :musam "doc/Aanaphora-markerA.V.md"))

(defun |#`reader|(stream character number)
  #.(doc :musam "doc/#`reader.F.md")
  (declare(ignore character number))
  (let((char(let((temp(read-char stream t t t)))
	      (if(char= #\( temp)
		(progn(unread-char temp stream) *anaphora-marker*)
		temp)))
       (form(read stream t t nil)))
    `(LAMBDA,(lambda-list form char)
       ,form)))

(defun lambda-list(form char)
  (remove-duplicates(anaphoric-symbols (flatten form)
				       char)
    :from-end t))

(defun anaphoric-symbols(list char)
  (loop :for elt :in list
	:when(anaphoric-symbolp elt char)
	:collect elt))

(defun anaphoric-symbolp(arg char)
  (and (symbolp arg)
       (char= char (char(symbol-name arg)0))))

(defreadtable syntax
  (:merge :standard)
  (:dispatch-macro-char #\# #\` #'|#`reader|))
