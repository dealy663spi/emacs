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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Configure package management
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; package.el is switched off in early-init.el and never initialized, so any
;; package-* setting here would be inert.  straight.el installs everything,
;; including use-package itself -- see the bootstrap below.
(setq straight-use-package-by-default t)

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
;; Load straight's copy explicitly.  Requiring use-package any earlier would
;; pull in the one built into Emacs and leave straight maintaining a checkout
;; that never runs.
(require 'use-package)
(straight-use-package 'modus-themes)
(require 'modus-themes)  ; ef-themes depends on modus-themes infrastructure

;; Sync exec-path from a login shell so nvm/node tools are visible to Emacs.
;; Spawning a login shell costs about a second here (the profile runs neofetch),
;; so cache the result on disk and only pay that cost again when a shell startup
;; file has been edited since the cache was written.  M-x my/sync-login-path
;; with a prefix argument forces a refresh.

(defvar my/login-path-cache-file
  (locate-user-emacs-file "login-path.cache")
  "File caching PATH as reported by a login shell.")

(defvar my/login-path-source-files
  (mapcar #'expand-file-name
          '("~/.bashrc" "~/.bash_profile" "~/.bash_login" "~/.profile"))
  "Shell startup files that invalidate `my/login-path-cache-file'.
These mirror what `bash -lc' reads; keep the two in sync if that command
changes.  Files that do not exist are ignored.")

(defun my/login-path--from-shell ()
  "Return PATH as reported by a login shell, or nil on failure.
The login shell prints banner output, so tag the value and pull it
back out by marker rather than trusting the whole of stdout."
  (let ((out (shell-command-to-string
              "bash -lc 'printf \"__EMACS_PATH__%s\\n\" \"$PATH\"'")))
    (when (string-match "__EMACS_PATH__\\(.*\\)$" out)
      (let ((path (match-string 1 out)))
        (unless (string-empty-p path) path)))))

(defun my/login-path--cache-fresh-p ()
  "Non-nil if the cache exists and no shell startup file is newer than it."
  (let ((stamp (file-attribute-modification-time
                (file-attributes my/login-path-cache-file))))
    (and stamp
         (not (seq-some
               (lambda (file)
                 (let ((mtime (file-attribute-modification-time
                               (file-attributes file))))
                   (and mtime (time-less-p stamp mtime))))
               my/login-path-source-files)))))

(defun my/login-path (&optional force)
  "Return the login shell's PATH, reading the cache when it is still fresh.
With FORCE non-nil, bypass the cache and re-run the login shell."
  (or (and (not force)
           (my/login-path--cache-fresh-p)
           (with-temp-buffer
             (insert-file-contents my/login-path-cache-file)
             (let ((cached (string-trim (buffer-string))))
               (unless (string-empty-p cached) cached))))
      (when-let* ((path (my/login-path--from-shell)))
        (with-temp-file my/login-path-cache-file (insert path "\n"))
        path)))

(defun my/sync-login-path (&optional force)
  "Set $PATH and `exec-path' from the login shell.
Interactively, a prefix argument bypasses the cache."
  (interactive "P")
  (when-let* ((path (my/login-path force)))
    (setenv "PATH" path)
    ;; `parse-colon-path' maps empty PATH components (a leading, trailing, or
    ;; doubled ":") to nil, and a nil in `exec-path' means "search
    ;; `default-directory'" -- so Emacs would look for executables in whatever
    ;; buffer you happen to be visiting.  Drop them.
    (setq exec-path (append (delq nil (parse-colon-path path))
                            (list exec-directory)))
    (when (called-interactively-p 'interactive)
      (message "exec-path synced from login shell (%d entries)"
               (length exec-path)))))

(my/sync-login-path)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; configure theme
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (straight-use-package 'ef-themes)
;; (require 'ef-themes)

;; (setq ef-themes-bold-constructs t
;;       ef-themes-italic-constructs t)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; set modus theme optinons
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;(straight-use-package 'modus-themes)
;; (require-theme 'modus-themes)

;; Removed: modus-themes-mode-line, -region, -paren-match, -syntax, -completion.
;; Those were dropped in the modus-themes 4.0 rewrite and do not exist in 5.3;
;; setq on an undefined variable succeeds silently, so they had no effect.  The
;; equivalents now live in modus-themes-common-palette-overrides.
(setq modus-themes-bold-constructs t
      modus-themes-italic-constructs t)
(setq modus-themes-italic-constructs t)

(setq modus-themes-common-palette-overrides
      '((bg-mode-line-active bg-inactive)
	,@modus-themes-preset-overrides-intense))
(setq modus-themes-preset-overrides-intense 1)

;; ;; all modus theme cusomizations must be done before the theme is loaded
;; (load-theme 'modus-vivendi t)
(load-theme 'modus-vivendi-deuteranopia t)

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
;; Deferred: a bare (use-package magit) emits a plain require and pulls in ~141
;; libraries (magit-section, transient, with-editor, ...) on every launch, which
;; costs about a third of startup.  :bind gives use-package an autoload to hang
;; the command on, so magit loads on first use instead.
(use-package magit
  :defer t
  :bind ("C-x g" . magit-status))

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

  ;; gptel ships the Claude 5 line (sonnet-5, fable-5) but its Opus entries stop
  ;; at claude-opus-4-8, so register claude-opus-5 ahead of the built-in list.
  ;; Only add models gptel is actually missing -- a duplicate id would shadow
  ;; gptel's own entry on lookup and show twice in the model picker.
  (defconst my/anthropic-models
    (append
     '((claude-opus-5
        :description "Most capable model for complex agentic coding and reasoning"
        :capabilities (media tool-use cache)
        :mime-types ("image/jpeg" "image/png" "image/gif" "image/webp" "application/pdf")
        :context-window 1000
        :input-cost 5
        :output-cost 25
        :cutoff-date "2026-05"))
     gptel--anthropic-models)
    "Anthropic models for gptel, plus claude-opus-5 which gptel lacks.")

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

;; No custom-set-variables/custom-set-faces block here on purpose: the only
;; entry was package-selected-packages, which package.el never reads under
;; straight.  M-x customize will write a fresh block if you ever save one.
