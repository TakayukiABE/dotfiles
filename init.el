(add-hook 'doc-view-mode-hook
	  '(lambda()(and (fboundp 'linum-mode) (linum-mode 0))))
(add-hook 'pdf-view-mode-hook
	  '(lambda()(and (fboundp 'linum-mode) (linum-mode 0))))

;; load-path
(add-to-list 'load-path "~/.emacs.d/elpa/yatex.el/")
(add-to-list 'load-path (expand-file-name "~/.emacs.d/elpa/realtime-preview.el/"))

;; 改行時に\\を表示しない
(set-display-table-slot standard-display-table 'wrap ? )

;; C-hをbackspaceとして用いる
(keyboard-translate ?\C-h ?\C-?)

;; エンコーディング設定
(set-language-environment  'utf-8)
(setq default-input-method "MacOSX")
(set-language-environment 'Japanese)
(prefer-coding-system 'utf-8)

;; Zsh利用時に4mと表示されないように
(setq system-uses-terminfo nil)

;; Marmalade and auto-install snippets
(require 'package)
(setq package-archives
      (append
       '(("melpa" . "http://melpa.milkbox.net/packages/")
	 ("marmalade" . "http://marmalade-repo.org/packages/")
	 ("ELPA" . "http://tromey.com/elpa/"))
       package-archives))
(package-initialize)

;; Wanderlust
(autoload 'wl "wl" "Wanderlust" t)
(autoload 'wl-draft "wl" "Write draft with Wanderlust." t)

;; Terminal
;;; shell の存在を確認
(defun skt:shell ()
  (or (executable-find "zsh")
      (executable-find "bash")
      (executable-find "cmdproxy")
      (error "can't find 'shell' command in PATH!!")))
;;; Shell 名の設定
(setq shell-file-name (skt:shell))
(setenv "SHELL" shell-file-name)
(setq explicit-shell-file-name shell-file-name)
;;; ヒストリの選択やカーソル移動の設定
(defun term-send-forward-char ()
  (interactive)
  (term-send-raw-string "\C-f"))
(defun term-send-backward-char ()
  (interactive)
  (term-send-raw-string "\C-b"))
(defun term-send-previous-line ()
  (interactive)
  (term-send-raw-string "\C-p"))
(defun term-send-next-line ()
  (interactive)
  (term-send-raw-string "\C-n"))
;;; Term-mode時のフック設定
(add-hook 'term-mode-hook
	  '(lambda ()
	     (let* ((key-and-func
		     `(("\C-p"           term-send-previous-line)
		       ("\C-n"           term-send-next-line)
		       ("\C-b"           term-send-backward-char)
		       ("\C-f"           term-send-forward-char)
		       (,(kbd "C-h")     term-send-backspace)
		       (,(kbd "C-y")     term-paste)
		       (,(kbd "ESC ESC") term-send-raw)
		       (,(kbd "C-S-p")   multi-term-prev)
		       (,(kbd "C-S-n")   multi-term-next)
		       )))
	       (loop for (keybind function) in key-and-func do
		     (define-key term-raw-map keybind function)))))
;;; C-c tでmulti-term起動、バッファがあれば継続
(global-set-key (kbd "C-c t") '(lambda ()
				 (interactive)
				 (if (get-buffer "*terminal<1>*")
				     (switch-to-buffer "*terminal<1>*")
				                                   (multi-term))))
;;; multi-termバッファの移動
(global-set-key (kbd "C-c n") 'multi-term-next)
(global-set-key (kbd "C-c p") 'multi-term-prev)

;; 1行ずつスクロール
(setq scroll-conservatively 35
      scroll-margin 0
      scroll-step 1)
(setq comint-scroll-show-maximum-output t) ;; shell-mode

;; yes or noをy or n
(fset 'yes-or-no-p 'y-or-n-p)

;; 現在行を目立たせる
(global-hl-line-mode)

;;multiple-cursors
(require 'multiple-cursors)
(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-M->") 'mc/skip-to-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)

;; 対応する括弧のハイライト
(show-paren-mode t)
(setq show-paren-style 'mixed) 

;; 行番号の設定（F5 キーで表示・非表示を切り替え）
(require 'linum)
(global-linum-mode)
(global-set-key [f5] 'linum-mode)
(setq linum-format
      (lambda (line) (propertize (format
				  (let ((w (length (number-to-string
						    (count-lines (point-min) (point-max))
						    )))) (concat "%" (number-to-string w) "d "))
				  line) 'face 'linum)))
(setq linum-format "%4d ")
;;; 行番号の桁数を可変にする場合
;;;(setq linum-format "%d ")

(require 'minimap)
(setq minimap-window-location 'right)


;; バックアップファイルを生成しない
(setq make-backup-files nil)
()
;; M-yでkill-ringのヒストリから選択してyank
;;(global-set-key (kbd "M-y") 'browse-kill-ring)

;;OSXのClipboardとEmacsのkill-ringを同期
;;http://blog.lathi.net/articles/2007/11/07/sharing-the-mac-clipboard-with-emacs
(defun copy-from-osx ()
  (shell-command-to-string "pbpaste"))
(defun paste-to-osx (text &optional push)
  (let ((process-connection-type nil))
    (let ((proc (start-process "pbcopy" "*Messages*" "pbcopy")))
      (process-send-string proc text)
      (process-send-eof proc))))
(setq interprogram-cut-function 'paste-to-osx)
(setq interprogram-paste-function 'copy-from-osx)

;; YaTeXの設定
(require 'yatex)
(autoload 'yatex-mode "yatex" "Yet Another LaTeX mode" t) 
;;; .texファイルを開いた際に自動でYaTeX-modeに
(setq auto-mode-alist
      (cons (cons "\\.tex$" 'yatex-mode) auto-mode-alist))
;;; sectionカラーの設定
(setq YaTeX-hilit-sectioning-face '(White/azure1 White/White))
;;(setq YaTeX-hilit-sectioning-face '(darkblue/LightGray LightGray/Black))
;;; YaTeX-mode時はautopair-modeをオフに
(add-hook 'yatex-mode-hook
	  '(lambda()(and (fboundp 'autopair-mode) (autopair-mode 0))))

;;flycheck-mode
(require 'flycheck)
(add-hook 'after-init-hook #'global-flycheck-mode)
;;あとでflycheck-next-errorとflycheck-previous-errorのキーを定義しておく
(eval-after-load 'flycheck
  '(custom-set-variables
    '(flycheck-display-errors-function #'flycheck-pos-tip-error-messages)))

;; PATHの共有
(load-file (expand-file-name "~/.emacs.d/shellenv.el"))
(dolist (path (reverse (split-string (getenv "PATH") ":")))
    (add-to-list 'exec-path path))

;; ewwの検索エンジンをGoogleに設定
(setq eww-search-prefix "http://www.google.co.jp/search?q=")

;; C-c C-rでウィンドウサイズ変更モードに
(defun window-resizer ()
  "Control window size and position."
  (interactive)
  (let ((window-obj (selected-window))
	(current-width (window-width))
	(current-height (window-height))
	(dx (if (= (nth 0 (window-edges)) 0) 1
	      -1))
	(dy (if (= (nth 1 (window-edges)) 0) 1
	      -1))
	action c)
    (catch 'end-flag
      (while t
	(setq action
	      (read-key-sequence-vector (format "size[%dx%d]"
						(window-width)
						(window-height))))
	(setq c (aref action 0))
	(cond ((= c ?l)
	       (enlarge-window-horizontally dx))
	      ((= c ?h)
	       (shrink-window-horizontally dx))
	      ((= c ?j)
	       (enlarge-window dy))
	      ((= c ?k)
	       (shrink-window dy))
	      ;; otherwise
	      (t
	       (let ((last-command-char (aref action 0))
		     (command (key-binding action)))
		 (when command
		   (call-interactively command)))
	       (message "Quit")
	       (throw 'end-flag t)))))))
(global-set-key "\C-c\C-r" 'window-resizer)

;; Markdownのリアルタイムプレビュー
(require 'realtime-preview)

;; 閉じ括弧等の自動補完
(require 'autopair)
(autopair-global-mode) ;; enable autopair in all buffers

;; 入力補完
(require 'auto-complete)
(require 'auto-complete-config) 
(global-auto-complete-mode t)
(define-key ac-completing-map (kbd "C-n") 'ac-next)
(define-key ac-completing-map (kbd "C-p") 'ac-previous)
(define-key ac-completing-map (kbd "C-m") 'ac-complete)

;; elispのインストールを簡単に
(require 'auto-install)
(auto-install-compatibility-setup)

;; Undoヒストリを木構造で保存
(require 'undo-tree)
(global-undo-tree-mode t)
(global-set-key (kbd "M-/") 'undo-tree-redo)

;; Undoヒストリの保存
(require 'undohist)
(undohist-initialize)

;; Markdown記述用モード
(require 'markdown-mode)
