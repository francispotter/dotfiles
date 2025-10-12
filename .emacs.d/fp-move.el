(defun forward-word-nomark ()
  "Clear the mark and move point forward by one word."
  (interactive)
  (setq deactivate-mark t) ; Clear the mark
  (forward-word 1)) ; Move forward by one word


(defun backward-word-nomark ()
  "Clear the mark and move point backward by one word."
  (interactive)
  (setq deactivate-mark t) ; Clear the mark
  (backward-word 1)) ; Move backward by one word

(defun forward-word-select ()
  "Set the mark if the region is not active and move point forward by one word."
  (interactive)
  (unless (region-active-p)
    (set-mark (point)))
  (forward-word 1))

(defun backward-word-select ()
  "Set the mark if the region is not active and move point backward by one word."
  (interactive)
  (unless (region-active-p)
    (set-mark (point)))
  (backward-word 1))

(defun right-char-select ()
  "Set the mark if the region is not active and move point right by one character."
  (interactive)
  (unless (region-active-p)
    (set-mark (point)))
  (right-char 1))

(defun left-char-select ()
  "Set the mark if the region is not active and move point left by one character."
  (interactive)
  (unless (region-active-p)
    (set-mark (point)))
  (left-char 1))

(defun left-char-nomark ()
  "Clear the mark and move point left by one word."
  (interactive)
  (setq deactivate-mark t) ; Clear the mark
  (left-char 1)) ; Move

(defun right-char-nomark ()
  "Clear the mark and move point left by one word."
  (interactive)
  (setq deactivate-mark t) ; Clear the mark
  (right-char 1)) ; Move

(defun next-line-select ()
  "Set the mark if the region is not active and move down one line."
  (interactive)
  (unless (region-active-p)
    (set-mark (point)))
  (next-line 1))

(defun previous-line-select ()
  "Set the mark if the region is not active and move up one line."
  (interactive)
  (unless (region-active-p)
    (set-mark (point)))
  (previous-line 1))

(defun next-line-nomark ()
  "Clear the mark and move down one line."
  (interactive)
  (setq deactivate-mark t) ; Clear the mark
  (next-line 1)) ; Move

(defun previous-line-nomark ()
  "Clear the mark and move up one line."
  (interactive)
  (setq deactivate-mark t) ; Clear the mark
  (previous-line 1)) ; Move

(defun beginning-of-line-nomark ()
  "Clear the mark and move point to beginning of line."
  (interactive)
  (setq deactivate-mark t)
  (beginning-of-line))

(defun end-of-line-nomark ()
  "Clear the mark and move point to end of line."
  (interactive)
  (setq deactivate-mark t)
  (end-of-line))

(defun beginning-of-line-select ()
  "Set the mark if the region is not active and move point to beginning of line."
  (interactive)
  (unless (region-active-p)
    (set-mark (point)))
  (beginning-of-line))

(defun end-of-line-select ()
  "Set the mark if the region is not active and move point to end of line."
  (interactive)
  (unless (region-active-p)
    (set-mark (point)))
  (end-of-line))

(defun beginning-of-buffer-nomark ()
  "Clear the mark and move point to beginning of buffer."
  (interactive)
  (setq deactivate-mark t)
  (goto-char (point-min)))

(defun end-of-buffer-nomark ()
  "Clear the mark and move point to end of buffer."
  (interactive)
  (setq deactivate-mark t)
  (goto-char (point-max)))

(defun beginning-of-buffer-select ()
  "Set the mark if the region is not active and move point to beginning of buffer."
  (interactive)
  (unless (region-active-p)
    (set-mark (point)))
  (goto-char (point-min)))

(defun end-of-buffer-select ()
  "Set the mark if the region is not active and move point to end of buffer."
  (interactive)
  (unless (region-active-p)
    (set-mark (point)))
  (goto-char (point-max)))
