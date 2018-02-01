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
## Converting a Vector of MOPSolution or BOPSolution into an array ##
#####################################################################

"""
    wrap_sols_into_array(sols::Vector{MOPSolution})
    
 Convert a vector of `MOPSolution` into an `Array{Float64,2}`
"""
function wrap_sols_into_array(sols::Vector{MOPSolution})
    wrap_pnts = zeros(length(sols), length(sols[1].obj_vals))
    @inbounds for i in 1:length(sols)
        wrap_pnts[i, :] = sols[i].obj_vals
    end
    wrap_pnts
end

"""
    wrap_sols_into_array(sols::Vector{BOPSolution})
    
 Convert a vector of `BOPSolution` into an `Array{Float64,2}`
"""
function wrap_sols_into_array(sols::Vector{BOPSolution})
    wrap_pnts = zeros(length(sols), 2)
    @inbounds for i in 1:length(sols)
        wrap_pnts[i, 1], wrap_pnts[i, 2] = sols[i].obj_val1, sols[i].obj_val2
    end
    wrap_pnts
end

#####################################################################
## Computing objective function values                             ##
#####################################################################

"""
    compute_objective_function_value!{T<:MOOInstance, S<:MOOSolution}(solution::S, instance::T)

 Compute objective function values of a `MOOSolution` of a Multi Objective Optimization Instance
"""
function compute_objective_function_value!{T<:MOOInstance, S<:MOOSolution}(solution::S, instance::T)
    @inbounds for i in 1:size(instance.c)[1]
        if length(solution.obj_vals) >= i
            solution.obj_vals[i] = sum(instance.c[i, :] .* solution.vars)
        else
            push!(solution.obj_vals, sum(instance.c[i, :] .* solution.vars))
        end
    end
end

"""
    compute_objective_function_value!{T<:MOOInstance, S<:MOOSolution}(solutions::Vector{S}, instance::T)
    
 Compute objective function values of a `vector{MOOSolution}` of a Multi Objective Optimization Instance
"""
function compute_objective_function_value!{T<:MOOInstance, S<:MOOSolution}(solutions::Vector{S}, instance::T)
    @inbounds for i in 1:length(solutions)
        compute_objective_function_value!(solutions[i], instance)
    end
end

"""
    compute_objective_function_value!{T<:BOOInstance, S<:BOOSolution}(solution::S, instance::T)

 Compute objective function values of a `BOOSolution` of a Bi Objective Optimization Instance
"""
function compute_objective_function_value!{T<:BOOInstance, S<:BOOSolution}(solution::S, instance::T)
    solution.obj_val1, solution.obj_val2 = sum(instance.c1 .* solution.vars), sum(instance.c2 .* solution.vars)
end

"""
    compute_objective_function_value!{T<:BOOInstance, S<:BOOSolution}(solutions::Vector{S}, instance::T)

 Compute objective function values of a `vector{BOOSolution}` of a Bi Objective Optimization Instance
"""
function compute_objective_function_value!{T<:BOOInstance, S<:BOOSolution}(solutions::Vector{S}, instance::T)
    @inbounds for i in 1:length(solutions)
        compute_objective_function_value!(solutions[i], instance)
    end
end

#####################################################################
## Checking Feasibility                                            ##
#####################################################################

@inbounds function check_feasibility(solution::Union{MOPSolution, BOPSolution}, instance::Union{MOBPInstance, BOBPInstance})
    for i in 1:length(solution.vars)
        if 0.0 <= solution.vars[i] && solution.vars[i] <= 1.0
        else
            return false
        end
    end
    if all(isinteger, solution.vars)
    else
        return false
    end
    tmp = instance.A * solution.vars
    for i in 1:length(tmp)
        if instance.cons_lb[i] <= tmp[i] && tmp[i] <= instance.cons_ub[i]
        else
            return false
        end
    end
    return true
end

@inbounds function check_feasibility(solution::Union{MOPSolution, BOPSolution}, instance::Union{MOIPInstance, BOIPInstance})
    for i in 1:length(solution.vars)
        if instance.v_lb[i] <= solution.vars[i] && solution.vars[i] <= instance.v_ub[i]
        else
            return false
        end
    end
    if all(isinteger, solution.vars)
    else
        return false
    end
    tmp = instance.A * solution.vars
    for i in 1:length(tmp)
        if instance.cons_lb[i] <= tmp[i] && tmp[i] <= instance.cons_ub[i]
        else
            return false
        end
    end
    return true
end

@inbounds function check_feasibility(solution::Union{MOPSolution, BOPSolution}, instance::Union{MOMILPInstance, MOMBLPInstance, BOMILPInstance, BOMBLPInstance})
    for i in 1:length(solution.vars)
        if instance.v_lb[i] <= solution.vars[i] && solution.vars[i] <= instance.v_ub[i]
        else
            return false
        end
    end
    if all(isinteger, solution.vars[setdiff([1:size(instance.A, 2)...], findin(instance.var_types, [:Cont]))])
    else
        return false
    end
    tmp = instance.A * solution.vars
    for i in 1:length(tmp)
        if instance.cons_lb[i] - instance.ϵ <= tmp[i] && tmp[i] <= instance.cons_ub[i] + instance.ϵ
        else
            return false
        end
    end
    return true
end

"""
    check_feasibility(solutions::Union{Vector{MOPSolution}, Vector{BOPSolution}}, instance::Union{MOBPInstance, MOIPInstance, MOMBLPInstance, MOMILPInstance, BOBPInstance, BOIPInstance, BOMBLPInstance, BOMILPInstance})
    
 Check feasibility of a vector of biobjective or a vector of multiobjective optimization solutions and only returns the vector of feasible solutions
"""
function check_feasibility(solutions::Union{Vector{MOPSolution}, Vector{BOPSolution}}, instance::Union{MOBPInstance, MOIPInstance, MOMBLPInstance, MOMILPInstance, BOBPInstance, BOIPInstance, BOMBLPInstance, BOMILPInstance})
    inds = fill(false, length(solutions))
    @inbounds for i in 1:length(solutions)
        if check_feasibility(solutions[i], instance)
            inds[i] = true
        end
    end
    solutions[inds]
end

#####################################################################
## Selecting Non Dominated Points                                  ##
#####################################################################

"""
    check_dominance{T<:Number}(point1::Vector{T}, point2::Vector{T})
    
 Checks whether points `point1` and `point2` dominate one another. 
"""
function check_dominance{T<:Number}(point1::Vector{T}, point2::Vector{T})
    if point1 == point2
        return (false, true)
    end
    dom1, dom2 = false, false
    @inbounds for i in 1:length(point1)
        if !dom1 && point1[i] > point2[i]
            dom1 = true
        end
        if !dom2 && point1[i] < point2[i]
            dom2 = true
        end
        if dom1 && dom2
            return (false, false)
        end
    end
    return (dom1, dom2)
end

"""
    select_non_dom_sols{T<:Number}(solutions::Array{T,2})

 Select nondominated points for both Biobjective and Multiobjective Programs. 
"""
function select_non_dom_sols{T<:Number}(solutions::Array{T,2})
    dom_inds = fill(false, size(solutions)[1])
    @inbounds for i in 1:size(solutions)[1]
        if dom_inds[i]
            continue
        end
        for j in i+1:size(solutions)[1]
            if dom_inds[j]
                continue
            end
            i_dom, j_dom = check_dominance(solutions[i, :], solutions[j, :])
            if j_dom
                dom_inds[j] = true
            end
            if i_dom
                dom_inds[i] = true
                break
            end
        end
    end
    solutions[.!dom_inds, :]
end

"""
    select_non_dom_sols(solutions::Vector{MOPSolution})

 Select nondominated solutions among `solutions` for Multiobjective Programs. 
"""
function select_non_dom_sols(solutions::Vector{MOPSolution})
    if length(solutions) == 0
        return solutions
    end
    non_dom_sols = select_non_dom_sols(wrap_sols_into_array(solutions))
    inds = fill(false, length(solutions))
    @inbounds for i in 1:size(non_dom_sols)[1]
        for j in 1:length(solutions)
            if non_dom_sols[i, 1] == solutions[j].obj_vals[1] && non_dom_sols[i, 2:end] == solutions[j].obj_vals[2:end]
                inds[j] = true
                break
            end
        end
    end
    solutions[inds]
end

"""
    select_non_dom_sols(solutions::Vector{BOPSolution})
    
 Select nondominated solutions among `solutions` for Biobjective Programs. 
"""
function select_non_dom_sols(solutions::Vector{BOPSolution})
    if length(solutions) == 0
        return solutions
    end
    non_dom_sols = select_non_dom_sols(wrap_sols_into_array(solutions))
    inds = fill(false, length(solutions))
    @inbounds for i in 1:size(non_dom_sols)[1]
        for j in 1:length(solutions)
            if non_dom_sols[i, 1] == solutions[j].obj_val1 && non_dom_sols[i, 2] == solutions[j].obj_val2
                inds[j] = true
                break
            end
        end
    end
    solutions[inds]
end

#####################################################################
## Selecting Unique Points                                         ##
#####################################################################

"""
    select_unique_sols{T<:Number}(solutions::Array{T, 2})
    
 Select unique nondominated points for both Biobjective and Multiobjective Programs. 
"""
function select_unique_sols{T<:Number}(solutions::Array{T, 2})
    unique(solutions, 1)
end

"""
    select_unique_sols(solutions::Vector{MOPSolution})
    
 Select unique nondominated solutions among `solutions` for Multiobjective Programs. 
"""
function select_unique_sols(solutions::Vector{MOPSolution})
    if length(solutions) == 0
        return solutions
    end
    unique_sols = select_unique_sols(wrap_sols_into_array(solutions))
    inds = fill(false, length(solutions))
    @inbounds for i in 1:size(unique_sols)[1]
        for j in 1:length(solutions)
            if unique_sols[i, 1] == solutions[j].obj_vals[1] && unique_sols[i, 2:end] == solutions[j].obj_vals[2:end]
                inds[j] = true
                break
            end
        end
    end
    solutions[inds]
end

"""
    select_non_dom_sols(solutions::Vector{BOPSolution})
    
 Select unique nondominated solutions among `solutions` for Biobjective Programs. 
"""
function select_unique_sols(solutions::Vector{BOPSolution})
    if length(solutions) == 0
        return solutions
    end
    unique_sols = select_unique_sols(wrap_sols_into_array(solutions))
    inds = fill(false, length(solutions))
    @inbounds for i in 1:size(unique_sols)[1]
        for j in 1:length(solutions)
            if unique_sols[i, 1] == solutions[j].obj_val1 && unique_sols[i, 2] == solutions[j].obj_val2
                inds[j] = true
                break
            end
        end
    end
    solutions[inds]
end

#####################################################################
## Sorting Nondominated Points                                     ##
#####################################################################

"""
    sort_non_dom_sols{T<:Number}(solutions::Array{T,2}, index::Int64=1)
    
 Sort nondominated `solutions` for both Biobjective and Multiobjective Programs based on `index` objective. 
"""
function sort_non_dom_sols{T<:Number}(solutions::Array{T,2}, index::Int64=1)
    if index == 1
        return sortrows(solutions)
    else
        solutions[:, 1], solutions[:, index] = solutions[:, index], solutions[:, 1]
        solutions = sortrows(solutions)
        solutions[:, 1], solutions[:, index] = solutions[:, index], solutions[:, 1]
        return sortrows(solutions)
    end
end

"""
    sort_non_dom_sols(solutions::Vector{MOPSolution}, index::Int64=1)
    
 Sort nondominated `solutions` for Multiobjective Programs based on `index` objective. 
"""
function sort_non_dom_sols(solutions::Vector{MOPSolution}, index::Int64=1)
    if length(solutions) == 0
        return solutions
    end
    sorted_sols = sort_non_dom_sols(wrap_sols_into_array(solutions), index)
    inds = Int64[]
    @inbounds for i in 1:size(sorted_sols)[1]
        for j in 1:length(solutions)
            if sorted_sols[i, 1] == solutions[j].obj_vals[1] && sorted_sols[i, 2:end] == solutions[j].obj_vals[2:end]
                push!(inds, j)
                break
            end
        end
    end
    solutions[inds]
end

"""
    sort_non_dom_sols(solutions::Vector{BOPSolution}, index::Int64=1)
    
 Sort nondominated `solutions` for Biobjective Programs based on `index` objective. 
"""
function sort_non_dom_sols(solutions::Vector{BOPSolution}, index::Int64=1)
    if length(solutions) == 0
        return solutions
    end
    sorted_sols = sort_non_dom_sols(wrap_sols_into_array(solutions), index)
    inds = Int64[]
    @inbounds for i in 1:size(sorted_sols)[1]
        for j in 1:length(solutions)
            if sorted_sols[i, 1] == solutions[j].obj_val1 && sorted_sols[i, 2] == solutions[j].obj_val2
                push!(inds, j)
                break
            end
        end
    end
    solutions[inds]
end

#####################################################################
## Selecting and Sorting Nondominated Points                       ##
#####################################################################

"""
    select_and_sort_non_dom_sols{T<:Number}(solutions::Array{T,2}, index::Int64=1)
    
 Select and Sort nondominated `solutions` for both Biobjective and Multiobjective Programs. 
"""
function select_and_sort_non_dom_sols{T<:Number}(solutions::Array{T,2}, index::Int64=1)
    sort_non_dom_sols(select_non_dom_sols(solutions), index)
end

"""
    select_and_sort_non_dom_sols(solutions::Vector{MOPSolution}, index::Int64=1)
    
 Select and sort nondominated `solutions` for Multiobjective Programs based on `index` objective. 
"""
function select_and_sort_non_dom_sols(solutions::Vector{MOPSolution}, index::Int64=1)
    if length(solutions) == 0
        return solutions
    end
    selected_and_sorted_sols = select_and_sort_non_dom_sols(wrap_sols_into_array(solutions), index)
    inds = Int64[]
    @inbounds for i in 1:size(selected_and_sorted_sols)[1]
        for j in 1:length(solutions)
            if selected_and_sorted_sols[i, 1] == solutions[j].obj_vals[1] && selected_and_sorted_sols[i, 2:end] == solutions[j].obj_vals[2:end]
                push!(inds, j)
                break
            end
        end
    end
    solutions[inds]
end

"""
    select_and_sort_non_dom_sols(solutions::Vector{BOPSolution}, index::Int64=1)
    
 Select and Sort nondominated `solutions` for Biobjective Programs based on `index` objective. 
"""
function select_and_sort_non_dom_sols(solutions::Vector{BOPSolution}, index::Int64=1)
    if length(solutions) == 0
        return solutions
    end
    selected_and_sorted_sols = select_and_sort_non_dom_sols(wrap_sols_into_array(solutions), index)
    inds = Int64[]
    @inbounds for i in 1:size(selected_and_sorted_sols)[1]
        for j in 1:length(solutions)
            if selected_and_sorted_sols[i, 1] == solutions[j].obj_val1 && selected_and_sorted_sols[i, 2] == solutions[j].obj_val2
                push!(inds, j)
                break
            end
        end
    end
    solutions[inds]
end

#####################################################################
# Writing Non Dominated Frontiers and Solutions                     #
#####################################################################

"""
    write_nondominated_frontier(non_dom_sols::Union{Vector{MOPSolution}, Vector{BOPSolution}}, filename::String)
    
 Write nondominated frontier of a `Vector{BOPSolution}` or a `Vector{MOPSolution}` and save it to `filename`.
"""
function write_nondominated_frontier(non_dom_sols::Union{Vector{MOPSolution}, Vector{BOPSolution}}, filename::String)
    writedlm(filename, wrap_sols_into_array(non_dom_sols))
end

"""
    write_nondominated_sols(non_dom_sols::Union{Vector{MOPSolution}, Vector{BOPSolution}}, filename::String)

 Write nondominated solutions of a `Vector{BOPSolution}` or a `Vector{MOPSolution}` and save it to `filename`.
"""
function write_nondominated_sols(non_dom_sols::Union{Vector{MOPSolution}, Vector{BOPSolution}}, filename::String)
    data = Array{Float64, 2}(length(non_dom_sols), length(non_dom_sols[1].vars))
    @inbounds for i in 1:length(non_dom_sols)
        data[i, :] = non_dom_sols[i].vars
    end
    writedlm(filename, data)
end

#####################################################################
# Normalizing a Frontier                                            #
#####################################################################

@inbounds function normalize_frontier{T<:Number}(non_dom_sols::Array{T, 2}, true_non_dom_sols::Array{T, 2})
    tmp = copy(non_dom_sols)
    num_i = [ minimum(true_non_dom_sols[:, i]) for i in 1:size(tmp)[2] ]
    den_i = [ maximum(true_non_dom_sols[:, i]) - minimum(true_non_dom_sols[:, i]) for i in 1:size(tmp)[2] ]
    for i in 1:size(tmp)[1]
        tmp[i, :] = (tmp[i, :] - num_i) ./ den_i
    end
    tmp
end

#####################################################################
# Computing Ideal Point of a Non Dominated Frontier                 #
#####################################################################

"""
    compute_ideal_point{T<:Number}(non_dom_sols::Array{T, 2})
    
 Returns the `Ideal Point` of the nondominated frontier `non_dom_sols`.
"""
function compute_ideal_point{T<:Number}(non_dom_sols::Array{T, 2})
    [ minimum(non_dom_sols[:, i]) for i in 1:size(non_dom_sols)[2] ]
end

"""
    compute_ideal_point(non_dom_sols::Union{Vector{MOPSolution}, Vector{BOPSolution}})

 Returns the `Ideal Point` of the nondominated frontier `non_dom_sols`.
"""
function compute_ideal_point(non_dom_sols::Union{Vector{MOPSolution}, Vector{BOPSolution}})
    compute_ideal_point(wrap_sols_into_array(select_non_dom_sols(non_dom_sols)))
end

#####################################################################
# Computing the Point closest to the Ideal Point                    #
# in a Non Dominated Frontier                                       #
#####################################################################

"""
    compute_closest_point_to_the_ideal_point{T<:Number}(non_dom_sols::Array{T, 2}, ideal_point::Vector{T}, return_pos::Bool=false)

 Returns the closest point in the nondominated frontier `non_dom_sols` from its Ideal Point `ideal_point`.
"""
function compute_closest_point_to_the_ideal_point{T<:Number}(non_dom_sols::Array{T, 2}, ideal_point::Vector{T}, return_pos::Bool=false)
    best_pt_dist = Inf
    best_pt = Float64[]
    best_pt_pos = 0
    @inbounds for i in 1:size(non_dom_sols)[1]
        dist = 0.0
        for j in 1:length(ideal_point)
            dist += (non_dom_sols[i, j] - ideal_point[j])^2
        end
        dist = sqrt(dist)
        if dist < best_pt_dist
            best_pt_dist = copy(dist)
            best_pt = vec(non_dom_sols[i, :])
            best_pt_pos = i
        end
    end
    if return_pos
        best_pt_pos
    else
        best_pt
    end
end

"""
    compute_closest_point_to_the_ideal_point{T<:Number}(non_dom_sols::Union{Vector{MOPSolution}, Vector{BOPSolution}}, ideal_point::Vector{T})

 Returns the closest point in the nondominated frontier `non_dom_sols` from its Ideal Point `ideal_point`.
"""
function compute_closest_point_to_the_ideal_point{T<:Number}(non_dom_sols::Union{Vector{MOPSolution}, Vector{BOPSolution}}, ideal_point::Vector{T})
    non_dom_sols[compute_closest_point_to_the_ideal_point(wrap_sols_into_array(non_dom_sols), ideal_point, true)]
end

"""
    compute_closest_point_to_the_ideal_point{T<:Number}(non_dom_sols::Array{T, 2})

 Returns the closest point in the nondominated frontier `non_dom_sols` from its Ideal Point.
"""
function compute_closest_point_to_the_ideal_point{T<:Number}(non_dom_sols::Array{T, 2})
    compute_closest_point_to_the_ideal_point(non_dom_sols, compute_ideal_point(non_dom_sols))
end

"""
    compute_closest_point_to_the_ideal_point(non_dom_sols::Union{Vector{MOPSolution}, Vector{BOPSolution}})
    
 Returns the closest point in the nondominated frontier `non_dom_sols` from its Ideal Point.
"""
function compute_closest_point_to_the_ideal_point(non_dom_sols::Union{Vector{MOPSolution}, Vector{BOPSolution}})
    compute_closest_point_to_the_ideal_point(non_dom_sols, compute_ideal_point(non_dom_sols))
end

#####################################################################
# Computing Nadir Point of a Non Dominated Frontier                 #
#####################################################################

"""
    compute_nadir_point{T<:Number}(non_dom_sols::Array{T, 2})
    
 Returns the `Nadir Point` of the nondominated frontier `non_dom_sols`.
"""
function compute_nadir_point{T<:Number}(non_dom_sols::Array{T, 2})
    [ maximum(non_dom_sols[:, i]) for i in 1:size(non_dom_sols)[2] ]
end

"""
    compute_nadir_point(non_dom_sols::Union{Vector{MOPSolution}, Vector{BOPSolution}})

 Returns the `Nadir Point` of the nondominated frontier `non_dom_sols`.
"""
function compute_nadir_point(non_dom_sols::Union{Vector{MOPSolution}, Vector{BOPSolution}})
    compute_nadir_point(wrap_sols_into_array(non_dom_sols))
end

#####################################################################
# Computing the Point farthest from the Nadir Point                 #
# in a Non Dominated Frontier                                       #
#####################################################################

"""
    compute_farthest_point_to_the_nadir_point{T<:Number}(non_dom_sols::Array{T, 2}, nadir_point::Vector{T}, return_pos::Bool=false)

 Returns the farthest point in the nondominated frontier `non_dom_sols` from its Nadir Point `nadir_point`.
"""
function compute_farthest_point_to_the_nadir_point{T<:Number}(non_dom_sols::Array{T, 2}, nadir_point::Vector{T}, return_pos::Bool=false)
    best_pt_dist = -Inf
    best_pt = Float64[]
    best_pt_pos = 0
    @inbounds for i in 1:size(non_dom_sols)[1]
        dist = 0.0
        for j in 1:length(nadir_point)
            dist += (non_dom_sols[i, j] - nadir_point[j])^2
        end
        dist = sqrt(dist)
        if dist > best_pt_dist
            best_pt_dist = copy(dist)
            best_pt = vec(non_dom_sols[i, :])
            best_pt_pos = i
        end
    end
    if return_pos
        best_pt_pos
    else
        best_pt
    end
end

"""
    compute_farthest_point_to_the_nadir_point{T<:Number}(non_dom_sols::Union{Vector{MOPSolution}, Vector{BOPSolution}}, nadir_point::Vector{T})

 Returns the farthest point in the nondominated frontier `non_dom_sols` from its Nadir Point `nadir_point`.
"""
function compute_farthest_point_to_the_nadir_point{T<:Number}(non_dom_sols::Union{Vector{MOPSolution}, Vector{BOPSolution}}, nadir_point::Vector{T})
    non_dom_sols[compute_farthest_point_to_the_nadir_point(wrap_sols_into_array(non_dom_sols), nadir_point, true)]
end

"""
    compute_farthest_point_to_the_nadir_point{T<:Number}(non_dom_sols::Array{T, 2})
    
 Returns the farthest point in the nondominated frontier `non_dom_sols` from its Nadir Point.
"""
function compute_farthest_point_to_the_nadir_point{T<:Number}(non_dom_sols::Array{T, 2})
    compute_farthest_point_to_the_nadir_point(non_dom_sols, compute_nadir_point(non_dom_sols))
end

"""
    compute_farthest_point_to_the_nadir_point(non_dom_sols::Union{Vector{MOPSolution}, Vector{BOPSolution}})
    
 Returns the farthest point in the nondominated frontier `non_dom_sols` from its Nadir Point.
"""
function compute_farthest_point_to_the_nadir_point(non_dom_sols::Union{Vector{MOPSolution}, Vector{BOPSolution}})
    compute_farthest_point_to_the_nadir_point(non_dom_sols, compute_nadir_point(non_dom_sols))
end
