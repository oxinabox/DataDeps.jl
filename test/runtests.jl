using Base.Test

tests = [
    "util",
    "locations",
    "main",
    "filename_solving"
]

for filename in tests
    @testset "$filename" begin
        include(filename * ".jl")
    end
end



@testset "examples" begin
    tempdir = mktempdir()
    try
        info("sending all datadeps to $tempdir")
        withenv("DATADEPS_LOAD_PATH"=>tempdir) do
            @testset "download and use" begin
                include("examples.jl")
                include("examples_manual.jl")
                include("examples_flaky.jl")
            end
            withenv("DATADEPS_DISABLE_DOWNLOAD"=>"true") do
                @testset "use already downloaded" begin
                    include("examples.jl")
                    include("examples_manual.jl")
                    include("examples_flaky.jl")
                end
            end
        end
    finally
		try
			info("removing $tempdir")
			rm(tempdir, recursive=true, force=true)
		catch err
			warn("Something went wrong with removing $tempdir")
			warn(err)
		end
    end
end
