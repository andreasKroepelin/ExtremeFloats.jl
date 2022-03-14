using BenchmarkTools
using ExtremeFloats
using Quadmath
using ArbNumerics
using MultiFloats

function log_sum_exp(exponents, ::Type{T}) where T
    sum(x -> exp(T(x)), exponents) |> log |> Float64
end

n = 1000
exponents = rand(n) .* 10.0 .^ rand(-10:10, n)

@info "Running log-sum-exp benchmarks..."
for T in (Float64, BigFloat, ArbFloat, Quadmath.Float128, MultiFloats.Float64x8, ExtremeFloat)
    @info T
    try
        result = @btime log_sum_exp($exponents, $T)
        @show result
    catch ex
        @info "Calculation failed."
    end
    println()
end
