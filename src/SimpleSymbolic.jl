module SimpleSymbolic

export S

"""
    S(x::Symbol)
    S(x::Expr)
    S(x::Number)

Create a symbolic wrapper `S <: Number` for the object `x`.
"""
struct S <: Number
    x
end

Base.show(io::IO, s::S) = print(io, "S($(s.x))")

# Promotion & conversion wraps types in `S`
Base.convert(::Type{S}, x::S) = x
Base.convert(::Type{S}, x) = S(x)
Base.promote_rule(::Type{S}, ::Type{<:Any}) = S

# Additive & multiplicative identity
struct Zero ; end
struct One  ; end

Base.zero(::Type{S}) = S(Zero())
Base.one(::Type{S}) = S(One())
Base.zero(::S) = zero(S)
Base.one(::S) = one(S)

# Arithmetic on `S` is implemented by unwrapping and rewrapping so that we can
# use the standard promotion machinery but also do some basic simplifications
# on the fly.
_funcname(f) = typeof(f).name.mt.name # See Base show(::IO, ::Function)
_op(f, es...) = Expr(:call, _funcname(f), es...)

unwrap() = ()
unwrap(s::S, ss::S...) = (s.x, unwrap(ss...)...)

Base.:+(s1::S, ss::S...) = S(_op(+, unwrap(s1, ss...)...))
Base.:*(s1::S, ss::S...) = S(_op(*, unwrap(s1, ss...)...))
Base.:-(s1::S, ss::S...) = S(_op(-, unwrap(s1, ss...)...))
Base.:/(s1::S, ss::S...) = S(_op(/, unwrap(s1, ss...)...))

for func in [:sqrt, :exp, :log, :sin, :cos, :conj]
    @eval Base.$func(s::S) = S(_op($func, s.x))
end

# Basic simplification
# Simplification for numbers
_op(f, xs::Number...) = f(xs...)

# Simplification for standard left-fold reductions
iscall(x::Expr, name) = x.head == :call && x.args[1] == name

_op(f::typeof(+), x::Zero, x2) = x2
_op(f::typeof(+), x::Zero, xs...) = _op(f, xs...)

_op(f::typeof(*), x::Zero, xs...) = Zero()
_op(f::typeof(*), x::One, x2) = x2
_op(f::typeof(*), x::One, xs...) = _op(f, xs...)

_op(f::typeof(conj), x::Expr) = iscall(x, :conj) ? x.args[2] : Expr(:call, _funcname(f), x)

end # module

