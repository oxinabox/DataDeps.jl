using Base.Test

tests = [
    "util",
    "main"
]
for filename in tests
    @testset "$name" begin
        include(filename * ".jl")
    end
end
