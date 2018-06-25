(setq user-full-name "Daniel <Siery> Sierpiński")
(setq user-mail-address "siery@comic.com")

(setq initial-scratch-message ";; SCRATCH YOUR THOUGHTS HERE.\n\n")
(setq inhibit-startup-echo-area-message "Welcome Siery")
(setq inhibit-startup-message t)

 (when window-system
  (tool-bar-mode -1)
  (menu-bar-mode -1)
  (tooltip-mode -1)
  (scroll-bar-mode -1))

(fset 'yse-or-no-p 'y-or-n-p)
(global-set-key (kbd "<f9>") 'revert-buffer)

(use-package try :ensure t)

(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)
(setq backup-directory-alist
  `((".*" . ,"/tmp/.backup")))
(setq auto-save-file-name-transforms
  `((".*" ,"/tmp/.backup" t)))

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

(use-package zerodark-theme
  :ensure t
  :config
  (load-theme 'zerodark t)
  (zerodark-setup-modeline-format))

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

;; yas
(use-package yasnippet
  :ensure t
  :config
  (yas-global-mode t))

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

;; Flycheck
(use-package flycheck
  :ensure t
  :config
  (global-flycheck-mode))

(with-eval-after-load "ob"
  (use-package org-babel-eval-in-repl
    :config
    (define-key org-mode-map (kbd "C-<return>") 'ober-eval-in-repl)
    (define-key org-mode-map (kbd "C-c C-c") 'ober-eval-block-in-repl)
    (with-eval-after-load "eval-in-repl"
      (setq eir-jump-after-eval nil))))

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

;; phantom js link
(add-to-list 'exec-path "/opt/local/bin")
(setenv "PATH" (mapconcat 'identity exec-path ":"))

(pdf-tools-install)

(use-package git
  :ensure t
  :config

    (autoload 'git-blame-mode "git-blame" "Minor mode for incremental blame for Git." t))

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

  ;; PHP auto-complete integration
  (auto-complete-mode t)
  (use-package ac-php :ensure t)
  (setq ac-sources  '(ac-source-php ) )
  (define-key php-mode-map  (kbd "C-]") 'ac-php-find-symbol-at-point)   ;goto define
  (define-key php-mode-map  (kbd "C-t") 'ac-php-location-stack-back))   ;go back

;;(require 'flymake-php)
;;add-hook 'php-mode-hook 'flymake-php-load)

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
    (css-mode "<style +type=\"text/css\"[^>]*>" "</style>"))))
(setq mweb-filename-extensions '("php" "htm" "html" "ctp" "phtml" "php4" "php5"))
(multi-web-global-mode t)

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
