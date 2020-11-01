;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Shaun Newman"
      user-mail-address "shaun@newmaninbox.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))
(setq doom-font (font-spec :family "Menlo" :size 15))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type nil)

(setq
 projectile-project-search-path '("~/dev/" "~/dev/eks/"))

(add-to-list 'initial-frame-alist '(fullscreen . maximized))

;; format jsonnet on save
(add-hook! jsonnet-mode
           (add-hook 'before-save-hook 'jsonnet-reformat-buffer))

;; change avy keys to dvorak homerow
(setq avy-keys '(?a ?o ?e ?u ?h ?t ?n ?s))
;; disable gray background it's too distracting
(setq avy-background nil)

;; window management
(defhydra hydra-window ()
  "window"
  ("h" windmove-left)
  ("j" windmove-down)
  ("k" windmove-up)
  ("l" windmove-right)

  ("H" hydra-move-splitter-left)
  ("J" hydra-move-splitter-down)
  ("K" hydra-move-splitter-up)
  ("L" hydra-move-splitter-right)
  ("=" balance-windows)

  ("C-h" +evil/window-move-left)
  ("C-j" +evil/window-move-down)
  ("C-k" +evil/window-move-up)
  ("C-l" +evil/window-move-right)

  ("s" scnewma/split-window-below)
  ("v" scnewma/split-window-right)
  ("C-s" split-window-below)
  ("C-v" split-window-right)

  ("d" delete-window)
  ("o" delete-other-windows :color blue)

  ("b" switch-to-buffer)
  ("f" find-file)

  ("a" ace-window "ace")
  ("m" ace-maximize-window "ace-one" :color blue)
  ("S" ace-swap-window "swap")
  ("D" ace-delete-window "delete")

  ("+" doom/increase-font-size)
  ("-" doom/decrease-font-size)
  ("0" doom/reset-font-size)

  ("q" nil "quit"))
;; evil-window-map is bound in "SPC w" by default
(map! :map evil-window-map
      ;; "overrides "w" as I never use that"
      :desc "management"        "w" #'hydra-window/body

      :desc "ace"               "a" #'ace-window
      :desc "ace delete"        "D" #'ace-delete-window
      :desc "ace swap"          "S" #'ace-swap-window

      ;; more often than not I want to move to the split that I create
      :desc "split right"       "v"   #'scnewma/split-window-right
      :desc "split below"       "s"   #'scnewma/split-window-below
      :desc "mirror right"      "C-v" #'split-window-right
      :desc "mirror below"      "C-s" #'split-window-below)

(map! :leader
      ;; swap ";" and ":" since I use M-x more often
      :desc "M-x"               ";" #'execute-extended-command
      :desc "Eval expreession"  ":" #'pp-eval-expression)

(defun scnewma/split-window-below ()
  "split below then move there"
  (interactive)
  (split-window-below)
  (windmove-down))

(defun scnewma/split-window-right ()
  "split right then move there"
  (interactive)
  (split-window-right)
  (windmove-right))

;; allows "." repeat when indenting in visual mode but sacrifices visual reselection
;; without this doom maps < to <gv and > to >gv
;; `gv` means restore previous visual selection
;; "." does not repeat in visual mode
(map! :v ">" #'evil-shift-right
      :v "<" #'evil-shift-left)

;; hydra for json-mode number formatting
(defhydra hydra-json (:color pink)
  "json editing mode"
  ("+" #'json-increment-number-at-point "inc")
  ("-" #'json-decrement-number-at-point "dec")
  ("f" #'json-mode-beautify "format")
  ("x" #'json-nullify-sexp "nullify")
  ("?" #'json-mode-show-path "path")
  ("y" #'json-mode-kill-path "copy path")
  ("t" #'json-toggle-boolean "toggle")
  ("q" nil "quit"))
(map! :after json-mode
      :map json-mode-map
      :localleader
      "e" #'hydra-json/body)

(map! :n "gsG" #'avy-goto-line ;; go to any visible line in any window

      ;; copy/move text from any visible line/region to the cursor
      :n "gsyy" #'avy-copy-line
      :n "gsyr" #'avy-copy-region
      :n "gsYy" #'avy-move-line
      :n "gsYr" #'avy-move-region)

;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
