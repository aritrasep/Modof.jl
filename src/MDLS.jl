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
# MDLS                                                              #
#####################################################################

#####################################################################
## Knapsack Instances                                              ##
#####################################################################

@inbounds function write_kpinstance_in_mdls_format(instance::Union{MOBPInstance, BOBPInstance}, filename::String)
    file = open(filename, "w")
    if typeof(instance) == MOBPInstance
        for i in 1:size(instance.c)[1]
            write(file, "max  ")
            for j in 1:size(instance.c)[2]
                if j < size(instance.c)[2]
                    write(file, "$(-1.0*instance.c[i, j]) x$(j-1) + ")
                else
                    write(file, "$(-1.0*instance.c[i, j]) x$(j-1)")
                end
            end
            write(file, "\n")
        end
        write(file, "\nst\n")
    else
        write(file, "max  ")
        for i in 1:length(instance.c1)
            if i < length(instance.c1)
                write(file, "$(-1.0*instance.c1[i]) x$(i-1) + ")
            else
                write(file, "$(-1.0*instance.c1[i]) x$(i-1)")
            end
        end
        write(file, "\nmax  ")
        for i in 1:length(instance.c2)
            if i < length(instance.c2)
                write(file, "$(-1.0*instance.c2[i]) x$(i-1) + ")
            else
                write(file, "$(-1.0*instance.c2[i]) x$(i-1)")
            end
        end
        write(file, "\n\nst\n")
    end
    for i in 1:size(instance.A)[1]
        if instance.cons_ub[i] == Inf
            for j in 1:size(instance.A)[2]
                if j < size(instance.A)[2]
                    write(file, "$(-1.0*instance.A[i, j]) x$(j-1) + ")
                else
                    write(file, "$(-1.0*instance.A[i, j]) x$(j-1) ")
                end
            end
            write(file, "<= $(-1.0*instance.cons_lb[i])\n")
        end
    end
    close(file)
end

@inbounds function read_non_dom_sols_mdls_kp(file_location::String, len::Int64, bokp::Bool)
    data = readdlm(file_location)
    non_dom_sols = @match bokp begin
        true => BOPSolution[]
        _ => MOPSolution[]
    end
    for i in 1:size(data)[1]
        if data[i, 1] == "Selected"
            tmp = data[i, 3:end]
            tmp2 = convert(Vector{Int64}, tmp[[data[i, j] != "" for j in 3:size(data)[2]]]) + 1
            @match bokp begin
                true => push!(non_dom_sols, BOPSolution(vars=zeros(len)))
                _ => push!(non_dom_sols, MOPSolution(vars=zeros(len)))
            end
            non_dom_sols[end].vars[tmp2] = 1.0
        end
    end
    non_dom_sols
end

@inbounds function mdls_kp(instance::Union{MOBPInstance, BOBPInstance})
    write_kpinstance_in_mdls_format(instance, "Instance_$(myid()).txt")
    try
        run(`mdls-mo01kp -i Instance_$(myid()).txt -MOMCKP -o Output_$(myid())`)
    catch
    end
    rm("Instance_$(myid()).txt")
    files = readdir()
    files = files[[contains(files[i], "Output_$(myid())-") for i in 1:length(files)]]
    files = files[[contains(files[i], "solutions") for i in 1:length(files)]]
    bokp = false
    if typeof(instance) == BOBPInstance
        bokp = true
    end
    non_dom_sols = @match bokp begin
        true => BOPSolution[]
        _ => MOPSolution[]
    end
    for i in 1:length(files)
        non_dom_sols = @match bokp begin
            true => vcat(non_dom_sols, read_non_dom_sols_mdls_kp(files[i], length(instance.c1), true))
            _ => vcat(non_dom_sols, read_non_dom_sols_mdls_kp(files[i], size(instance.c, 2), false))
        end
    end
    files = readdir()
    files = files[[contains(files[i], "Output_$(myid())-") for i in 1:length(files)]]
    for i in 1:length(files)
        rm(files[i])
    end
    compute_objective_function_value!(non_dom_sols, instance)
    non_dom_sols = check_feasibility(non_dom_sols, instance)
    select_and_sort_non_dom_sols(non_dom_sols)
end

#####################################################################
## Biobjective Set Packing Instances                               ##
#####################################################################

@inbounds function read_non_dom_sols_mdls_bospp(file_location::String, len::Int64)
    data = readdlm(file_location)
    non_dom_sols = BOPSolution[]
    for i in 1:size(data)[1]
        if data[i, 1] == "Selected:"
            tmp = data[i, 2:end]
            tmp2 = convert(Vector{Int64}, tmp[[data[i, j] != "" for j in 2:size(data)[2]]]) + 1
            push!(non_dom_sols, BOPSolution(vars=zeros(len)))
            non_dom_sols[end].vars[tmp2] = 1.0
        end
    end
    non_dom_sols
end

@inbounds function write_sppinstance_in_mdls_format(instance::BOBPInstance, filename::String)
    file = open(filename, "w")
    write(file, "$(size(instance.A, 1)) $(size(instance.A, 2))")
    write(file, "\n")
    [write(file, "$(convert(Int64, -1.0*instance.c1[i])) ") for i in 1:size(instance.A, 2)]
    write(file, "\n")
    [write(file, "$(convert(Int64, -1.0*instance.c2[i])) ") for i in 1:size(instance.A, 2)]
    write(file, "\n")
    for i in 1:size(instance.A, 1)
        inds = findn(instance.A[i, :])
        write(file, "  $(length(inds))\n")
        [write(file, "  $j") for j in inds]
        write(file, "\n")
    end
    write(file, "\n\n")
    close(file)
end

@inbounds function mdls_bospp(instance::BOBPInstance)
    write_sppinstance_in_mdls_format(instance, "Instance_$(myid()).txt")
    try
        run(`mdls-bospp -i Instance_$(myid()).txt -o Output_$(myid())`)
    catch
    end
    rm("Instance_$(myid()).txt")
    files = readdir()
    files = files[[contains(files[i], "Output_$(myid())-") for i in 1:length(files)]]
    files = files[[contains(files[i], "solutions") for i in 1:length(files)]]
    non_dom_sols = BOPSolution[]
    for i in 1:length(files)
        non_dom_sols = vcat(non_dom_sols, read_non_dom_sols_mdls_bospp(files[i], length(instance.c1)))
    end
    files = readdir()
    files = files[[contains(files[i], "Output_$(myid())-") for i in 1:length(files)]]
    for i in 1:length(files)
        rm(files[i])
    end
    compute_objective_function_value!(non_dom_sols, instance)
    non_dom_sols = check_feasibility(non_dom_sols, instance)
    select_and_sort_non_dom_sols(non_dom_sols)
end
