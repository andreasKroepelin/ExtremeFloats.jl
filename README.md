# ExtremeFloats.jl

ExtremeFloats.jl is a Julia package that lets you work with floating point numbers of extreme order of magnitude.
While standard 64-bits IEEE-754 floating point numbers (like `Float64`) use 1 bit for the sign, 52 bits for the mantissa, and 11 bits for the exponent, an `ExtremeFloat` offers 128 bits for the mantissa and 64 bits for the exponent.
This especially allows for positive and negative numbers much closer to zero.
While this can be achieved by general-purpose arbitray precision libraries as well, ExtremeFloats.jl tries to minimise dynamic memory allocations and can therefore be a bit faster (see benchmarks).

**This package is in a very early state of development!**
So far, you can:

* convert `Float64` and any `Integer` to `ExtremeFloat`
* convert `ExtremeFloat` to `Float64`
* add, multiply, and subtract two `ExtremeFloat`s
* multiply a `Float64` or any `Integer` with an `ExtremeFloat`
* invert an `ExtremeFloat`
* take the natural logarithm and exponential of an `ExtremeFloat`

More operations will be implemented in the future.
**If you would like to contribute, please feel free to reach out to me!**

## Usage

Get it from the official registry by typing
```
julia> ]
pkg> add ExtremeFloats
```

After that, you can use it just as regular numbers.

```julia
using ExtremeFloats

x = ExtremeFloat(-100_000)
y = ExtremeFloat(3.1415)

s = x + y
d = x - y
p = x * y
i = inv(x)
double = 2x
very_small = exp(x)
approx_x = log(very_small)
approx_x_f64 = Float64(approx_x) # ≈ -100_000.0
```

## Benchmark

To demonstrate the advantage of this package, let us consider the result of a benchmark I conducted on my laptop (code in `perf` folder).
I created 1000 random numbers with orders of magnitude between `10^-10` and `10^10` and then performed the *log-sum-exp* operation on it, *i.e.* summing the exponentials of all values and then taking the logarithm (`log(sum(exp, values))`, in Julia code).
This is famously hard for traditional floating point arithmetics and you can see that it typically just fails or returns infinity.
ExtremeFloats.jl is one of the libraries that can properly deal with that situation and is the fastest in this benchmark.
Let me know if you know any other library that should be considered in this benchmark.

```
[ Info: Running log-sum-exp benchmarks...
[ Info: Float64
  8.381 μs (1 allocation: 16 bytes)
result = Inf

[ Info: BigFloat # stdlib
  2.678 ms (9168 allocations: 414.16 KiB)
result = 9.958825022694363e9

[ Info: ArbFloat # ArbNumerics.jl
  1.251 ms (30017 allocations: 828.58 KiB)
result = 9.958825022694363e9

[ Info: Float128 # Quadmath.jl
  618.585 μs (1 allocation: 16 bytes)
result = Inf

[ Info: MultiFloat{Float64, 8} # MultiFloats.jl
[ Info: Calculation failed.

[ Info: ExtremeFloat
  450.896 μs (2003 allocations: 62.58 KiB)
result = 9.958825022694336e9
```
