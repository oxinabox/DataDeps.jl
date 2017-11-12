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



@testset "examples" begin
    tempdir = mktempdir()
    info("sending all datadeps to $tempdir")
    withenv("DATADEPS_LOAD_PATH"=>tempdir) do
        @testset "download and use" begin
            include("examples.jl")
            include("manual_examples.jl")
        end
        withenv("DATADEPS_DISABLE_DOWNLOAD"=>"true") do
            @testset "use already downloaded" begin
                include("examples.jl")
                include("manual_examples.jl")
            end
        end
    end

    info("removing $tempdir")
    rm(tempdir, recursive=true, force=true)
end
