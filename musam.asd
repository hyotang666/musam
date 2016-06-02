; vim: ft=lisp et
(in-package :asdf)
(defsystem :musam
  :in-order-to((test-op(test-op :musam-test)))
  :depends-on (:alexandria :named-readtables :millet)
  :components((:file "musam")))

(defsystem :musam-test
  :depends-on(:jingoh)
  :components ((:file "design"))
  :perform(test-op(o c)
            (uiop:symbol-call :jingoh 'report)))
