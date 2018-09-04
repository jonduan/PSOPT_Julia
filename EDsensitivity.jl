#=
$title Sensitivity Analysis in Economic Load Dispatch

$onText
For more details please refer to Chapter 3 (Gcode3.2), of the following book:
Soroudi, Alireza. Power System Optimization Modeling in GAMS. Springer, 2017.
--------------------------------------------------------------------------------
Model type: QCP
--------------------------------------------------------------------------------
Contributed by
Dr. Alireza Soroudi
IEEE Senior Member
Email: alireza.soroudi@gmail.com
We do request that publications derived from the use of the developed GAMS code
explicitly acknowledge that fact by citing
Soroudi, Alireza. Power System Optimization Modeling in GAMS. Springer, 2017.
DOI: doi.org/10.1007/978-3-319-62350-4
$offText

Converstion from GAMS to JuMP by Jon Duan
=#

N_Gen = 5
Gen_set = 1:N_Gen
Gen = [Symbol("G$i") for i in Gen_set]

N_counter = 11
counter = 1:N_counter

using DataFrames



Load = 400

Other_set = ["a"     ,"b",      "c",       "Pmin",  "Pmax"]
Other = [Symbol("$i") for i in Other_set]


# https://github.com/davidavdav/NamedArrays.jl
# using DataStructures
using NamedArrays
data = Float64[  [3     20     100     28    206]; 
                 [4.05  18.07  98.87   90    284];  
                 [4.05  15.55  104.26  68    189]; 
                 [3.99  19.21  107.21  76    266]; 
                 [3.88  26.18  95.31   19    53]]

data =  NamedArray(data, ( Gen, Other ), ("Rows", "Cols"))
# df[:y2] = parse.(Int,df[:yearsAsString])

using JuMP
using Gurobi

EDsensitivity = Model(solver=GurobiSolver())

@variable(EDsensitivity,  data[i, :Pmin]<= P[i in Gen]<=data[i, :Pmax])

@variable(EDsensitivity, OF>=0)

@objective(EDsensitivity, Min, sum( data[i, :a]*P[i]^2 + data[i,:b]*P[i] for i in Gen))

@constraint(EDsensitivity, Balance, sum( P[i]for i in Gen ) >= Load)

# post Optimization
# initialized
report = DataFrame(OF=Float64[], Load=Float64[])
repGen = convert(DataFrame,Dict([i => Float64[]  for i in Gen]))




# Modifying constraints
# JuMP does not currently support changing constraint coefficients. For less-than and greater-than constraints, the right-hand-side can be changed, e.g.:
for i in counter


    # update the model with increasing Load
    Load =sum(data[i,:Pmin] for i in Gen) +
        ((i -1)/(N_counter-1))*sum(data[i,:Pmax] - data[i,:Pmin] for i in Gen)
    JuMP.setRHS(Balance, Load)  # Now 
    
    # Solve the problem
    solve(EDsensitivity)

    # Print our final solution
    println("Objective value: ", getobjectivevalue(EDsensitivity))

    println("P = ", getvalue(P))
    push!(repGen, [getvalue(P)[i] for i in Gen])
    println("Marginal Value of Balance = ", getdual(Balance))
    # check balance
    sum(getvalue(P))
    # check margian value for P
    getdual(P)
    push!(report, [getobjectivevalue(EDsensitivity), Load])
 

end



# https://jump.readthedocs.io/en/latest/probmod.html
# JuMP will use the ability to modify problems exposed by the solver if possible, and will still work even if the solver does not support this functionality by passing the complete problem to the solver every time.


# Pkg.add("StatPlots")
using DataFrames, Plots, StatPlots, CSV

# http://docs.juliaplots.org/latest/tutorial/

@df report plot(:Load, :OF)

plot(report[:Load], report[:OF])

@df repGen plot(counter, cols(1:5), label = names(repGen))