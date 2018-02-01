var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#Multiobjective-Discrete-Optimization-Framework-in-Julia-1",
    "page": "Home",
    "title": "Multiobjective Discrete Optimization Framework in Julia",
    "category": "section",
    "text": "Modof.jl is a framework used for solving multiobjective mixed integer programs in Julia. It has functions for Selecting, sorting, writing and normalizing a nondominated frontier\nComputing ideal and nadir points of a nondominated frontier\nComputing the closest and the farthest point from the ideal and the nadir points respectively.\nComputing the quality of a nondominated frontier: exact (for biobjective and triobjective) and approximate (for more than 4 objectives) hypervolumes; cardinality; maximum and average coverage; uniformity\nPlotting nondominated frontiers of: 1) biobjective discrete and mixed problems and 2) triobjective discrete problems\nWrappers for the following algorithms in linux: 1) MDLS for solving multidimensional knapsack and biobjective set packing problems and 2) NSGA-II for solving biobjective binary programsNote: Functionalities corresponding to computing quality of a nondominated frontier and plotting nondominated frontiers have been moved to pyModofSup.jl"
},

{
    "location": "index.html#Dependencies:-1",
    "page": "Home",
    "title": "Dependencies:",
    "category": "section",
    "text": "Julia v0.6.0"
},

{
    "location": "index.html#Installation-1",
    "page": "Home",
    "title": "Installation",
    "category": "section",
    "text": "Once, Julia v0.6.0 has been properly installed, the following instructions in a Julia terminal will install Modof.jl on the local machine:Pkg.clone(\"https://github.com/aritrasep/Modof.jl\")\nPkg.build(\"Modof\")In case Pkg.build(\"Modof\") gives you an error on Linux, you may need to install the GMP library headers. For example, on Ubuntu/Debian and similar, give the following command from a terminal:$ sudo apt-get install libgmp-devAfter that, restart the installation of the package with:Pkg.build(\"Modof\")"
},

{
    "location": "index.html#Contents:-1",
    "page": "Home",
    "title": "Contents:",
    "category": "section",
    "text": "Pages = [\"types.md\", \"type_conversions.md\", \"functions.md\"]"
},

{
    "location": "index.html#Supporting-and-Citing:-1",
    "page": "Home",
    "title": "Supporting and Citing:",
    "category": "section",
    "text": "The software in this ecosystem was developed as part of academic research. If you would like to help support it, please star the repository as such metrics may help us secure funding in the future. If you use Modof.jl, Modolib.jl, FPBH.jl, FPBHCPLEX.jl or pyModofSup.jl software as part of your research, teaching, or other activities, we would be grateful if you could cite:Pal, A. and Charkhgard, H., A Feasibility Pump and Local Search Based Heuristic for Bi-objective Pure Integer Linear Programming.\nPal, A. and Charkhgard, H., FPBH.jl: A Feasibility Pump based Heuristic for Multi-objective Mixed Integer Linear Programming in Julia"
},

{
    "location": "index.html#Contributions-1",
    "page": "Home",
    "title": "Contributions",
    "category": "section",
    "text": "This package is written and maintained by Aritra Pal. Please fork and send a pull request or create a GitHub issue for bug reports or feature requests."
},

{
    "location": "index.html#Index:-1",
    "page": "Home",
    "title": "Index:",
    "category": "section",
    "text": ""
},

{
    "location": "types.html#",
    "page": "Types",
    "title": "Types",
    "category": "page",
    "text": ""
},

{
    "location": "types.html#Type-Definitions:-1",
    "page": "Types",
    "title": "Type Definitions:",
    "category": "section",
    "text": ""
},

{
    "location": "types.html#Modof.MOLPInstance",
    "page": "Types",
    "title": "Modof.MOLPInstance",
    "category": "Type",
    "text": "MOLPInstance\n\nDatatype to store a Multi Objective Linear Program\n\n\n\n"
},

{
    "location": "types.html#Modof.MOBPInstance",
    "page": "Types",
    "title": "Modof.MOBPInstance",
    "category": "Type",
    "text": "MOBPInstance\n\nDatatype to store a Multi Objective Binary Linear Program\n\n\n\n"
},

{
    "location": "types.html#Modof.MOIPInstance",
    "page": "Types",
    "title": "Modof.MOIPInstance",
    "category": "Type",
    "text": "MOIPInstance\n\nDatatype to store a Multi Objective Integer Linear Program\n\n\n\n"
},

{
    "location": "types.html#Modof.MOMBLPInstance",
    "page": "Types",
    "title": "Modof.MOMBLPInstance",
    "category": "Type",
    "text": "MOMBLPInstance\n\nDatatype to store a Multi Objective Mixed Binary Linear Program\n\n\n\n"
},

{
    "location": "types.html#Modof.MOMILPInstance",
    "page": "Types",
    "title": "Modof.MOMILPInstance",
    "category": "Type",
    "text": "MOMILPInstance\n\nDatatype to store a Multi Objective Mixed Integer Linear Program\n\n\n\n"
},

{
    "location": "types.html#Modof.BOLPInstance",
    "page": "Types",
    "title": "Modof.BOLPInstance",
    "category": "Type",
    "text": "BOLPInstance\n\nDatatype to store a Bi-Objective Linear Program\n\n\n\n"
},

{
    "location": "types.html#Modof.BOBPInstance",
    "page": "Types",
    "title": "Modof.BOBPInstance",
    "category": "Type",
    "text": "BOBPInstance\n\nDatatype to store a Bi-Objective Binary Linear Program\n\n\n\n"
},

{
    "location": "types.html#Modof.BOIPInstance",
    "page": "Types",
    "title": "Modof.BOIPInstance",
    "category": "Type",
    "text": "BOIPInstance\n\nDatatype to store a Bi-Objective Integer Linear Program\n\n\n\n"
},

{
    "location": "types.html#Modof.BOMBLPInstance",
    "page": "Types",
    "title": "Modof.BOMBLPInstance",
    "category": "Type",
    "text": "BOMBLPInstance\n\nDatatype to store a Bi-Objective Mixed Binary Linear Program\n\n\n\n"
},

{
    "location": "types.html#Modof.BOMILPInstance",
    "page": "Types",
    "title": "Modof.BOMILPInstance",
    "category": "Type",
    "text": "BOMILPInstance\n\nDatatype to store a Bi-Objective Mixed Integer Linear Program\n\n\n\n"
},

{
    "location": "types.html#Modof.OOESInstance",
    "page": "Types",
    "title": "Modof.OOESInstance",
    "category": "Type",
    "text": "OOESInstance\n\nDatatype to store an instance corresponding to minimizing a linear function over the efficient set\n\n\n\n"
},

{
    "location": "types.html#Storing-instances-of-different-classes-of-optimization-problems-1",
    "page": "Types",
    "title": "Storing instances of different classes of optimization problems",
    "category": "section",
    "text": "MOLPInstance\nMOBPInstance\nMOIPInstance\nMOMBLPInstance\nMOMILPInstance\nBOLPInstance\nBOBPInstance\nBOIPInstance\nBOMBLPInstance\nBOMILPInstance\nOOESInstance"
},

{
    "location": "types.html#Modof.MOPSolution",
    "page": "Types",
    "title": "Modof.MOPSolution",
    "category": "Type",
    "text": "MOPSolution\n\nDatatype to store a Multi Objective Optimization Solution\n\n\n\n"
},

{
    "location": "types.html#Modof.BOPSolution",
    "page": "Types",
    "title": "Modof.BOPSolution",
    "category": "Type",
    "text": "BOPSolution\n\nDatatype to store a Bi-Objective Optimization Solution\n\n\n\n"
},

{
    "location": "types.html#Modof.BOMSolution",
    "page": "Types",
    "title": "Modof.BOMSolution",
    "category": "Type",
    "text": "BOMSolution\n\nDatatype to store a Bi-Objective Mixed Optimization Solution\n\n\n\n"
},

{
    "location": "types.html#Modof.OOESSolution",
    "page": "Types",
    "title": "Modof.OOESSolution",
    "category": "Type",
    "text": "OOESSolution\n\nDatatype to store the solution of minimizing a linear function over the efficient set\n\n\n\n"
},

{
    "location": "types.html#Storing-solutions-of-different-classes-of-optimization-problems-1",
    "page": "Types",
    "title": "Storing solutions of different classes of optimization problems",
    "category": "section",
    "text": "MOPSolution\nBOPSolution\nBOMSolution\nOOESSolution"
},

{
    "location": "type_conversions.html#",
    "page": "Type Conversions",
    "title": "Type Conversions",
    "category": "page",
    "text": ""
},

{
    "location": "type_conversions.html#Type-Conversions:-1",
    "page": "Type Conversions",
    "title": "Type Conversions:",
    "category": "section",
    "text": ""
},

{
    "location": "type_conversions.html#Modof.lprelaxation",
    "page": "Type Conversions",
    "title": "Modof.lprelaxation",
    "category": "Function",
    "text": "lprelaxation(instance::BOBPInstance)\n\nLP relaxation of a BOBPInstance\n\n\n\nlprelaxation(instance::BOMBLPInstance)\n\nLP relaxation of a BOMBLPInstance\n\n\n\nlprelaxation(instance::MOBPInstance)\n\nLP relaxation of a MOBPInstance\n\n\n\nlprelaxation(instance::MOMBLPInstance)\n\nLP relaxation of a MOMBLPInstance\n\n\n\n"
},

{
    "location": "type_conversions.html#LP-relaxations-of-bi-objective-and-multi-objective-programs-1",
    "page": "Type Conversions",
    "title": "LP relaxations of bi-objective and multi-objective programs",
    "category": "section",
    "text": "lprelaxation"
},

{
    "location": "type_conversions.html#Modof.convert_ip_into_bp",
    "page": "Type Conversions",
    "title": "Modof.convert_ip_into_bp",
    "category": "Function",
    "text": "convert_ip_into_bp(instance::Union{BOIPInstance, BOMILPInstance}, ub::Float64=1.0e6)\n\nConvert a BOIPInstance or a BOMILPInstance into a BOBPInstance or a BOMBLPInstance respectively \n\n\n\nconvert_ip_into_bp(instance::Union{MOIPInstance, MOMILPInstance}, ub::Float64=1.0e6)\n\nConvert a MOIPInstance or a MOMILPInstance into a MOBPInstance or a MOMBLPInstance respectively \n\n\n\n"
},

{
    "location": "type_conversions.html#Converting-Integer-Variables-into-Binary-Variables-and-vice-versa-1",
    "page": "Type Conversions",
    "title": "Converting Integer Variables into Binary Variables and vice versa",
    "category": "section",
    "text": "convert_ip_into_bp"
},

{
    "location": "functions.html#",
    "page": "Functions",
    "title": "Functions",
    "category": "page",
    "text": ""
},

{
    "location": "functions.html#Functions:-1",
    "page": "Functions",
    "title": "Functions:",
    "category": "section",
    "text": ""
},

{
    "location": "functions.html#Modof.wrap_sols_into_array",
    "page": "Functions",
    "title": "Modof.wrap_sols_into_array",
    "category": "Function",
    "text": "wrap_sols_into_array(sols::Vector{MOPSolution})\n\nConvert a vector of MOPSolution into an Array{Float64,2}\n\n\n\nwrap_sols_into_array(sols::Vector{BOPSolution})\n\nConvert a vector of BOPSolution into an Array{Float64,2}\n\n\n\n"
},

{
    "location": "functions.html#Converting-a-Vector-of-MOPSolution-or-BOPSolution-into-an-array-1",
    "page": "Functions",
    "title": "Converting a Vector of MOPSolution or BOPSolution into an array",
    "category": "section",
    "text": "wrap_sols_into_array"
},

{
    "location": "functions.html#Modof.compute_objective_function_value!",
    "page": "Functions",
    "title": "Modof.compute_objective_function_value!",
    "category": "Function",
    "text": "compute_objective_function_value!{T<:MOOInstance, S<:MOOSolution}(solution::S, instance::T)\n\nCompute objective function values of a MOOSolution of a Multi Objective Optimization Instance\n\n\n\ncompute_objective_function_value!{T<:MOOInstance, S<:MOOSolution}(solutions::Vector{S}, instance::T)\n\nCompute objective function values of a vector{MOOSolution} of a Multi Objective Optimization Instance\n\n\n\ncompute_objective_function_value!{T<:BOOInstance, S<:BOOSolution}(solution::S, instance::T)\n\nCompute objective function values of a BOOSolution of a Bi Objective Optimization Instance\n\n\n\ncompute_objective_function_value!{T<:BOOInstance, S<:BOOSolution}(solutions::Vector{S}, instance::T)\n\nCompute objective function values of a vector{BOOSolution} of a Bi Objective Optimization Instance\n\n\n\n"
},

{
    "location": "functions.html#Computing-objective-function-values-1",
    "page": "Functions",
    "title": "Computing objective function values",
    "category": "section",
    "text": "compute_objective_function_value!"
},

{
    "location": "functions.html#Modof.check_feasibility",
    "page": "Functions",
    "title": "Modof.check_feasibility",
    "category": "Function",
    "text": "check_feasibility(solutions::Union{Vector{MOPSolution}, Vector{BOPSolution}}, instance::Union{MOBPInstance, MOIPInstance, MOMBLPInstance, MOMILPInstance, BOBPInstance, BOIPInstance, BOMBLPInstance, BOMILPInstance})\n\nCheck feasibility of a vector of biobjective or a vector of multiobjective optimization solutions and only returns the vector of feasible solutions\n\n\n\n"
},

{
    "location": "functions.html#Checking-feasibility-1",
    "page": "Functions",
    "title": "Checking feasibility",
    "category": "section",
    "text": "check_feasibility"
},

{
    "location": "functions.html#Modof.check_dominance",
    "page": "Functions",
    "title": "Modof.check_dominance",
    "category": "Function",
    "text": "check_dominance{T<:Number}(point1::Vector{T}, point2::Vector{T})\n\nChecks whether points point1 and point2 dominate one another. \n\n\n\n"
},

{
    "location": "functions.html#Modof.select_non_dom_sols",
    "page": "Functions",
    "title": "Modof.select_non_dom_sols",
    "category": "Function",
    "text": "select_non_dom_sols{T<:Number}(solutions::Array{T,2})\n\nSelect nondominated points for both Biobjective and Multiobjective Programs. \n\n\n\nselect_non_dom_sols(solutions::Vector{MOPSolution})\n\nSelect nondominated solutions among solutions for Multiobjective Programs. \n\n\n\nselect_non_dom_sols(solutions::Vector{BOPSolution})\n\nSelect nondominated solutions among solutions for Biobjective Programs. \n\n\n\n"
},

{
    "location": "functions.html#Modof.select_unique_sols",
    "page": "Functions",
    "title": "Modof.select_unique_sols",
    "category": "Function",
    "text": "select_unique_sols{T<:Number}(solutions::Array{T, 2})\n\nSelect unique nondominated points for both Biobjective and Multiobjective Programs. \n\n\n\nselect_unique_sols(solutions::Vector{MOPSolution})\n\nSelect unique nondominated solutions among solutions for Multiobjective Programs. \n\n\n\nselect_non_dom_sols(solutions::Vector{BOPSolution})\n\nSelect unique nondominated solutions among solutions for Biobjective Programs. \n\n\n\n"
},

{
    "location": "functions.html#Modof.sort_non_dom_sols",
    "page": "Functions",
    "title": "Modof.sort_non_dom_sols",
    "category": "Function",
    "text": "sort_non_dom_sols{T<:Number}(solutions::Array{T,2}, index::Int64=1)\n\nSort nondominated solutions for both Biobjective and Multiobjective Programs based on index objective. \n\n\n\nsort_non_dom_sols(solutions::Vector{MOPSolution}, index::Int64=1)\n\nSort nondominated solutions for Multiobjective Programs based on index objective. \n\n\n\nsort_non_dom_sols(solutions::Vector{BOPSolution}, index::Int64=1)\n\nSort nondominated solutions for Biobjective Programs based on index objective. \n\n\n\n"
},

{
    "location": "functions.html#Modof.select_and_sort_non_dom_sols",
    "page": "Functions",
    "title": "Modof.select_and_sort_non_dom_sols",
    "category": "Function",
    "text": "select_and_sort_non_dom_sols{T<:Number}(solutions::Array{T,2}, index::Int64=1)\n\nSelect and Sort nondominated solutions for both Biobjective and Multiobjective Programs. \n\n\n\nselect_and_sort_non_dom_sols(solutions::Vector{MOPSolution}, index::Int64=1)\n\nSelect and sort nondominated solutions for Multiobjective Programs based on index objective. \n\n\n\nselect_and_sort_non_dom_sols(solutions::Vector{BOPSolution}, index::Int64=1)\n\nSelect and Sort nondominated solutions for Biobjective Programs based on index objective. \n\n\n\n"
},

{
    "location": "functions.html#Modof.write_nondominated_frontier",
    "page": "Functions",
    "title": "Modof.write_nondominated_frontier",
    "category": "Function",
    "text": "write_nondominated_frontier(non_dom_sols::Union{Vector{MOPSolution}, Vector{BOPSolution}}, filename::String)\n\nWrite nondominated frontier of a Vector{BOPSolution} or a Vector{MOPSolution} and save it to filename.\n\n\n\n"
},

{
    "location": "functions.html#Modof.write_nondominated_sols",
    "page": "Functions",
    "title": "Modof.write_nondominated_sols",
    "category": "Function",
    "text": "write_nondominated_sols(non_dom_sols::Union{Vector{MOPSolution}, Vector{BOPSolution}}, filename::String)\n\nWrite nondominated solutions of a Vector{BOPSolution} or a Vector{MOPSolution} and save it to filename.\n\n\n\n"
},

{
    "location": "functions.html#Selecting,-sorting,-writing-and-normalizing-a-nondominated-frontier-1",
    "page": "Functions",
    "title": "Selecting, sorting, writing and normalizing a nondominated frontier",
    "category": "section",
    "text": "check_dominance\nselect_non_dom_sols\nselect_unique_sols\nsort_non_dom_sols\nselect_and_sort_non_dom_sols\nwrite_nondominated_frontier\nwrite_nondominated_sols"
},

{
    "location": "functions.html#Modof.compute_ideal_point",
    "page": "Functions",
    "title": "Modof.compute_ideal_point",
    "category": "Function",
    "text": "compute_ideal_point{T<:Number}(non_dom_sols::Array{T, 2})\n\nReturns the Ideal Point of the nondominated frontier non_dom_sols.\n\n\n\ncompute_ideal_point(non_dom_sols::Union{Vector{MOPSolution}, Vector{BOPSolution}})\n\nReturns the Ideal Point of the nondominated frontier non_dom_sols.\n\n\n\n"
},

{
    "location": "functions.html#Modof.compute_nadir_point",
    "page": "Functions",
    "title": "Modof.compute_nadir_point",
    "category": "Function",
    "text": "compute_nadir_point{T<:Number}(non_dom_sols::Array{T, 2})\n\nReturns the Nadir Point of the nondominated frontier non_dom_sols.\n\n\n\ncompute_nadir_point(non_dom_sols::Union{Vector{MOPSolution}, Vector{BOPSolution}})\n\nReturns the Nadir Point of the nondominated frontier non_dom_sols.\n\n\n\n"
},

{
    "location": "functions.html#Computing-ideal-and-nadir-points-of-a-nondominated-frontier-1",
    "page": "Functions",
    "title": "Computing ideal and nadir points of a nondominated frontier",
    "category": "section",
    "text": "compute_ideal_point\ncompute_nadir_point"
},

{
    "location": "functions.html#Modof.compute_closest_point_to_the_ideal_point",
    "page": "Functions",
    "title": "Modof.compute_closest_point_to_the_ideal_point",
    "category": "Function",
    "text": "compute_closest_point_to_the_ideal_point{T<:Number}(non_dom_sols::Array{T, 2}, ideal_point::Vector{T}, return_pos::Bool=false)\n\nReturns the closest point in the nondominated frontier non_dom_sols from its Ideal Point ideal_point.\n\n\n\ncompute_closest_point_to_the_ideal_point{T<:Number}(non_dom_sols::Union{Vector{MOPSolution}, Vector{BOPSolution}}, ideal_point::Vector{T})\n\nReturns the closest point in the nondominated frontier non_dom_sols from its Ideal Point ideal_point.\n\n\n\ncompute_closest_point_to_the_ideal_point{T<:Number}(non_dom_sols::Array{T, 2})\n\nReturns the closest point in the nondominated frontier non_dom_sols from its Ideal Point.\n\n\n\ncompute_closest_point_to_the_ideal_point(non_dom_sols::Union{Vector{MOPSolution}, Vector{BOPSolution}})\n\nReturns the closest point in the nondominated frontier non_dom_sols from its Ideal Point.\n\n\n\n"
},

{
    "location": "functions.html#Modof.compute_farthest_point_to_the_nadir_point",
    "page": "Functions",
    "title": "Modof.compute_farthest_point_to_the_nadir_point",
    "category": "Function",
    "text": "compute_farthest_point_to_the_nadir_point{T<:Number}(non_dom_sols::Array{T, 2}, nadir_point::Vector{T}, return_pos::Bool=false)\n\nReturns the farthest point in the nondominated frontier non_dom_sols from its Nadir Point nadir_point.\n\n\n\ncompute_farthest_point_to_the_nadir_point{T<:Number}(non_dom_sols::Union{Vector{MOPSolution}, Vector{BOPSolution}}, nadir_point::Vector{T})\n\nReturns the farthest point in the nondominated frontier non_dom_sols from its Nadir Point nadir_point.\n\n\n\ncompute_farthest_point_to_the_nadir_point{T<:Number}(non_dom_sols::Array{T, 2})\n\nReturns the farthest point in the nondominated frontier non_dom_sols from its Nadir Point.\n\n\n\ncompute_farthest_point_to_the_nadir_point(non_dom_sols::Union{Vector{MOPSolution}, Vector{BOPSolution}})\n\nReturns the farthest point in the nondominated frontier non_dom_sols from its Nadir Point.\n\n\n\n"
},

{
    "location": "functions.html#Selecting-points-in-a-nondominated-frontier-1",
    "page": "Functions",
    "title": "Selecting points in a nondominated frontier",
    "category": "section",
    "text": "compute_closest_point_to_the_ideal_point\ncompute_farthest_point_to_the_nadir_point"
},

]}
