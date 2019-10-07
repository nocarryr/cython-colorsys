# cython: language_level=3, boundscheck=False, wraparound=False
cimport cython

from libc.math cimport round as roundc

import numpy as np

from cycolorsys cimport (
    color_yiq, color_rgb, color_hls, color_hsv,
    _rgb_to_yiq, _yiq_to_rgb, _rgb_to_hls, _hls_to_rgb,
    _rgb_to_hsv, _hsv_to_rgb,
)

cdef void assign_yiq(color_yiq* yiq, double[:] values) nogil except *:
    yiq.y = values[0]
    yiq.i = values[1]
    yiq.q = values[2]

cdef void assign_hls(color_hls* hls, double[:] values) nogil except *:
    hls.h = values[0]
    hls.l = values[1]
    hls.s = values[2]

cdef void assign_hsv(color_hsv* hsv, double[:] values) nogil except *:
    hsv.h = values[0]
    hsv.s = values[1]
    hsv.v = values[2]

cdef void assign_rgb(color_rgb* rgb, double[:] values) nogil except *:
    rgb.r = values[0]
    rgb.g = values[1]
    rgb.b = values[2]

cdef void unpack_yiq(color_yiq* yiq, double[:] values) nogil except *:
    values[0] = yiq.y
    values[1] = yiq.i
    values[2] = yiq.q

cdef void unpack_hls(color_hls* hls, double[:] values) nogil except *:
    values[0] = hls.h
    values[1] = hls.l
    values[2] = hls.s

cdef void unpack_hsv(color_hsv* hsv, double[:] values) nogil except *:
    values[0] = hsv.h
    values[1] = hsv.s
    values[2] = hsv.v

cdef void unpack_rgb(color_rgb* rgb, double[:] values) nogil except *:
    values[0] = rgb.r
    values[1] = rgb.g
    values[2] = rgb.b

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
    cdef color_hls hls
    cdef color_yiq yiq
    cdef color_rgb rgb
    cdef color_hsv hsv
    cdef Py_ssize_t nrows = color_values.shape[0]
    cdef double[:,:] result = np.empty((nrows,3), dtype=np.double)
    cdef double[:] value = np.empty(3, dtype=np.double)
    cdef Py_ssize_t i

    for i in range(nrows):
        assign_rgb(&rgb, color_values[i])
        _rgb_to_hsv(&rgb, &hsv)
        _hsv_to_rgb(&hsv, &rgb)
        unpack_rgb(&rgb, value)
        check_values(value, color_values[i])

        assign_yiq(&yiq, color_values[i])
        _yiq_to_rgb(&yiq, &rgb)
        _rgb_to_yiq(&rgb, &yiq)
        unpack_yiq(&yiq, value)
        check_values(value, color_values[i])

        assign_hls(&hls, color_values[i])
        _hls_to_rgb(&hls, &rgb)
        _rgb_to_hls(&rgb, &hls)
        unpack_hls(&hls, value)
        check_values(value, color_values[i])

        assign_hsv(&hsv, color_values[i])
        _hsv_to_rgb(&hsv, &rgb)
        _rgb_to_hsv(&rgb, &hsv)
        unpack_hsv(&hsv, value)
        check_values(value, color_values[i])

        assign_rgb(&rgb, color_values[i])
        _rgb_to_hsv(&rgb, &hsv)
        _hsv_to_rgb(&hsv, &rgb)
        _rgb_to_hls(&rgb, &hls)
        _hls_to_rgb(&hls, &rgb)
        _rgb_to_yiq(&rgb, &yiq)
        _yiq_to_rgb(&yiq, &rgb)
        unpack_rgb(&rgb, value)
        check_values(value, color_values[i])

        result[i,:] = value

    return result
