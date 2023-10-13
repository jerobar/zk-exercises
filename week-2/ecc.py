from unittest import TestCase


class FiniteFieldElement:
    """
    Represents an element within a finite field.
    """

    def __init__(self, num, order):
        if  num < 0 or num >= order:
            raise ValueError(
                'Num not in field range 0 to {}'.format(num, order - 1)
            )
        
        self.num = num
        self.order = order # will always be prime

    def __repr__(self):
        return 'FieldElement_{}(F{})'.format(self.num, self.order)
    
    def __eq__(self, other):
        if other is None:
            return False

        return self.num == other.num and self.order == other.order
    
    def __ne__(self, other):
        return self.num != other.num or self.order != other.order
    
    def __add__(self, other):
        self.orders_equal_or_error(other)
        
        num = (self.num + other.num) % self.order

        return self.__class__(num, self.order)
    
    def __sub__(self, other):
        self.orders_equal_or_error(other)
        
        num = (self.num - other.num) % self.order

        return self.__class__(num, self.order)
    
    def __mul__(self, other):
        self.orders_equal_or_error(other)

        num = (self.num * other.num) % self.order

        return self.__class__(num, self.order)
    
    def __pow__(self, exponent):
        pos_exponent = exponent % (self.order - 1)
        num = pow(self.num, pos_exponent, self.order)

        return self.__class__(num, self.order)
    
    def __truediv__(self, other):
        # a/b = a * (1/b) = a * b^-1
        # b^-1 = b^-1 * 1 = b^-1 * b^(p-1) % p = b^(p-2)
        # or b^-1 = b^(p-2)
        num = (self.num * pow(other.num, self.order - 2, self.order)) % self.order
        
        return self.__class__(num, self.order)
    
    def __rmul__(self, coefficient):
        num = (self.num * coefficient) % self.order

        return self.__class__(num, self.order)

    def orders_equal_or_error(self, other):
        if self.order != other.order:
            raise TypeError('Cannot add two numbers in different fields')


class EllipticCurvePoint:
    """
    Represents a point along an elliptic curve over a finite field.
    """

    def __init__(self, y, x, a, b):
        # If not the point at infinity
        if not (y is None and x is None):
            # Ensure the point is along the curve
            if y**2 != x**3 + a*x + b:
                raise ValueError('Point ({}, {}) is not on the curve'.format(x, y))

        self.y = y
        self.x = x
        self.a = a
        self.b = b

    def __repr__(self):
        if self.y is None and self.x is None:
            return 'Point(Infinity)'
        
        return 'Point({}, {})'.format(self.x, self.y)

    def __eq__(self, other):
        return self.y == other.y and self.x == other.x and self.a == other.a and self.b == other.b
    
    def __ne__(self, other):
        return self.y != other.y or self.x != other.x or self.a != other.a or self.b != other.b
    
    def __add__(self, other):
        if self.a != other.a or self.b != other.b:
            raise TypeError('Points {}, {} are not on the same curve'.format(self, other))
        
        # If `self` or `other` are the point at infinity I (additive identity)
        # A + I = A
        if self.x is None:
            return other
        if other.x is None:
            return self
        
        # If `self` and `other` are additive inverses
        # A + (-A) = I
        if self.x == other.x and self.y != other.y:
            return self.point_at_infinity()
        
        # If `self` and `other` are not equal
        if self.x != other.x:
            # slope = (y2 - y1)/(x2 - x1)
            s = (other.y - self.y) / (other.x - self.x)
            # x3 = s^2 - x1 - x2
            x = s**2 - self.x - other.x
            # y3 = s(x1 - x3) - y1
            y = s*(self.x - x) - self.y

            return self.__class__(y, x, self.a, self.b)
        
        # If `self` and `other` are equal and the y coordinate is 0
        if self == other and self.y == 0 * self.x:
            return self.point_at_infinity()
        
        # If `self` and `other` are equal and the y coordinate is not 0
        if self == other:
            # Slope of the line tangent to the point
            # s = dy/dx = (3x^2 + a) / (2y)
            s = (3*self.x**2 + self.a) / (2*self.y)
            # x3 = s^2 - 2x1
            x = s**2 - 2*self.x
            # y3 = s(x1 - x3) - y1
            y = s*(self.x - x) - self.y

            return self.__class__(y, x, self.a, self.b)
    
    def __rmul__(self, coefficient):
        """Uses binary expansion to perform scalar multiplication of `self` * `coefficient`."""
        # Think of representing the coefficient in binary and only adding the point where there are 1's
        coefficient_ = coefficient
        current = self # The point that's at the current bit (1 * self in first loop, 2 * self, 4 * self, etc.)
        result = self.point_at_infinity() # Start at 0 (point at infinity)

        while coefficient_:
            if coefficient_ & 1:
                result += current
            current += current
            coefficient_ >>= 1

        return result
    
    def point_at_infinity(self):
        return self.__class__(None, None, self.a, self.b)


class Tests(TestCase):
    def all_tests(self):
        self.test_on_curve()
        self.test_add()

    def test_on_curve(self):
        order = 223
        a = FiniteFieldElement(0, order)
        b = FiniteFieldElement(7, order)
        valid_points = ((192, 105), (17, 56), (1, 193))
        invalid_points = ((201, 119), (42, 99))

        for x_raw, y_raw in valid_points:
            x = FiniteFieldElement(x_raw, order)
            y = FiniteFieldElement(y_raw, order)
            
            EllipticCurvePoint(y, x, a, b)
        
        for x_raw, y_raw in invalid_points:
            x = FiniteFieldElement(x_raw, order)
            y = FiniteFieldElement(y_raw, order) 
            
            with self.assertRaises(ValueError):
                EllipticCurvePoint(y, x, a, b)

        print('test_on_curve: OK')

    def test_add(self):
        order = 223
        a = FiniteFieldElement(0, order) 
        b = FiniteFieldElement(7, order)

        x1 = FiniteFieldElement(192, order)
        y1 = FiniteFieldElement(105, order)
        x2 = FiniteFieldElement(17, order)
        y2 = FiniteFieldElement(56, order)

        p1 = EllipticCurvePoint(y1, x1, a, b)
        p2 = EllipticCurvePoint(y2, x2, a, b)

        answer = EllipticCurvePoint(FiniteFieldElement(142, order), FiniteFieldElement(170, order), a, b)

        self.assertEquals(p1 + p2, answer)

        print('test_add: OK')

# Scalar multiplication = repeated point addition
# Point addition is straightforward but division is not <- discrete log problem
# At a certain multiple, we get the point at infinity
# {G, 2G, 3G, ..., nG} where nG = 0, this set is called a Group

# Binary expansion allows us to perform multiplication in log2(n) loops
