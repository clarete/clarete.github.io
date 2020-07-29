;;; publish.el --- Generate Static HTML -*- lexical-binding: t -*-
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
(add-to-list 'load-path "~/src/github.com/clarete/langlang/extra/")
(add-to-list 'load-path "~/src/github.com/clarete/effigy/extras/")
(add-to-list 'load-path "~/src/github.com/clarete/templatel/")
(add-to-list 'load-path "~/src/github.com/emacs-love/weblorg/")

;; Configure dependencies
(require 'ox-html)

;; Output HTML with syntax highlight with css classes instead of
;; directly formatting the output.
(setq org-html-htmlize-output-type 'css)

;; For syntax highlight of blocks containing these types of code
(require 'effigy-mode)
(require 'peg-mode)
(add-hook 'prog-mode-hook #'rainbow-delimiters-mode)

;; Static site generation
(require 'weblorg)

;; Site wide configuration
(if (string= (getenv "ENV") "prod")
    (setq weblorg-default-url "https://clarete.li"))
(if (string= (getenv "ENV") "local")
    (setq weblorg-default-url "http://guinho.local:8000"))

(weblorg-route
 :name "index"
 :input-pattern "index.org"
 :template "index.html"
 :output "index.html"
 :url "/")

(weblorg-route
 :name "posts"
 :input-pattern "posts/*.org"
 :template "post.html"
 :output "blog/{{ slug }}.html"
 :url "/blog/{{ slug }}.html")

(weblorg-route
 :name "blog"
 :input-pattern "posts/*.org"
 :input-aggregate #'weblorg-input-aggregate-all-desc
 :template "blog.html"
 :output "blog/index.html"
 :url "/blog")

(weblorg-route
 :name "rss"
 :input-pattern "posts/*.org"
 :input-aggregate #'weblorg-input-aggregate-all-desc
 :template "rss.xml"
 :output "blog/rss.xml"
 :url "/blog/rss.xml")

(weblorg-route
 :name "categories"
 :input-pattern "posts/*.org"
 :input-aggregate #'weblorg-input-aggregate-by-category-desc
 :template "category.html"
 :output "blog/{{ name }}/index.html"
 :url "/blog/{{ name }}")

(weblorg-route :name "slides" :url "/slides")

(setq debug-on-error t)

(weblorg-export)

;;; publish.el ends here
