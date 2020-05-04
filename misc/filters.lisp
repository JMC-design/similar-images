(in-package :similar-images-misc)

(defun get-dimensions-jpeg (image)
  (declare (type (or string pathname) image))
  (multiple-value-bind (width height)
      (with-decompressor (handle)
        (decompress-header handle image))
    (list width height)))

(defun get-dimensions-rest (image)
  (declare (type (or string pathname) image))
  (let ((image (read-image image)))
    (list
     (image-width image)
     (image-height image))))

(defparameter *dimension-getters*
  '(("jpg"  . #'get-dimensions-jpeg)
    ("jpeg" . #'get-dimensions-jpeg))
  "Functions which return dimensions based on the image's type")

(defun get-dimensions (image)
  "Get a list containing dimensions of an image. The full
decompression is avoided when possible"
  (declare (type (or string pathname) image))
  (let* ((type (pathname-type (pathname image)))
         (getter (or (car (assoc type *dimension-getters*))
                     #'get-dimensions-rest)))
    (funcall getter image)))

(defun get-biggest-image (images)
  "Get biggest image in the list @c(images) judging by its area."
  (reduce
   (lambda (image1 image2)
     (let ((dim1 (get-dimensions image1))
           (dim2 (get-dimensions image2)))
       (if (> (apply #'* dim1)
              (apply #'* dim2))
           image1 image2)))
   images))

(defun remove-similar (images &key (best-criterion
                                    #'get-biggest-image))
  (loop
     for group in images
     for best = (funcall best-criterion group)
     for rest = (remove best group :test #'equal)
     collect (mapc #'delete-file rest)))
