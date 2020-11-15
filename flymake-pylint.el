;;; flymake-pylint.el --- A flymake handler for pylint	-*- lexical-binding: t; -*-

;; Copyright (C) 2020  Jürgen Hötzel

;; Author: Jürgen Hötzel <juergen@hoetzel.info>
;; URL: https://github.com/juergenhoetzel/flymake-pylint
;; Version: 1.0.0
;; Package-Requires: ((emacs "26.1") (flymake-quickdef "0.1.1"))
;; Keywords: languages, tools

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation, either version 3 of the
;; License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see
;; <https://www.gnu.org/licenses/>.

;;; Commentary:

;; A flymake handler for pylint: https://github.com/PyCQA/pylint

;;; Code:

(require 'flymake)
(require 'flymake-quickdef)
(require 'cl-lib)

(flymake-quickdef-backend flymake-pylint-backend
  :pre-let ((pylint-exec (executable-find "pylint")))
  :pre-check (unless pylint-exec (error "Not found pylint on PATH"))
  :write-type 'pipe
  :proc-form `(,pylint-exec  "--from-stdin" ,(buffer-file-name))
  :search-regexp "^.+:\\([[:digit:]]+\\):\\([[:digit:]]+\\): \\([[:alnum:]]+\\): \\(.*\\) (\\(.*\\))$"
  :prep-diagnostic
  (let* ((lnum (string-to-number (match-string 1)))
	 (lcol (string-to-number (match-string 2)))
	 (severity (match-string 3))
	 (msg (match-string 4))
	 (pos (flymake-diag-region fmqd-source lnum lcol))
	 (beg (car pos))
	 (end (cdr pos))
	 (type (cl-case (string-to-char severity)
		 (?C :error)
		 (?W :warning)
		 (t :note))))
    (list fmqd-source beg end type msg)))

;;;###autoload
(defun flymake-pylint-setup ()
  "Enable flymake backend."
  (interactive)
  (add-hook 'flymake-diagnostic-functions
	    #'flymake-pylint-backend nil t))

(provide 'flymake-pylint)
;;; flymake-pylint.el ends here
