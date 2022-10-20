;;;; loremizer.asd

(defsystem #:loremizer
  :author "John Q. Splittist <splittist@splittist.com>"
  :maintainer "John Q. Splittist <splittist@splittist.com>"
  :version "0.1"
  :homepage "https://github.com/splittist/loremizer"
  :bug-tracker "https://github.com/splittist/lorermizer/issues"
  :source-control (:git "git@github.com:splittist/loremizer.git")
  :description "Replace text in Microsoft Word documents with lorem ipsum text"
  :depends-on (#:docxplora
	       #:alexandria
	       #:cl-ppcre)
  :serial t
  :components ((:file "package.lisp")
	       (:file "loremizer.lisp")))
