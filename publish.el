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
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; Install dependencies
(use-package htmlize :config :ensure t)
(use-package rainbow-delimiters :config :ensure t)

;; Local packages this blog depends on
(add-to-list 'load-path "~/src/github.com/clarete/templatel/")
(add-to-list 'load-path "~/src/github.com/clarete/blorg/")
(add-to-list 'load-path "~/src/github.com/clarete/langlang/extra/")
(add-to-list 'load-path "~/src/github.com/clarete/effigy/extras/")

;; Configure dependencies
(require 'ox-html)

;; Output HTML with syntax highlight with css classes instead of
;; directly formatting the output.
(setq org-html-htmlize-output-type 'css)

;; For syntax highlight of blocks containing these types of code
(require 'effigy-mode)
(require 'peg-mode)
(add-hook 'peg-mode-hook #'rainbow-delimiters-mode)
(add-hook 'effigy-mode-hook #'rainbow-delimiters-mode)

;; Static site generation
(require 'blorg)

;; Site wide configuration
(if (string= (getenv "ENV") "prod")
    (setq blorg-default-url "https://clarete.li"))

(blorg-route
 :name "index"
 :input-pattern "index.org"
 :template "index.html"
 :output "index.html"
 :url "/")

(blorg-route
 :name "posts"
 :input-pattern "posts/*.org"
 :input-filter #'blorg-input-filter-drafts
 :template "post.html"
 :output "blog/{{ slug }}.html"
 :url "/blog/{{ slug }}.html")

(blorg-route
 :name "blog"
 :input-pattern "posts/*.org"
 :input-filter #'blorg-input-filter-drafts
 :input-aggregate #'blorg-input-aggregate-all
 :template "blog-index.html"
 :output "blog/index.html"
 :url "/blog")

(blorg-route
 :name "categories"
 :input-pattern "posts/*.org"
 :input-aggregate #'blorg-input-aggregate-by-category
 :input-filter #'blorg-input-filter-drafts
 :template "category.html"
 :output "blog/{{ name }}/index.html"
 :url "/blog/{{ name }}")

(blorg-export)

;;; publish.el ends here
