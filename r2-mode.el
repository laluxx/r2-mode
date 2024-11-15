;;; r2-mode.el --- Interactive radare2 mode with INFO and Usage highlighting
;;; Commentary:
;;; Simple mode for radare2 that highlights INFO: and Usage: sections

;;; Code:
(require 'comint)
(require 'diredfl)

;; Faces
(defface r2-info-prefix-face
  '((t :inherit diredfl-flag-mark
       :extend t))
  "Face for the INFO: prefix at start of lines."
  :group 'r2-mode)

(defface r2-info-line-face
  '((t :inherit diredfl-flag-mark-line
       :extend t))
  "Face for the content of INFO: lines."
  :group 'r2-mode)

(defface r2-usage-title-face
  '((t :inherit font-lock-keyword-face
       :weight bold))
  "Face for Usage: titles."
  :group 'r2-mode)

(defface r2-usage-pipe-face
  '((t :inherit font-lock-comment-face
       :weight bold))
  "Face for the vertical pipes in usage sections."
  :group 'r2-mode)

(defface r2-usage-command-face
  '((t :inherit font-lock-function-name-face))
  "Face for command names in usage sections."
  :group 'r2-mode)

(defface r2-usage-description-face
  '((t :inherit font-lock-doc-face))
  "Face for command descriptions in usage sections."
  :group 'r2-mode)

(defvar r2-mode-font-lock-keywords
  `(;; INFO: lines
    (,"^\\(INFO:\\)\\(.*\\(\n\\|\\'\\)\\)"
     (1 'r2-info-prefix-face t)
     (2 'r2-info-line-face t))
    
    ;; Usage: title with comment
    ("^\\(Usage:\\) *\\([^#\n]*\\)\\(#.*\\)?$"
     (1 'r2-usage-title-face t)
     (2 'r2-usage-description-face t)
     (3 'font-lock-comment-face t t))
    
    ;; Command lines with vertical bars - handle both spaced and non-spaced variants
    ("^\\(|\\)\\(?:[[:space:]]*\\)\\([^[:space:]#|][^#|]*?\\)?\\(?:[[:space:]]+\\)\\([^#\n]*\\)\\(?:[[:space:]]*\\)\\(#.*\\)?$"
     (1 '(face r2-usage-pipe-face 
               display "┃") t)
     (2 'r2-usage-command-face t t)
     (3 'r2-usage-description-face t t)
     (4 'font-lock-comment-face t t)))
  "Font lock keywords for r2-mode.")

(defvar r2-mode-map
  (let ((map (make-sparse-keymap)))
    map)
  "Keymap for r2-mode.")

(define-derived-mode r2-mode comint-mode "R2"
  "Major mode for interacting with radare2."
  (setq comint-prompt-regexp "^\\[.*\\]> ")
  (setq comint-process-echoes t)
  (setq comint-use-prompt-regexp t)
  
  ;; Setup font-lock with case-insensitive highlighting
  (setq font-lock-defaults '(r2-mode-font-lock-keywords t nil))
  
  ;; Enable font-lock extend mode
  (setq-local font-lock-extend-region-functions
              '(font-lock-extend-region-wholelines)))

(defun r2-start-process (file)
  "Start radare2 process for FILE."
  (let* ((buffer (get-buffer-create (format "*r2:%s*" (expand-file-name file))))
         (process (make-comint-in-buffer "r2" buffer "r2" nil file)))
    (with-current-buffer buffer
      (r2-mode))
    buffer))

;;;###autoload
(defun r2-open (file)
  "Open FILE in radare2."
  (interactive 
   (list (read-file-name "File to analyze: " nil nil t)))
  (let ((file-path (expand-file-name file)))
    (unless (file-exists-p file-path)
      (error "File %s does not exist" file-path))
    (pop-to-buffer (r2-start-process file-path))))

(provide 'r2-mode)
;;; r2-mode.el ends here
