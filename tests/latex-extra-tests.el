(add-to-list 'load-path (expand-file-name "./"))
(add-to-list 'load-path (expand-file-name "../"))
(add-to-list 'load-path (expand-file-name "auctex-11.87.7/"))
(add-to-list 'load-path (expand-file-name "tests/auctex-11.87.7/"))

(require 'ert)
(load "auctex-autoloads")
(autoload 'latex-extra-mode "latex-extra")

(defmacro latex/deftest (name &rest body)
  "Define a test with point at beginning of test.tex."
  (declare (indent 1)
           (debug (form body)))
  `(ert-deftest ,(intern (format "latex/test-%s" name)) ()
     (cl-letf (((symbol-function 'message) 'ignore))
       (with-temp-buffer
         (insert-file-contents ,(expand-file-name "./test.tex"))
         (add-hook 'LaTeX-mode-hook #'latex-extra-mode)
         (latex-mode)
         (goto-char (point-min))
         ,@body))))

(latex/deftest sections
  (latex/next-section 3)
  (should (looking-at "\\\\section{1}"))
  (latex/next-section-same-level 2)
  (should (looking-at "\\\\appendix"))
  (latex/previous-section 1)
  (should (looking-at "\\\\subsection{4}"))
  (latex/up-section 2)
  (should (looking-at "\\\\chapter{7}"))
  (latex/next-section-same-level 1)
  (should (looking-at "\\\\appendix")))

(latex/deftest environments
  (latex/next-section 1)
  (forward-line 1)
  (latex/forward-environment 2)
  (forward-line -1)
  (should (looking-at "\\\\end{equation}"))
  (latex/beginning-of-environment 2)
  (should (looking-at "\\\\begin{document}"))
  (forward-line 1)
  (latex/end-of-environment 1)
  (forward-line -1)
  (should (looking-at "\\\\end{document}")))

;; (latex/deftest folding
;;   (should (search-forward "\\appendix" nil 'noerror))
;;   (goto-char (line-beginning-position))
;;   (latex/hide-show)
;;   (call-interactively 'next-line)
;;   (call-interactively 'next-line)
;;   (should (string= (thing-at-point 'line) "\\section{6}\n"))
;;   (latex/hide-show-all)
;;   (call-interactively 'previous-line)
;;   (call-interactively 'previous-line)
;;   (call-interactively 'previous-line)
;;   (call-interactively 'previous-line)
;;   (call-interactively 'previous-line)
;;   (call-interactively 'previous-line)
;;   (call-interactively 'previous-line)
;;   (should (string= (thing-at-point 'line) "\\section{2}\n")))

(latex/deftest filling
  (let ((end (point-max)))
    (goto-char (point-min))
    (search-forward "begin{document}" nil 'noerror)
    (latex/clean-fill-indent-environment)
    (write-file "out.tex")
    (should (= (point-max) end))))