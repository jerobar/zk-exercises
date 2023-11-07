from py_ecc.bn128 import neg, multiply, add, G1, G2

# Define scalars
a_1 = 5
b_2 = 6
alpha_1 = 2
beta_2 = 3
x1 = 1
x2 = 1
x3 = 1
x_1 = x1 + x2 + x3
gamma_2 = 4
c_1 = 2
delta_2 = 6

# Sanity check scalar values
print("Scalars sum to 0:", (-a_1*b_2) + (alpha_1*beta_2) + (x_1*gamma_2) + (c_1*delta_2) == 0, "\n")

# Calculate EC points
A1 = multiply(G1, a_1)
B2 = multiply(G2, b_2)
Alpha1 = multiply(G1, alpha_1)
Beta2 = multiply(G2, beta_2)
X1 = multiply(G1, x_1)
Gamma2 = multiply(G2, gamma_2)
C1 = multiply(G1, c_1)
Delta2 = multiply(G2, delta_2)

# Print points
print("A1:", A1, "\n")
print("B2:", B2, "\n")
print("C1:", C1, "\n")
print("Alpha1:", Alpha1, "\n")
print("Beta2:", Beta2, "\n")
print("Gamma2:", Gamma2, "\n")
print("Delta2:", Delta2, "\n")
