# Functions: #

## Converting a `Vector` of `MOPSolution` or `BOPSolution` into an array ##

```@docs
wrap_sols_into_array
```

## Computing objective function values ##

```@docs
compute_objective_function_value!
```

## Checking feasibility ##

```@docs
check_feasibility
```

## Selecting, sorting, writing and normalizing a nondominated frontier ##

```@docs
check_dominance
select_non_dom_sols
select_unique_sols
sort_non_dom_sols
select_and_sort_non_dom_sols
write_nondominated_frontier
write_nondominated_sols
```

## Computing ideal and nadir points of a nondominated frontier ##

```@docs
compute_ideal_point
compute_nadir_point
```

## Selecting points in a nondominated frontier ##

```@docs
compute_closest_point_to_the_ideal_point
compute_farthest_point_to_the_nadir_point
```
