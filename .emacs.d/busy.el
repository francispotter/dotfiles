;; Functions to work with https://busy.steamwiz.io

(defun busy ()
  (interactive)
  (let ((command (read-string "Busy: ")))
    (term (concat "busy " command))))

(defun busy-heading ()
  (interactive)
  (let ((title (shell-command-to-string "busy view 1"))
        (id (shell-command-to-string "busy view 1 -f val.i")))
    (let ((trimmed-title (string-trim title))
          (trimmed-id (string-trim id)))
      (if (and trimmed-id (not (string-empty-p trimmed-id)))
          (insert "## " trimmed-title " (issue #" trimmed-id ")")
        (insert "## " trimmed-title)))))

(defvar busy-minor-mode-map (make-keymap) "busy-minor-mode keymap.")

(define-key busy-minor-mode-map (kbd "C-b C-x") 'busy)
(define-key busy-minor-mode-map (kbd "C-b C-h") 'busy-heading)

(define-minor-mode busy-minor-mode
  "A minor mode for busy keys."
  :init-value t :lighter " busy" :keymap 'busy-minor-mode-map :global t)

(busy-minor-mode 1)

(defun busy-off-hook () (busy-minor-mode 0))
(add-hook 'minibuffer-setup-hook 'busy-off-hook)
(defun busy-on-hook () (busy-minor-mode 1))
(add-hook 'minibuffer-exit-hook 'busy-on-hook)
