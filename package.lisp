;;;; package.lisp

(defpackage #:gtk-tagged-streams
  (:nicknames #:gts)
  (:use :gtk :gdk :gdk-pixbuf :gobject :glib :gio :pango :cairo :cffi
	#:cl)
  (:export
   #:tb #:tv

   #:with-tag

   #:demo))

