;;; font-menus-da.el --- Additional font menus.
;; 
;; Filename: font-menus-da.el
;; Description: Additional font menus.  `font-menus.el' fixed for Emacs 24+.
;; Author: Simon Marshal, Francis J. Wright
;; Maintainer: Drew Adams
;; Copyright (C) 2000 Francis J. Wright
;; Copyright (C) 2012, Drew Adams, all rights reserved.
;; Created: Sun Aug 26 07:06:14 2012 (-0700)
;; Version: 
;; Last-Updated: Sun Aug 26 08:12:09 2012 (-0700)
;;           By: dradams
;;     Update #: 37
;; URL: http://www.emacswiki.org/emacs-en/start.el
;; Doc URL: 
;; Keywords: font, highlighting, syntax, decoration
;; Compatibility: 
;; 
;; Features that might be required by this library:
;;
;;   None
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;; Commentary: 
;; 
;; Additional font menus.  `font-menus.el' fixed for Emacs 24+.
;;
;; This is `font-menus.el', by Francis J. Wright, modified slightly so
;; that it continues to work with GNU Emacs 24 and later (as well as
;; older versions).
;;
;;
;; Here is the original Commentary, by F.J. Wright:
;;
;; This package is intended for use with GNU Emacs 20 and adds
;; submenus to the Edit menu to control font lock mode and provide
;; font display.
;;
;;; Installation:
;;
;; Put this file somewhere where Emacs can find it (i.e. in one of the
;; directories in your `load-path' such as `site-lisp'), optionally
;; byte-compile it, and put this in your .emacs:
;;
;;  (require 'font-menus)
;;
;;; Font Display:
;;
;; Extracted from font-lock.el for GNU Emacs 20.3 and
;; `font-lock-menu.el' for GNU Emacs 19, both by Simon Marshal
;; <simon@gnu.ai.mit.edu> and revised to use easymenu and run as a
;; stand-alone package by Francis J. Wright.  (It would be better put
;; back into font-lock.el!)
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;; Change Log:
;;
;; 2012/08/26 dadams
;;     Use font-lock-defaults if font-lock-defaults-alist no longer exists (24+).
;;     Don't put `Display Fonts' at end of menu. Put it after `Display Colors'.
;;     Created from font-menus.el.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 3, or
;; (at your option) any later version.
;; 
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;; 
;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;; Code:

(eval-when-compile
  (require 'easymenu)
  (require 'font-lock))

;; `Syntax Highlighting' menu.  Add to `Edit' menu, before `Text Properties' menu.
(easy-menu-add-item			; (map path item &optional before)
 menu-bar-edit-menu nil
 (easy-menu-create-menu			; (menu-name menu-items)
  "Syntax Highlighting"
  '(["In All Buffers" global-font-lock-mode
     :style toggle :selected global-font-lock-mode :active t]
    ["In Current Buffer" font-lock-mode
     :style toggle :selected font-lock-mode :active t]
    "--"
    ["More In Current Buffer" font-lock-fontify-more
     (nth 2 font-lock-fontify-level)]
    ["Less In Current Buffer" font-lock-fontify-less
     (nth 1 font-lock-fontify-level)]))
 'props)

(defvar font-lock-fontify-level nil	; For less/more fontification.
  "@@@@@@@@@@@@@@@@@")

(defun font-lock-fontify-level (level)
  "Set font-lock highlighting level for current buffer to LEVEL."
  (let ((font-lock-maximum-decoration  level))
    (when font-lock-mode (font-lock-mode))
    (font-lock-mode)
    (when font-lock-verbose
      (message "Fontifying `%s'... level %d" (buffer-name) level))))

(defun font-lock-fontify-less ()
  "Fontify the current buffer using less highlighting (decoration).
See `font-lock-maximum-decoration'."
  (interactive)
  ;; Check in case we get called interactively.
  (if (nth 1 font-lock-fontify-level)
      (font-lock-fontify-level (1- (car font-lock-fontify-level)))
    (error "No less decoration possible")))

(defun font-lock-fontify-more ()
  "Fontify the current buffer using more highlighting (decoration).
See `font-lock-maximum-decoration'."
  (interactive)
  ;; Check in case we get called interactively.
  (if (nth 2 font-lock-fontify-level)
      (font-lock-fontify-level (1+ (car font-lock-fontify-level)))
    (error "No more decoration possible")))

;; This should be called by `font-lock-set-defaults'.
(defun font-lock-set-menu ()
  "Activate fewer/more fontification entries.
Do nothing if there are not multiple levels for the current buffer.
Sets `font-lock-fontify-level' to be of this form:

 (CURRENT-LEVEL  IS-LOWER-LEVEL-P  IS-HIGHER-LEVEL-P)"
  (let ((keywords  (or (nth 0 font-lock-defaults)
                       (and (boundp 'font-lock-defaults-alist)
                            (nth 1 (assq major-mode font-lock-defaults-alist)))
                       (and (consp font-lock-defaults)
                            (carfont-lock-defaults))))
	(level     (font-lock-value-in-major-mode font-lock-maximum-decoration)))
    (make-local-variable 'font-lock-fontify-level)
    (if (or (symbolp keywords)  (= (length keywords) 1))
	(font-lock-unset-menu)
      (cond ((eq level t) (setq level  (1- (length keywords))))
	    ((or (null level) (zerop level))
	     ;; The default level is usually, but not necessarily, level 1.
	     (setq level  (- (length keywords)
                             (length (member (eval (car keywords))
                                             (mapcar 'eval (cdr keywords))))))))
      (setq font-lock-fontify-level  (list level (> level 1)
                                           (< level (1- (length keywords))))))))

;; This should be called by `font-lock-unset-defaults'.
(defun font-lock-unset-menu ()
  "Deactivate fewer/more fontification entries."
  (setq font-lock-fontify-level  nil))

;; Added by FJW:

(defadvice font-lock-set-defaults
  (after font-lock-set-defaults-advice activate)
  "Font Lock Mode Menu support added."
  (font-lock-set-menu))

(defadvice font-lock-unset-defaults
  (after font-lock-unset-defaults-advice activate)
  "Font Lock Mode Menu support added."
  (font-lock-unset-menu))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Font Display:

;; Based on code by "Daniel, Elijah" <Elijah.Daniel@compaq.com>
;; and `list-faces-display' in `faces.el'.

(defun display-fonts ()
  "Sort and display all fonts that Emacs knows about."
  (interactive)
  (with-output-to-temp-buffer "*Fonts*"
    (save-excursion
      (set-buffer standard-output)
      (mapcar (lambda (font) (insert font "\n"))
	      (sort (x-list-fonts "*") 'string-lessp)))
    (print-help-return-message)))

;; DADAMS: Don't put `Display Fonts' at end of menu. Put after `Display Colors'.
;; (define-key-after facemenu-menu [display-fonts]
;;   '("Display Fonts" . display-fonts) t)
;;
(define-key-after facemenu-menu [display-fonts] '("Display Fonts" . display-fonts) 'dc)

(provide 'font-menus)                   ; Need provide this also.
(provide 'font-menus-da)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; font-menus-da.el ends here
