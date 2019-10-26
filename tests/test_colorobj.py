import pytest
from pytest import approx
import numpy as np

from cycolorsys import *

from _test_colorobj import do_test as do_pyx_test

def test_colorobj(color_values):
    nrows = color_values.shape[0]
    result = np.zeros((nrows,3), dtype=np.double)
    do_pyx_test(color_values, result)
    assert np.allclose(color_values, result)
    # assert np.array_equal(color_values, result)
    # def check_values(rgb, *colors):
    #     yiq = rgb_to_yiq(*rgb)
    #     hls = rgb_to_hls(*rgb)
    #     hsv = rgb_to_hsv(*rgb)
    #
    #     for color in colors:
    #         assert np.allclose(rgb, color.get_rgb())
    #         assert np.allclose(hsv, color.get_hsv())
    #         assert np.allclose(hls, color.get_hls())
    #         assert np.allclose(yiq, color.get_yiq())
    #
    # N = color_values.shape[0] // 4
    #
    # for value in color_values[:N,:]:
    #
    #     color_rgb = Color(*value)
    #     color_hsv = ColorHSV(*color_rgb.get_hsv())
    #     color_hls = ColorHLS(*color_hsv.get_hls())
    #     color_yiq = ColorYIQ(*color_hls.get_yiq())
    #
    #     check_values(value, color_rgb, color_hsv, color_hls, color_yiq)

def test_descriptors(color_values):
    N = color_values.shape[0] // 4

    color_rgb = Color()
    color_hsv = ColorHSV()
    color_hls = ColorHLS()

    for value in color_values[:N,:]:
        color_rgb.set_rgb(*value)
        hsv = color_rgb.get_hsv()
        hls = color_rgb.get_hls()

        color_hsv.hue, color_hsv.saturation, color_hsv.value = hsv
        assert (color_hsv.hue, color_hsv.saturation, color_hsv.value) == tuple(hsv) == tuple(color_hsv.get_hsv())

        color_hls.hue, color_hls.lightness, color_hls.saturation = hls

        assert (color_hls.hue, color_hls.lightness, color_hls.saturation) == tuple(hls) == tuple(color_hls.get_hls())

        assert color_rgb.red == approx(color_hsv.red) == approx(color_hls.red) == value[0]
        assert color_rgb.green == approx(color_hsv.green) == approx(color_hls.green) == value[1]
        assert color_rgb.blue == approx(color_hsv.blue) == approx(color_hls.blue) == value[2]



def test_addition():
    red = Color(1, 0, 0)
    green = Color(0, 1, 0)
    blue = Color(0, 0, 1)

    yellow = red + green
    magenta = red + blue
    cyan = green + blue
    white = red + green + blue

    assert np.array_equal(yellow.get_rgb(), [1, 1, 0])
    assert np.array_equal(magenta.get_rgb(), [1, 0, 1])
    assert np.array_equal(cyan.get_rgb(), [0, 1, 1])
    assert np.array_equal(white.get_rgb(), [1, 1, 1])

    cyan = white - red
    magenta = white - green
    yellow = white - blue

    assert np.array_equal(yellow.get_rgb(), [1, 1, 0])
    assert np.array_equal(magenta.get_rgb(), [1, 0, 1])
    assert np.array_equal(cyan.get_rgb(), [0, 1, 1])

    red2 = white - green - blue
    green2 = white - red - blue
    blue2 = white - red - green

    assert np.array_equal(red2.get_rgb(), [1, 0, 0])
    assert np.array_equal(green2.get_rgb(), [0, 1, 0])
    assert np.array_equal(blue2.get_rgb(), [0, 0, 1])

    clr = Color(1, 1, 1)

    clr -= red
    assert np.array_equal(clr.get_rgb(), cyan.get_rgb())

    clr += red
    clr -= green
    assert np.array_equal(clr.get_rgb(), magenta.get_rgb())

    clr += green
    clr -= blue
    assert np.array_equal(clr.get_rgb(), yellow.get_rgb())

def test_bool_ops():
    red = Color(1, 0, 0)
    green = Color(0, 1, 0)
    blue = Color(0, 0, 1)
    yellow = Color(1, 1, 0)
    magenta = Color(1, 0, 1)
    cyan = Color(0, 1, 1)
    white = Color(1, 1, 1)

    assert red != green != blue != yellow != magenta != cyan != white

    assert red + green == yellow
    assert red + blue == magenta
    assert green + blue == cyan

    assert red + green + blue == white
    assert red + blue == {'red':1, 'green':0, 'blue':1}

def test_multiplication():

    red = Color(1, 0, 0)
    green = Color(0, 1, 0)
    blue = Color(0, 0, 1)

    yellow = Color(1, 1, 0)
    magenta = Color(1, 0, 1)
    cyan = Color(0, 1, 1)

    assert yellow * magenta == red
    assert magenta * cyan == blue
    assert yellow * cyan == green

    clr = yellow.copy()
    clr *= magenta
    assert clr == red

    clr = magenta.copy()
    clr *= cyan
    assert clr == blue

    clr = cyan.copy()
    clr *= yellow
    assert clr == green

def test_hsv():

    red = ColorHSV(0, 1, 1)
    cyan = ColorHSV(0.5, 1, 1)
    white = ColorHSV(0, 0, 1)

    green = Color(0, 1, 0)
    blue = Color(0, 0, 1)

    assert cyan == white - red
    assert green + blue == cyan
