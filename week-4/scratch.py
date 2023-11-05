from py_ecc.bn128 import multiply, G1, G2

# Scalars
x1 = 13
x2 = 18
x3 = 29

a_1 = 69 # will be treated as negative
b_2 = 420

alpha_1 = 22
beta_2 = 44

x_1 = x1 + x2 + x3
gamma_2 = 89

c_1 = 109
delta_2 = 208

# Sanity check
print("Scalars sum to 0:", -a_1*b_2 + alpha_1*beta_2 + x_1*gamma_2 + c_1*delta_2 == 0)

# Elliptic curve points
A1 = multiply(G1, a_1) # negated in Solidity contract
B2 = multiply(G2, b_2)
C1 = multiply(G1, c_1)
print("A1:\n", A1)
print("B2:\n", B2)
print("C1:\n", C1)

Alpha_1 = multiply(G1, alpha_1)
Beta_2 = multiply(G2, beta_2)
Gamma_2 = multiply(G2, gamma_2)
Delta_2 = multiply(G2, delta_2)
print("Alpha_1:\n", Alpha_1)
print("Beta_2:\n", Beta_2)
print("Gamma_2:\n", Gamma_2)
print("Delta_2:\n", Delta_2)

print(multiply(G1, x1 + x2 + x3))


# from py_ecc.bn128 import G1, G2, neg, pairing, add, multiply, eq

# # G1 and G2 are generator points for their respective groups
# print(G1) # (x, y)
# print(G2) # ((x, y), (x, y))
# # While G2 may seem strange, it behaves like other cyclic groups

# # print(G1 + G1 + G1 == G1*3)
# # # True
# # # The above is the same as this:
# # eq(add(add(G1, G1), G1), multiply(G1, 3))

# A = multiply(G2, 5) # Lib requires G2 as first arg
# B = multiply(G1, 6)
# C = multiply(G2, 5 * 6)
# # or C = multiply(G1, 5*6)
# pairing(A, B) == pairing(C, G1) # True

# # paring returns a member of G12
# # e: G1 × G2 → G12

# # 0 = -A1B2 + a1bet2 + X1gam2 + C1om2


# # If: ab + cd = 0
# # Then: A1B2 + C1D2 = 012 in G12 space

# x1 = 0
# x2 = 0 
# x3 = 0

# a = 6
# b = 4

# c = 2
# d = 4

# e = x1 + x2 + x3
# f = 8

# g = 4
# h = 2

# # -ab + cd + ef + gh = 0

# # neg(multiply(G1, a))
# a_b = pairing(neg(multiply(G1, a)), multiply(G2, b))
# c_d = pairing(multiply(G1, c), multiply(G1, d))
# e_f = pairing(multiply(G1, e), multiply(G1, f))
# g_h = pairing(multiply(G1, g), multiply(G1, h))




# """
# Blinear pairings allow us to take a, b, and c, encrypt them to 
# become E(a), E(b), and E(c), then send the three encrypted values
# to a verifier who can verify:
# E(a) * E(b) = E(c)

# p * q = r
# F(P, Q) = F(R)
# p * q = r * 1
# F(P,Q) = F(R,G) # Generator point G is "1" in this context

# f(aG, bG) = f(abG, G) = f(G, abG)

# A bilinear pairing is a mapping:
# e(aG, bG) = e(abG, G) = e(G, abG)
# e: G x G -> Gt (G target group)

# Symmetric/asymmetric

# Bilinear pairings are easier with different groups:
# e(G, G') -> G"
# e(aG, bG') = e(abG, G') = e(G, abG') # still holds
# # G" is the codomain (outside space) of e(G, G')

# Ethereum's bilinear pairing of choice uses elliptic curves with
# field extensions. We think of ec points as (x, y) but with field 
# extensions they consist of several (x, y) pairs. It is analagous to 
# how complex numbers extend real numbers. EC points with more than 2 
# dimensions.

# Bilinearity is a property that is hard to come by. the chances the 
# relationship holds for three random groups is slim. Using groups of 
# different dimensions, they become easier to construct. 

# G1, G2, and G12 (numbers correspond to number of dimensions)

# The py_ecc library is maintain by the Ethereum foundation. It 
# powers the precompile address at 0x8 in the pyEVM implementation. 
# The precompile works on points in G1, G2, and implicitly G12.
# """