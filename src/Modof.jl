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

module Modof

using JuMP, MathProgBase, GLPKMathProgInterface, Match

include("ModoModel.jl")
include("Types.jl")
include("Type_Conversion.jl")
include("Utilities.jl")
include("MDLS.jl")
include("NSGA_II.jl")

export MOOInstance, MOPInstance, MOMInstance, MOLPInstance, MOBPInstance, MOIPInstance, MOMBLPInstance, MOMILPInstance
export BOOInstance, BOPInstance, BOMInstance, BOLPInstance, BOBPInstance, BOIPInstance, BOMBLPInstance, BOMILPInstance
export MOOSolution, MOPSolution, BOOSolution, BOPSolution, BOMSolution
export OOESInstance, OOESSolution

export ModoModel, objective!, read_an_instance_from_a_jump_model, read_an_instance_from_a_lp_or_a_mps_file, read_a_boo_instance_from_a_mathprogbase_model, read_a_moo_instance_from_a_mathprogbase_model
export lprelaxation, convert_ip_into_bp, convert_bp_sol_into_ip_sol
export wrap_sols_into_array, compute_objective_function_value!, check_feasibility
export check_dominance, select_non_dom_sols, select_unique_sols, sort_non_dom_sols, select_and_sort_non_dom_sols, write_nondominated_frontier, write_nondominated_sols, normalize_frontier, compute_ideal_point, compute_closest_point_to_the_ideal_point, compute_nadir_point, compute_farthest_point_to_the_nadir_point
export mdls_kp, mdls_bospp, nsgaii

end
