import Pkg
Pkg.add("HiGHS")   # Ensure the HiGHS solver is installed. This package provides an optimization solver.
Pkg.add("JuMP")    # Ensure JuMP is installed. JuMP is used for defining optimization models.

using HiGHS        # Import the HiGHS solver for linear optimization.
using JuMP         # Import JuMP for modeling optimization problems.

# Read and include the problem data.
include("juliaData/floc2.jl")

# Specify the solver for the optimization problem using HiGHS
LP1 = Model(HiGHS.Optimizer)

# Define decision variables:
# x[i,j]: amount transported from facility i to customer j
# y[i]: indicates if a facility i is opened (binary, but here treated as continuous in the relaxation)
@variable(LP1, 0 <= x[1:m, 1:n])   # Non-negative transportation amounts between facilities and customers
@variable(LP1, 0 <= y[1:m])        # Facility status (continuous relaxation of the binary variable)

# Define the objective function (goal):
# The goal is to minimize the total cost, which consists of:
# - transportation cost from facility i to customer j: c[i,j] * x[i,j]
# - fixed cost of opening facility i: f[i] * y[i]
@objective(LP1, Min, sum(c[i,j] * x[i,j] for i in 1:m, j in 1:n) + sum(f[i] * y[i] for i in 1:m))

# Add constraint 1: Capacity limit for each facility i.
# The total amount transported from a facility i (sum(x[i,j])) cannot exceed the facility's capacity (s[i]), 
# and if the facility is not open (y[i] = 0), it cannot transport anything.
@constraint(LP1, [i=1:m], sum(x[i,j] for j in 1:n) <= s[i] * y[i])

# Add constraint 2: Demand satisfaction for each customer j.
# The total amount transported to customer j from all facilities must satisfy the customer's demand (d[j]).
@constraint(LP1, [j=1:n], sum(x[i,j] for i in 1:m) == d[j])

# Solve the linear optimization problem
optimize!(LP1)

# Fetch and print the optimal total cost (the minimized objective function value)
cost = objective_value(LP1)
println("Optimal cost for LP1: $cost")

# Count the number of facilities that are opened (where y[i] is greater than 0.5 in the continuous relaxation)
num_open_facilities = sum(value(y[i]) for i in 1:m if value(y[i]) > 0.5)  
println("Open facilities: $num_open_facilities")
