using Test

tests = [
    "util",
    "locations",
    "main",
    "fetch_helpers"
]

for filename in tests
    @testset "$filename" begin
        include(filename * ".jl")
    end
end


examples =  [
    "examples.jl",
    "examples_manual.jl",
    "deprecated_examples.jl"
]

@testset "examples" for fn in examples
    @testset "$fn" begin
        tempdir = mktempdir()
        try
            info("sending all datadeps to $tempdir")
            withenv("DATADEPS_LOAD_PATH"=>tempdir) do
                @testset "download and use" begin
                    include(fn)
                end
                withenv("DATADEPS_DISABLE_DOWNLOAD"=>"true") do
                    @testset "use already downloaded" begin
                        include(fn)
                    end
                end
            end
        finally
    		try
    			info("removing $tempdir")
    			rm(tempdir, recursive=true, force=true)
    		catch err
    			@warn("Something went wrong with removing $tempdir")
    			@warn(err)
    		end
        end
    end
end
