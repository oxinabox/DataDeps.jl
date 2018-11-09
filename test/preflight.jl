using DataDeps
using ExpectationStubs


@testset "Checksum" begin
    @testset "fail" begin
        @stub dummyhash
        @expect(dummyhash(::Any) = [0x12, 0x34])
    
        register(
            DataDep(
                "TestFailChecksumPreFlight",
                "dummy message",
                "http://example.void",
                (dummyhash, "0000")
            )
        )

        local_filepath = @__FILE__ # Need some real file to test on
        @test preflight("TestFailChecksumPreFlight",  local_filepath) == false
        @test @used dummyhash(@__FILE__)
    end

    @testset "pass" begin
        @stub dummyhash
        @expect(dummyhash(::Any) = [0x12, 0x34])

        register(
            DataDep(
                "TestPassChecksumPreFlight",
                "dummy message",
                "http://example.void",
                (dummyhash, "1234")
            )
        )

        local_filepath = @__FILE__ # Need some real file to test on
        @test preflight("TestPassChecksumPreFlight",  local_filepath) == true
        @test @used dummyhash(@__FILE__)
    end
end



@testset "PostFetch" begin
    @testset "fail" begin
        register(
            DataDep(
                "TestFailPostFetchPreFlight",
                "dummy message",
                "http://example.void",
                Any;
                post_fetch_method = error
            )
        )

        local_filepath = @__FILE__ # Need some real file to test on
        @test preflight("TestFailPostFetchPreFlight",  local_filepath) == false
    end

    @testset "pass" begin
        @stub dummy_postfetch
        @expect(dummy_postfetch(::Any) = [0x12, 0x34])

        register(
            DataDep(
                "TestPassPostFetchPreFlight",
                "dummy message",
                "http://example.void",
                Any,
                post_fetch_method = dummy_postfetch,
            )
        )

        local_filepath = @__FILE__ # Need some real file to test on
        @test preflight("TestPassPostFetchPreFlight",  local_filepath) == true
        @test !(@used dummy_postfetch(@__FILE__)) # should not run on file given, but on a copy.
        @test @used dummy_postfetch(::Any) # should run on some file
    end
end