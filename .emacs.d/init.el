;; Personal Emacs setup

(require 'package)
(add-to-list 'package-archives '("melpa-stable" . "https://melpa.org/packages/") t)
(package-initialize)


;; Always go fullscreen

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(initial-frame-alist '((fullscreen . maximized)))
 '(package-selected-packages '(smart-shift)))


;; No menu

(menu-bar-mode -1)


;; Automatically reload files when they change on the filesystem?

(global-auto-revert-mode t)


; Get rid of the ugly splash screen

(setq inhibit-splash-screen t)


; Figure out where I'm loading from, so I can reference other files

(defvar my-path (file-name-directory load-file-name))


; Markdown mode

(autoload 'markdown-mode (concat my-path "mode-markdown.el")
   "Major mode for Markdown" t)
(setq auto-mode-alist
   (cons '("\\.md" . markdown-mode) auto-mode-alist))
(setq markdown-command "multimarkdown")
(setq markdown-command-needs-filename t)


; YAML mode

(autoload 'yaml-mode (concat my-path "mode-yaml.el")
   "Major mode for YAML" t)
(add-to-list 'auto-mode-alist '("\\.yml\\'" . yaml-mode))


; First define some interactive functions to use

(defun generate-and-switch-to-buffer ()
  (interactive)
  (switch-to-buffer (generate-new-buffer "new")))

(defun search-whole-buffer ()
  (interactive)
  (beginning-of-buffer)
  (isearch-forward))


;; OS-level pastebin support in MacOS (code from ChatGPT)

(defun pbcopy ()
  "Copy selected text to clipboard using pbcopy."
  (interactive)
  (if (region-active-p)
      (shell-command-on-region (region-beginning) (region-end) "pbcopy")
    (message "No region selected.")))

(defun pbpaste ()
  "Insert text from clipboard at point using pbpaste."
  (interactive)
  (let ((paste (shell-command-to-string "pbpaste")))
    (insert paste)))



; Set up a minor mode map (I forgot why)

(defvar fp-keys-minor-mode-map (make-keymap) "fp-keys-minor-mode keymap.")


; Directional controls similar to contemporary editors

(load (concat my-path "fp-move.el"))

; Keyboard setup based on personal MacOS iTerm settings

(define-key input-decode-map "\e[1;9A" [M-up])
(define-key input-decode-map "\e[1;9B" [M-down])
(define-key input-decode-map "\e[1;9C" [M-right])
(define-key input-decode-map "\e[1;9D" [M-left])

(define-key input-decode-map "\e[1;10A" [S-M-up])
(define-key input-decode-map "\e[1;10B" [S-M-down])
(define-key input-decode-map "\e[1;10C" [S-M-right])
(define-key input-decode-map "\e[1;10D" [S-M-left])

(define-key input-decode-map "\e[1;5A" [C-up])
(define-key input-decode-map "\e[1;5B" [C-down])
(define-key input-decode-map "\e[1;6A" [C-S-up])
(define-key input-decode-map "\e[1;6B" [C-S-down])


(define-key fp-keys-minor-mode-map (kbd "M-<right>") 'forward-word-nomark)
(define-key fp-keys-minor-mode-map (kbd "M-<left>") 'backward-word-nomark)
(define-key fp-keys-minor-mode-map (kbd "S-M-<right>") 'forward-word-select)
(define-key fp-keys-minor-mode-map (kbd "S-M-<left>") 'backward-word-select)
(define-key fp-keys-minor-mode-map (kbd "S-<right>") 'right-char-select)
(define-key fp-keys-minor-mode-map (kbd "S-<left>") 'left-char-select)
(define-key fp-keys-minor-mode-map (kbd "<left>") 'left-char-nomark)
(define-key fp-keys-minor-mode-map (kbd "<right>") 'right-char-nomark)
(define-key fp-keys-minor-mode-map (kbd "S-<down>") 'next-line-select)
(define-key fp-keys-minor-mode-map (kbd "S-<up>") 'previous-line-select)
(define-key fp-keys-minor-mode-map (kbd "<down>") 'next-line-nomark)
(define-key fp-keys-minor-mode-map (kbd "<up>") 'previous-line-nomark)

; In MacOS setup, command-arrow looks like ctrl-arrow

(define-key fp-keys-minor-mode-map (kbd "C-<right>") 'end-of-line-nomark)
(define-key fp-keys-minor-mode-map (kbd "C-<left>") 'beginning-of-line-nomark)
(define-key fp-keys-minor-mode-map (kbd "C-S-<right>") 'end-of-line-select)
(define-key fp-keys-minor-mode-map (kbd "C-S-<left>") 'beginning-of-line-select)

(define-key fp-keys-minor-mode-map (kbd "C-<down>") 'end-of-buffer-nomark)
(define-key fp-keys-minor-mode-map (kbd "C-<up>") 'beginning-of-buffer-nomark)
(define-key fp-keys-minor-mode-map (kbd "C-S-<down>") 'end-of-buffer-select)
(define-key fp-keys-minor-mode-map (kbd "C-S-<up>") 'beginning-of-buffer-select)

(define-key fp-keys-minor-mode-map (kbd "M-<down>") 'scroll-up-command)
(define-key fp-keys-minor-mode-map (kbd "M-<up>") 'scroll-down-command)


; My versions of buffer commands

(define-key fp-keys-minor-mode-map (kbd "C-x C-e") 'eval-buffer)
(define-key fp-keys-minor-mode-map (kbd "C-x C-l") 'list-buffers)


; MacOS pastebin support

(define-key fp-keys-minor-mode-map (kbd "M-c") 'pbcopy)
(define-key fp-keys-minor-mode-map (kbd "M-v") 'pbpaste)


; Familiar controls like MacOS command keys

(define-key fp-keys-minor-mode-map (kbd "C-s") 'save-buffer)
(define-key fp-keys-minor-mode-map (kbd "C-n") 'generate-and-switch-to-buffer)
(define-key fp-keys-minor-mode-map (kbd "C-o") 'find-file)
(define-key fp-keys-minor-mode-map (kbd "C-w") 'kill-this-buffer)
(define-key fp-keys-minor-mode-map (kbd "C-q") 'save-buffers-kill-terminal)
(define-key fp-keys-minor-mode-map (kbd "C-p") 'print-buffer)
(define-key fp-keys-minor-mode-map (kbd "C-M-f") 'search-whole-buffer)
(define-key fp-keys-minor-mode-map (kbd "C-f") 'isearch-forward)
(define-key fp-keys-minor-mode-map (kbd "C-g") 'goto-line)


; Easier to remember shell and term commands

(defun shell-command-to-buffer (command)
  (interactive "sShell command to buffer: ")
  (let ((output (shell-command-to-string command)))
    (insert output)))

(defun shell-command-on-region-xarg (command)
  (interactive "sShell command on region: ")
  (let ((full-command (concat "xargs -0 " command)))
    (shell-command-on-region (region-beginning) (region-end) full-command)))

(define-key fp-keys-minor-mode-map (kbd "C-y C-y") 'shell-command)
(define-key fp-keys-minor-mode-map (kbd "C-y C-b") 'shell-command-to-buffer)
(define-key fp-keys-minor-mode-map (kbd "C-y C-r") 'shell-command-on-region-xarg)
(define-key fp-keys-minor-mode-map (kbd "C-y C-t") 'term)


; Custom indentation/tab behaviour

(load (concat my-path "fp-indent.el"))

(define-key fp-keys-minor-mode-map (kbd "TAB") 'shift-region-right)
(define-key fp-keys-minor-mode-map (kbd "<backtab>") 'shift-region-left)


;; Define the mode for the keys

(define-minor-mode fp-keys-minor-mode
  "A minor mode so that my key settings override annoying major modes."
  :init-value t :lighter " fp-keys" :keymap 'fp-keys-minor-mode-map :global t)


; Always use my keys...

(fp-keys-minor-mode 1)


; ...unless I'm in the minibuffer (isn't there an easier way?)

(defun fp-keys-off-hook () (fp-keys-minor-mode 0))
(add-hook 'minibuffer-setup-hook 'fp-keys-off-hook)
(defun fp-keys-on-hook () (fp-keys-minor-mode 1))
(add-hook 'minibuffer-exit-hook 'fp-keys-on-hook)


; ctrl-F to continue search once it's started
; http://stackoverflow.com/questions/18157602/emacs-key-binding-for-isearch-forward

(define-key isearch-mode-map "\C-f" 'isearch-repeat-forward)


; Load my favorite color theme

(load-theme 'tango-dark t)


; Always wrap text in text mode

(add-hook 'text-mode-hook 'visual-line-mode)


; Hide the tool bar
; http://superuser.com/questions/127420/how-can-i-hide-the-tool-bar-in-emacs-persistently

(if (functionp 'tool-bar-mode) (tool-bar-mode -1))


; Don't save those damn files with tildes or hashes

(setq make-backup-files nil)
(setq auto-save-default nil)


;; Copy/paste fixes
;; http://hugoheden.wordpress.com/2009/03/08/copypaste-with-emacs-in-terminal/
;; only for Linux or x-windows systems
;; (setq x-select-enable-clipboard t)
;; (unless window-system
;;  (when (getenv "DISPLAY")
;;   (defun xsel-cut-function (text &optional push)
;;     (with-temp-buffer
;;       (insert text)
;;       (call-process-region (point-min) (point-max) "xsel" nil 0 nil "--clipboard" "--input")))
;;   (defun xsel-paste-function()
;;     (let ((xsel-output (shell-command-to-string "xsel --clipboard --output")))
;;       (unless (string= (car kill-ring) xsel-output)
;; 	xsel-output )))
;;   (setq interprogram-cut-function 'xsel-cut-function)
;;   (setq interprogram-paste-function 'xsel-paste-function)
;;  ))


; Disable electric indent mode so it doesn't move stuff around

(if (functionp 'electric-indent-mode) (electric-indent-mode -1))


; Use CUA mode for Windows/MacOS-style copy/paste

(cua-mode t)
(setq cua-auto-tabify-rectangles nil)
(transient-mark-mode 1)
(setq cua-keep-region-after-copy t)
(define-key cua--cua-keys-keymap (kbd "M-v") nil)


(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(defun start-journal-date ()
  "Go to the end of the buffer, insert a newline, a hash symbol, space, date in YYYYMMDD format, and two more newlines."
  (interactive)
  ;; Go to the end of the buffer
  (goto-char (point-max))
  ;; Insert newline and hash symbol
  (insert "\n# ")
  ;; Insert the date by calling the shell command `date +%Y%m%d`
  (insert (shell-command-to-string "date +%Y%m%d"))
  ;; Insert two more newlines
  (insert "\n\n"))


;; Always follow symlinks
(setq vc-follow-symlinks t)

;; https://busy.steamwiz.io

(load (concat my-path "busy.el"))
