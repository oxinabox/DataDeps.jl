using Test


using DataDeps: env_bool, max_input_retries
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

@testset "max_input_retries" begin
    @testset "defaults to 10" begin
        withenv("DATADEPS_MAX_INPUT_RETRIES"=>nothing) do
            @test max_input_retries() == 10
        end
    end
    @testset "respects DATADEPS_MAX_INPUT_RETRIES=$val" for
            (val, expected) in [("3", 3), ("1", 1), ("50", 50)]
        withenv("DATADEPS_MAX_INPUT_RETRIES"=>val) do
            @test max_input_retries() == expected
        end
    end
    @testset "errors on invalid value" begin
        withenv("DATADEPS_MAX_INPUT_RETRIES"=>"abc") do
            @test_throws ArgumentError max_input_retries()
        end
    end
end
