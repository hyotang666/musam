; vim: ft=lisp et
(in-package :asdf)
(defsystem :musam.test :depends-on (:jingoh "musam") :components
 ((:file "musam")) :perform
 (test-op (o c) (symbol-call :jingoh :examine)))
