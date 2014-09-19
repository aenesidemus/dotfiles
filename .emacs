(custom-set-variables
 '(custom-enabled-themes (quote (wombat)))
 '(menu-bar-mode t)
 '(tool-bar-mode nil)
 '(make-backup-files nil) ; Don't want any backup files
 '(auto-save-list-file-name nil) ; Don't want any .saves files
 '(auto-save-default nil) ; Don't want any auto saving

 (custom-set-faces))

(add-to-list 'load-path "~/.emacs.d/")


(require 'linum+)
(setq linum-format "%d ")
(global-linum-mode 1)

(desktop-save-mode 1)
(menu-bar-mode 1)

(require 'ido)
(ido-mode t)
(setq ido-enable-flex-matching t)

(require 'bs)
(setq bs-configurations
      '(("files" "^\\*scratch\\*" nil nil bs-visits-non-file 
	 bs-sort-buffer-interns-are-last)))
(global-set-key (kbd "<f4>") 'bs-show)

(require 'sr-speedbar)
(global-set-key (kbd "<f12>") 'sr-speedbar-toggle)

(add-to-list 'load-path "~/.emacs.d/el-get/el-get")
(require 'el-get)

					;(add-to-list 'load-path "~/.emacs.d/yasnippet")
					;(require 'yasnippet)

(set-default 'truncate-lines nil)

(setq my-packages
      (append
       '(projectile litable sudo-save sudo-ext lua-mode org-mode 
		    web-mode js2-mode fill-column-indicator
		    google-maps tramp magit ctags auto-complete 
		    ctypes flycheck elpy company-mode eclim)
					;google-maps tramp magit ctags	ctypes flycheck)

       (mapcar 'el-get-as-symbol (mapcar 'el-get-source-name 
					 el-get-sources))))

(el-get 'sync my-packages)
					;(el-get 'sync)

(yas-global-mode 1)
(yas/load-directory "~/.emacs.d/yasnippet/snippets")

(require 'hideshow)

(defvar hs-special-modes-alist
  (mapcar 'purecopy
	  '((c-mode "{" "}" "/[*/]" nil nil)
	    (c++-mode "{" "}" "/[*/]" nil nil)
	    (bibtex-mode ("@\\S(*\\(\\s(\\)" 1))
	    (java-mode "{" "}" "/[*/]" nil nil)
	    (js-mode "{" "}" "/[*/]" nil)
	    (emacs-lisp-mode "(" ")" nil))))

(add-hook 'c-mode-common-hook	'hs-minor-mode)
(add-hook 'emacs-lisp-mode-hook 'hs-minor-mode)
(add-hook 'java-mode-hook	'hs-minor-mode)
(add-hook 'lisp-mode-hook	'hs-minor-mode)
(add-hook 'perl-mode-hook	'hs-minor-mode)
(add-hook 'sh-mode-hook		'hs-minor-mode)

(global-set-key (kbd "<f9>") 'hs-toggle-hiding)
(global-set-key (kbd "S-<f9>") 'hs-hide-all)
(global-set-key (kbd "C-S-<f9>") 'hs-show-all)

(show-paren-mode 1)

(defun create-tags (dir-name)
  "Create tags file."
  (interactive "DDirectory: ")
  (eshell-command 
   (format "find %s -type f -name \"*.[ch]\" | sudo etags -" dir-name)))

(defun show-file-name ()
  "Show the full path file name in the minibuffer."
  (interactive)
  (message (buffer-file-name)))

(semantic-mode 1)
(global-ede-mode 1)
(global-semantic-idle-completions-mode t)
(global-semantic-decoration-mode t)
(global-semantic-highlight-func-mode t)
(global-semantic-show-unmatched-syntax-mode t)

(font-lock-add-keywords
 'c-mode
 '(("\\<\\(\\sw+\\) ?(" 1 'font-lock-function-name-face)))
'(font-lock-faces)
					; CC-mode
(add-hook 'c-mode-hook '(lambda ()
			  (setq ac-sources (append '(ac-source-semantic) ac-sources))
			  (local-set-key (kbd "RET") 'newline-and-indent)
			  (semantic-mode t)))

;; Autocomplete
					;(require 'auto-complete-config)
					;(add-to-list 'ac-dictionary-directories (expand-file-name
					;					 "~/.emacs.d/el-get/auto-complete/dict"))
					;(setq ac-comphist-file (expand-file-name
					;			"~/.emacs.d/ac-comphist.dat"))
					;(ac-config-default)
(flycheck-mode t)
(defmacro flycheck-define-clike-checker (name command modes)
  `(flycheck-define-checker ,(intern (format "%s" name))
     ,(format "A %s checker using %s" name (car command))
     :command (,@command source-inplace)
     :error-patterns
     ((warning line-start (file-name) ":" line ":" column
	       ": warning: " (message) line-end)
      (error line-start (file-name) ":" line ":" column
	     ": error: " (message) line-end))
     :modes ',modes))
(flycheck-define-clike-checker c-gcc
			       ("gcc" "-fsyntax-only" "-Wall" "-Wextra")
			       c-mode)
(add-to-list 'flycheck-checkers 'c-gcc)

					;(load "jde")

(setq load-path (cons "/home/shur1k/.emacs.d/geben" load-path))

(autoload 'geben "geben" "DBGp protocol frontend, a script debugger" t)

;; Debug a simple PHP script.
;; Change the session key my-php-54 to any session key text you like
(defun my-php-debug ()
  "Run current PHP script for debugging with geben"
  (interactive)
  (call-interactively 'geben)
  (shell-command
   (concat "XDEBUG_CONFIG='idekey=my-php-55' /usr/bin/php5.5 "
	   (buffer-file-name) " &"))
  )

(global-set-key [f5] 'my-php-debug)

(add-to-list 'auto-mode-alist '("\\.phtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode)) 
(add-to-list 'auto-mode-alist '("\\.[gj]sp\\'" . web-mode)) 
(add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode)) 
(add-to-list 'auto-mode-alist '("\\.mustache\\'" . web-mode)) 
(add-to-list 'auto-mode-alist '("\\.djhtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.inc?\\'" . web-mode))

(add-to-list 'auto-mode-alist '("\\.php?\\'" . web-mode))

(add-hook 'js-mode-hook 'js2-minor-mode)

(add-hook 'js-mode-hook
	  (lambda () (flymake-mode t)))

(define-globalized-minor-mode
  global-fci-mode fci-mode (lambda () (fci-mode 1)))

(global-fci-mode t)

					;(package-initialize)
(elpy-enable)

;(setq eclim-executable "/opt/eclipse-sdk-bin-4.3/eclim")


;(add-hook 'python-mode-hook
;  (lambda ()
;    (setq indent-tabs-mode t)
;    (setq python-indent 4)
;    (setq tab-width 4))
;    (tabify (point-min) (point-max)))

(add-hook 'python-mode-hook
  (lambda ()
    (setq indent-tabs-mode nil))

(setq elpy-rpc-python-command 'python27)
