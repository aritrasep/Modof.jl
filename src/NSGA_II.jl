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
# NSGA - II                                                         #
#####################################################################

#####################################################################
## Biobjective Binary Instances                                    ##
#####################################################################

@inbounds function write_instance_for_nsgaii(instance::BOBPInstance, p::Int64, g::Int64)
    f = open("run_nsga_ii.sh", "w")
    write(f, "nsga2r 0.5 <Parameter.in & pid=\$!\n")
    write(f, "for ((i=1; i<= \$1; i++))\n")
    write(f, "do\n")
    write(f, "if [ -e /proc/\$pid ]\n")
    write(f, "then\n")
    write(f, "sleep 0.001\n")
    write(f, "else\n")
    write(f, "break\n")
    write(f, "fi\n")
    write(f, "done\n")
    write(f, "if [ -e /proc/\$pid ]\n")
    write(f, "then\n")
    write(f, "kill -9 \$pid\n")
    write(f, "fi\n")
    close(f)

    f = open(".problemdef.c", "w")
    write(f, "# include <stdio.h>\n")
    write(f, "# include <stdlib.h>\n")
    write(f, "# include <math.h>\n")
    write(f, "# include <global.h>\n")
    write(f, "# include <rand.h>\n")
    write(f, "void test_problem(double *xreal, double *xbin, int **gene, double *obj, double *constr) {\n")
    for i in 1:2
        if i == 1
            ind, tmp = findn(instance.c1), copy(instance.c1)
        else
            ind, tmp = findn(instance.c2), copy(instance.c2)
        end
        write(f, "obj[$(i-1)] = ")
        for j in ind
            if tmp[j] > 0
                write(f, "+ $(tmp[j])*xbin[$(j-1)] ")
            else
                write(f, "- $(abs(tmp[j]))*xbin[$(j-1)] ")
            end
        end
        write(f, ";\n")
    end
    count = 0
    for i in 1:size(instance.A)[1]
        if instance.cons_lb[i] == instance.cons_ub[i]
            tmp, tmp2 = vec(instance.A[i, :]), instance.cons_lb[i]
            ind = findn(tmp)
            for j in 1:2
                write(f, "constr[$count] = ")
                for k in ind
                    if tmp[k] > 0
                        write(f, "+ $(tmp[k])*xbin[$(k-1)] ")
                    else
                        write(f, "- $(abs(tmp[k]))*xbin[$(k-1)] ")
                    end
                end
                if tmp2 > 0
                    write(f, "- $(tmp2)")
                else
                    write(f, "+ $(abs(tmp2))")
                end
                write(f, ";\n")
                count += 1
                tmp = -1tmp
                tmp2 = -1tmp2
            end
        else
            if instance.cons_lb == -Inf
                tmp, tmp2 = -1*vec(instance.A[i, :]), -1*instance.cons_ub[i]
            else
                tmp, tmp2 = vec(instance.A[i, :]), instance.cons_lb[i]
            end
            write(f, "constr[$count] = ")
            ind = findn(tmp)
            for j in ind
                if tmp[j] > 0
                    write(f, "+ $(tmp[j])*xbin[$(j-1)] ")
                else
                    write(f, "- $(abs(tmp[j]))*xbin[$(j-1)] ")
                end
            end
            if tmp2 > 0
                write(f, "- $(tmp2)")
            else
                write(f, "+ $(abs(tmp2))")
            end
            write(f, ";\n")
            count += 1
        end
    end
    write(f, "return;\n")
    write(f, "}")
    close(f)

    f = open("Parameter.in", "w")
    write(f, "$(p)\n")
    write(f, "$(g)\n")
    write(f, "2\n")
    write(f, "$(size(instance.A)[1])\n")
    write(f, "0\n")
    write(f, "$(size(instance.A)[2])\n")
    for i in 1:size(instance.A)[2]
        write(f, "1 0 1\n")
    end
    write(f, "0.9\n1\n0\n")
    close(f)
end

@inbounds function read_non_dom_sols_nsgaii(instance::BOBPInstance)
    lines_in_file = readlines("best_pop.out")
    m, n = size(instance.A)
    non_dom_sols = BOPSolution[]
    if length(lines_in_file) >= 3
        for i in 3:length(lines_in_file)
            coeffs = Float64[]
            tmp = split(lines_in_file[i])
            for j in 2+m+1:2+m+n
                push!(coeffs, float(tmp[j]))
            end
            tmp2 = BOPSolution(vars=coeffs)
            compute_objective_function_value!(tmp2, instance)
            push!(non_dom_sols, tmp2)
        end
        non_dom_sols = check_feasibility(non_dom_sols, instance)
    end
    for files in ["best_pop.out", "all_pop.out", "final_pop.out", "initial_pop.out", "params.out"]
        try
            rm(files)
        catch
        end
    end
    select_non_dom_sols(non_dom_sols)
end

@inbounds function nsgaii(instance::BOBPInstance, p::Int64, g::Int64, timelimit::Float64)
    for files in ["best_pop.out", "all_pop.out", "final_pop.out", "initial_pop.out", "params.out"]
        try
            rm(files)
        catch
        end
    end 
    write_instance_for_nsgaii(instance, p, g)
    try
        run(`bash run_nsga_ii.sh $(round(Int64, timelimit/0.001))`)
    catch
    end
    read_non_dom_sols_nsgaii(instance)
end

@inbounds function nsgaii(instance::BOBPInstance, true_non_dom_sols::Array{Float64, 2}, timelimit::Float64)
    non_dom_sols = BOPSolution[]
    for alpha in [2, 4], beta in [2, 4]
        println("Started solving with alpha = $alpha and beta = $beta")
        p = alpha * size(true_non_dom_sols)[1]
        p -= p%4
        p += 4
        g = beta * size(true_non_dom_sols)[1]
        tmp = nsgaii(instance, p, g, timelimit/4)
        println("Finished")
        println("Number of Feasible Solutions Found = $(length(tmp))")
        if length(tmp) >= 1
            non_dom_sols = select_non_dom_sols([non_dom_sols..., tmp...])
        end
    end
    non_dom_sols
end
