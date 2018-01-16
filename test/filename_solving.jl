using DataDeps
using Base.Test
import DataDeps.get_filename

@testset "not requiring headers" begin
    @test get_filename("https://www.angio.net/pi/digits/10000.txt") == "10000.txt"
end


@testset "using headers" begin
    @test r"JuliaCI-Coverage.*\.tar\.gz"(get_filename("https://api.github.com/repos/JuliaCI/Coverage.jl/tarball"))
end
