;;; mcore-mode.el

;;;;;;;;;;;;;;;;;;
;; Highlighting ;;
;;;;;;;;;;;;;;;;;;

;; Please keep this list sorted
(setq mcore-keywords
     '(
       "Lam"
       "con"
       "else"
       "end"
       "fix"
       "if"
       "in"
       "lam"
       "lang"
       "let"
       "match"
       "recursive"
       "sem"
       "syn"
       "then"
       "type"
       "use"
       "utest"
       "with"
      ))

(setq mcore-constants
      '(
        "false"
        "true"
        ))

(setq mcore-primitives
      '( )) ;; Primitive types (intensionally left blank)

(setq mcore-operators
     '( )) ;; Intensionally left blank

(setq mcore-warning
     '("mexpr"
       "include"
       "never"
       "error"
       ))

(setq mcore-keywords-regexp (regexp-opt mcore-keywords 'symbols))
(setq mcore-operators-regexp (regexp-opt mcore-operators 'symbols))
(setq mcore-constants-regexp (regexp-opt mcore-constants 'symbols))
(setq mcore-primitives-regexp (regexp-opt mcore-primitives 'symbols))
(setq mcore-warning-regexp (regexp-opt mcore-warning 'symbols))

(setq mcore-types-regexp "\\_<[[:upper:]][[:word:]]*\\_>")

(setq mcore-font-lock-keywords
     `(
       (,mcore-keywords-regexp   . font-lock-keyword-face)
       (,mcore-constants-regexp  . font-lock-constant-face)
       (,mcore-primitives-regexp . font-lock-type-face)
       (,mcore-operators-regexp  . font-lock-builtin-face)
       (,mcore-types-regexp      . font-lock-type-face)
       (,mcore-warning-regexp     . font-lock-warning-face)
       )
     )

(defvar mcore-mode-syntax-table nil "Syntax table for `mcore-mode'.")

(setq mcore-mode-syntax-table
      (let ((table (make-syntax-table)))
        ;; Inline comment "-- ..."
        ;; Block comment "/- ... -/"
        (modify-syntax-entry ?- ". 123" table)
        (modify-syntax-entry ?/ ". 14cn" table)
        (modify-syntax-entry ?\n "> " table)
        (modify-syntax-entry ?' "\"" table)
        table))

;;;;;;;;;;;;;;
;; prettify ;;
;;;;;;;;;;;;;;

(defvar mcore-prettify-symbols-alist
  '(("lam" . 955))                      ; λ
  "List of syntax to prettify for `mcore-mode'.")

(if (boundp 'prettify-symbols-alist)
    (add-hook 'mcore-mode-hook
              (lambda ()
                (mapc (lambda (pair) (push pair prettify-symbols-alist))
                      mcore-prettify-symbols-alist))))

;;;;;;;;;;;;;;;;;
;; compilation ;;
;;;;;;;;;;;;;;;;;

(add-hook 'mcore-mode-hook
          (lambda ()
            ;; Set default compile command
            (progn
              (set (make-local-variable 'compile-command)
                   (concat "mi " (buffer-name)))
              ;; Get location of standard library from environment
              (let ((path
                     (replace-regexp-in-string
                      "[[:space:]\n]*$" ""
                      (shell-command-to-string "$SHELL -l -c 'echo $MCORE_STDLIB'"))))
                (if (> (length path) 0)
                  (set (make-local-variable 'compilation-environment)
                       (list (concat "MCORE_STDLIB=" path))))))))

(setq mcore-error-regexp
      '(mcore "\"\\(.+\\)\" \\([0-9]+\\):\\([0-9]+\\)" 1 2 3))
(add-hook 'compilation-mode-hook
          (lambda ()
            (add-to-list 'compilation-error-regexp-alist-alist mcore-error-regexp)
            (add-to-list 'compilation-error-regexp-alist 'mcore)))

;;;;;;;;;;;;;;;;;;;;;
;; mode definition ;;
;;;;;;;;;;;;;;;;;;;;;

(define-derived-mode mcore-mode prog-mode
 (setq font-lock-defaults '(mcore-font-lock-keywords))
 (setq mode-name "mcore")
 (setq-local comment-start "--")
 (setq-local comment-end ""))

;; Open “*.mcore” in mcore-mode
(add-to-list 'auto-mode-alist '("\\.mc\\'" . mcore-mode))

(provide 'mcore-mode)
;;; mcore-mode.el ends here
