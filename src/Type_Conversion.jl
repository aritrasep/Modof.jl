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

#####################################################################
# LP Relaxations of Pure Binary and Mixed Binary Programs           #
#####################################################################

"""
    lprelaxation(instance::BOBPInstance)
    
 LP relaxation of a `BOBPInstance`
"""
function lprelaxation(instance::BOBPInstance)
    if typeof(instance.A) == SparseMatrixCSC{Float64, Int64}
        instance2 = BOLPInstance(true)
    else
        instance2 = BOLPInstance(false)
    end
    instance2.v_lb = zeros(size(instance.A)[2])
    instance2.v_ub = ones(size(instance.A)[2])
    instance2.c1 = instance.c1
    instance2.c2 = instance.c2
    instance2.A = instance.A
    instance2.cons_lb = instance.cons_lb
    instance2.cons_ub = instance.cons_ub
    instance2.ϵ = 1.0e-6
    return instance2, [1:size(instance2.A)[2]...]
end

"""
    lprelaxation(instance::BOMBLPInstance)

 LP relaxation of a `BOMBLPInstance`
"""
function lprelaxation(instance::BOMBLPInstance)
    if typeof(instance.A) == SparseMatrixCSC{Float64,Int64}
        instance2 = BOLPInstance(true)
    else
        instance2 = BOLPInstance(false)
    end
    instance2.v_lb = instance.v_lb
    instance2.v_ub = instance.v_ub
    instance2.c1 = instance.c1
    instance2.c2 = instance.c2
    instance2.A = instance.A
    instance2.cons_lb = instance.cons_lb
    instance2.cons_ub = instance.cons_ub
    instance2.ϵ = instance.ϵ
    return instance2, findin(instance.var_types, [:Bin])
end

"""
    lprelaxation(instance::MOBPInstance)
    
 LP relaxation of a `MOBPInstance`
"""
function lprelaxation(instance::MOBPInstance)
    if typeof(instance.A) == SparseMatrixCSC{Float64,Int64}
        instance2 = MOLPInstance(true)
    else
        instance2 = MOLPInstance(false)
    end
    instance2.v_lb = zeros(size(instance.A)[2])
    instance2.v_ub = ones(size(instance.A)[2])
    instance2.c = instance.c
    instance2.A = instance.A
    instance2.cons_lb = instance.cons_lb
    instance2.cons_ub = instance.cons_ub
    instance2.ϵ = 1.0e-6
    return instance2, [1:size(instance2.A)[2]...]
end

"""
    lprelaxation(instance::MOMBLPInstance)
    
 LP relaxation of a `MOMBLPInstance`
"""
function lprelaxation(instance::MOMBLPInstance)
    if typeof(instance.A) == SparseMatrixCSC{Float64,Int64}
        instance2 = MOLPInstance(true)
    else
        instance2 = MOLPInstance(false)
    end
    instance2.v_lb = instance.v_lb
    instance2.v_ub = instance.v_ub
    instance2.c = instance.c
    instance2.A = instance.A
    instance2.cons_lb = instance.cons_lb
    instance2.cons_ub = instance.cons_ub
    instance2.ϵ = instance.ϵ
    return instance2, findin(instance.var_types, [:Bin])
end

#####################################################################
# Converting Integer Variables into Binary Variables and vice versa #
#####################################################################

"""
    convert_ip_into_bp(instance::Union{BOIPInstance, BOMILPInstance}, ub::Float64=1.0e6)
    
 Convert a `BOIPInstance` or a `BOMILPInstance` into a `BOBPInstance` or a `BOMBLPInstance` respectively 
"""
function convert_ip_into_bp(instance::Union{BOIPInstance, BOMILPInstance}, ub::Float64=1.0e6)::Tuple{Union{BOBPInstance, BOMBLPInstance}, Vector{Vector{Int64}}}
    if typeof(instance) == BOIPInstance
        instance2 = BOBPInstance()
    else
        instance2 = BOMBLPInstance()
    end
    pos = Vector{Int64}[]
    current_pos = 1
    instance2.c1 = copy(instance.c1)
    instance2.c2 = copy(instance.c2)
    instance2.A = copy(instance.A)
    instance2.cons_lb = copy(instance.cons_lb)
    instance2.cons_ub = copy(instance.cons_ub)
    if typeof(instance) == BOMILPInstance
        instance2.v_lb = copy(instance.v_lb)
        instance2.v_ub = copy(instance.v_ub)
        instance2.var_types = copy(instance.var_types)
    end
    @inbounds for i in 1:length(instance.v_ub)
        if instance.v_ub[i] > 1.0
            if typeof(instance) == BOMILPInstance && instance.var_types[i] == :Cont
                continue
            end    
            num = @match instance.v_ub[i] begin
                Inf => ceil(Int64, log(ub + 1.0) / log(2.0))
                _ => ceil(Int64, log(instance.v_ub[i] + 1.0) / log(2.0))
            end
            push!(pos, [current_pos:(current_pos + num - 1)...])
            tmp1 = instance.c1[i]
            tmp2 = instance.c2[i]
            tmp3 = instance.A[:, i] 
            instance2.c1[current_pos] = tmp1
            instance2.c2[current_pos] = tmp2
            instance2.A[:, current_pos] = tmp3
            if typeof(instance) == BOMILPInstance
                instance2.v_lb[current_pos] = 0.0
                instance2.v_ub[current_pos] = 1.0
                instance2.var_types[current_pos] = :Bin
            end
            for j in 2:num
                insert!(instance2.c1, current_pos + j - 1, 2^(j - 1) * tmp1)
                insert!(instance2.c2, current_pos + j - 1, 2^(j - 1) * tmp2)
                instance2.A = hcat(instance2.A[:, 1:current_pos + j - 2], 2^(j - 1) * tmp3, instance2.A[:, current_pos + j - 1:end])
                if typeof(instance) == BOMILPInstance
                    insert!(instance2.v_lb, current_pos + j - 1, 0.0)
                    insert!(instance2.v_ub, current_pos + j - 1, 1.0)
                    insert!(instance2.var_types, current_pos + j - 1, :Bin)
                end
            end    
            current_pos += num
        else
            current_pos += 1
        end
    end
    instance2, pos
end

"""
    convert_ip_into_bp(instance::Union{MOIPInstance, MOMILPInstance}, ub::Float64=1.0e6)
    
 Convert a `MOIPInstance` or a `MOMILPInstance` into a `MOBPInstance` or a `MOMBLPInstance` respectively 
"""
function convert_ip_into_bp(instance::Union{MOIPInstance, MOMILPInstance}, ub::Float64=1.0e6)::Tuple{Union{MOBPInstance, MOMBLPInstance}, Vector{Vector{Int64}}}
    if typeof(instance) == MOIPInstance
        instance2 = MOBPInstance()
    else
        instance2 = MOMBLPInstance()
    end
    pos = Vector{Int64}[]
    current_pos = 1
    instance2.c = copy(instance.c)
    instance2.A = copy(instance.A)
    instance2.cons_lb = copy(instance.cons_lb)
    instance2.cons_ub = copy(instance.cons_ub)
    if typeof(instance) == MOMILPInstance
        instance2.v_lb = copy(instance.v_lb)
        instance2.v_ub = copy(instance.v_ub)
        instance2.var_types = copy(instance.var_types)
    end
    @inbounds for i in 1:length(instance.v_ub)
        if instance.v_ub[i] > 1.0
            if typeof(instance) == MOMILPInstance && instance.var_types[i] == :Cont
                continue
            end    
            num = @match instance.v_ub[i] begin
                Inf => ceil(Int64, log(ub + 1.0) / log(2.0))
                _ => ceil(Int64, log(instance.v_ub[i] + 1.0) / log(2.0))
            end
            push!(pos, [current_pos:(current_pos + num - 1)...])
            tmp1 = instance.c[:, i]
            tmp2 = instance.A[:, i] 
            instance2.c[:, current_pos] = tmp1
            instance2.A[:, current_pos] = tmp2
            if typeof(instance) == MOMILPInstance
                instance2.v_lb[current_pos] = 0.0
                instance2.v_ub[current_pos] = 1.0
                instance2.var_types[current_pos] = :Bin
            end
            for j in 2:num
                instance2.c = hcat(instance2.c[:, 1:current_pos + j - 2], 2^(j - 1) * tmp1, instance2.c[:, current_pos + j - 1:end])
                instance2.A = hcat(instance2.A[:, 1:current_pos + j - 2], 2^(j - 1) * tmp2, instance2.A[:, current_pos + j - 1:end])
                if typeof(instance) == MOMILPInstance
                    insert!(instance2.v_lb, current_pos + j - 1, 0.0)
                    insert!(instance2.v_ub, current_pos + j - 1, 1.0)
                    insert!(instance2.var_types, current_pos + j - 1, :Bin)
                end
            end    
            current_pos += num
        else
            current_pos += 1
        end
    end
    instance2, pos
end

function convert_bp_sol_into_ip_sol(solution::Union{BOPSolution, MOPSolution}, instance::Union{BOIPInstance, BOMILPInstance, MOIPInstance, MOMILPInstance}, pos::Vector{Vector{Int64}})::Union{BOPSolution, MOPSolution}
    if typeof(instance) == BOIPInstance || typeof(instance) == BOMILPInstance
        solution2 = BOPSolution()
    else
        solution2 = MOPSolution()
    end
    current_pos = 1
    current_pos2 = 1
    @inbounds for i in 1:size(instance.A, 2)
        if instance.v_ub[i] <= 1.0
            push!(solution2.vars, solution.vars[current_pos])
            current_pos += 1
        else
            if (typeof(instance) == BOMILPInstance || typeof(instance) == MOMILPInstance) && instance.var_types[i] == :Cont
                push!(solution2.vars, solution.vars[current_pos])
                current_pos += 1
            else
                tmp = 0.0
                for j in 1:length(pos[current_pos2])
                    tmp += 2.0^(j - 1) * solution.vars[pos[current_pos2][j]]
                end
                push!(solution2.vars, tmp)
                current_pos += length(pos[current_pos2])
                current_pos2 += 1
            end
        end
    end
    compute_objective_function_value!(solution2, instance)
    solution2        
end

function convert_bp_sol_into_ip_sol(solutions::Union{Vector{BOPSolution}, Vector{MOPSolution}}, instance::Union{BOIPInstance, BOMILPInstance, MOIPInstance, MOMILPInstance}, pos::Vector{Vector{Int64}})::Union{Vector{BOPSolution}, Vector{MOPSolution}}
    if typeof(instance) == BOIPInstance || typeof(instance) == BOMILPInstance
        solutions2 = BOPSolution[]
    else
        solutions2 = MOPSolution[]
    end
    @inbounds for i in 1:length(solutions)
        push!(solutions2, convert_bp_sol_into_ip_sol(solutions[i], instance, pos))
    end
    solutions2
end
