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
cdef void check_values(double[:] a, double[:] b) nogil except *:
    cdef Py_ssize_t size = a.shape[0]
    cdef Py_ssize_t ndigits = 7
    cdef double mult = ndigits / 10**ndigits
    if b.shape[0] != size:
        with gil:
            assert b.shape[0] == size

    cdef Py_ssize_t i

    for i in range(size):
        if roundc(a[i] * mult) != roundc(b[i] * mult):
            with gil:
                raise Exception('{} != {}, diff={}'.format(a[i], b[i], abs(a[i])-abs(b[i])))

def do_test_cdef(double[:,:] color_values, double[:,:] result):
    cdef color_hls_t hls
    cdef color_yiq_t yiq
    cdef color_rgb_t rgb
    cdef color_hsv_t hsv
    cdef Py_ssize_t nrows = color_values.shape[0]
    cdef double[:] color_value
    cdef double[:] value = np.empty(3, dtype=np.double)
    cdef Py_ssize_t i

    for i in range(nrows):
        color_value = color_values[i]

        assign_color_tuple(rgb.array, color_value)
        _rgb_to_hsv(&rgb, &hsv)
        _hsv_to_rgb(&hsv, &rgb)
        unpack_color_tuple(rgb.array, value)
        assert check_hsv_values(&hsv)
        assert check_rgb_values(&rgb)
        check_values(value, color_value)

        assign_color_tuple(yiq.array, color_value)
        _yiq_to_rgb(&yiq, &rgb)
        _rgb_to_yiq(&rgb, &yiq)
        unpack_color_tuple(yiq.array, value)
        assert check_yiq_values(&yiq)
        assert check_rgb_values(&rgb)
        check_values(value, color_value)

        assign_color_tuple(hls.array, color_value)
        _hls_to_rgb(&hls, &rgb)
        _rgb_to_hls(&rgb, &hls)
        unpack_color_tuple(hls.array, value)
        assert check_hls_values(&hls)
        assert check_rgb_values(&rgb)
        check_values(value, color_value)

        assign_color_tuple(hsv.array, color_value)
        _hsv_to_rgb(&hsv, &rgb)
        _rgb_to_hsv(&rgb, &hsv)
        unpack_color_tuple(hsv.array, value)
        assert check_hsv_values(&hsv)
        assert check_rgb_values(&rgb)
        check_values(value, color_value)

        assign_color_tuple(rgb.array, color_value)
        _rgb_to_hsv(&rgb, &hsv)
        _hsv_to_rgb(&hsv, &rgb)
        _rgb_to_hls(&rgb, &hls)
        _hls_to_rgb(&hls, &rgb)
        _rgb_to_yiq(&rgb, &yiq)
        _yiq_to_rgb(&yiq, &rgb)
        unpack_color_tuple(rgb.array, value)
        check_values(value, color_value)

        result[i,:] = value

    return result

def do_test_cpdef(double[:,:] color_values, double[:,:] result):
    cdef Py_ssize_t nrows = color_values.shape[0]
    cdef Py_ssize_t i
    cdef double[:] color_value
    cdef double[:] value = np.empty(3, dtype=np.double)
    cdef double[3] val1, val2

    for i in range(nrows):
        color_value = color_values[i]

        val1 = rgb_to_hsv(color_value[0], color_value[1], color_value[2])
        val2 = hsv_to_rgb(val1[0], val1[1], val1[2])
        value = val2
        check_values(value, color_value)

        val1 = yiq_to_rgb(color_value[0], color_value[1], color_value[2])
        val2 = rgb_to_yiq(val1[0], val1[1], val1[2])
        value = val2
        check_values(value, color_value)

        val1 = hls_to_rgb(color_value[0], color_value[1], color_value[2])
        val2 = rgb_to_hls(val1[0], val1[1], val1[2])
        value = val2
        check_values(value, color_value)

        val1 = hsv_to_rgb(color_value[0], color_value[1], color_value[2])
        val2 = rgb_to_hsv(val1[0], val1[1], val1[2])
        value = val2
        check_values(value, color_value)

        val1 = rgb_to_hsv(color_value[0], color_value[1], color_value[2])
        val2 = hsv_to_rgb(val1[0], val1[1], val1[2])
        val1 = rgb_to_hls(val2[0], val2[1], val2[2])
        val2 = hls_to_rgb(val1[0], val1[1], val1[2])
        val1 = rgb_to_yiq(val2[0], val2[1], val2[2])
        val2 = yiq_to_rgb(val1[0], val1[1], val1[2])
        value = val2
        check_values(value, color_value)

        result[i,:] = value
