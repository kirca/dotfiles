;; init.el --- Emacs configuration

;; INSTALL PACKAGES
;; --------------------------------------

(require 'package)

(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/") t)
(load-file "~/.emacs.d/yaml-mode/yaml-mode.el")
(load-file "~/.emacs.d/docker-tramp.el/docker-tramp.el")
(load-file "~/.emacs.d/lxc-tramp.el/lxc-tramp.el")

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
(elpy-use-ipython)

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

(setq org-src-fontify-natively t)
(setq org-startup-truncated nil)
(setq org-time-clocksum-use-fractional t)


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
