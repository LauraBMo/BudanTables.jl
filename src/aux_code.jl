
monicderivative(p, i::Int) = derivative(p, degree(p)-i)*factorial(i)/factorial(degree(p))

# define a function that returns a Plots.Shape
# code from https://discourse.julialang.org/t/how-to-draw-a-rectangular-region-with-plots-jl/1719/4
rectangle(x1, y1, x2, y2) = ([x1,x2,x2,x1], [y1,y1,y2,y2])

isapproxreal(x::Real) = true
isapproxreal(x::Complex{T}; atol::Real=1e-7) where {T} = abs(imag(x)) < atol
realroots(poly) = real.(filter(isapproxreal, _ROOTS[](poly)))

function ithrectangles(sortrealroots, i;
                       mininf=-5, inf=5, w=.5)
    xs = [mininf; sortrealroots]
    xs2 = [sortrealroots; inf]
    return [rectangle(x1, i-w, x2, i+w) for (x1,x2) in zip(xs, xs2)]
end

function ithcolors(_iseven::Bool, nboxes, gray, black)
    grays = _iseven ? iseven.(1:nboxes) : isodd.(1:nboxes)
    blacks = (!).(grays)
    return gray*grays + black*blacks
end
