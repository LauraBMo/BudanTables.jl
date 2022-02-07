module BudanTables

using DocStringExtensions:SIGNATURES
using RecipesBase
using Polynomials:roots, derivative, degree # Polynomial type, roots function
# using Plots:Shape

const _ROOTS = Ref{Function}(roots)

"""

$(SIGNATURES)

Sets the method used to compute the roots of the polynomials for drawing a Budan's table.
The input is a function `f` computing the roots of a polynomial of type `T` for which `degree(p::T)` and `derivative(p::T)` must be defined (e.g., `T==Polynomial` from Polynomials.jl).
An example of valid input for polynomials of type `Polynomial` is the following:

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

include("aux_code.jl")

@userplot BudanTable
export BudanTable, budantable

"""

$(SIGNATURES)

Plots the Budan table for a given polynomial (see https://hal.inria.fr/hal-00653762/document).
The input is a polynomial of type `T` for which `degree(p::T)` and `derivative(p::T, i::Int)` must be defined (by default it uses `T==Polynomial` from Polynomials.jl).
Examples of use:

Using Polynomials' types and api:

```julia
   using BudanTables
   using Plots

   using Polynomials

   pp = Polynomial([-1,2,3])
   budantable(pp)
```

Or define our own api for julia vectors:

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
    actualroots = filter((!)∘isempty, allroots)
    _xmin = minimum(first.(actualroots)) - xplus
    _xmax = maximum(last.(actualroots)) + xplus
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
                              mininf=_xmin, inf=_xmax, w=w)
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

# Plots.@deps boxplot shape

end
