using Test
using DataDeps: try_determine_load_path, determine_save_path, try_determine_package_datadeps_dir


@testset "package data deps dir" begin
    target = joinpath(realpath(joinpath(dirname(@__FILE__),"..")),"deps","data")
    @test try_determine_package_datadeps_dir(@__FILE__) |> get == target

    mktemp() do fn, fh
        @test try_determine_package_datadeps_dir(fn) |> isnull
    end

end


@testset "determine_save_path" begin
    if !contains(Pkg.dir(), "/DataDeps/") 
        # Test assumes that not, e.g. running from a home directory called "DataDeps"
        # But actually this occurs, as JuliaCIBot runs its tests in just such a directory
        @test !contains(determine_save_path("EG"), "/DataDeps/") # Ensure package path is not included
    end
end
