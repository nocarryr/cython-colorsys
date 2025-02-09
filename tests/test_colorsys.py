import unittest
import cycolorsys as colorsys
# import colorsys

# import numpy as np

def frange(start, stop, step):
    while start <= stop:
        yield start
        start += step

ONE_THIRD = 1.0 / 3.0
TWO_THIRD = 2.0 / 3.0

class ColorsysTest(unittest.TestCase):

    def assertTripleEqual(self, tr1, tr2):
        # a1 = np.array(tr1)
        # a2 = np.array(tr2)
        # assert np.allclose(a1, a2)
        self.assertEqual(len(tr1), 3)
        self.assertEqual(len(tr2), 3)
        self.assertAlmostEqual(tr1[0], tr2[0])
        self.assertAlmostEqual(tr1[1], tr2[1])
        self.assertAlmostEqual(tr1[2], tr2[2])

    def test_hsv_roundtrip(self):
        for r in frange(0.0, 1.0, 0.2):
            for g in frange(0.0, 1.0, 0.2):
                for b in frange(0.0, 1.0, 0.2):
                    rgb = (r, g, b)
                    self.assertTripleEqual(
                        rgb,
                        colorsys.hsv_to_rgb(*colorsys.rgb_to_hsv(*rgb))
                    )

    def test_hsv_values(self):
        values = [
            # rgb, hsv
            ((0.0, 0.0, 0.0), (  0  , 0.0, 0.0)), # black
            ((0.0, 0.0, 1.0), (4./6., 1.0, 1.0)), # blue
            ((0.0, 1.0, 0.0), (2./6., 1.0, 1.0)), # green
            ((0.0, 1.0, 1.0), (3./6., 1.0, 1.0)), # cyan
            ((1.0, 0.0, 0.0), (  0  , 1.0, 1.0)), # red
            ((1.0, 0.0, 1.0), (5./6., 1.0, 1.0)), # purple
            ((1.0, 1.0, 0.0), (1./6., 1.0, 1.0)), # yellow
            ((1.0, 1.0, 1.0), (  0  , 0.0, 1.0)), # white
            ((0.5, 0.5, 0.5), (  0  , 0.0, 0.5)), # grey
        ]
        for (rgb, hsv) in values:
            self.assertTripleEqual(hsv, colorsys.rgb_to_hsv(*rgb))
            self.assertTripleEqual(rgb, colorsys.hsv_to_rgb(*hsv))

    def test_hls_roundtrip(self):
        for r in frange(0.0, 1.0, 0.2):
            for g in frange(0.0, 1.0, 0.2):
                for b in frange(0.0, 1.0, 0.2):
                    rgb = (r, g, b)
                    # h,l,s = colorsys.rgb_to_hls(r, g, b)
                    # if round(h, 8) == round(TWO_THIRD, 8):
                    #     eq = h == TWO_THIRD
                    #     print(f'hue={h}, eq={eq}')
                    # rgb2 = colorsys.hls_to_rgb(h, l, s)
                    # n1 = np.array(rgb)
                    # n2 = np.array(rgb2)
                    # if not np.allclose(n1, n2):
                    #     print(h, l, s)
                    # assert np.allclose(n1, n2)
                    self.assertTripleEqual(
                        rgb,
                        colorsys.hls_to_rgb(*colorsys.rgb_to_hls(*rgb))
                    )

    def test_hls_values(self):
        values = [
            # rgb, hls
            ((0.2, 0.2, 0.4), (TWO_THIRD, 0.3, ONE_THIRD)),
            ((0.0, 0.0, 0.0), (  0  , 0.0, 0.0)), # black
            ((0.0, 0.0, 1.0), (4./6., 0.5, 1.0)), # blue
            ((0.0, 1.0, 0.0), (2./6., 0.5, 1.0)), # green
            ((0.0, 1.0, 1.0), (3./6., 0.5, 1.0)), # cyan
            ((1.0, 0.0, 0.0), (  0  , 0.5, 1.0)), # red
            ((1.0, 0.0, 1.0), (5./6., 0.5, 1.0)), # purple
            ((1.0, 1.0, 0.0), (1./6., 0.5, 1.0)), # yellow
            ((1.0, 1.0, 1.0), (  0  , 1.0, 0.0)), # white
            ((0.5, 0.5, 0.5), (  0  , 0.5, 0.0)), # grey
        ]
        for (rgb, hls) in values:
            self.assertTripleEqual(hls, colorsys.rgb_to_hls(*rgb))
            self.assertTripleEqual(rgb, colorsys.hls_to_rgb(*hls))

    def test_yiq_roundtrip(self):
        for r in frange(0.0, 1.0, 0.2):
            for g in frange(0.0, 1.0, 0.2):
                for b in frange(0.0, 1.0, 0.2):
                    rgb = (r, g, b)
                    self.assertTripleEqual(
                        rgb,
                        colorsys.yiq_to_rgb(*colorsys.rgb_to_yiq(*rgb))
                    )

    def test_yiq_values(self):
        values = [
            # rgb, yiq
            ((0.0, 0.0, 0.0), (0.0, 0.0, 0.0)), # black
            ((0.0, 0.0, 1.0), (0.11, -0.3217, 0.3121)), # blue
            ((0.0, 1.0, 0.0), (0.59, -0.2773, -0.5251)), # green
            ((0.0, 1.0, 1.0), (0.7, -0.599, -0.213)), # cyan
            ((1.0, 0.0, 0.0), (0.3, 0.599, 0.213)), # red
            ((1.0, 0.0, 1.0), (0.41, 0.2773, 0.5251)), # purple
            ((1.0, 1.0, 0.0), (0.89, 0.3217, -0.3121)), # yellow
            ((1.0, 1.0, 1.0), (1.0, 0.0, 0.0)), # white
            ((0.5, 0.5, 0.5), (0.5, 0.0, 0.0)), # grey
        ]
        for (rgb, yiq) in values:
            self.assertTripleEqual(yiq, colorsys.rgb_to_yiq(*rgb))
            self.assertTripleEqual(rgb, colorsys.yiq_to_rgb(*yiq))

if __name__ == "__main__":
    unittest.main()
