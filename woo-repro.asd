;;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-

(defsystem woo-repro
  :depends-on ("woo")
  :components ((:file "main")))

(defsystem woo-repro/executable
  :build-pathname "bin/woo-repro"
  :entry-point "woo-repro:main"
  :depends-on ("woo-repro"))
