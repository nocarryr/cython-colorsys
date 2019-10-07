# cython: language_level=3


cdef struct color_rgb:
    double r
    double g
    double b

cdef struct color_yiq:
    double y
    double i
    double q

cdef struct color_hls:
    double h
    double l
    double s

cdef struct color_hsv:
    double h
    double s
    double v


cdef void _rgb_to_yiq(color_rgb *rgb, color_yiq *yiq) nogil except *
cpdef (double, double, double) rgb_to_yiq(double r, double g, double b)
cdef void _yiq_to_rgb(color_yiq *yiq, color_rgb *rgb) nogil except *
cpdef (double, double, double) yiq_to_rgb(double y, double i, double q)
cdef void _rgb_to_hls(color_rgb *rgb, color_hls *hls) nogil except *
cpdef (double, double, double) rgb_to_hls(double r, double g, double b)
cdef void _hls_to_rgb(color_hls *hls, color_rgb *rgb) nogil except *
cpdef (double, double, double) hls_to_rgb(double h, double l, double s)
cdef void _rgb_to_hsv(color_rgb *rgb, color_hsv *hsv) nogil except *
cpdef (double, double, double) rgb_to_hsv(double r, double g, double b)
cdef void _hsv_to_rgb(color_hsv *hsv, color_rgb *rgb) nogil except *
cpdef (double, double, double) hsv_to_rgb(double h, double s, double v)
