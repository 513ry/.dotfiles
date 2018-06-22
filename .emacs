;;; .emacs --- My personal config-file <siery@comic.com>xs
;;;
;;; Commentary:
;;; Feel free to use it as you want!
;;; C-END to see custom key-binidngs.
;;;
;;; Code:

;;; ABOUT
(setq user-full-name "Daniel <Siery> Sierpiński")
(setq user-mail-address "siery@comic.com")

(setq initial-scratch-message ";; SCRATCH YOUR THOUGHTS HERE.\n\n")
(setq inhibit-startup-echo-area-message "siery")
(setq inhibit-startup-message t)


;;; PACKAGES CONFIGUARATION
(require 'package)
(add-to-list 'package-archives
	     ;; Enable Melpa Unstable archive
	     '("melpa" . "https://melpa.org/packages/"))
(when (< emacs-major-version 24)
  (add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/")))
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

'(use-package-compute-statistics)

;; Ensure system binaries keyword
(use-package use-package-ensure-system-package
  :ensure t)

(use-package auto-package-update
  :ensure t
  :config
  (setq auto-package-update-delete-old-versions t)
  (setq auto-package-update-hide-results t)
  (auto-package-update-maybe))

(use-package try
  :ensure t)


;;; SET VARIABLES
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes (quote (zerodark)))
 '(custom-safe-themes
   (quote
    ("ff79b206ad804c41a37b7b782aca44201edfa8141268a6cdf60b1c0916343bd4" default)))
 '(menu-bar-mode nil)
 '(org-agenda-files (quote ("~/Documents/Notes/todo.org")))
 '(org-agenda-restore-windows-after-quit t)
 '(org-agenda-window-setup t)
 '(package-selected-packages
   (quote
    (ffip ag fd helm-config zerodark use-package-ensure-system-package use-package-compute-statistics use-package auto-package-update try projectile org-babel-eval-in-repl ess matlab-mode eval-in-repl omnisharp csharp-mode xah-css-mode helm-ag-r find-file-in-project ob-browser pdf-tools tablist git ac-html flycheck-clang-analyzer flymake-css flymake-php flymake-easy inf-ruby ac-php ac-php-core geiser zerodark-theme yasnippet sexy-monochrome-theme popwin php-mode multi-web-mode mmm-mode log4e helm-swoop gntp geben eslint-fix enh-ruby-mode edit-color-stamp company-plsense cmm-mode circe auto-complete-c-headers ac-js2)))
 '(printer-name nil)
 '(projectile-mode t nil (projectile))
 '(safe-local-variable-values
   (quote
    ((ffip-project-root . "/var/www/html/nobobox/")
     (ffip-project-root . "~/hak/Ruby/mazeing/"))))
 '(scroll-bar-mode nil)
 '(tool-bar-mode nil)
 '(tooltip-mode nil))

(setq backup-directory-alist
      `((".*" . ,"/tmp/.backup")))
(setq auto-save-file-name-transforms
      `((".*" ,"/tmp/.backup" t)))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;;; GENERAL LAMBDAS AND FUNCTIONS
;; Automaticly switch to sudo mode while opening a file when necessary
(defadvice find-file (after find-file-sudo activate)
  "Find file as root if necessary."
  (unless (and buffer-file-name
               (file-writable-p buffer-file-name))
    (find-alternate-file (concat "/sudo:root@localhost:" buffer-file-name))))

;; Insert file path (designet to insert image paths for blog posts
;; inside org-mode
(defun my-insert-file-name (filename &optional args)
  "Insert name of file FILENAME into buffer after point.
  
  Prefixed with \\[universal-argument], expand the file name to
  its fully canocalized path.  See `expand-file-name'.
  
  Prefixed with \\[negative-argument], use relative path to file
  name from current directory, `default-directory'.  See
  `file-relative-name'.
  
  The default with no prefix is to insert the file name exactly as
  it appears in the minibuffer prompt."
  ;; Based on insert-file in Emacs -- ashawley 20080926
  (interactive "*fInsert file name: \nP")
  (cond ((eq '- args)
	 (insert (file-relative-name filename)))
	((not (null args))
	 (insert (expand-file-name filename)))
	(t
	 (insert filename))))


(when window-system
  (tooltip-mode nil))

;; THEME SETUP
(use-package zerodark-theme
  :ensure t
  :config
  (load-theme 'zerodark t)
  (zerodark-setup-modeline-format))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; UI AND GRAPHIC PARSING
;; popup windows setup
(use-package popwin
  :ensure t
  :config
  (popwin-mode t))

;; Helm
(use-package helm :ensure t)
(use-package helm-swoop
  :ensure t
  :config
  (setq helm-swoop-speed-or-color nil))


;; YAS SETUP
(use-package yasnippet
  :ensure t
  :config
  (yas-global-mode t))

;; AUTOCOMPLETION
;; auto-complete setup
(use-package auto-complete
  :ensure t
  :config
  (ac-config-default))

;; company setup
(use-package company
  :ensure f
  :config
  (add-to-list 'company-backends 'company-plsense)
  (add-hook 'perl-mode-hook 'company-mode)
  (add-hook 'cperl-mode-hook 'company-mode)
  (add-hook 'after-init-hook 'company-mode))

;;; AUTOVALIDATION
;; Flycheck
(use-package flycheck
  :ensure t
  :config
  (global-flycheck-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; PUBLISHING AND JEKYLL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ORG-MODE
(with-eval-after-load "ob"
  (use-package org-babel-eval-in-repl
    :config
    (define-key org-mode-map (kbd "C-<return>") 'ober-eval-in-repl)
    (define-key org-mode-map (kbd "C-c C-c") 'ober-eval-block-in-repl)
    (with-eval-after-load "eval-in-repl"
      (setq eir-jump-after-eval nil))))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; PROJECT MENAGEING
(use-package projectile
  :ensure t
  :init
  (setq projectile-enable-caching t) ; To avoid slow indexing
  :config
  (projectile-mode t))

;; Enable fd for faster file search
`(setq ffip-use-rust-fd t)'

;; Enable silver-search with helm
(use-package ag
  :ensure t
  :ensure-system-package (ag . "wajig install ag")
  :config
  (use-package helm-ag-r :ensure t))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; DOC VIEW
;; phantop js link
(add-to-list 'exec-path "/opt/local/bin")
(setenv "PATH" (mapconcat 'identity exec-path ":"))

(pdf-tools-install)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Elisp



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; C and C ++
(defun my:c-lang-support ()
  ;; Auto-Complete C headers
  (use-package auto-complete-c-headers
    :ensure t
    :config (add-to-list 'ac-sources 'ac-source-c-headers)))

  ;; hook support for c/c++
  (add-hook 'c++-mode-hook 'my:c-lang-support)
  (add-hook 'c-mode-hook 'my:c-lang-support)

;; Live compilation
(with-eval-after-load 'flycheck
  (use-package flycheck-clang-analyzer
    :ensure t
    :config
    (flycheck-clang-analyzer-setup)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; RUBY
(use-package inf-ruby :ensure t)
(use-package enh-ruby-mode
  :ensure t
  :load-path "(path-to)/Enhanced-Ruby-Mode"
  :config
  (autoload 'enh-ruby-mode "enh-ruby-mode" "Major mode for ruby files" t)
  (add-to-list 'auto-mode-alist '("\\.rb$" . enh-ruby-mode))
  (add-to-list 'interpreter-mode-alist '("ruby" . enh-ruby-mode))
  ;; inf-ruby REPL
  (autoload 'inf-ruby "inf-ruby" "Run an inferior Ruby process" t)
  (add-hook 'enh-ruby-mode-hook 'inf-ruby-minor-mode)
  (add-hook 'compilation-filter-hook 'inf-ruby-auto-enter)

  (eval-after-load 'inf-ruby
    '(define-key inf-ruby-minor-mode-map
       (kbd "C-c s") 'inf-ruby-console-auto)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; PHP
(use-package php-mode
  :ensure t
  :config
  (defun my:php-mode-hook ()
    "My PHP mode configuration."
    '(define-abbrev php-mode-abbrev-table "ex" "extends"))
  (add-hook 'php-mode-hook 'my:php-mode-hook)

  ;; Gaben - Script Debug
  (setq load-path (cons "/home/siery/.emacs.d/elpa/geben-20170801.551/" load-path))
  (autoload 'geben "geben" "DBGp protocol frontend, a script debugger" t)
  ;; Debug a simple PHP script.
  (defun my-php-debug ()
    "Run current PHP script for debugging with geben."
    (interactive)
    (call-interactively 'geben)
    (shell-command
     (concat "XDEBUG_CONFIG='idekey=my-php-7.0' /usr/bin/php7.0 "
	     (buffer-file-name) " &")))
  ;; php auto-complete integration
  (auto-complete-mode t)
  (use-package ac-php :ensure t)
  (setq ac-sources  '(ac-source-php ) )
  (define-key php-mode-map  (kbd "C-]") 'ac-php-find-symbol-at-point)   ;goto define
  (define-key php-mode-map  (kbd "C-t") 'ac-php-location-stack-back))   ;go back


;(require 'flymake-php)
;  (add-hook 'php-mode-hook 'flymake-php-load)


;;; WEB DEVELOPEMENT ************************************************

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; CSS
;; (use-package flymake-css
;;   :ensure t
;;   :config (add-hook 'css-mode-hook 'flymake-css-load))


;; Multi Web Mode
(use-package multi-web-mode
  :ensure t
  :init
  (setq mweb-default-major-mode 'html-mode)
  :config
  (setq mweb-tags '((php-mode "<\\?php\\|<\\? \\|<\\?= " "\\?>")
		    (js2-mode "<script +\\(type=\"text/javascript\"\\|language=\"javascript\"\\)[^>]*>" "</script>")
		    (css-mode "<style +type=\"text/css\"[^>]*>" "</style>")))
  (setq mweb-filename-extensions '("php" "htm" "html" "ctp" "phtml" "php4" "php5"))
  (multi-web-global-mode t))

;; Set MMM Mode for embandet html code etc.
;;(use-package mmm-mode :ensure t)
;;
;;(setq mmm-global-mode 'maybe)
;;(mmm-add-mode-ext-class 'html-mode "\\.php\\'" 'html-php)

;; Set JS2 Mode as default
(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))
(add-to-list 'interpreter-mode-alist '("node" . js2-mode))
(add-hook 'js2-mode-hook 'ac-js2-mode)
`(setq ac-js2-evaluate-calls t)
;; JS experimental libs
;;(add-to-list 'ac-js2-external-libraries "path/to/lib/library.js")'

;; Hook Skewer mode
(add-hook 'js2-mode-hook 'skewer-mode)
(add-hook 'css-mode-hook 'skewer-css-mode)
(add-hook 'html-mode-hook 'skewer-html-mode)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; C# AND MONO
(use-package csharp-mode
  :ensure f
  :init
  (setq auto-mode-alist
      (append '(("\\.cs$" . csharp-mode)) auto-mode-alist))
  :config
  (defun my-csharp-mode-fn ()
    "function that runs when csharp-mode is initialized for a buffer."
    (turn-on-auto-revert-mode)
    (setq indent-tabs-mode nil))
  (add-hook  'csharp-mode-hook 'my-csharp-mode-fn t)
  (add-hook 'csharp-mode-hook 'omnisharp-mode)
  (eval-after-load
      'company
    '(add-to-list 'company-backends 'company-omnisharp))
  (add-hook 'csharp-mode-hook #'company-mode))


;;; KEY BANDINGS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; My functions:
(global-set-key [f5] 'my-php-debug)
(global-set-key "\C-cr" 'my-insert-file-name)
;; Overwrite defaults:
(global-set-key (kbd "C-x C-b") 'helm-buffers-list)
(global-set-key (kbd "C-c f") 'ff-find-other-file)
;; Project menager
(global-set-key (kbd "C-x f") 'find-file-in-project)
(global-set-key (kbd "C-c p") 'ffip-create-project-file)
(global-set-key (kbd "C-x r p") 'project-find-regexp)
;; Helm-swoop:
;;(define-key isearch-mode-map (kbd "M-i") 'helm-swoop-from-isearch)
;;(define-key helm-swoop-map (kbd "M-i") 'helm-multi-swoop-all-from-helm-swoop)
(global-set-key (kbd "M-i") 'helm-swoop)
(global-set-key (kbd "M-I") 'helm-swoop-back-to-last-point)
(global-set-key (kbd "C-c M-i") 'helm-multi-swoop)
(global-set-key (kbd "M-s s") 'helm-multi-swoop-all)

(provide '.emacs)
;;; .emacs ends here
