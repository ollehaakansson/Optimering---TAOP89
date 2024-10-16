import Pkg
Pkg.add("HiGHS")    # Ensure HiGHS solver is installed
Pkg.add("JuMP")     # JuMP for optimization modeling
Pkg.add("Printf")   # Printf for formatted printing

using HiGHS         # Import the HiGHS solver for linear optimization
using JuMP          # Import JuMP for optimization modeling
using Printf        # Import Printf for formatted output

# Include the data file that contains problem parameters (m, n, s, d, f, c, e)
include("juliaData/floc1.jl")

# Define the optimization model and specify HiGHS as the solver
model_P1 = Model(HiGHS.Optimizer)

# Define decision variables:
# x[i,j] represents the quantity transported from facility i to customer j
# y[i] is a binary variable that indicates whether a facility i is open (1) or closed (0)
@variable(model_P1, 0 <= x[1:m, 1:n])  # Transportation amount between facilities and customers
@variable(model_P1, y[1:m], Bin)       # Binary variable indicating facility open/close status

# Define the objective function to minimize:
# - Transportation costs between facilities and customers
# - Fixed costs of opening facilities, scaled by discount factor 'e'
@objective(model_P1, Min, sum(c[i,j] * x[i,j] for i in 1:m, j in 1:n) + sum(e * f[i] * y[i] for i in 1:m))

# Constraint (1): Capacity constraint for each facility
# The total amount transported from facility i cannot exceed its capacity (if the facility is open).
# If a facility is not open (y[i] = 0), no transportation can occur.
@constraint(model_P1, [i=1:m], sum(x[i,j] for j in 1:n) <= s[i] * y[i])

# Constraint (2): Demand satisfaction constraint for each customer
# The total amount transported to customer j from all facilities must satisfy their demand.
@constraint(model_P1, [j=1:n], sum(x[i,j] for i in 1:m) == d[j])

# Start the timer to measure optimization time
start_time = time()

# Solve the optimization problem using HiGHS
optimize!(model_P1)

# Stop the timer after optimization completes
end_time = time()

# Calculate the elapsed time for solving the problem
elapsed_time = end_time - start_time

# Retrieve and display the optimal cost (the minimized objective value)
optimal_cost_P1 = objective_value(model_P1)
@printf("Optimal cost for P1: %f\n", optimal_cost_P1)

# Count the number of facilities that are opened (y[i] = 1 for each i)
# We use a threshold (0.5) to determine if a facility is considered opened or closed
number_of_opened_facilities = sum(value(y[i]) >= 0.5 for i in 1:m)
println("Number of opened facilities (y_i = 1): $number_of_opened_facilities")

# Print the total time taken for the optimization process
@printf("Optimization time: %.5f seconds\n", elapsed_time)

