module ExtremeFloats
export ExtremeFloat

struct ExtremeFloat <: AbstractFloat
    negative::Bool
    mantissa::UInt128
    exponent::Int64

    @inline ExtremeFloat(negative, mantissa, exponent) = new(negative, mantissa, exponent)
end

function normalize(ef::ExtremeFloat)
    tz = trailing_zeros(ef.mantissa)
    ExtremeFloat(ef.negative, ef.mantissa >> tz, ef.exponent + tz)
end

Base.Float64(ef::ExtremeFloat) = ifelse(ef.negative, -1, 1) * Float64(ef.mantissa) * 2.0 ^ ef.exponent

function ExtremeFloat(f::Float64)
    if iszero(f)
        return ExtremeFloat(false, UInt128(0), Int64(0))
    end

    negative = false
    if f < zero(f)
        f *= -1
        negative = true
    end

    mantissa = round(UInt128, significand(f) * 2.0 ^ 52)
    exponent = Base.exponent(f) - 52
    ExtremeFloat(negative, mantissa, exponent) |> normalize
end

function ExtremeFloat(i::Integer)
    negative = false
    if i < zero(i)
        negative = true
        i *= -1
    end

    ExtremeFloat(negative, UInt128(i), Int64(0))
end

function Base.:*(ef1::ExtremeFloat, ef2::ExtremeFloat)
    exponent = ef1.exponent + ef2.exponent
    negative = ef1.negative ⊻ ef2.negative

    mantissa1 = ef1.mantissa
    mantissa2 = ef2.mantissa

    # shift mantissas such that their product has at most one leading zero
    num_digits = 128
    remaining_zeros = leading_zeros(mantissa1) + leading_zeros(mantissa2) - num_digits
    shift1 = remaining_zeros ÷ 2
    shift2 = remaining_zeros - shift1
    mantissa1 <<= shift1
    mantissa2 <<= shift2
    mantissa = mantissa1 * mantissa2
    exponent -= shift1 + shift2

    ExtremeFloat(negative, mantissa, exponent) |> normalize
end

function Base.:*(other::Number, ef::ExtremeFloat)
    ExtremeFloat(other) * ef
end

function Base.:+(ef1::ExtremeFloat, ef2::ExtremeFloat)
    if iszero(ef1.mantissa)
        return ef2
    elseif iszero(ef2.mantissa)
        return ef1
    end


    ef1, ef2 = if ef1.exponent > ef2.exponent
        (ef1, ef2)
    else
        (ef2, ef1)
    end
    exponent_diff = ef1.exponent - ef2.exponent
    shift1 = min(leading_zeros(ef1.mantissa) - 1, exponent_diff)
    shift2 = max(0, exponent_diff - shift1)

    mantissa1 = ef1.mantissa << shift1
    mantissa2 = ef2.mantissa >> shift2

    negative = if mantissa1 > mantissa2
        ef1.negative
    else
        ef2.negative
    end

    mantissa =
        ifelse(ef1.negative, -1, 1) * mantissa1 +
        ifelse(ef2.negative, -1, 1) * mantissa2
    if negative
        mantissa *= -1
    end
    exponent = ef1.exponent - shift1

    ExtremeFloat(negative, mantissa, exponent) |> normalize
end

function Base.:-(ef1::ExtremeFloat, ef2::ExtremeFloat)
    ef1 + ExtremeFloat(!ef2.negative, ef2.mantissa, ef2.exponent)
end

function Base.inv(ef::ExtremeFloat)
    mantissa_inv = ef.mantissa |> inv |> ExtremeFloat
    pow2 = ExtremeFloat(ef.negative, UInt128(1), -ef.exponent) |> normalize
    mantissa_inv * pow2
end

const LN2 = ExtremeFloat(log(2.))

function Base.log(ef::ExtremeFloat)
    ExtremeFloat(log(ef.mantissa)) + ExtremeFloat(ef.exponent) * LN2
end

const E = ℯ |> Float64 |> ExtremeFloat
const C1 = ExtremeFloat(362880)
const C2 = ExtremeFloat(362880)
const C3 = ExtremeFloat(181440)
const C4 = ExtremeFloat(60480)
const C5 = ExtremeFloat(15120)
const C6 = ExtremeFloat(3024)
const C7 = ExtremeFloat(504)
const C8 = ExtremeFloat(72)
const C9 = ExtremeFloat(9)
const C0 = ExtremeFloat(2.75573192e-6)

function Base.exp(ef::ExtremeFloat)
    non_frac = ef.mantissa << ef.exponent
    exp_non_frac = if iszero(non_frac)
        ExtremeFloat(1)
    else
        E ^ non_frac
    end

    frac = ef - ExtremeFloat(ef.negative, non_frac, 0)
    # from https://stackoverflow.com/a/10552567
    exp_frac = (C1+frac*(C2+frac*(C3+frac*(C4+frac*(C5+frac*(C6+frac*(C7+frac*(C8+frac*(C9+frac)))))))))*C0

    result = exp_non_frac * exp_frac
    if ef.negative
        result = inv(result)
    end

    result
end

end # module
