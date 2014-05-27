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
      '(("files" "^\\*scratch\\*" nil nil bs-visits-non-file bs-sort-buffer-interns-are-last)))

(add-to-list 'load-path "~/.emacs.d/auto-complete")
(require 'auto-complete-config)
(ac-config-default)
(add-to-list 'ac-dictionary-directories "/home/shur1k/.emacs.d/auto-complete/dict")

(require 'sr-speedbar)
(global-set-key (kbd "<f12>") 'sr-speedbar-toggle)

(add-to-list 'load-path "~/.emacs.d/yasnippet")
(require 'yasnippet)
(yas-global-mode 1)
(yas/load-directory "~/.emacs.d/yasnippet/snippets")

(add-to-list 'load-path "~/.emacs.d/el-get/el-get")
(require 'el-get)

(set-default 'truncate-lines nil)

(setq my-packages
      (append
       ;; list of packages we use straight from official recipes
       '(projectile litable sudo-save sudo-ext google-maps tramp magit ctags)

       (mapcar 'el-get-as-symbol (mapcar 'el-get-source-name el-get-sources))))

(el-get 'sync my-packages)
					;(el-get 'sync)

(defvar hs-special-modes-alist
  (mapcar 'purecopy
	  '((c-mode "{" "}" "/[*/]" nil nil)
	    (c++-mode "{" "}" "/[*/]" nil nil)
	    (bibtex-mode ("@\\S(*\\(\\s(\\)" 1))
	    (java-mode "{" "}" "/[*/]" nil nil)
	    (js-mode "{" "}" "/[*/]" nil)
	    (emacs-lisp-mode "(" ")" nil))))

(require 'hideshow)

(global-set-key (kbd "<f9>") 'hs-toggle-hiding)
(global-set-key (kbd "S-<f9>") 'hs-hide-all)
(global-set-key (kbd "C-S-<f9>") 'hs-show-all)

(show-paren-mode 1)

(defun create-tags (dir-name)
  "Create tags file."
  (interactive "DDirectory: ")
  (eshell-command 
   (format "find %s -type f -name \"*.[ch]\" | sudo etags -" dir-name)))
