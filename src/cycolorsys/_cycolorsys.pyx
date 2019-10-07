# cython: language_level=3

"""Conversion functions between RGB and other color systems.

This modules provides two functions for each color system ABC:

  rgb_to_abc(r, g, b) --> a, b, c
  abc_to_rgb(a, b, c) --> r, g, b

All inputs and outputs are triples of floats in the range [0.0...1.0]
(with the exception of I and Q, which covers a slightly larger range).
Inputs outside the valid range may cause exceptions or invalid outputs.

Supported color systems:
RGB: Red, Green, Blue components
YIQ: Luminance, Chrominance (used by composite video signals)
HLS: Hue, Luminance, Saturation
HSV: Hue, Saturation, Value
"""

# References:
# http://en.wikipedia.org/wiki/YIQ
# http://en.wikipedia.org/wiki/HLS_color_space
# http://en.wikipedia.org/wiki/HSV_color_space


__all__ = ["rgb_to_yiq","yiq_to_rgb","rgb_to_hls","hls_to_rgb",
           "rgb_to_hsv","hsv_to_rgb"]

__cyall__ = [
    '_rgb_to_yiq', '_yiq_to_rgb', '_rgb_to_hls', '_hls_to_rgb',
    '_rgb_to_hsv', '_hsv_to_rgb',
]


# Some floating point constants

cdef double ONE_THIRD = 1.0/3.0
cdef double ONE_SIXTH = 1.0/6.0
cdef double TWO_THIRD = 2.0/3.0

# YIQ: used by composite video signals (linear combinations of RGB)
# Y: perceived grey level (0.0 == black, 1.0 == white)
# I, Q: color components
#
# There are a great many versions of the constants used in these formulae.
# The ones in this library uses constants from the FCC version of NTSC.

cdef void _rgb_to_yiq(color_rgb *rgb, color_yiq *yiq) nogil except *:
    yiq.y = 0.30*rgb.r + 0.59*rgb.g + 0.11*rgb.b
    yiq.i = 0.74*(rgb.r-yiq.y) - 0.27*(rgb.b-yiq.y)
    yiq.q = 0.48*(rgb.r-yiq.y) + 0.41*(rgb.b-yiq.y)

cpdef (double, double, double) rgb_to_yiq(double r, double g, double b):
    cdef color_yiq yiq
    cdef color_rgb rgb
    rgb.r = r
    rgb.g = g
    rgb.b = b
    _rgb_to_yiq(&rgb, &yiq)
    return (yiq.y, yiq.i, yiq.q)

cdef void _yiq_to_rgb(color_yiq *yiq, color_rgb *rgb) nogil except *:
    # r = y + (0.27*q + 0.41*i) / (0.74*0.41 + 0.27*0.48)
    # b = y + (0.74*q - 0.48*i) / (0.74*0.41 + 0.27*0.48)
    # g = y - (0.30*(r-y) + 0.11*(b-y)) / 0.59

    rgb.r = yiq.y + 0.9468822170900693*yiq.i + 0.6235565819861433*yiq.q
    rgb.g = yiq.y - 0.27478764629897834*yiq.i - 0.6356910791873801*yiq.q
    rgb.b = yiq.y - 1.1085450346420322*yiq.i + 1.7090069284064666*yiq.q

    if rgb.r < 0.0:
        rgb.r = 0.0
    if rgb.g < 0.0:
        rgb.g = 0.0
    if rgb.b < 0.0:
        rgb.b = 0.0
    if rgb.r > 1.0:
        rgb.r = 1.0
    if rgb.g > 1.0:
        rgb.g = 1.0
    if rgb.b > 1.0:
        rgb.b = 1.0

cpdef (double, double, double) yiq_to_rgb(double y, double i, double q):
    cdef color_rgb rgb
    cdef color_yiq yiq
    yiq.y = y
    yiq.i = i
    yiq.q = q
    _yiq_to_rgb(&yiq, &rgb)
    return (rgb.r, rgb.g, rgb.b)

# HLS: Hue, Luminance, Saturation
# H: position in the spectrum
# L: color lightness
# S: color saturation

cdef void _rgb_to_hls(color_rgb *rgb, color_hls *hls) nogil except *:
    cdef double maxc = max(rgb.r, rgb.g, rgb.b)
    cdef double minc = min(rgb.r, rgb.g, rgb.b)
    cdef double diffc = maxc - minc
    cdef double sumc = maxc + minc
    hls.l = (sumc)/2.0
    if minc == maxc:
        hls.h = 0.0
        hls.s = 0.0
        return
    if hls.l <= 0.5:
        hls.s = diffc / sumc
    else:
        hls.s = diffc / (2.0-maxc-minc)
    cdef double rc = (maxc-rgb.r) / diffc
    cdef double gc = (maxc-rgb.g) / diffc
    cdef double bc = (maxc-rgb.b) / diffc
    if rgb.r == maxc:
        hls.h = bc-gc
    elif rgb.g == maxc:
        hls.h = 2.0+rc-bc
    else:
        hls.h = 4.0+gc-rc
    hls.h = (hls.h/6.0) % 1.0

cpdef (double, double, double) rgb_to_hls(double r, double g, double b):
    cdef color_hls hls
    cdef color_rgb rgb
    rgb.r = r
    rgb.g = g
    rgb.b = b
    _rgb_to_hls(&rgb, &hls)
    return (hls.h, hls.l, hls.s)

cdef void _hls_to_rgb(color_hls *hls, color_rgb *rgb) nogil except *:
    if hls.s == 0.0:
        rgb.r = hls.l
        rgb.g = hls.l
        rgb.b = hls.l
        return
    cdef double m2
    if hls.l <= 0.5:
        m2 = hls.l * (1.0+hls.s)
    else:
        m2 = hls.l + hls.s - (hls.l * hls.s)
    cdef double m1 = 2.0*hls.l - m2
    rgb.r = _v(m1, m2, hls.h+ONE_THIRD)
    rgb.g = _v(m1, m2, hls.h)
    rgb.b = _v(m1, m2, hls.h-ONE_THIRD)

cpdef (double, double, double) hls_to_rgb(double h, double l, double s):
    cdef color_rgb rgb
    cdef color_hls hls
    hls.h = h
    hls.l = l
    hls.s = s
    _hls_to_rgb(&hls, &rgb)
    return (rgb.r, rgb.g, rgb.b)

cdef double _v(const double m1, const double m2, const double hue) nogil except *:
    cdef double hue2 = hue % 1.0
    if hue2 < ONE_SIXTH:
        return m1 + (m2-m1)*hue2*6.0
    if hue2 < 0.5:
        return m2
    if hue2 < TWO_THIRD:
        return m1 + (m2-m1)*(TWO_THIRD-hue2)*6.0
    return m1


# HSV: Hue, Saturation, Value
# H: position in the spectrum
# S: color saturation ("purity")
# V: color brightness

cdef void _rgb_to_hsv(color_rgb *rgb, color_hsv *hsv) nogil except *:
    cdef double maxc = max(rgb.r, rgb.g, rgb.b)
    cdef double minc = min(rgb.r, rgb.g, rgb.b)
    cdef double diffc = maxc - minc
    hsv.v = maxc
    if minc == maxc:
        hsv.h = 0.0
        hsv.s = 0.0
        return
    if maxc == 0 or diffc == 0:
        with gil:
            raise ZeroDivisionError()
    hsv.s = diffc / maxc
    cdef double rc = (maxc-rgb.r) / diffc
    cdef double gc = (maxc-rgb.g) / diffc
    cdef double bc = (maxc-rgb.b) / diffc
    if rgb.r == maxc:
        hsv.h = bc-gc
    elif rgb.g == maxc:
        hsv.h = 2.0+rc-bc
    else:
        hsv.h = 4.0+gc-rc
    hsv.h = (hsv.h/6.0) % 1.0

cpdef (double, double, double) rgb_to_hsv(double r, double g, double b):
    cdef color_hsv hsv
    cdef color_rgb rgb
    rgb.r = r
    rgb.g = g
    rgb.b = b
    _rgb_to_hsv(&rgb, &hsv)
    return (hsv.h, hsv.s, hsv.v)

cdef void _hsv_to_rgb(color_hsv *hsv, color_rgb *rgb) nogil except *:
    if hsv.s == 0.0:
        rgb.r = hsv.v
        rgb.g = hsv.v
        rgb.b = hsv.v
        return
    cdef int i = <int>(hsv.h*6.0) # XXX assume int() truncates!
    cdef double f = (hsv.h*6.0) - i
    cdef double p = hsv.v*(1.0 - hsv.s)
    cdef double q = hsv.v*(1.0 - hsv.s*f)
    cdef double t = hsv.v*(1.0 - hsv.s*(1.0-f))
    i = i%6
    if i == 0:
        rgb.r = hsv.v
        rgb.g = t
        rgb.b = p
    elif i == 1:
        rgb.r = q
        rgb.g = hsv.v
        rgb.b = p
    elif i == 2:
        rgb.r = p
        rgb.g = hsv.v
        rgb.b = t
    elif i == 3:
        rgb.r = p
        rgb.g = q
        rgb.b = hsv.v
    elif i == 4:
        rgb.r = t
        rgb.g = p
        rgb.b = hsv.v
    elif i == 5:
        rgb.r = hsv.v
        rgb.g = p
        rgb.b = q
    else:
        with gil:
            raise ValueError()
    # Cannot get here

cpdef (double, double, double) hsv_to_rgb(double h, double s, double v):
    cdef color_rgb rgb
    cdef color_hsv hsv
    hsv.h = h
    hsv.s = s
    hsv.v = v
    _hsv_to_rgb(&hsv, &rgb)
    return (rgb.r, rgb.g, rgb.b)
