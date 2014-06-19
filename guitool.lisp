(defpackage #:guitool
  (:use #:cl)
  (:export #:patch)
  (:import-from #:nibbles
                #:read-ub16/le #:read-ub32/le #:write-ub16/le))

(in-package #:guitool)

(defun subsystem-position (stream)
  (file-position stream 0)
  (let ((mz (read-ub16/le stream)))
    (unless (= mz #x5A4D)
      (error "Not an MZ executable.")))
  (file-position stream 60)
  (let ((lfanew (read-ub32/le stream)))
    (file-position stream lfanew)
    (let ((pe (read-ub32/le stream)))
      (unless (= pe #x4550)
        (error "Not a PE executable.")))
    (file-position stream (+ lfanew 24))
    (let ((magic (read-ub16/le stream)))
      (unless (= magic #x10B)
        (error "Optional header magic gone bad.")))
    (+ lfanew 92)))

(defvar *subsystem-symbols*
  '((1 . :native)
    (2 . :win-gui)
    (3 . :win-cui)
    (5 . :os2-cui)
    (7 . :pos-cui)))

(defun subsystem (stream)
  (file-position stream (subsystem-position stream))
  (let ((x (read-ub16/le stream)))
    (or (cdr (assoc x *subsystem-symbols*))
        x)))

(defun (setf subsystem) (new-value stream)
  (file-position stream (subsystem-position stream))
  (let ((x (or (car (rassoc new-value *subsystem-symbols*))
               new-value)))
    (check-type x integer)
    (write-ub16/le x stream))
  new-value)

(defun patch (filename &optional new-subsystem)
  (with-open-file (stream filename
                          :direction :io
                          :element-type '(unsigned-byte 8)
                          :if-exists :overwrite
                          :if-does-not-exist :error)
    (let ((old-subsystem (subsystem stream)))
      (when new-subsystem
        (setf (subsystem stream) new-subsystem))
      (list :old old-subsystem :new new-subsystem))))

(format t "~%~%Loaded. To operate, do:~%~%")
(format t "  (guitool:patch \"/path/to/exe\" [ :native | :win-gui | :win-cui | :os2-cui | :pos-cui ])~%~%")

