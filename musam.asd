; vim: ft=lisp et
(in-package :asdf)
(defsystem :musam
  :description "Shorthand for LAMBDA."
  :long-description #.(uiop:read-file-string
                        (uiop:subpathname *load-pathname* "README.md"))
  :author "Shinich Sato"
  :depends-on
  (
   "named-readtables"   ; manage readtables.
   "millet"             ; wrapper for implementation dependent utilities.
   "trestrul"           ; utilities for tree structured list.
   )
  :license "MIT"
  :components((:file "musam")))

(defmethod component-depends-on ((o test-op) (c (eql (find-system "musam"))))
  (append (call-next-method)'((test-op "musam.test"))))
