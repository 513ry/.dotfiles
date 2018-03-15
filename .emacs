;;; This .emacs file served for siery <siery@comic.com>
;; Feel free to use it as you want!
;;
;; C-END to see custom key-binidngs.

(setq user-full-name "Siery")
(setq user-mail-address "siery@comic.com")

(setq initial-scratch-message ";; SCRATCH YOUR THOUGHTS HERE.\n\n")
(setq inhibit-startup-message "Wellcome to the new section!")

(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes (quote (zerodark)))
 '(menu-bar-mode nil)
 '(org-agenda-files (quote ("~/Documents/Notes/todo.org")))
 '(org-agenda-restore-windows-after-quit 1)
 '(org-agenda-window-setup 1)
 '(scroll-bar-mode nil)
 '(tool-bar-mode nil)
 '(tooltip-mode nil))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(setq backup-directory-alist
      `((".*" . ,"./.backup")))
(setq auto-save-file-name-transforms
      `((".*" ,"./.backup" t)))

;;; Automaticly switch to sudo mode while opening a file when necessary
(defadvice find-file (after find-file-sudo activate)
  "Find file as root if necessary."
  (unless (and buffer-file-name
               (file-writable-p buffer-file-name))
    (find-alternate-file (concat "/sudo:root@localhost:" buffer-file-name))))

(when window-system
  (tooltip-mode nil))

(require 'package)
;;; PACKAGE-ARCHIVES INSTANCE
;; Including more of thouse sections may
;; broke package access and will look ugly!
(add-to-list 'package-archives
	     ;; enable MELPA package archive data transfering.
	     ;; link: http://melpa.org/
	     '("melpa" . "https://melpa.org/packages/"))
(when (< emacs-major-version 24)
  ;; For important compatibility libraries like cl-lib
  (add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/")))
(package-initialize)

;; THEME SETUP
(load-theme 'zerodark t)
;; Optionally setup the modeline
(zerodark-setup-modeline-format)

;; YAT SETUP
(require 'yasnippet)
(yas-global-mode 1)
;(global-set-key (kbd "C-c y")
;		(lambda ()
;		  (indent-for-tab-command))
;		  (yas-expand)))

;; auto-complete set
(require 'auto-complete)
(require 'auto-complete-config)
(ac-config-default)

;; auto-complete c headers
(defun my:ac-c-header-init ()
  (require 'auto-complete-c-headers)
  (add-to-list 'ac-sources 'ac-source-c-headers))
;; hook headers for c/c++
(add-hook 'c++-mode-hook 'my:ac-c-header-init)
(add-hook 'c-mode-hook 'my:ac-c-header-init)


;; initialize company
(require 'company)
(add-to-list 'company-backends 'company-plsense)
(add-hook 'perl-mode-hook 'company-mode)
(add-hook 'cperl-mode-hook 'company-mode)

(add-hook 'after-init-hook 'company-mode)

;;; WEB DEVELOPEMENT *************************************************************
;; Multi Web Mode
(require 'multi-web-mode)
(setq mweb-default-major-mode 'html-mode)
(setq mweb-tags '((php-mode "<\\?php\\|<\\? \\|<\\?= " "\\?>")
		  (js2-mode "<script +\\(type=\"text/javascript\"\\|language=\"javascript\"\\)[^>]*>" "</script>")
		  (css-mode "<style +type=\"text/css\"[^>]*>" "</style>")))
(setq mweb-filename-extensions '("php" "htm" "html" "ctp" "phtml" "php4" "php5"))
(multi-web-global-mode 1)

;; Set MMM Mode for embandet html code etc.
;;(require 'mmm-mode)
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

;; Gaben - Script Debug
(setq load-path (cons "/home/siery/.emacs.d/elpa/geben-20170801.551/" load-path))
(autoload 'geben "geben" "DBGp protocol frontend, a script debugger" t)
;; Debug a simple PHP script.
;; Change the session key my-php-54 to any session key text you like
(defun my-php-debug ()
  "Run current PHP script for debugging with geben"
  (interactive)
  (call-interactively 'geben)
  (shell-command
   (concat "XDEBUG_CONFIG='idekey=my-php-7.0' /usr/bin/php7.0 "
	   (buffer-file-name) " &"))
  )
(global-set-key [f5] 'my-php-debug)


;; popup windows setup
(require 'popwin)
(popwin-mode 1)

;; Insert file path (designet to insert image paths for blog posts)
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

(global-set-key "\C-cr" 'my-insert-file-name)

  ;     ;;-----------------------------------------------------------------------------;;..,
;( );;;;00;;; HELM SETUP  _________________________________________________________________;;;\
  ;     ;;-----------------------------------------------------------------------------;;''`
(require 'helm)

(require 'helm-config)
;;set helm-bufers-list as a default buffers-list


;;Locate the helm-swoop folder to your path
;;This line is unnecessary if you get this program from MELPA
;;(add-to-list 'load-path "~/.emacs.d/elisp/helm-swoop")

(require 'helm-swoop)

;;Save buffer when helm-multi-swoop-edit complete
;(setq helm-multi-swoop-edit-save t)

;;If this value is t, split window inside the current window
;(setq helm-swoop-split-with-multiple-windows nil)

;;Split direction. 'split-window-vertically or 'split-window-horizontally
;(setq helm-swoop-split-direction 'split-window-vertically)

;;If nil, you can slightly boost invoke speed in exchange for text color
;(setq helm-swoop-speed-or-color nil)

;;Go to the opposite side of line from the end or beginning of line
;(setq helm-swoop-move-to-line-cycle t)

;;Optional face for line numbers
;;Face name is `helm-swoop-line-number-face`
;(setq helm-swoop-use-line-number-face t)


;;; KEY BANDINGS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;overwrite defaults:
(global-set-key (kbd "C-x C-b") 'helm-buffers-list)

;;helm-swoop:
;;(define-key isearch-mode-map (kbd "M-i") 'helm-swoop-from-isearch)
;;(define-key helm-swoop-map (kbd "M-i") 'helm-multi-swoop-all-from-helm-swoop)
(global-set-key (kbd "M-i") 'helm-swoop)
(global-set-key (kbd "M-I") 'helm-swoop-back-to-last-point)
(global-set-key (kbd "C-c M-i") 'helm-multi-swoop)
(global-set-key (kbd "M-s s") 'helm-multi-swoop-all)
