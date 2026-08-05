;; prep for straight.el later
(setq package-enable-at-startup nil)

;; Don't pop up a window for native-compilation warnings from third-party
;; packages.  GNU ELPA flymake 1.4.5 (pulled in as an eglot dependency) is
;; written against Emacs 31 and references functions this Emacs lacks; the
;; call sites are guarded at runtime, so the warnings are cosmetic.
;; They still get logged to *Warnings* if you want to read them.
(setq native-comp-async-report-warnings-errors 'silent)

