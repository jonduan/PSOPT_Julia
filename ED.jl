#=
$title Economic Load Dispatch

$onText
For more details please refer to Chapter 3 (Gcode3.1), of the following book:
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

Other_set = ["a"     ,"b",      "c",       "Pmin",  "Pmax"]
Other = [Symbol("$i") for i in Other_set]

Load = 400

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

ED = Model(solver=GurobiSolver())

@variable(ED,  data[i, :Pmin]<= P[i in Gen]<=data[i, :Pmax])

@variable(ED, OF>=0)

@objective(ED, Min, sum( data[i, :a]*P[i]^2 + data[i,:b]*P[i] for i in Gen))

@constraint(ED, Balance, sum( P[i]for i in Gen ) >= Load)



# Solve the problem
solve(ED)

# Print our final solution
println("Objective value: ", getobjectivevalue(ED))
println("P = ", getvalue(P))
println("Marginal Value of Balance = ", getdual(Balance))
# check balance
sum(getvalue(P))
# check margian value for 
getdual(P)






























# Pkg.add("ExcelFiles")
# Info: Using the Python distribution in the Conda package by default.
# To use a different Python version, set ENV["PYTHON"]="pythoncommand" and re-run Pkg.build("PyCall").

using ExcelFiles, DataFrames

years = [Symbol("$i") for i in 2006:2015];

demand = DataFrame(load("Data.xlsx", "Load!A1:K8761"));

head(demand)

demand = demand[2:end];

demand.colindex

size(demand)

windSouthEast = DataFrame(load("Data.xlsx", "SouthEast!A1:K8761"));


head(windSouthEast)

windNorth = DataFrame(load("Data.xlsx", "North!A1:K8761"));

windNorth =windNorth[2:end];

windSouthWest = DataFrame(load("Data.xlsx", "SouthWest!A1:K8761"));

windSouthWest = windSouthWest[2:end];

#SouthsolarInput rng=PINCHER-CREEK
solarSouth = DataFrame(load("Data.xlsx", "PINCHER-CREEK"));

solarSouth = solarSouth[2:end-1];

# par= MiddleSolarInput rng=EDMONTON-STONY-PLAIN-CS!A1:K8761 Rdim=1 Cdim=1
# par= NorthSolarInput rng=GRANDE-PRAIRIE-A!A1:K8761 Rdim=1 Cdim=1
solarMiddle = DataFrame(load("Data.xlsx", "EDMONTON-STONY-PLAIN-CS!A1:K8761"));

#solarMiddle

solarMiddle = solarMiddle[2:end]; 

solarNorth = DataFrame(load("Data.xlsx", "GRANDE-PRAIRIE-A!A1:K8761"));

solarNorth = solarNorth[2:end];

#solarNorth[Symbol("2006")]

size(solarSouth)

#solarSouth

#solarSouth

typeof(solarSouth)

#solarSouth1 = similar(solarSouth)

#* the unit of output in data table is w. transfor to MW. A solar farm with 50000 PV panel? may cause floating point problem, number is too small
 
for (i,j) in eachcol(solarSouth) # a tuple with symbol and array
  solarSouth[i] = j*50000/1000000;
end

for (i,j) in eachcol(solarMiddle) # a tuple with symbol and array
  solarMiddle[i] = j*50000/1000000;
end

for (i,j) in eachcol(solarNorth) # a tuple with symbol and array
  solarNorth[i] = j*50000/1000000;
end

#Para.csv
using CSV
para =  CSV.read("Para.csv")

para

para[1].== "wind"

turbine = parse(para[ para[1].== "wind",:UnitCap][1]);

turbine

panel =  parse(para[ para[1].== "solar",:UnitCap][1]);
panel

generation_assets = [Symbol(i) for i in para[:,1][2:end]]  

fossil_fuel = [Symbol(i) for i in para[:,1][end-1:end]]  

renewables = [Symbol(i) for i in para[:,1][2:3]]  

windLoc = [:se, :sw, :n]
solarLoc = [:s, :m, :n]

size(para)

#para.columns[1]

para.colindex

FixOMCosts = Dict( zip( generation_assets    , ([parse(i) for i in para[:FixOMCost][2:end]]) )   )

VarOMCosts = Dict( zip( generation_assets    , ([parse(i) for i in para[:VarOMCost][2:end]]) )   )

ONights= Dict( zip( generation_assets    , ([parse(i) for i in para[:ONight][2:end]]) )   )

UnitCaps  = Dict( zip( generation_assets    , ([parse(i) for i in para[:UnitCap][2:end]]) )   )

Maxis  = Dict( zip( generation_assets    , ([parse(i) for i in para[:Max][2:end]]) )   )

Emits  = Dict( zip( generation_assets    , ([parse(i) for i in para[:Emit][2:end]]) )   )

Ramps  = Dict( zip( generation_assets    , ([parse(i) for i in para[:Ramp][2:end]]) )   )

LTimes= Dict( zip( generation_assets    , ([parse(i) for i in para[:LTime][2:end]]) )   )

# # parameters
# ''''''
# round = Para("battery", "Round") ;
# duration = Para("battery", "duration") ;
# taxEm = Para("CT","CTax");
# turbine = Para("wind","UnitCap");
# maxturbine = Para("wind","Max");
# panel = Para("solar","UnitCap");
# maxPanel = Para("solar","Max");
# rate = Para("CT","Discount");
# ''''''






maximums = Dict( zip( generation_assets    , ([parse(i) for i in para[:Max][2:end]]) )   )

roundEfficiency = Dict( zip( generation_assets    , ([parse(i) for i in para[:Round][2:end]]) )   )

duration= Dict( zip( generation_assets    , ([i for i in para[:duration][2:end]]) )   )

taxEm = Dict( zip( generation_assets    , ([parse(i) for i in para[:Ctax][2:end]]) )   )

rate = Dict( zip( generation_assets    , ([parse(i) for i in para[:Discount][2:end]]) )   )

Vcost = Dict( zip( generation_assets    , ( VarOMCosts[i] + taxEm[i]* Emits[i]  for i in generation_assets) )   ) ;



Vcost

Fcost =   Dict( zip(generation_assets, (ONights[i]*rate[i]*((1+rate[i])^LTimes[i])/(((1+rate[i])^LTimes[i])-1) + 
                                            FixOMCosts[i] for i in generation_assets) 
                    )  
                );

Fcost

using JuMP
using Gurobi

m = Model(solver=GurobiSolver())

T = 8760

@variable(m, batteryCap>=0)

# energy in battery
@variable(m, v[1:T]>=0)

@variable(m, charge[1:T]>=0)
@variable(m, discharge[1:T]>=0)

@variable(m, fuelCap[fossil_fuel] >=0)


@variable(m, gen[ 1:T,fossil_fuel] >=0)

@variable(m, nSolarPlant[solarLoc] >=0)
@variable(m, nWindTurbine[windLoc] >=0)



wind = DataFrame(s = 1.0:T,m = 1.0:T, n = 1.0:T);

solar = DataFrame(s = 1.0:T,m = 1.0:T, n = 1.0:T);

year = 2006

Symbol("$year")

wind[:se] = windSouthEast[Symbol("$year")];
wind[:sw] = windSouthWest[Symbol("$year")];
wind[:n] = windNorth[ Symbol("$year")];

#* solar unit output per hour  (MW), number of panel is in 50000, so total solar ouput is MW
solar[:s] = solarSouth[Symbol("$year")];
solar[:m] = solarMiddle[Symbol("$year")];
solar[:n] = solarNorth[Symbol("$year")];

demand0 = demand[Symbol("$year")];

@objective(m, Min, sum(sum(wind[t,L]*nWindTurbine[L]*Vcost[:wind] for L in windLoc) +
                            (sum(solar[t,Ls]*nSolarPlant[Ls]*Vcost[:solar] for Ls in solarLoc))  +  
                            (sum(gen[t,f] *Vcost[f] for f in fossil_fuel )) +   
                            discharge[t]*Vcost[:battery] 
                            for t in 1:T
                            ) + 
                    sum(Fcost[:wind]*nWindTurbine[L]*turbine for L in windLoc) +
                    sum(Fcost[:solar]*nSolarPlant[Ls]*turbine for Ls in solarLoc) +
                    sum(Fcost[f]*fuelCap[f] for f in fossil_fuel) +
                    Fcost[:battery]*batteryCap
            );

@constraint(m,  sum(wind[1,L]*nWindTurbine[L] for L in windLoc) +
                                sum(solar[1,Ls]*nSolarPlant[Ls] for Ls in solarLoc) +
                                  sum(gen[1,f] for f in fossil_fuel) +
                                   discharge[1] -charge[1] >= demand0[1]);

   



# for t in 1:T    
#     @constraint(m, Balance[t], sum(wind[t,L].*nWindTurbine[L] for L in windLoc) +
#                                 sum(solar[t,Ls].*nSolarPlant[Ls] for Ls in solarLoc) +
#                                   sum(gen[t,f] for f in fossil_fuel) +
#                                    discharge[t] -charge[t] >= demand0[t]);
# end


@constraint(m, Balance0[t=1:T], sum(wind[t,L].*nWindTurbine[L] for L in windLoc) +
                            sum(solar[t,Ls].*nSolarPlant[Ls] for Ls in solarLoc) +
                              sum(gen[t,f] for f in fossil_fuel) +
                               discharge[t] -charge[t] >= demand0[t]);

 @constraint(m, capacityFuel[t=1:T, f = fossil_fuel], gen[t,f] <= fuelCap[f] );

 @constraint(m, capacityWind[L=windLoc], nWindTurbine[L] <= maximums[:wind] );

 @constraint(m, capacitySolar[Ls=solarLoc], nSolarPlant[Ls] <= maximums[:solar] );

@constraint(m, RampUp[t=2:T, f = fossil_fuel], gen[t, f] <= gen[t-1,f]+Ramps[f]*fuelCap[f] );

@constraint(m, RampDn[t=2:T, f = fossil_fuel], gen[t, f] >= gen[t-1,f]-Ramps[f]*fuelCap[f] );

@constraint(m, Storage[t=2:T], v[t] ==   v[t-1]+(roundEfficiency[:battery]*charge[t-1]-discharge[t-1]));


@constraint(m, MaxStorage[t=1:T], v[t] <= duration[:battery] * batteryCap);

@constraint(m, MaxCharge[t=1:T], charge[t] <= duration[:battery] * batteryCap);

@constraint(m, MaxDischarge[t=1:T], discharge[t] <= batteryCap);

solve(m)

# # include("examples_julia/2_uc.jl");

# n_machines = 3;
# time_steps = 12;

# fixed_costs = [5, 10, 1000];
# variable_costs = [800, 700, 20];
# max_power = [500, 700, 1500];
# startup_costs = [10, 5, 850];
# demands = [1500, 1200, 1800, 2000, 2200, 1750, 1600, 1500, 1200, 1500, 1600, 1800];


# using JuMP
# using Gurobi

# m = Model(solver=GurobiSolver())

# @variable(m, on[1:time_steps, 1:n_machines], Bin)
# @variable(m, power[1:time_steps, 1:n_machines] >= 0)
# @variable(m, start[1:time_steps, 1:n_machines], Bin)

# @objective(m, Min, sum(dot(fixed_costs, vec(on[t, :])) + 
#         dot(variable_costs, vec(power[t, :])) + dot(startup_costs, vec(start[t, :])) for t in 1:time_steps))


# for t in 1:time_steps
#     for i in 1:n_machines
#         @constraint(m, power[t, i] <= max_power[i] * on[t, i])
#     end
#     @constraint(m, sum(power[t, :]) == demands[t])
# end


# for i in 1:n_machines
#     @constraint(m, start[1, i] == on[1, i])
# end

# for t in 2:time_steps
#     for i in 1:n_machines
#         @constraint(m, start[t, i] >= on[t, i] - on[t - 1, i])
#     end
# end


# for t in 1:time_steps
#     for i in 1:n_machines
#         @constraint(m, on[t, i] >= start[t, i])
#         if t <= time_steps - 1
#             @constraint(m, on[t + 1, i] >= start[t, i])
#         end
#         if t <= time_steps - 2
#             @constraint(m, on[t + 2, i] >= start[t, i])
#         end
#     end
# end

# print(m)
# solve(m)
# getvalue(on)


Gurobi.Env()
