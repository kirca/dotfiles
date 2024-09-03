;; init.el --- Emacs configuration

;; INSTALL PACKAGES
;; --------------------------------------

(require 'package)

(add-to-list 'package-archives '("org" . "https://orgmode.org/elpa/") t)
(add-to-list 'package-archives
             '("melpa-stable" . "https://stable.melpa.org/packages/"))
(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/") t)
(load-file "~/.emacs.d/yaml-mode/yaml-mode.el")
;; (load-file "~/.emacs.d/docker-tramp.el/docker-tramp.el")
;; (load-file "~/.emacs.d/lxc-tramp.el/lxc-tramp.el")
;; (load-file "~/.emacs.d/haxe-mode.el")
;; (load-file "~/.emacs.d/beancount.el")
;; (load-file "~/.emacs.d/subtitles.el")

;; (add-to-list 'load-path "~/.emacs.d/notmuch-0.21/")
;; (require 'notmuch)

;; (add-to-list 'load-path "~/.emacs.d/emacs-gdscript-mode/")
;; (setq prog-first-column 0)
;; (require 'gdscript-mode)

(add-to-list 'process-coding-system-alist '("python" . (utf-8 . utf-8)))

(add-to-list 'load-path "~/.emacs.d/copilot.el")

(package-initialize)
(when (not package-archive-contents)
  (package-refresh-contents))

(defvar myPackages
  '(better-defaults
    dockerfile-mode
    elpy
    csv-mode
    flycheck
    material-theme
    magit
    elixir-mode
    alchemist
    cider
    haskell-mode
    ;;intero
    go-mode
    ledger-mode
    rust-mode
    elm-mode
    haxe-mode
    markdown-mode
    web-mode
    org-plus-contrib
    nix-mode
    s
    dash
    editorconfig
    ;;gdscript-mode
    ))

(mapc #'(lambda (package)
    (unless (package-installed-p package)
      (package-install package)))
      myPackages)

;; BASIC CUSTOMIZATION
;; --------------------------------------

(setq inhibit-startup-message t) ;; hide the startup message
(load-theme 'material t) ;; load material theme
(add-hook 'prog-mode-hook #'display-line-numbers-mode) ;; enable line numbers in programming modes
(global-auto-revert-mode 1) ;; auto reload buffer when underlying file is changed 
                            ;; (example by git checkout)

(setq csv-separators '("," ";"))
(setq nxml-child-indent 4 nxml-attribute-indent 4)
(setq html-child-indent 4 html-attribute-indent 4)
(setq-default tab-width 4)

(menu-bar-mode -1)
(toggle-scroll-bar -1)
(tool-bar-mode -1)

(require 'better-defaults)

;; PYTHON CUSTOMIZATION
;; ------------------------

(require 'pyvenv)
(pyvenv-activate "~/.elpy-venv")

(elpy-enable)
(setq python-shell-interpreter "~/.elpy-venv/bin/ipython3"
      python-shell-interpreter-args "-i --simple-prompt"
      elpy-rpc-python-command "~/.elpy-venv/bin/python3")

(when (require 'flycheck nil t)
  (setq elpy-modules (delq 'elpy-module-flymake elpy-modules))
  (add-hook 'elpy-mode-hook 'flycheck-mode))

;; init.el ends here
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ledger-reports
   (quote
    (("balance" "hledger balancesheet ")
     ("bal" "%(binary) -f %(ledger-file) bal")
     ("reg" "%(binary) -f %(ledger-file) reg")
     ("payee" "%(binary) -f %(ledger-file) reg @%(payee)")
     ("account" "%(binary) -f %(ledger-file) reg %(account)"))))
 '(package-selected-packages
   (quote
    (kubernetes erlang markdown-mode magit material-theme flycheck elpy dockerfile-mode csv-mode better-defaults))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; Org CUSTOMIZATION
;; ------------------------

(global-set-key "\C-cl" 'org-store-link)

(org-babel-do-load-languages
 'org-babel-load-languages
 '((python . t)))
(setq org-babel-python-command "python3")
(setq org-src-tab-acts-natively t)
(setq org-src-fontify-natively t)
(setq org-startup-truncated nil)
(setq org-startup-folded t)
(setq org-time-clocksum-use-fractional t)
(setq org-agenda-files '("~/projects/lambda-is-tasks"))
(setq org-agenda-prefix-format
      '((agenda . " %-12:c %b %?-12t% s")
        (timeline . "  % s")
        (todo . " %i %-12:c")
        (tags . " %i %-12:c")
        (search . " %i %-12:c")))

(require 'ol-notmuch)
(require 'ox-latex)
(add-to-list 'org-latex-packages-alist '("" "tabularx"))

;; Tramp
;;-----------------
(setq tramp-histfile-override "/tmp/.tramp_history")

;; Haskell
;;-----------------
(add-hook 'haskell-mode-hook 'intero-mode)

;; hledger
;;------------
;; Required to use hledger instead of ledger itself.
(setq ledger-mode-should-check-version nil
      ledger-report-links-in-register nil
      ledger-binary-path "hledger")

;; haXe
;;-------
(defconst my-haxe-style
  '("java" (c-offsets-alist . ((case-label . +)
                               (arglist-intro . +)
                               (arglist-cont-nonempty . 0)
                               (arglist-close . 0)
                               (cpp-macro . 0))))
  "My Haxe Programming Style")
(add-hook 'haxe-mode-hook
  (function (lambda () (c-add-style "haxe" my-haxe-style t))))
(add-hook 'haxe-mode-hook
          (function
           (lambda ()
             (setq tab-width 4)
             (setq indent-tabs-mode t)
             (setq fill-column 80)
             (local-set-key [(return)] 'newline-and-indent))))

;; web-mode
;; -------------

(add-to-list 'auto-mode-alist '("\\.liquid\\'" . web-mode))

;; nix
;; -----------
(require 'nix-mode)
(add-to-list 'auto-mode-alist '("\\.nix\\'" . nix-mode))

;; copilot
;; -----------
(require 'copilot)
(defun rk/no-copilot-mode ()
  "Helper for `rk/no-copilot-modes'."
  (copilot-mode -1))

(defvar rk/no-copilot-modes '(shell-mode
                              inferior-python-mode
                              eshell-mode
                              term-mode
                              vterm-mode
                              comint-mode
                              compilation-mode
                              debugger-mode
                              org-mode
                              dired-mode-hook
                              compilation-mode-hook
                              flutter-mode-hook
                              minibuffer-mode-hook)
  "Modes in which copilot is inconvenient.")

(defun rk/copilot-disable-predicate ()
  "When copilot should not automatically show completions."
  (or rk/copilot-manual-mode
      (member major-mode rk/no-copilot-modes)
      (company--active-p)))

(add-to-list 'copilot-disable-predicates #'rk/copilot-disable-predicate)

(defvar rk/copilot-manual-mode nil
  "When `t' will only show completions when manually triggered, e.g. via M-C-<return>.")

(defun rk/copilot-change-activation ()
  "Switch between three activation modes:
- automatic: copilot will automatically overlay completions
- manual: you need to press a key (M-C-<return>) to trigger completions
- off: copilot is completely disabled."
  (interactive)
  (if (and copilot-mode rk/copilot-manual-mode)
      (progn
        (message "deactivating copilot")
        (global-copilot-mode -1)
        (setq rk/copilot-manual-mode nil))
    (if copilot-mode
        (progn
          (message "activating copilot manual mode")
          (setq rk/copilot-manual-mode t))
      (message "activating copilot mode")
      (global-copilot-mode))))

(define-key global-map (kbd "M-C-c") #'rk/copilot-change-activation)

(defun rk/copilot-complete-or-accept ()
  "Command that either triggers a completion or accepts one if one
is available. Useful if you tend to hammer your keys like I do."
  (interactive)
  (if (copilot--overlay-visible)
      (progn
        (copilot-accept-completion)
        (open-line 1)
        (next-line))
    (copilot-complete)))

(define-key copilot-mode-map (kbd "M-C-<next>") #'copilot-next-completion)
(define-key copilot-mode-map (kbd "M-C-<prior>") #'copilot-previous-completion)
(define-key copilot-mode-map (kbd "M-C-w") #'copilot-accept-completion-by-word)
(define-key copilot-mode-map (kbd "M-C-l") #'copilot-accept-completion-by-line)
(define-key global-map (kbd "M-C-<return>") #'rk/copilot-complete-or-accept)

(defun rk/copilot-quit ()
  "Run `copilot-clear-overlay' or `keyboard-quit'. If copilot is
cleared, make sure the overlay doesn't come back too soon."
  (interactive)
  (condition-case err
      (when copilot--overlay
        (lexical-let ((pre-copilot-disable-predicates copilot-disable-predicates))
          (setq copilot-disable-predicates (list (lambda () t)))
          (copilot-clear-overlay)
          (run-with-idle-timer
           1.0
           nil
           (lambda ()
             (setq copilot-disable-predicates pre-copilot-disable-predicates)))))
    (error handler)))

(advice-add 'keyboard-quit :before #'rk/copilot-quit)
