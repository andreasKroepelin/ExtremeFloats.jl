# ExtremeFloats.jl

ExtremeFloats.jl is a Julia package that lets you work with floating point numbers of extreme order of magnitude.
While standard 64-bits IEEE-754 floating point numbers (like `Float64`) use 1 bit for the sign, 52 bits for the mantissa, and 11 bits for the exponent, an `ExtremeFloat` offers 128 bits for the mantissa and 64 bits for the exponent.
This especially allows for positive and negative numbers much closer to zero.

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
```
