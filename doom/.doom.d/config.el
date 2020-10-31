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
(setq display-line-numbers-type t)

(setq
 projectile-project-search-path '("~/dev/" "~/dev/eks/"))

(add-to-list 'initial-frame-alist '(fullscreen . maximized))

;; format jsonnet on save
(add-hook! jsonnet-mode
           (add-hook 'before-save-hook 'jsonnet-reformat-buffer))

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

  ("s" split-window-below)
  ("v" split-window-right)

  ("d" delete-window)
  ("o" delete-other-windows)

  ("b" switch-to-buffer)
  ("f" find-file)

  ("a" ace-window "ace")
  ("S" ace-swap-window "swap")
  ("D" ace-delete-window "delete")

  ("q" nil "quit"))
;; evil-window-map is bound in "SPC w" by default
(map! :map evil-window-map
      ;; "overrides "w" as I never use that"
      :desc "management"        "w" #'hydra-window/body
      :desc "ace"               "a" #'ace-window
      :desc "ace delete"        "D" #'ace-delete-window
      :desc "ace swap"          "S" #'ace-swap-window)

;; allows "." repeat when indenting in visual mode but sacrifices visual reselection
;; without this doom maps < to <gv and > to >gv
;; `gv` means restore previous visual selection
;; "." does not repeat in visual mode
(map! :v ">" #'evil-shift-right
      :v "<" #'evil-shift-left)

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
