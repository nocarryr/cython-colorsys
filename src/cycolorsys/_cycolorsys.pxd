# cython: language_level=3


cdef struct _color_rgb_st:
    double r
    double g
    double b

cdef struct _color_yiq_st:
    double y
    double i
    double q

cdef struct _color_hls_st:
    double h
    double l
    double s

cdef struct _color_hsv_st:
    double h
    double s
    double v

ctypedef double color_tuple_t[3]

ctypedef union color_rgb_t:
    _color_rgb_st values
    color_tuple_t array

ctypedef union color_yiq_t:
    _color_yiq_st values
    color_tuple_t array

ctypedef union color_hls_t:
    _color_hls_st values
    color_tuple_t array

ctypedef union color_hsv_t:
    _color_hsv_st values
    color_tuple_t array


cdef void _rgb_to_yiq(color_rgb_t *rgb_ptr, color_yiq_t *yiq_ptr) nogil except *
cpdef rgb_to_yiq(double r, double g, double b)
cdef void _yiq_to_rgb(color_yiq_t *yiq_ptr, color_rgb_t *rgb_ptr) nogil except *
cpdef yiq_to_rgb(double y, double i, double q)
cdef void _rgb_to_hls(color_rgb_t *rgb_ptr, color_hls_t *hls_ptr) nogil except *
cpdef rgb_to_hls(double r, double g, double b)
cdef void _hls_to_rgb(color_hls_t *hls_ptr, color_rgb_t *rgb_ptr) nogil except *
cpdef hls_to_rgb(double h, double l, double s)
cdef void _rgb_to_hsv(color_rgb_t *rgb_ptr, color_hsv_t *hsv_ptr) nogil except *
cpdef rgb_to_hsv(double r, double g, double b)
cdef void _hsv_to_rgb(color_hsv_t *hsv_ptr, color_rgb_t *rgb_ptr) nogil except *
cpdef hsv_to_rgb(double h, double s, double v)
