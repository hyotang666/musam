; vim: ft=lisp et
(in-package :asdf)
(defsystem :musam
  :description "Shorthand for LAMBDA."
  :long-description #.(uiop:read-file-string
                        (uiop:subpathname *load-pathname* "README.md"))
  :author "Shinich Sato"
  :depends-on (:named-readtables :millet :trestrul)
  :components((:file "musam")))
;; Perform method below is added by JINGOH.GENERATOR.
(defmethod perform ((o test-op) (c (eql (find-system "musam"))))
 (test-system :musam.test))
