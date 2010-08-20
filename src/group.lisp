;;; group.lisp --- Group management

;; Copyright (C) 2010 Didier Verna

;; Author:        Didier Verna <didier@lrde.epita.fr>
;; Maintainer:    Didier Verna <didier@lrde.epita.fr>
;; Created:       Tue Jul  1 15:52:44 2008
;; Last Revision: Sat Jun 12 18:19:32 2010

;; This file is part of Clon.

;; Clon is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License version 3,
;; as published by the Free Software Foundation.

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

(in-package :com.dvlsoft.clon)
(in-readtable :com.dvlsoft.clon)


;; ==========================================================================
;; The Group class
;; ==========================================================================

(defclass group (container)
  ((header :documentation "The group's header."
	   :initform nil
	   :initarg :header
	   :reader header))
  (:documentation "The GROUP class.
This class groups other groups, options or strings together, effectively
implementing hierarchical program command-line."))


;; ---------------------------
;; Help specification protocol
;; ---------------------------

(defmethod help-spec ((group group) &key)
  "Return GROUP's help specification."
  (accumulate (group)
    (accumulate (header)
      (header group))
    ;; This calls the container's method.
    (let ((items (call-next-method)))
      (when items
	(push 'items items)))))



;; ==========================================================================
;; Group Instance Creation
;; ==========================================================================

(defun make-group (&rest keys &key header item hidden)
  "Make a new group."
  (declare (ignore header item hidden))
  (apply #'make-instance 'group keys))

(defmacro %defgroup (internalp (&rest keys &key header hidden) &body forms)
  "Define a new group."
  (declare (ignore header hidden))
  `(make-group ,@keys
    ,@(loop :for form :in forms
	    :nconc (list :item
			 (let ((item-name
				(when (consp form)
				  (car (member (symbol-name (car form))
					       *item-names*
					       :test #'string=)))))
			   (if item-name
			       (list* (intern
				       (cond ((string= item-name "GROUP")
					      "%DEFGROUP")
					     (t
					      (format nil
						  "MAKE-~:[~;INTERNAL-~]~A"
						internalp item-name)))
				       :com.dvlsoft.clon)
				      (if (string= item-name "GROUP")
					  (list* internalp (cdr form))
					(cdr form)))
			     form))))))

(defmacro defgroup ((&rest keys &key header hidden) &body forms)
  "Define a new group.
KEYS are initargs to MAKE-GROUP (currently, only :header).
Each form in FORMS will be treated as a new :item.
The CAR of each form is the name of the operation to perform: TEXT, GROUP, or
an option class name. The rest are the arguments to the MAKE-<OP> function or
the DEFGROUP macro."
  (declare (ignore header hidden))
  `(%defgroup nil ,keys ,@forms))


;;; group.lisp ends here
