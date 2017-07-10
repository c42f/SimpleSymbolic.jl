# SimpleSymbolic

A tiny package for symbolic manipulation of julia expressions, aimed at code
generation tasks.  Example:

```julia
julia> using SimpleSymbolic

julia> m = [S(:(m[$i,$j])) for i=1:3, j=1:3]
3×3 Array{SimpleSymbolic.S,2}:
 S(m[1, 1])  S(m[1, 2])  S(m[1, 3])
 S(m[2, 1])  S(m[2, 2])  S(m[2, 3])
 S(m[3, 1])  S(m[3, 2])  S(m[3, 3])

julia> v = [S(:(v[$i])) for i=1:3]
3-element Array{SimpleSymbolic.S,1}:
 S(v[1])
 S(v[2])
 S(v[3])

julia> m*v
3-element Array{SimpleSymbolic.S,1}:
 S((m[1, 1] * v[1] + m[1, 2] * v[2]) + m[1, 3] * v[3])
 S((m[2, 1] * v[1] + m[2, 2] * v[2]) + m[2, 3] * v[3])
 S((m[3, 1] * v[1] + m[3, 2] * v[2]) + m[3, 3] * v[3])

julia> LowerTriangular(m)*v
3-element Array{SimpleSymbolic.S,1}:
                                     S(m[1, 1] * v[1])
                    S(m[2, 2] * v[2] + m[2, 1] * v[1])
 S((m[3, 3] * v[3] + m[3, 1] * v[1]) + m[3, 2] * v[2])
```
