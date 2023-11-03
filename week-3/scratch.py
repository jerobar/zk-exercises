from py_ecc.bn128 import G1, multiply, add, eq, curve_order

# "I know two rational numbers that add up to num/denom"
# a + b = c/d
# Proof: ([A], [B], num, denom)
a = 2
b = 4
num = 12
denom = 2

a_hidden = multiply(G1, a)
print('a',a_hidden)
b_hidden = multiply(G1, b)
print('b',b_hidden)
print('inv',pow(2, -1, curve_order))
print('co', curve_order)

print(
  eq(
    add(a_hidden, b_hidden), 
    multiply(G1, (12 * pow(2, -1, curve_order)))
  )
)


# Matrix multiplication of an nxn of uint256 and 1xn of points
# Validate that claim that matrix Ms = o where o is a 1xn matrix
# of uint256, s is an 1xn matrix of EC points
n = 3
matrix = [1234, 5678, 9101, 
          453, 6565, 9874794, 
          793973, 22, 38768] # nxn uint256 matrix
s = [G1, G1, G1] # multiplied by 1xn matrix of ec points
o = [1234 + 453 + 793973, 
     5678 + 6565 + 22, 
     9101 + 9874794 + 38768] # equals 1xn uint256 matrix
# [nxn uint256][1xn ec_points] = [1xn uint256] (homomorphism -> ec)

def verify(matrix, n, s, o):
    # Ensure the dimensions make sense
    if len(matrix) != n * n or len(s) != n or len(o) != n:
        return False

    # Initialize the result vector
    result = [0] * n

    # Evaluate result (matrix * s)
    for i in range(n):
        for j in range(n):
            if result[i] is not 0:
                result[i] = add(result[i], multiply(s[j], matrix[j * n + i]))
            else:
                result[i] = multiply(s[j], matrix[j * n + i])

    # Check that Ms = o
    for i, elem in enumerate(result):
        print("equals:", eq(elem, multiply(G1, o[i])))


verify(matrix, n, s, o)
print(curve_order)
print(hex(curve_order).zfill(64))