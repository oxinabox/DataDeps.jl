using Test


using DataDeps: env_bool
@testset "Env Bool" begin
    withenv("A"=>"True") do
        @test env_bool("A")
    end
    withenv("B"=>"No") do
        @test !env_bool("B")
    end

    withenv("C"=>"") do
        @test !env_bool("C")
    end


    withenv("D"=>"0") do
        @test !env_bool("D")
    end

    withenv("E"=>"1") do
        @test env_bool("E")
    end
end
