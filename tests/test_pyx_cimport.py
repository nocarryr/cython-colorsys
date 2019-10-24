import pytest
import numpy as np

from _test_pyx_cimport import do_test_cdef, do_test_cpdef

@pytest.mark.benchmark(group='cdef-vs-cpdef')
@pytest.mark.parametrize('cy_mode', ['cdef', 'cpdef'])
def test_pyx(benchmark, cy_mode, color_values):
    nrows = color_values.shape[0]
    result = np.zeros((nrows,3), dtype=np.double)
    if cy_mode == 'cdef':
        benchmark(do_test_cdef, color_values, result)
    else:
        benchmark(do_test_cpdef, color_values, result)
    assert np.allclose(color_values, result)
