#!/usr/bin/env -S emacs --script
;;; publish --- Publish contents of my blog
;;
;;; Commentary:
;;
;; A massive pile of barely useful of Emacs Lisp configuration for
;; generating HTML files off the `.org' files within the `sources'
;; directory.
;;
;; Huge thanks to the following references:
;;  * https://orgmode.org/worg/org-tutorials/org-publish-html-tutorial.html
;;  * https://vicarie.in/posts/blogging-with-org.html
;;  * https://gitlab.com/to1ne/blog/blob/master/elisp/publish.el#L69-112
;;  * https://www.brautaset.org/articles/2017/blogging-with-org-mode.html
;;; Code:

;; This is where I downloaded ox-rss
(add-to-list 'load-path (expand-file-name "site-lisp" user-emacs-directory))
(require 'package)
(package-initialize)

(require 'org)
(require 'org-element)

(require 'ox)
(require 'ox-publish)
(require 'ox-html)
(require 'ox-rss)

(defun lc/blog/file-path (path)
  "Return the relative path file at `PATH'."
  (let ((name (or load-file-name "~/src/github.com/clarete/clarete.github.io/")))
    (concat (file-name-directory name) path)))

(defun lc/blog/file-contents (relative-path)
  "Return the contents of file at RELATIVE-PATH."
  (with-temp-buffer
    (insert-file-contents (lc/blog/file-path relative-path))
    (buffer-string)))

(defun lc/blog/preamble (_plist)
  "Header (or preamble) for the blog."
  (lc/blog/file-contents "layout/navbar.html"))

(defun lc/blog/postamble (_plist)
  "Footer (or postamble) for the blog."
  (lc/blog/file-contents "layout/footer.html"))

(defun lc/blog/rss/sitemap-entry (file style project)
  "Format a FILE entry of the RSS feed.

PROJECT is the list of properties of the project FILE is part of.
STYLE is either 'list' or 'tree'."
  (cond ((not (directory-name-p file))
         (let* ((file (org-publish--expand-file-name file project))
                (title (org-publish-find-title file project))
                (date (format-time-string "%Y-%m-%d" (org-publish-find-date file project)))
                (link (lc/blog/post/relative-link file project)))
           (with-temp-buffer
             (insert (format "* %s\n" title))
             (org-set-property "TITLE" title)
             (org-set-property "RSS_PERMALINK" link)
             (org-set-property "DATE" date)
             (org-set-property "PUBDATE" date)
             (insert-file-contents file)
             (buffer-string))))
        ((eq style 'tree)
         ;; Return only last subdir.
         (file-name-nondirectory (directory-file-name file)))
        (t file)))

(defun lc/blog/rss/sitemap (title list)
  "Generate RSS feed, as a string.

TITLE is the title of the RSS feed.  LIST is an internal
representation for the files to include, as returned by
`org-list-to-lisp'.  PROJECT is the current project."
  (concat "#+TITLE: " title "\n\n"
          (org-list-to-subtree list nil '(:icount "" :istart ""))))

(defun lc/blog/rss/publish (plist file pub-dir)
  "Publish RSS with PLIST, only when FILE is 'rss.org'.

PUB-DIR is when the output will be placed."
  (if (lc/blog/is-file file "rss.org")
      (org-rss-publish-to-rss plist file pub-dir)))

(defun lc/blog/is-file (file basename)
  "Return t if FILE match BASENAME file and nil otherwise."
  (string= (file-name-nondirectory file) basename))

(defun lc/blog/post/date-subtitle (file project)
  "Format the date found in FILE of PROJECT."
  (format-time-string "%B %d %Y" (org-publish-find-date file project)))

(defun lc/blog/post/date-ydm (file project)
  "Retrieve date of the post at FILE formatted as '%Y-%m-%d'.

PROJECT is a plist with all the properties of the project that
FILE is part of."
  (format-time-string "%Y-%m-%d" (org-publish-find-date file project)))

(defun lc/blog/post/relative-link (file project)
  "Generate relative link for FILE within PROJECT."
  (concat
   (lc/blog/post/date-ydm file project)
   "/"
   (concat (file-name-sans-extension (file-name-nondirectory file)) ".html")))

(defun lc/blog/post/output-path (file project pub-dir)
  "Final post path assembled from FILE, PROJECT and PUB-DIR."
  (expand-file-name (lc/blog/post/date-ydm file project) pub-dir))

(defun lc/blog/post/sitemap (title list)
  "Generate index page.

TITLE is the title of the blog and LIST is the list of blog
posts."
  (concat "#+TITLE: " title "\n\n"
          (lc/blog/file-contents "layout/index.txt")
          "\n\n"
          "@@html:<hr>@@\n\n"
          "** Writing\n\n"
          (org-list-to-org list)))

(defun lc/blog/post/sitemap-entry (file style project)
  "Format each entry of sitemap.

FILE is the entry's path within PROJECT.  The list of properties
of all files bundled together is contained in PROJECT and STYLE
is either `list' or `tree'."
  (cond ((not (directory-name-p file))
	 (format "[[file:%s][%s — %s]]"
		 (lc/blog/post/relative-link file project)
                 (lc/blog/post/date-ydm file project)
		 (org-publish-find-title file project)))
	((eq style 'tree)
	 ;; Return only last subdir.
	 (file-name-nondirectory (directory-file-name file)))
	(t file)))

(defun lc/blog/publish (project file pub-dir)
  "Wrapper function to publish an org file to html.

PROJECT contains the project properties, FILE contains the source
file path and PUB-DIR the output directory.

For the 'index.org' file, this function is a no-op.  For the
posts, The path where it's going to be saved is prepended with
the post date and the formatted date is also added as a subtitle
to the post file."
  (if (lc/blog/is-file file "index.org")
      ;; The index file goes to the root directory
      (progn
        (plist-put project :subtitle nil)
        (org-html-publish-to-html project file pub-dir))
    ;; All the other files go to a date subdirectory.  They also get
    ;; a subtitle with the post date.
    (progn
      (plist-put project :subtitle (lc/blog/post/date-subtitle file project))
      (org-html-publish-to-html project file (lc/blog/post/output-path file project pub-dir)))))

(defun lc/blog/link-img-follow (path)
  "Retrieve image at PATH from the media directory."
  (expand-file-name path (lc/blog/file-path "media/blogimg")))

(defun lc/blog/link-img-export (path desc backend)
  "Custom image export.

Export image at PATH and generate link with DESC only when it
matches BACKEND."
  (cond
   ((eq backend 'html)
    (format "<img src=\"/media/blogimg/%s\" alt=\"%s\"/>" path (or desc path)))))

(org-link-set-parameters
 "blogimg"
 :follow 'lc/blog/link-img-follow
 :export 'lc/blog/link-img-export)

(defvar lc/blog/source-dir (lc/blog/file-path "sources")
  "Path to the Org files.")

(defvar lc/blog/media-dir (lc/blog/file-path "media")
  "Path to the media files.")

(defvar lc/blog/pub-dir (lc/blog/file-path "")
  "Path that all documents are exported.")

;; This is where we set all the variables and link to all the
;; functions we created so far and finally call `org-publish-project'
;; in the end.

(setq org-export-with-toc nil
      org-export-with-author t
      org-export-with-email nil
      org-export-with-creator nil
      org-export-with-section-numbers nil

      org-html-doctype "html5"
      org-html-html5-fancy t
      org-html-link-home "/"
      org-html-link-up "/"
      org-html-postamble 'auto
      org-html-divs
      '((preamble  "header" "top")
        (content   "main"   "content")
        (postamble "footer" "postamble"))
      org-html-head (lc/blog/file-contents "layout/header.html")

      ;; Control where the cache is kept, it can be kept in sync with
      ;; .gitignore
      org-publish-timestamp-directory ".cache/"

      ;; List of stuff to be published
      org-publish-project-alist
      `(("blog" :components ("blog-posts" "blog-rss"))
        ("blog-posts"
         ;; I want to style the whole thing myself. Years working with
         ;; CSS MUST pay off at some point!
         :html-head-include-default-style nil
         ;; Functions to insert the partial layout pieces I have
         :html-preamble lc/blog/preamble
         :html-postamble lc/blog/postamble
         ;; Override the default function to tweak the HTML it
         ;; generates
         :publishing-function lc/blog/publish
         ;; The `sources` directory
         :base-directory ,lc/blog/source-dir
         ;; The `blog` directory
         :publishing-directory ,lc/blog/pub-dir
         ;; Configure output options
         :section-numbers nil
         :table-of-contents nil
         :headline-levels 4
         ;; Although all the posts are in the same directory, I might
         ;; have subdirectories with assets
         :recursive t
         :exclude "rss.org"
         :auto-sitemap t
         :sitemap-filename "index.org"
         :sitemap-title "Hi! I'm Lincoln"
         :sitemap-sort-files anti-chronologically
         :sitemap-format-entry lc/blog/post/sitemap-entry
         :sitemap-function lc/blog/post/sitemap
         :with-date t)

        ;; Generate RSS feed
        ("blog-rss"
         :base-directory ,lc/blog/source-dir
         :exclude ,(regexp-opt '("rss.org" "index.org" "404.org"))
         :recursive nil
         :base-extension "org"
         :rss-extension "xml"
         :rss-feed-url: "https://clarete.li/blog/rss.xml"
         :html-link-home "https://clarete.li/"
         :html-link-use-abs-url t
         :html-link-org-files-as-html t
         :auto-sitemap t
         :sitemap-filename "rss.org"
         :sitemap-title "Lincoln Clarete"
         :sitemap-style list
         :sitemap-sort-files anti-chronologically
         :sitemap-format-entry lc/blog/rss/sitemap-entry
         :sitemap-function lc/blog/rss/sitemap
         :publishing-function lc/blog/rss/publish
         :publishing-directory ,lc/blog/pub-dir
         :section-numbers nil
         :table-of-contents nil)))

;(org-publish-project "blog" t)
;(org-publish-project "blog-posts" t)
;(org-publish-project "blog-rss" t)

;;; publish ends here
