# cython: language_level=3, boundscheck=False, wraparound=False
cimport cython

from libc.math cimport round as roundc
from libc.string cimport memcpy

import numpy as np

from cycolorsys cimport *
# from cycolorsys.colorobj cimport Color, ColorYIQ, ColorHLS, ColorHSV

# @cython.cdivision(True)
# cdef void check_values(double[:,:] values) nogil except *:
#     cdef Py_ssize_t nrows = values.shape[0], ncols = values.shape[1]
#     cdef Py_ssize_t ndigits = 7
#     cdef double mult = ndigits / 10**ndigits
#     cdef double a, b=0
#
#     cdef Py_ssize_t i, j
#
#     for j in range(ncols):
#         for i in range(nrows):
#             a = values[i,j]
#             if i == 0:
#                 b = a
#                 continue
#             if roundc(a[i] * mult) != roundc(b[i] * mult):
#                 with gil:
#                     raise Exception('{} != {}, diff={}'.format(a[i], b[i], abs(a[i])-abs(b[i])))
#             b = a

@cython.cdivision(True)
cdef bint isclose(double a, double b) nogil except *:
    cdef int ndigits = 7
    cdef double mult = 10**ndigits
    return roundc(a * mult) / mult == roundc(b * mult) / mult

cdef void check_values(const color_tuple_t a, const color_tuple_t b) nogil except *:
    cdef Py_ssize_t size = 3
    # if b.shape[0] != size:
    #     with gil:
    #         assert b.shape[0] == size

    cdef Py_ssize_t i

    for i in range(size):
        # if roundc(a[i] * mult) != roundc(b[i] * mult):
        if not isclose(a[i], b[i]):
            with gil:
                raise Exception('{} != {}, diff={}'.format(a[i], b[i], abs(a[i])-abs(b[i])))

def do_test(const double[:,:] color_values, double[:,:] result):
    cdef Py_ssize_t nrows = color_values.shape[0]
    cdef double[:] color_value = np.empty(3, dtype=np.double)
    cdef double[:] value = np.empty(3, dtype=np.double)
    # cdef double[:,:] temp_values = np.empty((5,3), dtype=np.double)
    cdef Py_ssize_t i, j

    cdef color_rgb_t src_rgb
    cdef color_rgb_t rgb
    cdef color_yiq_t yiq
    cdef color_hls_t hls
    cdef color_hsv_t hsv

    cdef Color color_rgb = Color()
    cdef ColorYIQ color_yiq = ColorYIQ()
    cdef ColorHLS color_hls = ColorHLS()
    cdef ColorHSV color_hsv = ColorHSV()

    for i in range(nrows):
        color_value[:] = color_values[i]

        src_rgb.array = <double *>&color_value[0]
        _rgb_to_hls(&src_rgb, &hls)
        _rgb_to_hsv(&src_rgb, &hsv)
        _rgb_to_yiq(&src_rgb, &yiq)
        # for j in range(3):
        #     src_rgb.array[j] = color_value[j]

        color_hsv._set_rgb(&src_rgb)
        # color_hsv.set_rgb(color_value[0], color_value[1], color_value[2])
        check_values(src_rgb.array, color_hsv.rgb.array)
        check_values(color_hsv.hsv.array, hsv.array)
        # _hsv_to_rgb(&color_hsv.hsv, &rgb)
        # for j in range(3):
        #     try:
        #         assert isclose(src_rgb.array[j], color_value[j])
        #     except:
        #         print('i={}, j={}, src_rgb={}, color_value={}, rgb={}'.format(
        #             i, j, src_rgb.array[j], color_value[j], rgb.array[j]
        #         ))
        #         raise
        #     try:
        #         assert isclose(rgb.array[j], src_rgb.array[j])
        #     except:
        #         print('i={}, j={}, src_rgb={}, color_value={}, rgb={}'.format(
        #             i, j, src_rgb.array[j], color_value[j], rgb.array[j]
        #         ))
        #         raise
        # memcpy(hsv.array, color_hsv.hsv.array, sizeof(color_tuple_t))

        color_hls._set_hsv(&color_hsv.hsv)
        check_values(src_rgb.array, color_hls.rgb.array)
        check_values(color_hls.hls.array, hls.array)
        # memcpy(hls.array, color_hls.hls.array, sizeof(color_tuple_t))

        color_yiq._set_hls(&color_hls.hls)
        check_values(src_rgb.array, color_yiq.rgb.array)
        check_values(color_yiq.yiq.array, yiq.array)
        # memcpy(yiq.array, color_yiq.yiq.array, sizeof(color_tuple_t))

        color_rgb._set_yiq(&color_yiq.yiq)
        check_values(src_rgb.array, color_rgb.rgb.array)
        # memcpy(rgb.array, color_rgb.rgb.array, sizeof(color_tuple_t))

        for j in range(3):
            # value[j] = src_rgb.array[j]
            # value[j] = color_hsv.rgb.array[j]
            result[i,j] = color_rgb.rgb.array[j]
        # result[i,:] = value
