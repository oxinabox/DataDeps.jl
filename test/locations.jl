using Test
using DataDeps: try_determine_load_path, determine_save_path, try_determine_package_datadeps_dir, NoValidPathError


@testset "package data deps dir" begin
    target = joinpath(realpath(joinpath(dirname(@__FILE__),"..")),"deps","data")
    @test try_determine_package_datadeps_dir(@__FILE__) == target

    mktemp() do fn, fh
        @test try_determine_package_datadeps_dir(fn) == nothing
    end

    # Make sure we get the right error when no writeable path
    #  see #89
    withenv("DATADEPS_LOAD_PATH" => "", "DATADEPS_NO_STANDARD_LOAD_PATH" => "true") do
        @test_throws NoValidPathError determine_save_path("DummyDataDepName")
    end

    if Sys.iswindows()
        # Absolute Windows paths contain a colon after the drive letter
        mktempdir() do dir
            @test occursin(':', dir)
            withenv("DATADEPS_LOAD_PATH" => dir, "DATADEPS_NO_STANDARD_LOAD_PATH" => "true") do
                @test determine_save_path("DummyDataDepName") == joinpath(dir, "DummyDataDepName")
            end
        end
    end

end
