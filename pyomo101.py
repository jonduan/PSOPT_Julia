# simple.py 

from pyomo.environ import *

M = ConcreteModel() 
M.x1 = Var() 
M.x2 = Var(bounds=(-1,1)) 
M.x3 = Var(bounds=(1,2)) 
M.c1 = Constraint(expr=M.x1 == M.x2 + M.x3) 
M.o = Objective( expr=M.x1**2 + (M.x2*M.x3)**4 + \ 
                        M.x1*M.x3 + \
                        M.x2*sin(M.x1+M.x3) + M.x2)
opt_result = SolverFactory(‘ipopt’).solve(M) 
opt_model = M