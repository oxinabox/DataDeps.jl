using Base.Test

tests = [
    "util",
    "main"
]
for filename in tests
    @testset "$filename" begin
        include(filename * ".jl")
    end
end
