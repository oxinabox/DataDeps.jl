using Base.Test

tests = [
    "util",
    "locations",
    "main",
]
for filename in tests
    @testset "$filename" begin
        include(filename * ".jl")
    end
end
