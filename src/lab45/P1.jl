import Pkg;
Pkg.add("HiGHS")
Pkg.add("JuMP")
Pkg.add("Printf")

using HiGHS   # Make sure this is added
using JuMP
using Printf

include("juliaData/floc3.jl")

e = 100

# Definiera modellen med HiGHS som solver
model_P1 = Model(HiGHS.Optimizer)

# Definiera variablerna
@variable(model_P1, 0 <= x[1:m, 1:n])  # xij: transporterad mängd från plats i till kund j
@variable(model_P1, y[1:m], Bin)       # yi: 1 om anläggning på plats i öppnas, 0 annars

# Definiera målfunktionen (total kostnad) med diskonteringsfaktorn på fasta kostnader
@objective(model_P1, Min, sum(c[i,j] * x[i,j] for i in 1:m, j in 1:n) + sum(e * f[i] * y[i] for i in 1:m))

# Begränsning (1): Kapacitet hos anläggning
@constraint(model_P1, [i=1:m], sum(x[i,j] for j in 1:n) <= s[i] * y[i])

# Begränsning (2): Tillgodose kundernas efterfrågan
@constraint(model_P1, [j=1:n], sum(x[i,j] for i in 1:m) == d[j])

# Starta timer innan optimering
start_time = time()

# Lös modellen
optimize!(model_P1)

# Stoppa timer efter optimering
end_time = time()

# Beräkna tiden det tog att optimera
elapsed_time = end_time - start_time

# Hämta och visa resultat
optimal_cost_P1 = objective_value(model_P1)
println("Optimal kostnad för P1: $optimal_cost_P1")

# Räkna antal y_i som är lika med 1
number_of_opened_facilities = sum(value(y[i]) for i in 1:m if value(y[i]) > 0.5)  # Använd en tröskel för att räkna binära värden
println("Antal öppnade anläggningar (y_i = 1): $number_of_opened_facilities")

# Skriv ut tiden för optimeringen med fler decimaler
@printf "Tid för optimering: %.5f sekunder\n" elapsed_time

