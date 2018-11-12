using DataDeps
using ExpectationStubs


@testset "Checksum" begin
    @testset "fail" begin
        @stub dummyhash
        @expect(dummyhash(::Any) = [0x12, 0x34])
    
        register(
            DataDep(
                "TestFailChecksumPreupload",
                "dummy message",
                "http://example.void",
                (dummyhash, "0000")
            )
        )

        local_filepath = @__FILE__ # Need some real file to test on
        @test preupload_check("TestFailChecksumPreupload",  local_filepath) == false
        @test @used dummyhash(@__FILE__)
    end

    @testset "pass" begin
        @stub dummyhash
        @expect(dummyhash(::Any) = [0x12, 0x34])

        register(
            DataDep(
                "TestPassChecksumPreupload",
                "dummy message",
                "http://example.void",
                (dummyhash, "1234")
            )
        )

        local_filepath = @__FILE__ # Need some real file to test on
        @test preupload_check("TestPassChecksumPreupload",  local_filepath) == true
        @test @used dummyhash(@__FILE__)
    end
end



@testset "PostFetch" begin
    @testset "fail" begin
        register(
            DataDep(
                "TestFailPostFetchPreupload",
                "dummy message",
                "http://example.void",
                Any;
                post_fetch_method = error
            )
        )

        local_filepath = @__FILE__ # Need some real file to test on
        @test preupload_check("TestFailPostFetchPreupload",  local_filepath) == false
    end

    @testset "pass" begin
        @stub dummy_postfetch
        @expect(dummy_postfetch(::Any) = [0x12, 0x34])

        register(
            DataDep(
                "TestPassPostFetchPreupload",
                "dummy message",
                "http://example.void",
                Any,
                post_fetch_method = dummy_postfetch,
            )
        )

        local_filepath = @__FILE__ # Need some real file to test on
        @test preupload_check("TestPassPostFetchPreupload",  local_filepath) == true
        @test !(@used dummy_postfetch(@__FILE__)) # should not run on file given, but on a copy.
        @test @used dummy_postfetch(::Any) # should run on some file
    end
end