using DataDeps
using DataDeps: should_abort_on_error, checksum_pass, UserAbortError
using Test
using ExpectationStubs

# HACK: same as in main.jl — must be at top level in Julia 1.12+
Base.open(stub::Stub, t::Any, ::AbstractString) = stub(t)

@testset "should_abort_on_error()" begin
    # DATADEPS_ABORT_ON_ERROR takes precedence over CI when explicitly set
    # (both ENV vars passed to withenv to ensure clean slate)
    @testset "DATADEPS_ABORT_ON_ERROR=$val overrides CI=$ci" for
            (val, expected) in [("true", true), ("false", false)],
            ci in [nothing, "true", "false"]
        withenv("CI"=>ci, "DATADEPS_ABORT_ON_ERROR"=>val) do
            @test should_abort_on_error() == expected
        end
    end

    # When DATADEPS_ABORT_ON_ERROR is not set, falls back to CI
    @testset "falls back to CI=$ci" for
            (ci, expected) in [(nothing, false), ("true", true), ("false", false)]
        withenv("CI"=>ci, "DATADEPS_ABORT_ON_ERROR"=>nothing) do
            @test should_abort_on_error() == expected
        end
    end
end

@testset "checksum_pass aborts in non-interactive mode" begin
    withenv("DATADEPS_ABORT_ON_ERROR"=>"true") do
        bad_hash = "0000000000000000000000000000000000000000000000000000000000000000"
        @test_throws UserAbortError checksum_pass(bad_hash, @__FILE__)
    end
end

@testset "file-not-readable aborts in non-interactive mode" begin
    withenv("DATADEPS_ABORT_ON_ERROR"=>"true",
            "DATADEPS_ALWAYS_ACCEPT"=>"true") do
        path_current = @__DIR__

        @stub dummyhash
        @expect(dummyhash(::Any) = [0x12, 0x34])

        @stub dummydown
        @expect(dummydown("http://www.example.com/eg.zip", ::String) = joinpath(path_current, "eg.zip"))

        register(DataDep("TestAbortOnErrorRead",
            "A dummy message",
            "http://www.example.com/eg.zip",
            (dummyhash, "1234"),
            fetch_method=dummydown
        ))

        # First resolve should work (downloads to dir)
        dirpath = datadep"TestAbortOnErrorRead"
        @test isdir(dirpath)

        # Resolving with a non-existent inner file should abort
        @test_throws UserAbortError resolve("TestAbortOnErrorRead/nonexistent_file.txt", @__FILE__)

        rm(dirpath; recursive=true)
    end
end

@testset "ManualDataDep aborts in non-interactive mode" begin
    withenv("DATADEPS_ABORT_ON_ERROR"=>"true") do
        register(ManualDataDep("TestAbortOnErrorManual",
            "Please install this manually."
        ))

        @test_throws UserAbortError datadep"TestAbortOnErrorManual"
    end
end
