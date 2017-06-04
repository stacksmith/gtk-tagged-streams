(in-package :gtk-tagged-streams)
;;=============================================================================
;; tag-only-in-stream
;;
;; It is often useful to input user text from a GTK text buffer, without
;; confusing it with text generated by the appliction.  This stream is an input
;; stream that ignores all text except the text tagged with a specified tag.
;

(defclass user-in-stream (tag-only-in-stream)
  ((mutex :accessor mutex :initform nil)
   (condvar :accessor condvar :initform nil)))

(defmethod initialize-instance :after ((stream user-in-stream) &key)
  (setf (mutex stream) (bt:make-lock)
	(condvar stream) (bt:make-condition-variable))  )

(defmethod interactive-stream-p ((stream user-in-stream))
  t)
;;===========================================================================
(defmethod trivial-gray-streams:stream-read-char
    ((stream user-in-stream))
  ;;  (loop until (tois-prep-iter stream) do)
  (with-slots (buffer iter mark  condvar mutex tag) stream
    ;;-----------------------------------------------------------------------
    ;; We need to know that iter is not :eof.
    ;; If eof, we wait! and check again, since there are no guarantees.
    (loop until (tois-prep-iter stream)
       do (bt:with-lock-held (mutex)
	    (bt:condition-wait condvar mutex)
	    (%gtb-get-iter-at-mark buffer iter mark)))
    (prog1
	    (gti-get-char iter)
	  (gti-forward-char iter)
	  (gtb-move-mark buffer mark iter))))

;;===========================================================================

