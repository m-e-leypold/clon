;;; group.lisp --- Group management for Clon

;; Copyright (C) 2008 Didier Verna

;; Author:        Didier Verna <didier@lrde.epita.fr>
;; Maintainer:    Didier Verna <didier@lrde.epita.fr>
;; Created:       Tue Jul  1 15:52:44 2008
;; Last Revision: Tue Jul  1 15:52:44 2008

;; This file is part of Clon.

;; Clon is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2 of the License, or
;; (at your option) any later version.

;; Clon is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.


;;; Commentary:

;; Contents management by FCM version 0.1.


;;; Code:

(in-package :clon)


;; ============================================================================
;; The Group class
;; ============================================================================

(defclass group (container)
  ()
  (:documentation "The GROUP class.
This class groups other groups, options or strings together, effectively
implementing hierarchical program command-line."))

(defun make-group ()
  "Make a new group."
  (make-instance 'group))


;; ============================================================================
;; Group sealing
;; ============================================================================

(defmethod seal ((group group))
  "Seal GROUP."
  (call-next-method)) ;; this calls the CONTAINER sealing method


;; ============================================================================
;; Convenience group definition
;; ============================================================================

(defmacro define-group (group &body body)
  "Evaluate BODY with GROUP bound to a new group, and return it.
GROUP is automatically sealed after BODY is evaluated."
  `(let ((,group (make-group)))
    ,@body
    (seal ,group)
    ,group))

(defmacro declare-group (&body body)
  "Create a new group, evaluate BODY and return the group.
The result of every form in BODY is automatically added to the group.
The group is automatically sealed after BODY is avaluated."
  (let* ((grp (gensym "grp"))
	 (body (mapcar (lambda (form)
			 (list (intern "ADD-TO" 'clon) grp form))
		       body))
	 (text (intern "TEXT"))
	 (flag (intern "FLAG"))
	 (switch (intern "SWITCH"))
	 (stropt (intern "STROPT"))
	 (group (intern "GROUP")))
    `(macrolet ((,text (&rest args) `(make-text ,@args))
		(,flag (&rest args) `(make-flag ,@args))
		(,switch (&rest args) `(make-switch ,@args))
		(,stropt (&rest args) `(make-stropt ,@args))
		(,group (&rest args) `(declare-group ,@args)))
      (let ((,grp (make-group)))
	,@body
	(seal ,grp)
	,grp))))


;;; group.lisp ends here