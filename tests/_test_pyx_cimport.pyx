# cython: language_level=3, boundscheck=False, wraparound=False
cimport cython

from libc.math cimport round as roundc

import numpy as np

from cycolorsys cimport *

cdef bint check_rgb_values(color_rgb_t *rgb) nogil except *:
    if rgb.values.r != rgb.array[0]:
        return False
    if rgb.values.g != rgb.array[1]:
        return False
    if rgb.values.b != rgb.array[2]:
        return False
    return True

cdef check_yiq_values(color_yiq_t *yiq):
    if yiq.values.y != yiq.array[0]:
        return False
    if yiq.values.i != yiq.array[1]:
        return False
    if yiq.values.q != yiq.array[2]:
        return False
    return True

cdef check_hls_values(color_hls_t *hls):
    if hls.values.h != hls.array[0]:
        return False
    if hls.values.l != hls.array[1]:
        return False
    if hls.values.s != hls.array[2]:
        return False
    return True

cdef check_hsv_values(color_hsv_t *hsv):
    if hsv.values.h != hsv.array[0]:
        return False
    if hsv.values.s != hsv.array[1]:
        return False
    if hsv.values.v != hsv.array[2]:
        return False
    return True

cdef void assign_color_tuple(color_tuple_t color, double[:] values) nogil except *:
    cdef Py_ssize_t i
    for i in range(3):
        color[i] = values[i]

cdef void unpack_color_tuple(color_tuple_t color, double[:] values) nogil except *:
    cdef Py_ssize_t i
    for i in range(3):
        values[i] = color[i]

@cython.cdivision(True)
cdef void check_values(double[:] a, double[:] b) except *:
    cdef Py_ssize_t size = a.shape[0]
    cdef Py_ssize_t ndigits = 7
    cdef double mult = ndigits / 10**ndigits
    if b.shape[0] != size:
        assert b.shape[0] == size

    cdef Py_ssize_t i

    for i in range(size):
        if roundc(a[i] * mult) != roundc(b[i] * mult):
            raise Exception('{} != {}, diff={}'.format(a[i], b[i], abs(a[i])-abs(b[i])))

def do_test(double[:,:] color_values):
    cdef color_hls_t hls
    cdef color_yiq_t yiq
    cdef color_rgb_t rgb
    cdef color_hsv_t hsv
    cdef Py_ssize_t nrows = color_values.shape[0]
    cdef double[:,:] result = np.empty((nrows,3), dtype=np.double)
    cdef double[:] value = np.empty(3, dtype=np.double)
    cdef Py_ssize_t i

    for i in range(nrows):
        assign_color_tuple(rgb.array, color_values[i])
        _rgb_to_hsv(&rgb, &hsv)
        _hsv_to_rgb(&hsv, &rgb)
        unpack_color_tuple(rgb.array, value)
        assert check_hsv_values(&hsv)
        assert check_rgb_values(&rgb)
        check_values(value, color_values[i])

        assign_color_tuple(yiq.array, color_values[i])
        _yiq_to_rgb(&yiq, &rgb)
        _rgb_to_yiq(&rgb, &yiq)
        unpack_color_tuple(yiq.array, value)
        assert check_yiq_values(&yiq)
        assert check_rgb_values(&rgb)
        check_values(value, color_values[i])

        assign_color_tuple(hls.array, color_values[i])
        _hls_to_rgb(&hls, &rgb)
        _rgb_to_hls(&rgb, &hls)
        unpack_color_tuple(hls.array, value)
        assert check_hls_values(&hls)
        assert check_rgb_values(&rgb)
        check_values(value, color_values[i])

        assign_color_tuple(hsv.array, color_values[i])
        _hsv_to_rgb(&hsv, &rgb)
        _rgb_to_hsv(&rgb, &hsv)
        unpack_color_tuple(hsv.array, value)
        assert check_hsv_values(&hsv)
        assert check_rgb_values(&rgb)
        check_values(value, color_values[i])

        assign_color_tuple(rgb.array, color_values[i])
        _rgb_to_hsv(&rgb, &hsv)
        _hsv_to_rgb(&hsv, &rgb)
        _rgb_to_hls(&rgb, &hls)
        _hls_to_rgb(&hls, &rgb)
        _rgb_to_yiq(&rgb, &yiq)
        _yiq_to_rgb(&yiq, &rgb)
        unpack_color_tuple(rgb.array, value)
        check_values(value, color_values[i])

        result[i,:] = value

    return result
