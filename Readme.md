# Multiobjective Discrete Optimization Framework in Julia #

**Build Status:** 
[![Build Status](https://travis-ci.org/aritrasep/Modof.jl.svg?branch=master)](https://travis-ci.org/aritrasep/Modof.jl)

**Documentation:**
[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://aritrasep.github.io/Modof.jl/docs/build/)

**DOI:** 
[![DOI](https://zenodo.org/badge/84245385.svg)](https://zenodo.org/badge/latestdoi/84245385)

`Modof.jl` is a framework used for solving multiobjective mixed integer programs in Julia. It has functions for 
1. Selecting, sorting, writing and normalizing a nondominated frontier
2. Computing ideal and nadir points of a nondominated frontier
3. Computing the closest and the farthest point from the ideal and the nadir points respectively.
4. Computing the quality of a nondominated frontier: 
	1. Exact (for biobjective and triobjective) and approximate (for more than 4 objectives) hypervolumes
	2. Cardinality
	3. Maximum and average coverage
	4. Uniformity
5. Plotting nondominated frontiers of:
	1. Biobjective discrete and mixed problems
	2. Triobjective discrete problems
6. Wrappers for the following algorithms in linux:
	1. [MDLS](http://prolog.univie.ac.at/research/MDLS/mdls_code.tar.gz) for solving multidimensional knapsack and biobjective set packing problems
	2. [NSGA-II](http://www.iitk.ac.in/kangal/codes/nsga2/nsga2-gnuplot-v1.1.6.tar.gz) for solving biobjective binary programs
	
**Note:** Functionalities corresponding to computing quality of a nondominated frontier and plotting nondominated frontiers have been moved to [pyModofSup.jl](https://github.com/aritrasep/pyModofSup.jl)
	
## Dependencies: ##

1. [Julia v0.6.0](https://julialang.org/downloads/)

## Installation ##

Once, Julia v0.6.0 has been properly installed, the following instructions in a **Julia** terminal will install **Modof.jl** on the local machine:

```julia
Pkg.clone("https://github.com/aritrasep/Modof.jl")
Pkg.build("Modof")
```

In case `Pkg.build("Modof")` gives you an error on Linux, you may need to install the GMP library headers. For example, on Ubuntu/Debian and similar, give the following command from a terminal:

```
$ sudo apt-get install libgmp-dev
```

After that, restart the installation of the package with:

```
Pkg.build("Modof")
```

## Supporting and Citing: ##

The software in this ecosystem was developed as part of academic research. If you would like to help support it, please star the repository as such metrics may help us secure funding in the future. If you use [Modof.jl](https://github.com/aritrasep/Modof.jl), [Modolib.jl](https://github.com/aritrasep/Modolib.jl), [FPBH.jl](https://github.com/aritrasep/FPBH.jl), [FPBHCPLEX.jl](https://github.com/aritrasep/FPBHCPLEX.jl) or [pyModofSup.jl](https://github.com/aritrasep/pyModofSup.jl) software as part of your research, teaching, or other activities, we would be grateful if you could cite:

1. [Pal, A. and Charkhgard, H., A Feasibility Pump and Local Search Based Heuristic for Bi-objective Pure Integer Linear Programming](http://www.optimization-online.org/DB_FILE/2017/03/5902.pdf).
2. [Pal, A. and Charkhgard, H., FPBH.jl: A Feasibility Pump based Heuristic for Multi-objective Mixed Integer Linear Programming in Julia](http://www.optimization-online.org/DB_FILE/2017/09/6195.pdf)

## Contributions ##

This package is written and maintained by [Aritra Pal](https://github.com/aritrasep). Please fork and send a pull request or create a [GitHub issue](https://github.com/aritrasep/Modof.jl/issues) for bug reports or feature requests.
