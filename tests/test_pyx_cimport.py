import numpy as np

from _test_pyx_cimport import do_test

def test_pyx(color_values):
    result = do_test(color_values)
    assert np.allclose(color_values, result)
