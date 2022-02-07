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

include("BudanTablesBase.jl")
include("Recipes.jl")

end
