import Pkg
Pkg.add("HiGHS")   # Ensure the HiGHS solver is installed. This package provides an optimization solver.
Pkg.add("JuMP")    # Ensure JuMP is installed. JuMP is used for defining optimization models.

using HiGHS        # Import the HiGHS solver for linear optimization
using JuMP         # Import JuMP for modeling optimization problems

# Read and include the problem data.
include("juliaData/floc1.jl")

# Specify the solver for the optimization problem using HiGHS
LP2 = Model(HiGHS.Optimizer)

# Variables:
# x[i,j] represents the amount transported from facility i to customer j
# y[i] is a binary variable that indicates whether facility i is open (1) or closed (0)
@variable(LP2, x[1:m, 1:n] >= 0)  # Transportation amounts between facilities and customers (non-negative continuous variables)
@variable(LP2, y[1:m], Bin)       # Binary variable for whether each facility is open or closed

# Objective: Minimize total cost (transport + fixed opening costs)
# The objective consists of:
# - Transportation cost from facility i to customer j: c[i,j] * x[i,j]
# - Fixed cost of opening facility i: f[i] * y[i]
@objective(LP2, Min, sum(c[i,j] * x[i,j] for i in 1:m, j in 1:n) + sum(f[i] * y[i] for i in 1:m))

# Constraints:
# 1. Capacity constraint: For each facility i, the total amount transported (sum(x[i,j])) must not exceed the facility's capacity (s[i]),
#    but only if the facility is open (y[i] = 1). If the facility is closed (y[i] = 0), no transportation can occur.
@constraint(LP2, [i = 1:m], sum(x[i,j] for j in 1:n) <= s[i] * y[i])

# 2. Demand satisfaction constraint: For each customer j, the total amount transported to that customer (sum(x[i,j])) 
#    must equal their demand (d[j]).
@constraint(LP2, [j = 1:n], sum(x[i,j] for i in 1:m) == d[j])

# 3. New additional constraints: Ensure that x[i,j] <= d[j] * y[i], i.e., the amount transported from facility i to customer j
#    must be less than or equal to the customer's demand, but only if the facility is open (y[i] = 1).
@constraint(LP2, [i = 1:m, j = 1:n], x[i,j] <= d[j] * y[i])

# Solve the model using HiGHS solver
optimize!(LP2)

# Retrieve the results:
# - objective_value(LP2): Fetches the optimal cost after solving the problem
# - termination_status(LP2): Provides the status of the solver (whether it found an optimal solution, timed out, etc.)
objective_value_LP2 = objective_value(LP2)
status_LP2 = termination_status(LP2)

# Fetch and print the optimal cost
println("Optimal cost for LP2: $objective_value_LP2")
println("Solver status for LP2: $status_LP2")

# Count the number of facilities that are opened (y[i] = 1)
# We use a threshold (0.5) to determine if a facility is considered open or closed
num_open_facilities = sum(value(y[i]) for i in 1:m if value(y[i]) > 0.5)
println("Open facilities: $num_open_facilities")
