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

See also [`budantable`](@ref)
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

Plots the Budan's table of a polynomial (see https://hal.inria.fr/hal-00653762/document).
The input is a polynomial of type `T` for which
- `degree(p::T)` and `derivative(p::T, i::Int)` must be defined
- it is compatible with function computing roots (see [`set_getting_roots`](@ref)).

The default are type `T==Polynomial` and `Polynomials.roots` from [Polynomials.jl](https://github.com/JuliaMath/Polynomials.jl).
But, if [PolynomialRoots.jl](https://github.com/giordano/PolynomialRoots.jl) is loaded, it uses `PolynomialRoots.roots` (accepting polynomials of type `Polynomial`).

# Examples

## Default use, type `Polynomials` and roots `Polynomials.roots`

```julia
   using Plots
   using Polynomials
   using BudanTables
   P = fromroots([0,0,1,2,2,4,4])
   budantable(P)
```

## Use type `Polynomials` and roots `PolynomialRoots.roots`

```julia
   using Plots
   using Polynomials
   using PolynomialRoots
   using BudanTables
   P = fromroots([0,0,1,2,2,4,4])
   budantable(P)
```

## Or define our own API for julia vectors:

```julia
   using Plots
   using BudanTables

   # Setting function to compute roots from a polynomial represented
   # as a vector.
   import PolynomialRoots
   _BigFloat(A::AbstractArray) = BigFloat.(A)
   # Notice we do not precompose by `coeffs`
   set_getting_roots(PolynomialRoots.roots∘_BigFloat)

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

   import Polynomials
   P = Polynomials.coeffs(Polynomials.fromroots([0,0,1,2,2,4,4]))
   budantable(P)
```
"""
function budantable end

@recipe function f(bt::BudanTable;
                   w=.5,
                   gray=.5, black=.8,
                   color=:gray)
    p, = bt.args
    allroots = [sort(realroots(monicderivative(p,i))) for i in 0:degree(p)]
    lower, upper = find_bounds(allroots)
    xplus = (upper - lower)/5
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
                              mininf=lower-xplus, inf=upper+xplus, w=w)
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
