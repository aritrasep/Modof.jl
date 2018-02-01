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

import Base.copy

#####################################################################
# Data Types for Storing MOO Instances                              #
#####################################################################

abstract type MOO end

abstract type MOOInstance <: MOO end

abstract type MOPInstance <: MOOInstance end

abstract type MOMInstance <: MOOInstance end

"""
    MOIPInstance
    
 Datatype to store a Multi Objective Integer Linear Program
"""
mutable struct MOIPInstance <: MOPInstance 
    v_lb::Vector{Float64}
    v_ub::Vector{Float64}
    c::Array{Float64, 2}
    A::Union{Array{Float64, 2},SparseMatrixCSC{Float64,Int64}}
    cons_lb::Vector{Float64}
    cons_ub::Vector{Float64}
end

function MOIPInstance(sparse::Bool=true)
    if sparse
        return MOIPInstance(Float64[], Float64[], Array{Float64}(1, 1), spzeros(1,1), Float64[], Float64[])
    else
        return MOIPInstance(Float64[], Float64[], Array{Float64}(1, 1), Array{Float64}(1, 1), Float64[], Float64[])
    end
end

function copy(instance::MOIPInstance)
    MOIPInstance(instance.v_lb, instance.v_ub, instance.c, instance.A, instance.cons_lb, instance.cons_ub)
end

"""
    MOBPInstance
    
 Datatype to store a Multi Objective Binary Linear Program
"""
mutable struct MOBPInstance <: MOPInstance
    c::Array{Float64, 2}
    A::Union{Array{Float64, 2},SparseMatrixCSC{Float64,Int64}}
    cons_lb::Vector{Float64}
    cons_ub::Vector{Float64}
end

function MOBPInstance(sparse::Bool=true)
    if sparse
        return MOBPInstance(Array{Float64}(1, 1), spzeros(1,1), Float64[], Float64[])
    else
        return MOBPInstance(Array{Float64}(1, 1), Array{Float64}(1, 1), Float64[], Float64[])
    end
end

function copy(instance::MOBPInstance)
    MOBPInstance(instance.c, instance.A, instance.cons_lb, instance.cons_ub)
end

"""
    MOLPInstance
    
 Datatype to store a Multi Objective Linear Program
"""
mutable struct MOLPInstance <: MOPInstance
    v_lb::Vector{Float64}
    v_ub::Vector{Float64}
    c::Array{Float64, 2}
    A::Union{Array{Float64, 2},SparseMatrixCSC{Float64,Int64}}
    cons_lb::Vector{Float64}
    cons_ub::Vector{Float64}
    ϵ::Float64
end

function MOLPInstance(sparse::Bool=true)
    if sparse
        return MOLPInstance(Float64[], Float64[], Array{Float64}(1, 1), spzeros(1,1), Float64[], Float64[], 1.0e-9)
    else
        return MOLPInstance(Float64[], Float64[], Array{Float64}(1, 1), Array{Float64}(1, 1), Float64[], Float64[], 1.0e-9)
    end
end

function copy(instance::MOLPInstance)
    MOLPInstance(instance.v_lb, instance.v_ub, instance.c, instance.A, instance.cons_lb, instance.cons_ub, instance.ϵ)
end

"""
    MOMILPInstance
    
 Datatype to store a Multi Objective Mixed Integer Linear Program
"""
mutable struct MOMILPInstance <: MOMInstance 
    var_types::Vector{Symbol}
    v_lb::Vector{Float64}
    v_ub::Vector{Float64}
    c::Array{Float64, 2}
    A::Union{Array{Float64, 2},SparseMatrixCSC{Float64,Int64}}
    cons_lb::Vector{Float64}
    cons_ub::Vector{Float64}
    ϵ::Float64
end

function MOMILPInstance(sparse::Bool=true)
    if sparse
        return MOMILPInstance(Symbol[], Float64[], Float64[], Array{Float64}(1, 1), spzeros(1,1), Float64[], Float64[], 1.0e-9)
    else
        return MOMILPInstance(Symbol[], Float64[], Float64[], Array{Float64}(1, 1), Array{Float64}(1, 1), Float64[], Float64[], 1.0e-9)
    end
end

function copy(instance::MOMILPInstance)
    MOMILPInstance(instance.var_types, instance.v_lb, instance.v_ub, instance.c, instance.A, instance.cons_lb, instance.cons_ub, instance.ϵ)
end

"""
    MOMBLPInstance
    
 Datatype to store a Multi Objective Mixed Binary Linear Program
"""
mutable struct MOMBLPInstance <: MOMInstance
    var_types::Vector{Symbol}
    v_lb::Vector{Float64}
    v_ub::Vector{Float64}
    c::Array{Float64, 2}
    A::Union{Array{Float64, 2},SparseMatrixCSC{Float64,Int64}}
    cons_lb::Vector{Float64}
    cons_ub::Vector{Float64}
    ϵ::Float64
end

function MOMBLPInstance(sparse::Bool=true)
    if sparse
        return MOMBLPInstance(Symbol[], Float64[], Float64[], Array{Float64}(1, 1), spzeros(1,1), Float64[], Float64[], 1.0e-9)
    else
        return MOMBLPInstance(Symbol[], Float64[], Float64[], Array{Float64}(1, 1), Array{Float64}(1, 1), Float64[], Float64[], 1.0e-9)
    end
end

function copy(instance::MOMBLPInstance)
    MOMBLPInstance(instance.var_types, instance.v_lb, instance.v_ub, instance.c, instance.A, instance.cons_lb, instance.cons_ub, instance.ϵ)
end

abstract type BOO <: MOO end

abstract type BOOInstance <: BOO end

abstract type BOPInstance <: BOOInstance end

abstract type BOMInstance <: BOOInstance end

"""
    BOIPInstance
    
 Datatype to store a Bi-Objective Integer Linear Program
"""
mutable struct BOIPInstance <: BOPInstance
    v_lb::Vector{Float64}
    v_ub::Vector{Float64}
    c1::Vector{Float64}
    c2::Vector{Float64}
    A::Union{Array{Float64, 2},SparseMatrixCSC{Float64,Int64}}
    cons_lb::Vector{Float64}
    cons_ub::Vector{Float64}
end

function BOIPInstance(sparse::Bool=true)
    if sparse
        return BOIPInstance(Float64[], Float64[], Float64[], Float64[], spzeros(1,1), Float64[], Float64[])
    else
        return BOIPInstance(Float64[], Float64[], Float64[], Float64[], Array{Float64}(1, 1), Float64[], Float64[])
    end
end

function copy(instance::BOIPInstance)
    BOIPInstance(instance.v_lb, instance.v_ub, instance.c1, instance.c2, instance.A, instance.cons_lb, instance.cons_ub)
end

"""
    BOBPInstance
    
 Datatype to store a Bi-Objective Binary Linear Program
"""
mutable struct BOBPInstance <: BOPInstance
    c1::Vector{Float64}
    c2::Vector{Float64}
    A::Union{Array{Float64, 2},SparseMatrixCSC{Float64,Int64}}
    cons_lb::Vector{Float64}
    cons_ub::Vector{Float64}
end

function BOBPInstance(sparse::Bool=true)
    if sparse
        return BOBPInstance(Float64[], Float64[], spzeros(1,1), Float64[], Float64[])
    else
        return BOBPInstance(Float64[], Float64[], Array{Float64}(1, 1), Float64[], Float64[])
    end
end

function copy(instance::BOBPInstance)
    BOBPInstance(instance.c1, instance.c2, instance.A, instance.cons_lb, instance.cons_ub)
end

"""
    BOLPInstance
    
 Datatype to store a Bi-Objective Linear Program
"""
mutable struct BOLPInstance <: BOPInstance
    v_lb::Vector{Float64}
    v_ub::Vector{Float64}
    c1::Vector{Float64}
    c2::Vector{Float64}
    A::Union{Array{Float64, 2},SparseMatrixCSC{Float64,Int64}}
    cons_lb::Vector{Float64}
    cons_ub::Vector{Float64}
    ϵ::Float64
end

function BOLPInstance(sparse::Bool=true)
    if sparse
        return BOLPInstance(Float64[], Float64[], Float64[], Float64[], spzeros(1,1), Float64[], Float64[], 1.0e-9)
    else
        return BOLPInstance(Float64[], Float64[], Float64[], Float64[], Array{Float64}(1, 1), Float64[], Float64[], 1.0e-9)
    end
end

function copy(instance::BOLPInstance)
    BOLPInstance(instance.v_lb, instance.v_ub, instance.c1, instance.c2, instance.A, instance.cons_lb, instance.cons_ub, instance.ϵ)
end

"""
    BOMILPInstance
    
 Datatype to store a Bi-Objective Mixed Integer Linear Program
"""
mutable struct BOMILPInstance <: BOMInstance 
    var_types::Vector{Symbol}
    v_lb::Vector{Float64}
    v_ub::Vector{Float64}
    c1::Vector{Float64}
    c2::Vector{Float64}
    A::Union{Array{Float64, 2},SparseMatrixCSC{Float64,Int64}}
    cons_lb::Vector{Float64}
    cons_ub::Vector{Float64}
    ϵ::Float64
end

function BOMILPInstance(sparse::Bool=true)
    if sparse
        return BOMILPInstance(Symbol[], Float64[], Float64[], Float64[], Float64[], spzeros(1,1), Float64[], Float64[], 1.0e-9)
    else
        return BOMILPInstance(Symbol[], Float64[], Float64[], Float64[], Float64[], Array{Float64}(1, 1), Float64[], Float64[], 1.0e-9)
    end
end

function copy(instance::BOMILPInstance)
    BOMILPInstance(instance.var_types, instance.v_lb, instance.v_ub, instance.c1, instance.c2, instance.A, instance.cons_lb, instance.cons_ub, instance.ϵ)
end

"""
    BOMBLPInstance
    
 Datatype to store a Bi-Objective Mixed Binary Linear Program
"""
mutable struct BOMBLPInstance <: BOMInstance 
    var_types::Vector{Symbol}
    v_lb::Vector{Float64}
    v_ub::Vector{Float64}
    c1::Vector{Float64}
    c2::Vector{Float64}
    A::Union{Array{Float64, 2},SparseMatrixCSC{Float64,Int64}}
    cons_lb::Vector{Float64}
    cons_ub::Vector{Float64}
    ϵ::Float64
end

function BOMBLPInstance(sparse::Bool=true)
    if sparse
        return BOMBLPInstance(Symbol[], Float64[], Float64[], Float64[], Float64[], spzeros(1,1), Float64[], Float64[], 1.0e-9)
    else
        return BOMBLPInstance(Symbol[], Float64[], Float64[], Float64[], Float64[], Array{Float64}(1, 1), Float64[], Float64[], 1.0e-9)
    end
end

function copy(instance::BOMBLPInstance)
    BOMBLPInstance(instance.var_types, instance.v_lb, instance.v_ub, instance.c1, instance.c2, instance.A, instance.cons_lb, instance.cons_ub, instance.ϵ)
end

#####################################################################
# Data Types for Storing MOO and BOO Solutions                      #
#####################################################################

abstract type Solution end

abstract type MOOSolution <: Solution end

"""
    MOPSolution

 Datatype to store a Multi Objective Optimization Solution
"""
mutable struct MOPSolution <: MOOSolution
    vars::Vector{Float64}
    obj_vals::Vector{Float64}
end

function MOPSolution(;vars::Vector{Float64}=Float64[], obj_vals::Vector{Float64}=Float64[])
    MOPSolution(vars, obj_vals)
end

abstract type BOOSolution <: Solution end

"""
    BOPSolution

 Datatype to store a Bi-Objective Optimization Solution
"""
mutable struct BOPSolution <: BOOSolution
    vars::Vector{Float64}
    obj_val1::Float64
    obj_val2::Float64
end

function BOPSolution(;vars::Vector{Float64}=Float64[], obj_val1::Float64=0.0, obj_val2::Float64=0.0)
    BOPSolution(vars, obj_val1, obj_val2)
end

"""
    BOMSolution
    
 Datatype to store a Bi-Objective Mixed Optimization Solution
"""
mutable struct BOMSolution <: BOOSolution
    vars::Vector{Float64}
    obj_val1::Float64
    obj_val2::Float64
    connection::Bool
end

function BOMSolution(;vars::Vector{Float64}=Float64[], obj_val1::Float64=0.0, obj_val2::Float64=0.0, connection::Bool=false)
    BOMSolution(vars, obj_val1, obj_val2, connection)
end

#####################################################################
# Data Types for Storing OOES Instances                             #
#####################################################################

abstract type OOES <: MOO end

"""
    OOESInstance

 Datatype to store an instance corresponding to minimizing a linear function over the efficient set
"""
mutable struct OOESInstance <: OOES
    fx::Vector{Float64}
    instance::Union{MOBPInstance, MOMBLPInstance, BOBPInstance, BOMBLPInstance}
end

function OOESInstance(type_of_instance::Type=BOBPInstance)
    OOESInstance(Float64[], type_of_instance())
end

function copy(instance::OOESInstance)
    OOESInstance(instance.fx, instance.instance)
end

"""
    OOESSolution
    
 Datatype to store the solution of minimizing a linear function over the efficient set
"""
mutable struct OOESSolution <: OOES
    min_fx::Float64
    non_dom_sols::Union{MOPSolution, BOPSolution}
end
