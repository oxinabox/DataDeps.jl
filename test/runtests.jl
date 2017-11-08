using Base.Test

tests = [
    "util",
    "locations",
    "main",
    "examples"
]

for filename in tests
    @testset "$filename" begin
        include(filename * ".jl")
    end
end
