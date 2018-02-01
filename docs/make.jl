using Documenter, Modof

makedocs(modules=[Modof],
         doctest = false,
         format = :html,
         sitename = "Modof",
         authors = "Aritra Pal",
         pages = Any[
        	"Home" => "index.md",
        	"Types" => "types.md",
        	"Type Conversions" => "type_conversions.md",
        	"Functions" => "functions.md"
    	])

deploydocs(
	repo = "github.com/aritrasep/Modof.jl.git",
    target = "build",
    osname = "linux",
    julia  = "0.6",
    deps   = nothing,
    make   = nothing,
)
