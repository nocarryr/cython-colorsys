# cython: language_level=3

from . cimport (
    color_yiq_t, color_hls_t, color_hsv_t, color_rgb_t, color_tuple_t,
)

ctypedef enum Operation:
    OP_add
    OP_sub
    OP_mul
    OP_div
    OP_gt
    OP_lt
    OP_eq
    OP_ne
    OP_iadd
    OP_isub
    OP_imul
    OP_idiv

cdef class Color:
    cdef readonly color_rgb_t rgb

    cpdef set_yiq(self, double y, double i, double q)
    cpdef get_yiq(self)
    cpdef set_hls(self, double h, double l, double s)
    cpdef get_hls(self)
    cpdef set_hsv(self, double h, double s, double v)
    cpdef get_hsv(self)
    cpdef set_rgb(self, double r, double g, double b)
    cpdef get_rgb(self)
    cdef void _set_yiq(self, color_yiq_t* yiq) nogil except *
    cdef void _set_hls(self, color_hls_t* hls) nogil except *
    cdef void _set_hsv(self, color_hsv_t* hsv) nogil except *
    cdef void _set_rgb(self, color_rgb_t* rgb) nogil except *
    cdef Color _copy(self)
    cdef void _operator(Color self, Color other, color_rgb_t* result, Operation op) except *

cdef class ColorYIQ(Color):
    cdef readonly color_yiq_t yiq

cdef class ColorHLS(Color):
    cdef readonly color_hls_t hls

cdef class ColorHSV(Color):
    cdef readonly color_hsv_t hsv
