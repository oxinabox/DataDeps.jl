using Test

@info "Notice: These tests check paths some of which are supposed to throw warnings. Others of which are not. Some attention should be paid when reading the output."

tests = [
    "util",
    "locations",
    "main",
    "preupload"
]

for filename in tests
    @testset "$filename" begin
        include(filename * ".jl")
    end
end


examples =  [
    "examples.jl",
    "examples_manual.jl",
]

@testset "examples" for fn in examples
    @testset "$fn" begin
        tempdir = mktempdir()
        try
            @info("sending all datadeps to $tempdir")
            withenv("DATADEPS_LOAD_PATH"=>tempdir,
                    "DATADEPS_NO_STANDARD_LOADPATH"=>true) do
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
    			@info("removing $tempdir")
                cd(@__DIR__)  # Ensure not currently in directory being deleted
                rm(tempdir, recursive=true, force=true)
    		catch err
    			@warn("Something went wrong with removing $tempdir")
    			@warn(err)
    		end
        end
    end
end
