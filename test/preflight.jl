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


        @test preflight("TestFailChecksumPreFlight",  "DummyFileFail.txt") == false
        @test @used dummyhash("DummyFileFail.txt")
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

        @test preflight("TestPassChecksumPreFlight",  "DummyFilePass.txt") == true
        @test @used dummyhash("DummyFilePass.txt")
    end
end



@testset "Checksum" begin
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


        @test preflight("TestFailPostFetchPreFlight",  "DummyFileFail.txt") == false
        
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

        @test preflight("TestPassPostFetchPreFlight",  "DummyFilePass.txt") == true
        @test !(@used dummy_postfetch("DummyFilePass.txt")) # should not run on file given, but on a copy.
        @test @used dummy_postfetch(::Any) # should run on some file
    end
end