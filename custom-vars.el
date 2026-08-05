;; manual config file guided from system crafters

;; Don't display startup message
(setq inhibit-startup-message t
      visible-bell t)

;; Turn off some unneeded UI elements
(menu-bar-mode -1)  ; Leave this one on if you're a beginner!
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; keep track of recently opened files
(recentf-mode 1)

;; Display line numbers in every buffer
(global-display-line-numbers-mode 1)

;; save history of minibuffer inputs
(setq history-length 25)
(savehist-mode 1)

;; remember the last place you visited a file
(save-place-mode 1)

;; Revert buffers when the underlying file has changed
(global-auto-revert-mode 1)
(setq global-auto-revert-non-file-buffers 1)

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ;; configure package management
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;(require 'package)

;; (setq package-archives '(("melpa" . "https://melpa.org/packages/")
;; 			 ("org" . "https://orgmode.org/elpa/")
;; 			 ("elpa" . "https://elpa.gnu.org/packages/")))

;; (package-initialize)
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))
;; (setq use-package-always-ensure t)
(setq straight-use-package-by-default t)

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ;; upgrade built in installer
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq package-install-upgrade-built-in t)

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ;; use some packages
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; (use-package command-log-mode)

;; ;; configure Ivy completion
;; (use-package ivy
;;   :diminish
;;   :bind (("C-s" . swiper)
;;          :map ivy-minibuffer-map
;;          ("TAB" . ivy-alt-done)	
;;          ("C-l" . ivy-alt-done)
;;          ("C-j" . ivy-next-line)
;;          ("C-k" . ivy-previous-line)
;;          :map ivy-switch-buffer-map
;;          ("C-k" . ivy-previous-line)
;;          ("C-l" . ivy-done)
;;          ("C-d" . ivy-switch-buffer-kill)
;;          :map ivy-reverse-i-search-map
;;          ("C-k" . ivy-previous-line)
;;          ("C-d" . ivy-reverse-i-search-kill))
;;   :config
;;   (ivy-mode 1))
;; (custom-set-variables
;;  ;; custom-set-variables was added by Custom.
;;  ;; If you edit it by hand, you could mess it up, so be careful.
;;  ;; Your init file should contain only one such instance.
;;  ;; If there is more than one, they won't work right.
;;  '(package-selected-packages '(command-log-mode ivy)))
;; (custom-set-faces
;;  ;; custom-set-faces was added by Custom.
;;  ;; If you edit it by hand, you could mess it up, so be careful.
;;  ;; Your init file should contain only one such instance.
;;  ;; If there is more than one, they won't work right.
;;  )



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Configure straight.el
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        (or (bound-and-true-p straight-base-dir)
            user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'use-package)
(straight-use-package 'modus-themes)
(require 'modus-themes)  ; ef-themes depends on modus-themes infrastructure

;; Sync exec-path from a login shell so nvm/node tools are visible to Emacs.
;; The login shell prints banner output (neofetch), so tag the value and pull it
;; back out by marker rather than trusting the whole of stdout.
(let* ((out (shell-command-to-string
             "bash -lc 'printf \"__EMACS_PATH__%s\\n\" \"$PATH\"'"))
       (path (and (string-match "__EMACS_PATH__\\(.*\\)$" out)
                  (match-string 1 out))))
  (when (and path (not (string-empty-p path)))
    (setenv "PATH" path)
    (setq exec-path (append (parse-colon-path path) (list exec-directory)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; configure theme
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (straight-use-package 'ef-themes)
;; (require 'ef-themes)

;; (setq ef-themes-bold-constructs t
;;       ef-themes-italic-constructs t)

(load-theme 'modus-vivendi-deuteranopia t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; set modus theme optinons
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;(straight-use-package 'modus-themes)
;; (require-theme 'modus-themes)

;; (setq modus-themes-mode-line '(borderless accented padded))
;; (setq modus-themes-region '(bg-only))
;; (setq modus-themes-bold-constructs t
;;       modus-themes-italic-constructs t
;;       modus-themes-paren-match '(bold intense underline))
;; (setq modus-themes-italic-constructs t)
;; (setq modus-themes-syntax '(alt-syntax faint))

;; (setq modus-themes-common-palette-overrides
;;       '((bg-mode-line-active bg-inactive)
;; 	,@modus-themes-preset-overrides-intense))
;; (setq modus-themes-preset-overrides-intense 1)
;;(setq modus-themes-completion 'opinionated)

;; ;; all modus theme cusomizations must be done before the theme is loaded
;; (load-theme 'modus-vivendi t)
;; (load-theme 'modus-vivendi-deuteranopia t)

;; (define-key global-map (kbd "<f5>")  #'modus-themes-toggle)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Configure windmove
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package windmove
  ;; For readers: don't ensure means that we don't need to download it. It is built in
  :ensure nil
  :bind*
  (("M-<left>" . windmove-left)
   ("M-<right>" . windmove-right)
   ("M-<up>" . windmove-up)
   ("M-<down>" . windmove-down)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Configure magit
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package magit)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Configure co-pilot integration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package editorconfig)

;; jsonrpc is built into Emacs 29+; tell straight not to fetch it as a dependency
(straight-use-package '(jsonrpc :type built-in))

(use-package copilot
  :straight (:host github :repo "copilot-emacs/copilot.el" :files ("*.el"))
  :ensure t
  :bind (:map copilot-completion-map
	      ("<tab>" . 'copilot-accept-completion)
	      ("TAB" . 'copilot-accept-completion)
      	      ("C-<tab>" . 'copilot-accept-completion-by-word)
      	      ("C-TAB" . 'copilot-accept-completion-by-word)))


;; (use-package copilot-chat
;;   :straight (:host github :repo "chep/copilot-chat.el" :files ("*.el"))
;;   :after (request org markdown-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Configure LSP with eglot
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package eglot
  :ensure t
  :defer t
  :config
  (add-to-list 'eglot-server-programs '((sh-mode bash-ts-mode) . ("bash-language-server" "start")))
  
  :hook
  (sh-mode . eglot-ensure)
  (bash-ts-mode . eglot-ensure)
  (python-mode . eglot-ensure))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ;;  Configure Python IDE
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (use-package python-mode
;;   :ensure nil
;;   :custom
;;   (python-shell-interpreter "python3"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Configure gptel (Claude / LLM integration)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package gptel
  :straight (:host github :repo "karthink/gptel" :files ("*.el"))
  :config
  ;; gptel.el does not pull this in, but gptel--anthropic-models lives there.
  (require 'gptel-anthropic)

  ;; This gptel checkout predates the Claude 5 line, so its built-in list stops
  ;; at claude-opus-4-8.  Register the current IDs ahead of it so both show up
  ;; in gptel's model picker.
  (defconst my/anthropic-models
    (append
     '((claude-sonnet-5
        :description "Best combination of speed and intelligence"
        :capabilities (media tool-use cache)
        :mime-types ("image/jpeg" "image/png" "image/gif" "image/webp" "application/pdf")
        :context-window 1000
        :input-cost 3
        :output-cost 15)
       (claude-opus-5
        :description "Most capable model for complex agentic coding and reasoning"
        :capabilities (media tool-use cache)
        :mime-types ("image/jpeg" "image/png" "image/gif" "image/webp" "application/pdf")
        :context-window 1000
        :input-cost 5
        :output-cost 25))
     gptel--anthropic-models)
    "Anthropic models for gptel, with the Claude 5 line prepended.")

  ;; Sonnet is the default; escalate to Opus per-request when a task needs it.
  (defvar my/gptel-default-model 'claude-sonnet-5)
  (defvar my/gptel-heavy-model 'claude-opus-5)

  (defun my/gptel-toggle-model ()
    "Toggle the gptel model between Sonnet and Opus."
    (interactive)
    (setq-local gptel-model
                (if (eq gptel-model my/gptel-heavy-model)
                    my/gptel-default-model
                  my/gptel-heavy-model))
    (message "gptel model: %s" gptel-model))

  ;; Resolve the key lazily: a GUI Emacs may not inherit the login shell's env,
  ;; so fall back to ~/.authinfo.gpg (machine api.anthropic.com ...).
  (setq gptel-model my/gptel-default-model
        gptel-backend (gptel-make-anthropic "Claude"
                        :stream t
                        :models my/anthropic-models
                        :key (lambda ()
                               (or (getenv "ANTHROPIC_API_KEY")
                                   (gptel-api-key-from-auth-source)))))

  :bind (("C-c g" . gptel)
         ("C-c G" . gptel-menu)
         ("C-c M" . my/gptel-toggle-model)))

;; customs after use package
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages '(use-package)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Configure Claude integration 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (use-package gptel
;;   :config
;;   (setq gptel-backend
;;         (gptel-make-anthropic "Claude"
;;           :stream t
;;           :key (getenv "ANTHROPIC_API_KEY")))
;;   (setq gptel-model 'claude-sonnet-4-6))
