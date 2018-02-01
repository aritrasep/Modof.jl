###############################################################################
#                                                                             #
#  This file is part of the julia module for Multi Objective Optimization     #
#  (c) Copyright 2017 by Aritra Pal                                           #
#                                                                             #
# Permission is hereby granted, free of charge, to any person obtaining a     # 
# copy of this software and associated documentation files (the "Software"),  #
# to deal in the Software without restriction, including without limitation   #
# the rights to use, copy, modify, merge, publish, distribute, sublicense,    #
# and/or sell copies of the Software, and to permit persons to whom the       #
# Software is furnished to do so, subject to the following conditions:        #
#                                                                             #
# The above copyright notice and this permission notice shall be included in  #
# all copies or substantial portions of the Software.                         #
#                                                                             #
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  #
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,    #
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE #
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER      #
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING     #
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER         #
# DEALINGS IN THE SOFTWARE.                                                   #
#                                                                             #
# Every publication and presentation for which work based on the Program or   #
# its output has been used must contain an appropriate citation and           #
# acknowledgment of the author(s) of the Program.                             #
###############################################################################

###############################################################################
# ModoModel - JuMP Extension                                                  #
###############################################################################

mutable struct objectives
    sense::Vector{Symbol}
    coefficients::Vector{Vector{Float64}}
end	

function objectives()
    objectives(Symbol[], Vector{Float64}[])
end

function ModoModel()
    model = Model(solver=GLPKSolverMIP())
    model.ext[:objs] = objectives()
    model
end

@inbounds function objective!(model::JuMP.Model, position::Int64, sense::Symbol, obj)
    if position == 1
        @objective(model, sense, obj)
    else
        position -= 1
        if position > length(model.ext[:objs].sense)
            for i in length(model.ext[:objs].sense)+1:position
                push!(model.ext[:objs].sense, :Min)
                push!(model.ext[:objs].coefficients, zeros(model.numCols))
            end
        end
        model.ext[:objs].sense[position] = sense    
        expr = QuadExpr(obj)
        model.ext[:objs].coefficients[position] = zeros(model.numCols)
        for i in 1:length(expr.aff.vars)
            model.ext[:objs].coefficients[position][expr.aff.vars[i].col] += expr.aff.coeffs[i]
        end
    end
end

@inbounds function read_a_moo_instance_from_a_mathprogbase_model(model::MathProgBase.AbstractMathProgModel, sense::Vector{Symbol})
    var_types = MathProgBase.getvartype(model)
    v_lb = MathProgBase.getvarLB(model)
    v_ub = MathProgBase.getvarUB(model)
    for i in 1:length(v_lb)
        if v_lb[i] == 0.0 && v_ub[i] == 1.0 && var_types[i] != :Cont
            var_types[i] = :Bin
        end
    end
    A = MathProgBase.getconstrmatrix(model)
    cons_lb = MathProgBase.getconstrLB(model)
    cons_lb = cons_lb[1:end-length(sense)+1]
    cons_ub = MathProgBase.getconstrUB(model)
    cons_ub = cons_ub[1:end-length(sense)+1]
    m, n = size(A)
    c = zeros(length(sense), n)
    c[1, :] = MathProgBase.getobj(model)
    c[2:end, :] = A[end-length(sense)+2:end, :]
    for i in 1:length(sense)
        if sense[i] == :Max
            c[i, :] = -1.0*c[i, :]
        end
    end
    A = A[1:end-length(sense)+1, :]
    m, n = size(A)
    for i in 1:m
        if cons_ub[i] != Inf && cons_lb[i] == -Inf
            cons_lb[i] = -1.0*cons_ub[i]
            cons_ub[i] = Inf
            A[i, :] = -1.0*A[i, :]
        end
    end
    sparsity = length(findin(A, 0.0))/(m*n)
    if sparsity >= 0.5
        A = sparse(A)
    end
    if !(:Bin in var_types) && !(:Int in var_types)
        instance = MOLPInstance(v_lb, v_ub, c, A, cons_lb, cons_ub, 1.0e-9)	
    end
    if !(:Cont in var_types) && !(:Int in var_types)
        instance = MOBPInstance(c, A, cons_lb, cons_ub)	
    end
    if !(:Cont in var_types)
        instance = MOIPInstance(v_lb, v_ub, c, A, cons_lb, cons_ub)	
    end
    if :Cont in var_types && :Bin in var_types && !(:Int in var_types)
        instance = MOMBLPInstance(var_types, v_lb, v_ub, c, A, cons_lb, cons_ub, 1.0e-9)	
    end
    if :Cont in var_types && :Int in var_types
        instance = MOMILPInstance(var_types, v_lb, v_ub, c, A, cons_lb, cons_ub, 1.0e-9)	
    end
    instance, sense
end

@inbounds function read_a_boo_instance_from_a_mathprogbase_model(model::MathProgBase.AbstractMathProgModel, sense::Vector{Symbol})
    var_types = MathProgBase.getvartype(model)
    v_lb = MathProgBase.getvarLB(model)
    v_ub = MathProgBase.getvarUB(model)
    for i in 1:length(v_lb)
        if v_lb[i] == 0.0 && v_ub[i] == 1.0 && var_types[i] != :Cont
            var_types[i] = :Bin
        end
    end
    A = MathProgBase.getconstrmatrix(model)
    cons_lb = MathProgBase.getconstrLB(model)
    cons_lb = cons_lb[1:end-length(sense)+1]
    cons_ub = MathProgBase.getconstrUB(model)
    cons_ub = cons_ub[1:end-length(sense)+1]
    m, n = size(A)
    c1 = MathProgBase.getobj(model)
    c2 = vec(A[end, :])
    if sense[1] == :Max
        c1 = -1.0*c1
    end
    if sense[2] == :Max
        c2 = -1.0*c2
    end
    A = A[1:end-1, :]
    m, n = size(A)
    for i in 1:m
        if cons_ub[i] != Inf && cons_lb[i] == -Inf
            cons_lb[i] = -1.0*cons_ub[i]
            cons_ub[i] = Inf
            A[i, :] = -1.0*A[i, :]
        end
    end
    sparsity = length(findin(A, 0.0))/(m*n)
    if sparsity >= 0.5
        A = sparse(A)
    end
    if !(:Bin in var_types) && !(:Int in var_types)
        instance = BOLPInstance(v_lb, v_ub, c1, c2, A, cons_lb, cons_ub, 1.0e-9)	
    end
    if !(:Cont in var_types) && !(:Int in var_types)
        instance = BOBPInstance(c1, c2, A, cons_lb, cons_ub)	
    end
    if !(:Cont in var_types)
        instance = BOIPInstance(v_lb, v_ub, c1, c2, A, cons_lb, cons_ub)	
    end
    if :Cont in var_types && :Bin in var_types && !(:Int in var_types)
        instance = BOMBLPInstance(var_types, v_lb, v_ub, c1, c2, A, cons_lb, cons_ub, 1.0e-9)
    end
    if :Cont in var_types && :Int in var_types
        instance = BOMILPInstance(var_types, v_lb, v_ub, c1, c2, A, cons_lb, cons_ub, 1.0e-9)	
    end
    instance, sense
end

@inbounds function read_an_instance_from_a_jump_model(model::JuMP.Model)
    model_ = deepcopy(model)
    JuMP.build(model_)
    insert!(model_.ext[:objs].sense, 1, MathProgBase.getsense(model_.internalModel))
    for i in 1:length(model_.ext[:objs].coefficients)
        inds = findn(model_.ext[:objs].coefficients[i])
        MathProgBase.addconstr!(model_.internalModel, inds, model_.ext[:objs].coefficients[i][inds], 0.0, 0.0)
    end
    if length(model_.ext[:objs].sense) == 2
        read_a_boo_instance_from_a_mathprogbase_model(model_.internalModel, model_.ext[:objs].sense)
    else
        read_a_moo_instance_from_a_mathprogbase_model(model_.internalModel, model_.ext[:objs].sense)
    end
end

@inbounds function read_an_instance_from_a_lp_or_a_mps_file(filename::String, sense::Vector{Symbol})
    model = MathProgBase.LinearQuadraticModel(GLPKSolverMIP())
    MathProgBase.loadproblem!(model, filename)
    insert!(sense, 1, MathProgBase.getsense(model))
    if length(sense) == 2
        read_a_boo_instance_from_a_mathprogbase_model(model, sense)
    else
        read_a_moo_instance_from_a_mathprogbase_model(model, sense)
    end
end
