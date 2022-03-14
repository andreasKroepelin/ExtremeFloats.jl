using ExtremeFloats
using Test

@testset "conversion to Float64" begin
    numbers = rand(100)
    for num in numbers
        @test (num |> ExtremeFloat |> Float64) ≈ num
    end
end
