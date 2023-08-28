(defpackage #:woo-repro
  (:use #:cl)
  (:export #:main))
(in-package #:woo-repro)

(defun main ()
  (woo.response::current-rfc-1123-timestamp))
