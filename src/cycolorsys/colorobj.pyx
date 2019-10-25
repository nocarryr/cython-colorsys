# cython: language_level=3

from libc.string cimport memcpy

from . cimport (
    _rgb_to_yiq, _yiq_to_rgb, _rgb_to_hls, _hls_to_rgb,
    _rgb_to_hsv, _hsv_to_rgb,
)


RGB_KEYS = ('red', 'green', 'blue')
HLS_KEYS = ('hue', 'lightness', 'saturation')
HSV_KEYS = ('hue', 'saturation', 'value')
YIQ_KEYS = ('y', 'i', 'q')
COLOR_KEYS = {
    'rgb':RGB_KEYS,
    'hls':HLS_KEYS,
    'hsv':HSV_KEYS,
    'yiq':YIQ_KEYS,
}

cpdef Color _parse_color(kwargs):
    cdef set color_keys_s
    cdef set kw_keys = set(kwargs.keys())
    cdef tuple color_keys
    cdef str clr_space
    cdef Color color
    cdef list values

    for clr_space, color_keys in COLOR_KEYS.items():
        color_keys_s = set(color_keys)
        if color_keys_s & kw_keys != color_keys_s:
            continue
        color = Color()
        values = [kwargs[key] for key in color_keys]
        if clr_space == 'rgb':
            color.set_rgb(*values)
        elif clr_space == 'hls':
            color.set_hls(*values)
        elif clr_space == 'hsv':
            color.set_hsv(*values)
        else:
            color.set_yiq(*values)
        return color
    return None

def parse_color(**kwargs):
    return _parse_color(kwargs)

cdef class Color:
    def __init__(self, double r=0, double g=0, double b=0):
        self.rgb.array = [r, g, b]

    cpdef set_yiq(self, double y, double i, double q):
        cdef color_yiq_t yiq
        yiq.array = [y, i, q]
        self._set_yiq(&yiq)
    cpdef get_yiq(self):
        cdef color_yiq_t yiq
        _rgb_to_yiq(&self.rgb, &yiq)
        return yiq.array

    cpdef set_hls(self, double h, double l, double s):
        cdef color_hls_t hls
        hls.array = [h, l, s]
        self._set_hls(&hls)
    cpdef get_hls(self):
        cdef color_hls_t hls
        _rgb_to_hls(&self.rgb, &hls)
        return hls.array

    cpdef set_hsv(self, double h, double s, double v):
        cdef color_hsv_t hsv
        hsv.array = [h, s, v]
        self._set_hsv(&hsv)
    cpdef get_hsv(self):
        cdef color_hsv_t hsv
        _rgb_to_hsv(&self.rgb, &hsv)
        return hsv.array

    cpdef set_rgb(self, double r, double g, double b):
        cdef color_rgb_t rgb
        rgb.array = [r, g, b]
        self._set_rgb(&rgb)
    cpdef get_rgb(self):
        return self.rgb.array

    cdef void _set_yiq(self, color_yiq_t* yiq) nogil except *:
        _yiq_to_rgb(yiq, &self.rgb)
    cdef void _set_hls(self, color_hls_t* hls) nogil except *:
        _hls_to_rgb(hls, &self.rgb)
    cdef void _set_hsv(self, color_hsv_t* hsv) nogil except *:
        _hsv_to_rgb(hsv, &self.rgb)
    cdef void _set_rgb(self, color_rgb_t* rgb) nogil except *:
        memcpy(&self.rgb.array, rgb.array, sizeof(color_tuple_t))

    def copy(self):
        return self._copy()

    cdef Color _copy(self):
        cdef Color obj = Color()
        obj._set_rgb(&self.rgb)
        return obj

    cdef void _operator(Color self, Color other, color_rgb_t* result, Operation op) except *:
        cdef color_rgb_t* self_rgb = &self.rgb
        cdef color_rgb_t* oth_rgb = &other.rgb
        cdef double value
        cdef Py_ssize_t i
        for i in range(3):
            if op == OP_add or op == OP_iadd:
                value = self_rgb.array[i] + oth_rgb.array[i]
            elif op == OP_sub or op == OP_isub:
                value = self_rgb.array[i] - oth_rgb.array[i]
            elif op == OP_mul or op == OP_imul:
                value = self_rgb.array[i] * oth_rgb.array[i]
            elif op == OP_div or op == OP_idiv:
                value = self_rgb.array[i] * oth_rgb.array[i]
            else:
                raise ValueError()
            result.array[i] = value
    def __add__(Color self, Color other):
        cdef color_rgb_t rgb
        self._operator(other, &rgb, OP_add)
        cdef Color result = self._copy()
        result._set_rgb(&rgb)
        return result
    def __sub__(Color self, Color other):
        cdef color_rgb_t rgb
        self._operator(other, &rgb, OP_sub)
        cdef Color result = self._copy()
        result._set_rgb(&rgb)
        return result
    def __mul__(Color self, Color other):
        cdef color_rgb_t rgb
        self._operator(other, &rgb, OP_mul)
        cdef Color result = self._copy()
        result._set_rgb(&rgb)
        return result
    def __div__(Color self, Color other):
        cdef color_rgb_t rgb
        self._operator(other, &rgb, OP_div)
        cdef Color result = self._copy()
        result._set_rgb(&rgb)
        return result
    def __iadd__(Color self, Color other):
        cdef color_rgb_t rgb
        self._operator(other, &rgb, OP_iadd)
        self._set_rgb(&rgb)
        return self
    def __isub__(Color self, Color other):
        cdef color_rgb_t rgb
        self._operator(other, &rgb, OP_isub)
        self._set_rgb(&rgb)
        return self
    def __imul__(Color self, Color other):
        cdef color_rgb_t rgb
        self._operator(other, &rgb, OP_imul)
        self._set_rgb(&rgb)
        return self
    def __idiv__(Color self, Color other):
        cdef color_rgb_t rgb
        self._operator(other, &rgb, OP_idiv)
        self._set_rgb(&rgb)
        return self
    def __eq__(Color self, other):
        cdef color_rgb_t* oth_rgb_ptr
        cdef Color other_clr

        if isinstance(other, Color):
            other_clr = other
            oth_rgb_ptr = &other_clr.rgb
        elif isinstance(other, dict):
            other_clr = _parse_color(other)
            if other_clr is None:
                return NotImplemented
            oth_rgb_ptr = &other_clr.rgb
        else:
            return NotImplemented
        cdef Py_ssize_t i
        for i in range(3):
            if self.rgb.array[i] != oth_rgb_ptr.array[i]:
                return False
        return True

    def __repr__(self):
        return f'<{self.__class__}: {self}>'
    def __str__(self):
        return str(self.rgb.values)

cdef class ColorYIQ(Color):
    def __init__(self, double y=0, double i=0, double q=0):
        self.yiq.array = [y, i, q]
        _yiq_to_rgb(&self.yiq, &self.rgb)

    cpdef get_yiq(self):
        return self.yiq.array

    cdef Color _copy(self):
        cdef ColorYIQ obj = ColorYIQ()
        obj._set_yiq(&self.yiq)
        return obj

    cdef void _set_yiq(self, color_yiq_t* yiq) nogil except *:
        Color._set_yiq(self, yiq)
        memcpy(&self.yiq.array, yiq.array, sizeof(color_tuple_t))
    cdef void _set_hls(self, color_hls_t* hls) nogil except *:
        Color._set_hls(self, hls)
        _rgb_to_yiq(&self.rgb, &self.yiq)
    cdef void _set_hsv(self, color_hsv_t* hsv) nogil except *:
        Color._set_hsv(self, hsv)
        _rgb_to_yiq(&self.rgb, &self.yiq)
    cdef void _set_rgb(self, color_rgb_t* rgb) nogil except *:
        Color._set_rgb(self, rgb)
        _rgb_to_yiq(&self.rgb, &self.yiq)

cdef class ColorHLS(Color):
    def __init__(self, double h=0, double l=0, double s=0):
        self.hls.array = [h, l, s]
        _hls_to_rgb(&self.hls, &self.rgb)

    cpdef get_hls(self):
        return self.hls.array

    cdef Color _copy(self):
        cdef ColorHLS obj = ColorHLS()
        obj._set_hls(&self.hls)
        return obj

    cdef void _set_yiq(self, color_yiq_t* yiq) nogil except *:
        Color._set_yiq(self, yiq)
        _rgb_to_hls(&self.rgb, &self.hls)
    cdef void _set_hls(self, color_hls_t* hls) nogil except *:
        Color._set_hls(self, hls)
        memcpy(&self.hls.array, hls.array, sizeof(color_tuple_t))
    cdef void _set_hsv(self, color_hsv_t* hsv) nogil except *:
        Color._set_hsv(self, hsv)
        _rgb_to_hls(&self.rgb, &self.hls)
    cdef void _set_rgb(self, color_rgb_t* rgb) nogil except *:
        Color._set_rgb(self, rgb)
        _rgb_to_hls(&self.rgb, &self.hls)

cdef class ColorHSV(Color):
    def __init__(self, double h=0, double s=0, double v=0):
        self.hsv.array = [h, s, v]
        _hsv_to_rgb(&self.hsv, &self.rgb)

    cpdef get_hsv(self):
        return self.hsv.array

    cdef Color _copy(self):
        cdef ColorHSV obj = ColorHSV()
        obj._set_hsv(&self.hsv)
        return obj

    cdef void _set_yiq(self, color_yiq_t* yiq) nogil except *:
        Color._set_yiq(self, yiq)
        _rgb_to_hsv(&self.rgb, &self.hsv)
    cdef void _set_hls(self, color_hls_t* hls) nogil except *:
        Color._set_hls(self, hls)
        _rgb_to_hsv(&self.rgb, &self.hsv)
    cdef void _set_hsv(self, color_hsv_t* hsv) nogil except *:
        Color._set_hsv(self, hsv)
        memcpy(&self.hsv.array, hsv.array, sizeof(color_tuple_t))
    cdef void _set_rgb(self, color_rgb_t* rgb) nogil except *:
        Color._set_rgb(self, rgb)
        _rgb_to_hsv(&self.rgb, &self.hsv)
