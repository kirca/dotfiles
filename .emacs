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
(load-file "~/.emacs.d/docker-tramp.el/docker-tramp.el")
(load-file "~/.emacs.d/lxc-tramp.el/lxc-tramp.el")
(load-file "~/.emacs.d/haxe-mode.el")
(load-file "~/.emacs.d/beancount.el")
(load-file "~/.emacs.d/subtitles.el")

(add-to-list 'load-path "~/.emacs.d/notmuch-0.21/")
(require 'notmuch)

(add-to-list 'load-path "~/.emacs.d/emacs-gdscript-mode/")
(setq prog-first-column 0)
(require 'gdscript-mode)

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
    intero
    go-mode
    ledger-mode
    rust-mode
    elm-mode
    haxe-mode
    markdown-mode
    web-mode
    org-plus-contrib
    ))

(mapc #'(lambda (package)
    (unless (package-installed-p package)
      (package-install package)))
      myPackages)

;; BASIC CUSTOMIZATION
;; --------------------------------------

(setq inhibit-startup-message t) ;; hide the startup message
(load-theme 'material t) ;; load material theme
(global-linum-mode t) ;; enable line numbers globally
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

(elpy-enable)
(setq python-shell-interpreter "ipython3"
      python-shell-interpreter-args "-i --simple-prompt"
      elpy-rpc-python-command "python3")

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

(setq org-src-fontify-natively t)
(setq org-startup-truncated nil)
(setq org-time-clocksum-use-fractional t)

(require 'ol-notmuch)
(require 'ox-latex)
(add-to-list 'org-latex-packages-alist '("" "tabularx"))
(add-hook 'org-mode-hook (lambda() (linum-mode -1)))

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
