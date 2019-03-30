using Test
using DataDeps: try_determine_load_path, determine_save_path, try_determine_package_datadeps_dir, NoValidPathError


@testset "package data deps dir" begin
    target = joinpath(realpath(joinpath(dirname(@__FILE__),"..")),"deps","data")
    @test try_determine_package_datadeps_dir(@__FILE__) == target

    mktemp() do fn, fh
        @test try_determine_package_datadeps_dir(fn) == nothing
    end

    mktemp() do fn, fh
        ENV["DATADEPS_LOAD_PATH"] = ""
        ENV["DATADEPS_NO_STANDARD_LOAD_PATH"] = false
        @test try_determine_package_datadeps_dir(fn) == nothing
        @test_throws NoValidPathError determine_save_path("test")
    end

end
