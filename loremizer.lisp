;;;; loremizer.lisp

(in-package #:com.splittist.loremizer)

#|

Standard lorem ipsum text:

"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."

|#

(defparameter *words* #("lorem" "ipsum" "dolor" "sit" "amet" "consectetur" "adipiscing" "elit" "sed"
			"do" "eiusmod" "tempor" "incididunt" "ut" "labore" "et" "dolore" "magna"
			"aliqua" "ut" "enim" "ad" "minim" "veniam" "quis" "nostrud" "exercitation"
			"ullamco" "laboris" "nisi" "ut" "aliquip" "ex" "ea" "commodo" "consequat"
			"duis" "aute" "irure" "dolor" "in" "reprehenderit" "in" "voluptate" "velit"
			"esse" "cillum" "dolore" "eu" "fugiat" "nulla" "pariatur" "excepteur" "sint"
			"occaecat" "cupidatat" "non" "proident" "sunt" "in" "culpa" "qui" "officia"
			"deserunt" "mollit" "anim" "id" "est" "laborum"))

(defparameter *dictionary* (make-hash-table :test #'equal))

(defun match-case (source target)
  (cond ((string= source (string-upcase source))
	 (string-upcase target))
	((string= source (string-capitalize source))
	 (string-capitalize target))
	(t
	 target)))

(defun replace-word (word)
  (alexandria:if-let ((translation (gethash (string-downcase word) *dictionary*)))
    (match-case word translation)
    (let ((translation (aref *words* (random (length *words*)))))
      (setf (gethash (string-downcase word) *dictionary*) translation)
      (match-case word translation))))

(defparameter *passthrough-words* (list "chapter" "part"
					"article" "clause" "section"
					"exhibit" "schedule"
					"subsection" "subclause"
					"th" "st" "nd"))

(defparameter *roman-regex*
  (cl-ppcre:create-scanner "^M{0,3}(CM|CD|D?C{0,3})(XC|XL|L?X{0,3})(IX|IV|V?I{0,3})$"
			   :case-insensitive-mode t))

(defun passthroughp (word)
  (or (= 1 (length word))
      (member word *passthrough-words* :test #'string-equal)
      (cl-ppcre:scan *roman-regex* word)))

(defun process-text (string)
  (with-output-to-string (s)
    (let ((acc '()))
      (labels ((process-word ()
		 (when acc
		   (let ((word (coerce (nreverse acc) 'string)))
		     (princ (if (passthroughp word)
				word
				(replace-word word))
			    s))
		   (setf acc '()))))
	(loop for char across string
	      if (alpha-char-p char)
		do (push char acc)
	      else do
		(process-word)
		(princ char s)
	      finally
		 (process-word))))))

(defun process-part (part)
  (let ((text-nodes (append
		     (mapcar #'plump:first-child
			     (plump:get-elements-by-tag-name (opc:xml-root part) "w:t"))
		     (mapcar #'plump:first-child
			     (plump:get-elements-by-tag-name (opc:xml-root part) "w:delText"))))) ;; FIXME
    (loop for node in text-nodes
	  do (let ((original (plump:text node)))
	       (setf (plump:text node)
		     (process-text original))))
    part))

(defun process-document (document)
  (alexandria:when-let ((md (docxplora:main-document document)))
    (process-part md))
  (alexandria:when-let ((comments (docxplora:comments document)))
    (process-part comments))
  (alexandria:when-let ((footnotes (docxplora:footnotes document)))
    (process-part footnotes))
  (alexandria:when-let ((endnotes (docxplora:endnotes document)))
    (process-part endnotes))
  (dolist (header (docxplora:headers document))
    (process-part header))
  (dolist (footer (docxplora:footers document))
    (process-part footer))
  document)

(defun reset-dictionary ()
  (clrhash *dictionary*))

(defun loremize (infile &key outfile reset-dictionary)
  (when reset-dictionary (clrhash *dictionary*))
  (let ((document (process-document (docxplora:open-document infile)))
	(outfile (or outfile
		     (merge-pathnames (format nil "Lorem-~A" (pathname-name infile))
				      infile))))
    (docxplora:save-document document outfile)))
