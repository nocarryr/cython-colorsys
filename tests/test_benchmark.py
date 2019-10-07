import pytest
import numpy as np
#
# def build_values(N=8192):
#     a = np.zeros((N,3), dtype=float)
#     for i in range(3):
#         a[:,i] = np.roll(np.linspace(0., 1., N), i)
#     return a

def do_stuff(m, values, results):
    for i, value in enumerate(values):
        _ = m.rgb_to_yiq(*m.yiq_to_rgb(*value))
        _ = m.rgb_to_hls(*m.hls_to_rgb(*value))
        _ = m.rgb_to_hsv(*m.hsv_to_rgb(*value))
        rgb = m.yiq_to_rgb(*m.rgb_to_yiq(*m.hls_to_rgb(*m.rgb_to_hls(*m.hsv_to_rgb(*m.rgb_to_hsv(*value))))))
        results[i,:] = rgb

@pytest.mark.parametrize('colorsys_module', ['cython', 'stdlib'])
def test_bench_colorsys(benchmark, colorsys_module, color_values):
    if colorsys_module == 'stdlib':
        import colorsys
    elif colorsys_module == 'cython':
        import cycolorsys as colorsys

    # values = build_values()
    results = np.zeros(color_values.shape, dtype=float)
    benchmark(do_stuff, colorsys, color_values, results)
    assert np.allclose(color_values, results)
