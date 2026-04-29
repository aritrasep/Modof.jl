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
    expressions::Vector{Any}
end

objectives() = objectives(Symbol[], Any[])

function _modo_objectives(model::JuMP.Model)
    return get!(model.ext, :objs) do
        objectives()
    end
end

function ModoModel(optimizer=GLPK.Optimizer; kwargs...)
    model = JuMP.Model(optimizer; kwargs...)
    model.ext[:objs] = objectives()
    return model
end

function _jump_sense(sense)
    if sense in (:Min, :MIN, :Minimize, JuMP.MIN_SENSE)
        return JuMP.MIN_SENSE
    elseif sense in (:Max, :MAX, :Maximize, JuMP.MAX_SENSE)
        return JuMP.MAX_SENSE
    end
    error("Unsupported objective sense $(repr(sense)); expected :Min or :Max.")
end

function _sense_symbol(sense)
    jump_sense = _jump_sense(sense)
    return jump_sense == JuMP.MAX_SENSE ? :Max : :Min
end

function objective!(model::JuMP.Model, position::Integer, sense, obj)
    position >= 1 || throw(ArgumentError("objective position must be positive"))
    if position == 1
        JuMP.set_objective(model, _jump_sense(sense), obj)
        return model
    end
    objs = _modo_objectives(model)
    index = position - 1
    while length(objs.sense) < index
        push!(objs.sense, :Min)
        push!(objs.expressions, 0.0)
    end
    objs.sense[index] = _sense_symbol(sense)
    objs.expressions[index] = obj
    return model
end

function _variable_map(vars::Vector{JuMP.VariableRef})
    return Dict(var => i for (i, var) in enumerate(vars))
end

function _linear_coefficients(expr, vars::Vector{JuMP.VariableRef}, var_to_index::Dict{JuMP.VariableRef, Int})
    coefficients = zeros(length(vars))
    if expr isa Number
        return coefficients
    elseif expr isa JuMP.VariableRef
        coefficients[var_to_index[expr]] = 1.0
        return coefficients
    elseif expr isa JuMP.AffExpr
        for (var, coefficient) in expr.terms
            coefficients[var_to_index[var]] += Float64(coefficient)
        end
        return coefficients
    end
    error("Modof only supports linear JuMP objectives and constraints; got $(typeof(expr)).")
end

function _linear_constant(expr)
    if expr isa Number || expr isa JuMP.VariableRef
        return 0.0
    elseif expr isa JuMP.AffExpr
        return Float64(JuMP.constant(expr))
    end
    error("Modof only supports linear JuMP objectives and constraints; got $(typeof(expr)).")
end

function _constraint_bounds(set::MOI.LessThan{Float64}, constant::Float64)
    return -Inf, set.upper - constant
end

function _constraint_bounds(set::MOI.GreaterThan{Float64}, constant::Float64)
    return set.lower - constant, Inf
end

function _constraint_bounds(set::MOI.EqualTo{Float64}, constant::Float64)
    rhs = set.value - constant
    return rhs, rhs
end

function _constraint_bounds(set::MOI.Interval{Float64}, constant::Float64)
    return set.lower - constant, set.upper - constant
end

function _append_constraints!(rows, cons_lb, cons_ub, model::JuMP.Model, vars, var_to_index, F, S)
    for constraint_ref in JuMP.all_constraints(model, F, S)
        constraint = JuMP.constraint_object(constraint_ref)
        push!(rows, _linear_coefficients(constraint.func, vars, var_to_index))
        lower, upper = _constraint_bounds(constraint.set, _linear_constant(constraint.func))
        push!(cons_lb, lower)
        push!(cons_ub, upper)
    end
    return nothing
end

function _extract_linear_constraints(model::JuMP.Model, vars, var_to_index, function_types)
    rows = Vector{Vector{Float64}}()
    cons_lb = Float64[]
    cons_ub = Float64[]
    for F in function_types
        for S in (MOI.LessThan{Float64}, MOI.GreaterThan{Float64}, MOI.EqualTo{Float64}, MOI.Interval{Float64})
            _append_constraints!(rows, cons_lb, cons_ub, model, vars, var_to_index, F, S)
        end
    end
    if isempty(rows)
        A = zeros(0, length(vars))
    else
        A = reduce(vcat, transpose.(rows))
    end
    return A, cons_lb, cons_ub
end

_extract_linear_constraints(model::JuMP.Model, vars, var_to_index) =
    _extract_linear_constraints(model, vars, var_to_index, (JuMP.AffExpr, JuMP.VariableRef))

function _extract_variable_data(vars::Vector{JuMP.VariableRef})
    var_types = Symbol[]
    v_lb = Float64[]
    v_ub = Float64[]
    for var in vars
        if JuMP.is_binary(var)
            push!(var_types, :Bin)
            push!(v_lb, 0.0)
            push!(v_ub, 1.0)
        else
            push!(var_types, JuMP.is_integer(var) ? :Int : :Cont)
            push!(v_lb, JuMP.has_lower_bound(var) ? Float64(JuMP.lower_bound(var)) : -Inf)
            push!(v_ub, JuMP.has_upper_bound(var) ? Float64(JuMP.upper_bound(var)) : Inf)
        end
    end
    return var_types, v_lb, v_ub
end

function _objective_coefficients(model::JuMP.Model, vars, var_to_index)
    if JuMP.objective_sense(model) == JuMP.FEASIBILITY_SENSE
        return zeros(length(vars)), :Min
    end
    return _linear_coefficients(JuMP.objective_function(model), vars, var_to_index),
        _sense_symbol(JuMP.objective_sense(model))
end

function _normalize_objective_rows!(c, sense::Vector{Symbol})
    for i in 1:length(sense)
        if sense[i] == :Max
            c[i, :] = -1.0 * c[i, :]
        end
    end
    return c
end

function _normalize_constraint_rows!(A, cons_lb::Vector{Float64}, cons_ub::Vector{Float64})
    for i in 1:size(A, 1)
        if cons_ub[i] != Inf && cons_lb[i] == -Inf
            cons_lb[i] = -1.0 * cons_ub[i]
            cons_ub[i] = Inf
            A[i, :] = -1.0 * A[i, :]
        end
    end
    return A, cons_lb, cons_ub
end

function _maybe_sparse(A)
    if isempty(A)
        return sparse(A)
    end
    sparsity = count(iszero, A) / length(A)
    return sparsity >= 0.5 ? sparse(A) : A
end

function _build_instance(var_types, v_lb, v_ub, c, A, cons_lb, cons_ub)
    has_cont = :Cont in var_types
    has_bin = :Bin in var_types
    has_int = :Int in var_types
    A = _maybe_sparse(A)
    if size(c, 1) == 2
        c1 = vec(c[1, :])
        c2 = vec(c[2, :])
        if !has_bin && !has_int
            return BOLPInstance(v_lb, v_ub, c1, c2, A, cons_lb, cons_ub, 1.0e-9)
        elseif has_bin && !has_cont && !has_int
            return BOBPInstance(c1, c2, A, cons_lb, cons_ub)
        elseif !has_cont
            return BOIPInstance(v_lb, v_ub, c1, c2, A, cons_lb, cons_ub)
        elseif has_bin && !has_int
            return BOMBLPInstance(var_types, v_lb, v_ub, c1, c2, A, cons_lb, cons_ub, 1.0e-9)
        else
            return BOMILPInstance(var_types, v_lb, v_ub, c1, c2, A, cons_lb, cons_ub, 1.0e-9)
        end
    end
    if !has_bin && !has_int
        return MOLPInstance(v_lb, v_ub, c, A, cons_lb, cons_ub, 1.0e-9)
    elseif has_bin && !has_cont && !has_int
        return MOBPInstance(c, A, cons_lb, cons_ub)
    elseif !has_cont
        return MOIPInstance(v_lb, v_ub, c, A, cons_lb, cons_ub)
    elseif has_bin && !has_int
        return MOMBLPInstance(var_types, v_lb, v_ub, c, A, cons_lb, cons_ub, 1.0e-9)
    else
        return MOMILPInstance(var_types, v_lb, v_ub, c, A, cons_lb, cons_ub, 1.0e-9)
    end
end

function _instance_from_jump_data(model::JuMP.Model, c, sense::Vector{Symbol}, A, cons_lb, cons_ub)
    vars = JuMP.all_variables(model)
    var_types, v_lb, v_ub = _extract_variable_data(vars)
    c = _normalize_objective_rows!(copy(c), sense)
    A, cons_lb, cons_ub = _normalize_constraint_rows!(copy(A), copy(cons_lb), copy(cons_ub))
    return _build_instance(var_types, v_lb, v_ub, c, A, cons_lb, cons_ub), sense
end

function read_an_instance_from_a_jump_model(model::JuMP.Model)
    vars = JuMP.all_variables(model)
    var_to_index = _variable_map(vars)
    primary_coefficients, primary_sense = _objective_coefficients(model, vars, var_to_index)
    objs = _modo_objectives(model)
    sense = [primary_sense; objs.sense]
    c = zeros(length(sense), length(vars))
    c[1, :] = primary_coefficients
    for i in 1:length(objs.expressions)
        c[i + 1, :] = _linear_coefficients(objs.expressions[i], vars, var_to_index)
    end
    A, cons_lb, cons_ub = _extract_linear_constraints(model, vars, var_to_index)
    return _instance_from_jump_data(model, c, sense, A, cons_lb, cons_ub)
end

function _read_jump_model_with_constraint_objectives(model::JuMP.Model, sense::Vector{Symbol})
    vars = JuMP.all_variables(model)
    var_to_index = _variable_map(vars)
    primary_coefficients, _ = _objective_coefficients(model, vars, var_to_index)
    A_aff, cons_lb_aff, cons_ub_aff =
        _extract_linear_constraints(model, vars, var_to_index, (JuMP.AffExpr,))
    A_var, cons_lb_var, cons_ub_var =
        _extract_linear_constraints(model, vars, var_to_index, (JuMP.VariableRef,))
    length(sense) >= 1 || throw(ArgumentError("sense must contain at least the primary objective sense"))
    tail_objectives = length(sense) - 1
    tail_objectives <= size(A_aff, 1) || throw(ArgumentError("not enough trailing affine constraints to read as additional objectives"))
    c = zeros(length(sense), length(vars))
    c[1, :] = primary_coefficients
    if tail_objectives > 0
        first_tail = size(A_aff, 1) - tail_objectives + 1
        c[2:end, :] = A_aff[first_tail:end, :]
        A_aff = A_aff[1:first_tail-1, :]
        cons_lb_aff = cons_lb_aff[1:first_tail-1]
        cons_ub_aff = cons_ub_aff[1:first_tail-1]
    end
    A = vcat(A_aff, A_var)
    cons_lb = vcat(cons_lb_aff, cons_lb_var)
    cons_ub = vcat(cons_ub_aff, cons_ub_var)
    return _instance_from_jump_data(model, c, copy(sense), A, cons_lb, cons_ub)
end

function read_an_instance_from_a_lp_or_a_mps_file(filename::String, sense::Vector{Symbol}=Symbol[])
    model = JuMP.read_from_file(filename)
    all_senses = [_sense_symbol(JuMP.objective_sense(model)); sense]
    return _read_jump_model_with_constraint_objectives(model, all_senses)
end
