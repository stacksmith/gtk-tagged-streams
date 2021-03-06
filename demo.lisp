(in-package :gtk-tagged-streams)
(defparameter *buffer* nil)
(defparameter *view* nil)

(defparameter *tHead* nil)
(defparameter *tLink* nil)


;;━┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉┉
(defun demo ()
  
  (let ((so *standard-output*))
    
    (within-main-loop
      (setf *standard-output* so)
      (let* ((window (make-instance 'gtk-window
				    :type :toplevel
				    :title "TAGGED-STREAMS"
				    :border-width 3
				    :default-width 640
				    :default-height 400))
	     (scrolled (make-instance 'gtk-scrolled-window
				      :border-width 0
				      :hscrollbar-policy :automatic
				      :vscrollbar-policy :always))
	     (buffer (make-instance 'tb))
	     (tHead (make-instance 'tag :buffer buffer
				   :background-rgba (gdk-rgba-parse "#CEDFF2")
				   :size 20000
				   ))
	     (tBody (make-instance 'tag :buffer buffer
				   :background-rgba (gdk-rgba-parse "#F5FAFF")
				   :indent -15
				   :size 12000
				   :pixels-above-lines 10))
	    
	     (tBoldLink (make-instance 'tag :buffer buffer
				       :foreground-rgba (gdk-rgba-parse "#0645AD")
				       :weight 800))
	     (tLink (make-instance 'tag :buffer buffer
				   :foreground-rgba (gdk-rgba-parse "#0645AD")))
	     (view (make-instance 'gtk-text-view :buffer buffer
				  :wrap-mode :word)))
	
	(gtk-container-add scrolled view)
	(gtk-container-add window scrolled)
	(setf *buffer* buffer
	      *view* view
	      *tHead* tHead
	      *tLink* tLink)
	
	(g-signal-connect window "destroy"
			  (lambda (widget)
			    (declare (ignore widget))
			    (leave-gtk-main)))


	
	;;========================================================================
	;; On mouse button click, open an input stream on a tag and print contents
	(g-signal-connect
	 view "button-press-event"
	 (lambda (tv event)
	   (mvb (w x y mod) (gdk-window-get-pointer (gtk-widget-window tv))
		(mvb (x y) (gtv-window-to-buffer-coords tv :widget x y )
		     (let* ((iter (gtv-get-iter-at-location tv x y))
			    (tag (car (last (gti-get-tags iter))))) ;
		      ;; (setf *t* tag)
		       (when tag
			 (let ((input
				(make-instance
				 'tag-in-stream
				 :tag tag
				 :buffer buffer
				 :position iter)))
			   (file-position input :start)
			  
			   (loop for c = (read-char input nil nil)
			      while c do (write-char c ))
			   (close input) ))))
		nil; let gtk handle the click
	  )))
	;;	(format buffer "Hello, this is some text. ")
	(populate buffer tHead tBody tLink tBoldLink)
	
		
	(gtk-widget-show-all window)))))

(defun populate (buffer tHead tBody tLink tBoldLink)
  (with-buffer buffer
    (with-tag tHead (format t " In the news ~&"))
    (with-tag tBody
      (format t "•  United States President Donald Trump (pictured) announces that the U.S. will ")
      (with-tag tBoldLink (format t "withdraw from the Paris Agreement"))
      (format t" on ")
	      (with-tag tLink (format t "climate change mitigation"))
	      (format t ".~&")
	      (format t "•  ")
	      (with-tag tBoldLink (format t "A suspected robbery and arson"))
	      (format t " at the ")
	      (with-tag tLink (format t "Resorts World Manila"))
	      (format t " complex in the Philippines kills at least 34 people and injures 54 others.~&"))))
