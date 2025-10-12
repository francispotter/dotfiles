; A personal style of indention and tab control. Uses tab-width to determine
; column for tabbing. If a region is active, then shift the whole region left
; or right to the next tab stop, based on the leftmost occupied column in the
; region. Stop dedention when it hits the left edge. This behaviour is most
; intuitive to me.

(defun col-of-first-char ()
  (save-excursion
    (let ((start (line-beginning-position)))
      (goto-char start)
      (skip-chars-forward " \t")
      (current-column))))

(defun col-of-first-char-in-block (first-line last-line)
    (let* (
        (i first-line)
        (min-col -1))
        (while (<= i last-line)
            (goto-line i)
            (setq i (1+ i))
            (when (or (= min-col -1) (< (col-of-first-char) min-col))
                (setq min-col (col-of-first-char))))
        min-col))

(defun round-up (n w)
  (let ((remainder (mod n w)))
    (if (zerop remainder) w (- w remainder))))

(defun round-down (n w)
    (if (zerop n)
        0        
        (let ((remainder (mod n w)))
            (if (zerop remainder) w remainder))))

(defun indent-numbered-lines (first-line last-line)
    (let* (
        (left-col (col-of-first-char-in-block first-line last-line))
        (shift (round-up left-col tab-width))
        (spaces (make-string shift ? ))
        (i first-line))
        (while (<= i last-line)
            (goto-line i)
            (insert spaces)
            (setq i (1+ i)))))

(defun dedent-numbered-lines (first-line last-line)
    (let* (
        (left-col (col-of-first-char-in-block first-line last-line))
        (shift (round-down left-col tab-width))
        (i first-line))
        (while (<= i last-line)
            (goto-line i)
            (delete-char shift)
            (setq i (1+ i)))))

(defun shift-region-right (&optional tabs)  ; TODO: implement the tabs argument
  (interactive (list (if current-prefix-arg
    (prefix-numeric-value current-prefix-arg) 1)))
    (setq tab-width 4) ; Do this in python-mode? 2 for yaml-mode?
    (if mark-active
        (save-excursion
            (let ((deactivate-mark nil))
                (let ((first-point (region-beginning)) (last-point (region-end)))
                (goto-char first-point)
                (let ((first-line (line-number-at-pos)))
                    (goto-char last-point)
                    (let ((last-line (if (= (point) (line-beginning-position)) (- (line-number-at-pos) 1) (line-number-at-pos))))
                        (indent-numbered-lines first-line last-line))))))
        (if (= (point) (line-beginning-position))
            (indent-numbered-lines (line-number-at-pos) (line-number-at-pos))
            (save-excursion
                (indent-numbered-lines (line-number-at-pos) (line-number-at-pos))))))

(defun shift-region-left (&optional tabs)
  (interactive (list (if current-prefix-arg
    (prefix-numeric-value current-prefix-arg) 1)))
    (setq tab-width 4) ; Do this in python-mode? 2 for yaml-mode?
    (if mark-active
        (save-excursion
            (let ((deactivate-mark nil))
                (let ((first-point (region-beginning)) (last-point (region-end)))
                (goto-char first-point)
                (let ((first-line (line-number-at-pos)))
                    (goto-char last-point)
                    (let ((last-line (if (= (point) (line-beginning-position)) (- (line-number-at-pos) 1) (line-number-at-pos))))
                        (dedent-numbered-lines first-line last-line))))))
        (if (= (point) (line-beginning-position))
            (dedent-numbered-lines (line-number-at-pos) (line-number-at-pos))
            (save-excursion
                (dedent-numbered-lines (line-number-at-pos) (line-number-at-pos))))))
