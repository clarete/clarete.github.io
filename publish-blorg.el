;;; publish-blorg.el --- Blog Settings ; -*- lexical-binding: t -*-
;;
;; Author: Lincoln Clarete <lincoln@clarete.li>
;;
;; Copyright (C) 2020  Lincoln Clarete
;;
;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.
;;
;;; Commentary:
;;
;; How my blog is generated
;;
;;; Code:

;; Initialize packaging system
(require 'package)
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/"))
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/"))
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(use-package htmlize
  :config
  :ensure t)

(use-package templatel
  :config
  :ensure t)

(use-package blorg
  :config
  :ensure t)


;; (add-to-list 'load-path "~/.emacs.d/")
;; (require 'init)
;; (message "We've passed that")

(require 'htmlize)
(setq org-export-htmlize-output-type 'css)

(add-to-list 'load-path "~/src/github.com/clarete/templatel/")
(add-to-list 'load-path "~/src/github.com/clarete/blorg/")
(require 'blorg)

;; For syntax highlight
(add-to-list 'load-path "~/src/github.com/clarete/langlang/extra/")
(require 'peg-mode)

;; Customize face attributes
(setq font-lock-face-attributes
      ;; Symbol-for-Face Foreground Background Bold Italic Underline
      '((font-lock-comment-face       "DarkGreen")
        (font-lock-string-face        "Sienna")
        (font-lock-keyword-face       "RoyalBlue")
        (font-lock-function-name-face "Blue")
        (font-lock-variable-name-face "Black")
        (font-lock-type-face          "Black")
        (font-lock-reference-face     "Purple")
        ))
;; Load the font-lock package.
(require 'font-lock)
;; Maximum colors
(setq font-lock-auto-fontify t)
(setq font-lock-maximum-decoration t)
;; Turn on font-lock in all modes that support it
(global-font-lock-mode t)
(font-lock-mode t)

;; '(font-lock-constant-face ((t (:foreground "#2aa198" :weight normal))))
;; '(font-lock-keyword-face ((t (:foreground "#859900" :weight normal))))
;; '(font-lock-variable-name-face ((t (:foreground "#839496")))))


(defun main ()
  "Main function."
  (blorg-gen
   :input-pattern "sources/.*\\.org$"
   :template "theme/post.html"
   :output "output/blog/{{ slug }}/index.html"))

(main)

(provide 'publish-blorg)
;;; publish-blorg.el ends here
