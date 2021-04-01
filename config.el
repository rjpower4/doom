;;; $DOOMDIR/config.el  --- Personal Configuration -*- lexical-binding: t; -*-
;;
;;; Commentary:
;;
;;; Code:

;; --- Contact information
(setq user-full-name       "Rolfe Power"
      user-mail-address    (rot13 "ebysrcbjre4@tznvy.pbz"))

;; --- Check system type
(defconst *sys/linux*
  (eq system-type 'gnu/linux))

(defconst *sys/win32*
  (eq system-type 'windows-nt))

(defconst *sys/win32*
  (eq system-type 'darwin))

;; --- Are we root?
(defconst *sys/root*
  (string-equal "root" (getenv "USER")))

;;; --- We on a GUI
(defconst *sys/gui*
  (display-graphic-p))

;; --- Finding Executables
(defconst *clangd*
  (or (executable-find "clangd")
      (executable-find "/usr/local/opt/llvm/bin/clangd")))

(defconst *gcc*
  (executable-find "gcc"))

(defconst *git*
  (executable-find "git"))

(defconst *pdflatex*
  (executable-find "pdflatex"))

(defconst *python3*
  (executable-find "python3"))

(defconst *python*
  (executable-find "python"))

(defconst *rg*
  (executable-find "rg"))

(defconst *tr*
  (executable-find "tr"))

;; Basic Settings
(setq-default delete-by-moving-to-trash t
              tab-width 4
              uniquify-buffer-name-style 'forward)
(setq inhibit-compacting-font-caches t)
(global-subword-mode 1) ;; Iterate through CamelCaseWords

;; --- Directories
(setq power/home-directory "/home/rpower/")
(setq power/org-directory (concat power/home-directory "Documents/org"))

;; --- Visual Settings
(setq doom-font (font-spec :family "Hack" :size 15)
      doom-variable-pitch-font (font-spec :family "Roboto")
      doom-serif-font (font-spec :family "Roboto"))

;; Line Numbers
(setq display-line-numbers-type t)

;; Thin grey line separating windows
(set-face-background 'vertical-border "grey")
(set-face-foreground 'vertical-border (face-background 'vertical-border))


;; --- Themes
(use-package! modus-themes
 :config
 (setq modus-themes-no-mixed-fonts t
       modus-themes-org-blocks 'grayscale
       modus-themes-slanted-constructs t))
(setq power/light-theme   'modus-operandi)
(setq power/dark-theme    'modus-vivendi)
(setq power/default-theme 'power/dark-theme)

(defun power/night-mode ()
  (interactive)
  (load-theme power/dark-theme t)
  (doom/reload-theme))

(defun power/day-mode ()
  (interactive)
  (load-theme power/light-theme t)
  (doom/reload-theme))

(after! modus-themes
  (power/night-mode))

;; --- Misc
;; Show time in mode line
(display-time-mode 1)

;; --- Org
(setq org-directory power/org-directory)
(use-package! org
  :mode ("\\.org\\'" . org-mode)
  :init
  (setq org-catch-invisible-edits 'show))

(after! org
  ;; Clear Doom's default templates
  (setq org-capture-templates '())
  (setq org-todo-keywords
        '((sequence "TODO(t)" "PROG(p)" "WAIT(w)" "ATND(a)" "QUES(q)"
                    "|"
                    "DONE(d)" "DEFR(f)" "CANC(c)")))
  (setq org-todo-keyword-faces
        '(("TODO" . "red")
          ("PROG" . "gold")
          ("WAIT" . "orchid")
          ("ATND" . "magenta")
          ("QUES" . "salmon")
          ("DONE" . "forest green")
          ("DEFR" . "steel blue")
          ("CANC" . "dark gray"))
        )
  (setq org-confirm-babel-evaluate nil
        org-use-property-inheritance t
        org-export-use-babel nil
        org-startup-indented t
        org-pretty-entities nil
        org-outline-path-complete-in-steps nil)
  (setq org-agenda-files (list org-directory (concat org-directory "journal/"))))


;; Org Journal
(use-package! org-journal
  :after org
  :config
  (customize-set-variable 'org-journal-dir
                          (expand-file-name "journal/" org-directory))
  (customize-set-variable 'org-journal-file-format "%Y-%m-%d.org")
  (customize-set-variable 'org-journal-date-format "%Y-%m-%d")
  (customize-set-variable 'org-journal-time-prefix "* ")
  (customize-set-variable 'org-journal-time-format ""))

;; Pomodoro
(setq org-pomodoro-keep-killed-pomodoro-time 1)

;; -- Dired
(after! dired
  (setq dired-listing-switches "-aBhl  --group-directories-first"))

;; --- Python
(after! python
  (setq python-shell-interpreter "python3"))

;; --- Latex
(after! latex (setq font-latex-fontify-script nil))

;; --- Avy

;; Custom Bindings for jumping
(use-package! avy
  :custom
  (avy-all-windows t)
  :config
  (map! :leader
        :desc "Word"   "j" #'avy-goto-word-or-subword-1
        :desc "Window" "W" #'ace-window
        :desc "Line"   "J" #'avy-goto-line))

;; --- Ace window
(use-package! ace-window
  :config
  (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))
  (map! :leader
        "w w" 'ace-window))

;; --- Swiper
(setq swiper-use-visual-line nil)
(setq swiper-use-visual-line-p (lambda (_) nil))

;; --- Clangd
(setq lsp-clients-clangd-args '("-j=3"
                                "--background-index"
                                "--clang-tidy"
                                "--completion-style=detailed"
                                "--header-insertion=never"))
(after! lsp-clangd (set-lsp-priority! 'clangd 2))

;; Misc
(setq confirm-kill-emacs nil)
(add-hook 'compilation-filter-hook 'comint-truncate-buffer)
(setq comint-buffer-maximum-size 2000)

;; History
(use-package! recentf
  :custom
  (recentf-exclude '((expand-file-name package-user-dir)
                     ".cache"
                     ".cask"
                     ".elfeed"
                     "bookmarks"
                     "cache"
                     "ido.*"
                     "persp-confs"
                     "recentf"
                     "undo-tree-hist"
                     "url"
                     "COMMIT_EDITMSG\\'")))

;; Evil
(use-package! evil
  :custom
  (evil-normal-state-cursor  'box)
  (evil-insert-state-cursor  'box)
  (evil-visual-state-cursor  'hollow)
  (evil-motion-state-cursor   nil)
  (evil-replace-state-cursor  'hbar)
  (evil-operator-state-cursor 'evil-half-cursor))

;; Show a message
(setq initial-scratch-message ";; Welcome to emacs!\n\n")

;; Show the fill column
(add-hook 'prog-mode-hook 'display-fill-column-indicator-mode)
(setq fill-column 90)

;; Julia
(use-package! julia-repl
  :config
  (julia-repl-set-terminal-backend 'vterm))

(setq recentf-max-saved-items 10000)
