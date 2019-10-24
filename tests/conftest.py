import pytest
import numpy as np

@pytest.fixture
def color_values():
    N = 16384
    a = np.zeros((N,3), dtype=float)
    for i in range(3):
        a[:,i] = np.roll(np.linspace(0., 1., N), i)
    return a
