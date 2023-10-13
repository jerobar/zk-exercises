from ecc import FiniteFieldElement, EllipticCurvePoint, Tests

# Tests().all_tests()

prime = 223

a = FiniteFieldElement(0, prime)
b = FiniteFieldElement(7, prime)
x = FiniteFieldElement(15, prime)
y = FiniteFieldElement(86, prime)

p = EllipticCurvePoint(y, x, a, b)

print(7*p)
