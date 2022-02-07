module BudanTables

using DocStringExtensions:SIGNATURES
using Requires

using RecipesBase
using Polynomials # Polynomial type, roots function
# using Plots

export BudanTable, budantable, set_getting_roots

const _ROOTS = Ref{Function}(Polynomials.roots)

"""
$(SIGNATURES)

Sets the function used to compute the roots of polynomials building a Budan's table.
The input is a function `f` computing the roots of a polynomial represented as an object of type `T`, for which `degree(p::T)` and `derivative(p::T)` must be defined.
By default it uses `roots` from [Polynomials.jl](https://github.com/JuliaMath/Polynomials.jl).

See also [`budantable`](@ref)

# Examples

## For polynomials of type `Polynomial`:

```julia
   using Polynomials
   pp = Polynomial([-1,2,3])
   import PolynomialRoots as PR # Fast roots
   # Notice pre-composition with Polynomials' `coeffs`.
   BudanTables.set_getting_roots(PR.roots∘coeffs)
   budantable(pp)
```
"""
function set_getting_roots(f)
    _ROOTS[] = f
end

function __init__()
        @require PolynomialRoots="3a141323-8675-5d76-9d11-e1df1406c778" begin
            # Use Polynomials api for poly arith. and PR's roots for roots
            _BigFloat(A::AbstractArray) = BigFloat.(A)
            set_getting_roots(PolynomialRoots.roots∘_BigFloat∘Polynomials.coeffs)
        end
end

include("aux_code.jl")

@userplot BudanTable

"""
$(SIGNATURES)

Plots the Budan's table of a given polynomial (see https://hal.inria.fr/hal-00653762/document).
The input is a polynomial of type `T` for which
- `degree(p::T)` and `derivative(p::T, i::Int)` must be defined
- it is compatible with function computing roots (see [`BudanTables.set_getting_roots`](@ref)).

By default it uses `T==Polynomial` from [Polynomials.jl](https://github.com/JuliaMath/Polynomials.jl).

# Examples

## Using Polynomials' types and api:

```julia
   using BudanTables
   using Plots

   using Polynomials

   pp = Polynomial([-1,2,3])
   budantable(pp)
```

## Or define our own api for julia vectors:

```julia
   using BudanTables
   using Plots

   BudanTables.degree(v::AbstractVector) = length(v) - 1

   BudanTables.derivative(v::AbstractVector) = .*(v[begin+1:end], 1:(length(v)-1))
   function BudanTables.derivative(v::AbstractVector, i::Int)
       out = copy(v)
       while i > 0
           i-=1
           out = derivative(out)
       end
       return out
   end

   # PolynomialRoots.jl represents polynomials as julia vectors.
   import PolynomialRoots as PR
   BudanTables.set_getting_roots(PR.roots)

   pp = [-1,-2,3,4]
   budantable(pp)
```
"""
function budantable end

@recipe function f(bt::BudanTable;
                   xplus=2, w=.5,
                   gray=.5, black=.8,
                   color=:gray)
    p, = bt.args
    allroots = [sort(realroots(monicderivative(p,i))) for i in 0:degree(p)]
    mininf, inf = find_bounds(allroots, xplus)
    color := color
    # add a legend
    legend --> true
    label := ["pos" "neg"]
    @series begin
        opacity := gray
        []
    end
    @series begin
        opacity := black
        []
    end
    for (i, rts) in enumerate(allroots)
        # Plot ith row
        boxes = ithrectangles(rts, i;
                              mininf=mininf, inf=inf, w=w)
        colors = ithcolors(iseven(i), length(boxes), gray, black)
        for (box, col) in zip(boxes, colors)
            @series begin
                label := nothing
                seriestype := :shape
                opacity := col
                box
            end
        end
    end
end

# Plots.@deps budantable shape

end
