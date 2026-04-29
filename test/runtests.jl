using Modof
using Test
using JuMP

@testset "Modof smoke tests" begin
    instance = BOBPInstance(false)
    instance.c1 = [1.0, 2.0]
    instance.c2 = [2.0, 1.0]
    instance.A = [1.0 1.0]
    instance.cons_lb = [-Inf]
    instance.cons_ub = [1.0]

    solution = BOPSolution(vars=[1.0, 0.0])
    compute_objective_function_value!(solution, instance)

    @test solution.obj_val1 == 1.0
    @test solution.obj_val2 == 2.0
    @test check_feasibility(solution, instance)
    @test select_and_sort_non_dom_sols([1.0 2.0; 2.0 1.0; 3.0 3.0]) == [1.0 2.0; 2.0 1.0]
end

@testset "JuMP bridge" begin
    model = ModoModel()
    @variable(model, x[1:2], Bin)
    @constraint(model, 2x[1] + x[2] <= 2)

    objective!(model, 1, :Max, x[1] + 3x[2])
    objective!(model, 2, :Min, 4x[1] + x[2])

    instance, sense = read_an_instance_from_a_jump_model(model)

    @test sense == [:Max, :Min]
    @test instance isa BOBPInstance
    @test instance.c1 == [-1.0, -3.0]
    @test instance.c2 == [4.0, 1.0]
    @test Matrix(instance.A) == [-2.0 -1.0]
    @test instance.cons_lb == [-2.0]
    @test instance.cons_ub == [Inf]

    @test !any(name -> occursin("math" * "progbase", lowercase(String(name))), names(Modof; all=true))
end

@testset "LP file bridge" begin
    model = ModoModel()
    @variable(model, 0 <= x <= 1)
    @variable(model, 0 <= y <= 1)
    @constraint(model, x + y <= 1)
    objective!(model, 1, :Min, x + 2y)

    filename = tempname() * ".lp"
    try
        JuMP.write_to_file(model, filename)
        instance, sense = read_an_instance_from_a_lp_or_a_mps_file(filename)
        @test sense == [:Min]
        @test instance isa MOLPInstance
        @test instance.c == [1.0 2.0]
    finally
        isfile(filename) && rm(filename)
    end

    filename = tempname() * ".lp"
    try
        write(filename, """
        Minimize
         obj: x + 2 y
        Subject To
         cap: x + y <= 1
         obj_2: 3 x + y = 0
        Binaries
         x y
        End
        """)
        instance, sense = read_an_instance_from_a_lp_or_a_mps_file(filename, [:Min])
        @test sense == [:Min, :Min]
        @test instance isa BOBPInstance
        @test instance.c1 == [1.0, 2.0]
        @test instance.c2 == [3.0, 1.0]
        @test any(i -> Matrix(instance.A)[i, :] == [-1.0, -1.0], axes(instance.A, 1))
    finally
        isfile(filename) && rm(filename)
    end
end
